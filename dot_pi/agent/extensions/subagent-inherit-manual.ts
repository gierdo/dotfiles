// Authorizer-chain link for @gotgenes/pi-permission-system.
//
// Goal: an authorizer link that only acts on SUBAGENT asks. When a subagent's
// ask is forwarded up to this (parent) session, the link checks whether the
// parent human has already manually approved a matching request earlier in this
// same session. If so, it passes the subagent's ask through (allow). Otherwise
// it defers, so the human is still prompted.
//
// Scope control:
//   * The authorizer chain is session-wide; there is no config key to restrict
//     it to subagents. This link self-scopes instead: it only acts when the ask
//     carries forwarding provenance (details.forwarding), i.e. it was raised by
//     a subagent and forwarded here. A LOCAL parent ask always gets `defer`, so
//     the parent's own asks are untouched and reach the human as usual.
//
// "Temporal (manual) approval already exists":
//   * The PermissionQuery handed to a link sees CONFIG-LAYER rules only; it does
//     NOT expose runtime session approvals, and there is deliberately no public
//     reader for them. So this link learns the parent's manual approvals by
//     observing the `permissions:decision` bus and remembering the patterns the
//     human approved this session.
//   * Note: a `user_approved_for_session` grant is ALSO recorded by the serving
//     node as a session rule, and the serving node resolves a forwarded ask
//     against its own session rules BEFORE the chain runs -- so that case is
//     already passed through natively and this link never sees it. The link's
//     added value is the single-shot `user_approved` (approved once, not "for
//     session") decision, which leaves no session rule behind.
//
// To activate: add "subagent-inherit-manual" to "authorizerChain" in
// extensions/pi-permission-system/config.json, then /reload.

import type {
  PermissionsReadyEvent,
  PermissionDecisionEvent,
  PromptPermissionDetails,
  PermissionQuery,
  AuthorizerLog,
  AuthorizerVerdict,
} from "@gotgenes/pi-permission-system";

// A manual approval is keyed by the gate surface plus the pattern/value the
// human approved. Matching a later ask to it is done on the same key shape.
function approvalKey(surface: string, pattern: string): string {
  return `${surface}\u0000${pattern}`;
}

// Translate a recorded approval's glob pattern into a check against a concrete
// ask value. Patterns are the suggested session wildcards (e.g. "git status *",
// "exa:*", "/tmp/*"); treat a trailing "*" as a prefix match, and "*" anywhere
// else conservatively as a literal. Same-surface only.
function patternMatches(
  known: Set<string> | undefined,
  surface: string,
  value: string,
): boolean {
  if (!known) return false;
  const prefix = `${surface}\u0000`;
  for (const key of known) {
    if (!key.startsWith(prefix)) continue;
    const pattern = key.slice(prefix.length);
    if (pattern === value) return true;
    if (pattern.endsWith("*")) {
      const head = pattern.slice(0, -1);
      if (value.startsWith(head)) return true;
    }
  }
  return false;
}

export default function activate(pi: any) {
  const disposers = new Map<string, () => void>();
  // Per serving-session set of manual approvals the human granted this session.
  const manualApprovals = new Map<string, Set<string>>();

  // Learn the parent human's manual approvals by watching gate decisions.
  // Only decisions made directly by the human in THIS session count, so we
  // ignore forwarded decisions (forwarding != null) and non-human resolutions.
  pi.events.on("permissions:decision", (raw: unknown) => {
    const ev = raw as PermissionDecisionEvent;
    if (!ev || typeof ev.surface !== "string") return;
    // A decision made while serving a forwarded request carries a non-null
    // forwarding context; those are subagent asks, not the human's own grants.
    if ((ev as { forwarding?: unknown }).forwarding) return;
    if (ev.result !== "allow") return;
    // Human grants only: a one-shot approval or an explicit for-session grant.
    if (
      ev.resolution !== "user_approved" &&
      ev.resolution !== "user_approved_for_session"
    ) {
      return;
    }
    // The decision event does not carry its own session id; attribute it to
    // every serving session we track. In the common single-parent case there is
    // exactly one, so this is precise. The pattern (or value as fallback) is the
    // thing the human agreed to.
    const pattern = ev.matchedPattern ?? ev.value ?? "";
    if (!pattern) return;
    const key = approvalKey(ev.surface, pattern);
    for (const set of manualApprovals.values()) set.add(key);
  });

  pi.events.on("permissions:ready", (raw: unknown) => {
    const { sessionId } = raw as PermissionsReadyEvent;
    if (!sessionId || disposers.has(sessionId)) return;
    if (!manualApprovals.has(sessionId)) manualApprovals.set(sessionId, new Set());

    void (async () => {
      try {
        const { getPermissionsService } = await import(
          "@gotgenes/pi-permission-system"
        );
        const service = getPermissionsService(sessionId);
        if (!service) return;

        const dispose = service.registerAuthorizer(
          "subagent-inherit-manual",
          async (
            details: PromptPermissionDetails,
            query: PermissionQuery,
            log: AuthorizerLog,
          ): Promise<AuthorizerVerdict> => {
            // 1. Only act on a forwarded subagent ask. A local parent ask is
            //    left for the human (or a later link) to decide.
            if (!details.forwarding) return { kind: "defer" };

            const surface = details.surface ?? details.toolName ?? "";
            const value = details.command ?? details.value ?? "";
            if (!surface || !value) return { kind: "defer" };

            // 2. Did the parent human already manually approve a matching
            //    request this session? The human may have approved either the
            //    exact value or a session pattern (e.g. "git status *"); match
            //    the ask's value against both spellings we recorded.
            const known = manualApprovals.get(sessionId);
            const matched =
              (known?.has(approvalKey(surface, value)) ?? false) ||
              patternMatches(known, surface, value);

            if (!matched) {
              // No prior manual approval exists -> keep asking the human.
              return { kind: "defer" };
            }

            // 3. Never override an explicit config deny. Re-query at gate parity
            //    using the gate surface; a deny there means defer (fail closed).
            const check = query.checkPermission(surface, value);
            if (check.state === "deny") {
              log.debug("subagent-inherit-manual:deny-guard", {
                surface,
                value,
              });
              return { kind: "defer" };
            }

            // 4. Pass the subagent's ask through on the strength of the parent's
            //    earlier manual approval. The bounded-delegation checkpoint still
            //    caps an allow on the external_directory/path families to defer.
            log.review("subagent-inherit-manual:allow", {
              surface,
              value,
              requesterAgentName: details.forwarding.requesterAgentName ?? null,
            });
            return { kind: "allow" };
          },
        );

        disposers.set(sessionId, dispose);
      } catch {
        // Permission system not installed - nothing to register.
      }
    })();
  });

  pi.on?.("session_shutdown", (_e: unknown, ctx: any) => {
    const id = ctx?.sessionManager?.getSessionId?.();
    if (!id) return;
    disposers.get(id)?.();
    disposers.delete(id);
    manualApprovals.delete(id);
  });
}
