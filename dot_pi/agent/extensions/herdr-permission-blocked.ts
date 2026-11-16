// Bridges @gotgenes/pi-permission-system prompts to Herdr's agent-state display.
//
// The permission system does not play nicely with Herdr: when a pi instance
// stops to ask the user to approve a tool call, Herdr still shows the pane as
// "working" because pi never goes idle. This extension listens to the
// permission system's documented event bus and:
//
//   1. emits the `herdr:blocked` event that the herdr integration
//      (herdr-agent-state.ts) already listens for, flipping the pane to the
//      red "blocked" state, and
//   2. fires a Herdr system notification so the request is visible even when
//      the pane is not focused.
//
// It is a standalone companion to the herdr-managed herdr-agent-state.ts and
// does not edit that file (which Herdr overwrites on reinstall).
//
// Event contract: @gotgenes/pi-permission-system exports these channels and
// payload types with a semver-major stability guarantee.

import { spawn } from "node:child_process";
import type {
  PermissionUiPromptEvent,
  PermissionDecisionEvent,
} from "@gotgenes/pi-permission-system";

const HERDR_ENV = process.env.HERDR_ENV;
const socketPath = process.env.HERDR_SOCKET_PATH;
const paneId = process.env.HERDR_PANE_ID;

function enabled(): boolean {
  return HERDR_ENV === "1" && !!socketPath && !!paneId;
}

const UI_PROMPT_CHANNEL = "permissions:ui_prompt";
const DECISION_CHANNEL = "permissions:decision";
const HERDR_BLOCKED_EVENT = "herdr:blocked";

// Human-readable label for the blocked state and the notification body.
function describe(
  source: string | null | undefined,
  surface: string | null | undefined,
  value: string | null | undefined,
  agentName: string | null | undefined,
): string {
  const head = surface || source || "permission";
  const detail = typeof value === "string" ? value.trim() : "";
  const truncated =
    detail.length > 120 ? `${detail.slice(0, 117)}...` : detail;
  const core = truncated ? `${head}: ${truncated}` : head;
  return agentName ? `${agentName} - ${core}` : core;
}

// Fire a Herdr system notification. Best-effort and fully isolated: a missing
// binary, a non-zero exit, or a spawn error must never affect the pi session.
function notify(title: string, body: string): void {
  try {
    const child = spawn(
      "herdr",
      ["notification", "show", title, "--body", body, "--sound", "request"],
      { stdio: "ignore", detached: true },
    );
    child.on("error", () => {});
    child.unref();
  } catch {
    // Ignore: the red pane state is the primary signal; the notification is
    // an enhancement.
  }
}

export default function (pi: any) {
  if (!enabled()) {
    return;
  }

  // Pair each ui_prompt with its decision so the herdr integration's blocked
  // counter stays balanced. The permission system mints a unique requestId per
  // ask and resolves exactly one decision per request; one tool call can raise
  // several requests, each with its own id.
  const pending = new Set<string>();

  pi.events.on(UI_PROMPT_CHANNEL, (raw: unknown) => {
    const event = raw as Partial<PermissionUiPromptEvent> | undefined;
    const requestId =
      event && typeof event.requestId === "string" ? event.requestId : undefined;
    if (!requestId || pending.has(requestId)) {
      return;
    }
    pending.add(requestId);

    const label = describe(
      event?.source,
      event?.surface,
      event?.value,
      event?.agentName,
    );

    // Red state on the Herdr pane (handled by herdr-agent-state.ts).
    pi.events.emit(HERDR_BLOCKED_EVENT, { active: true, label });

    // System notification.
    notify("Permission requested", label);
  });

  const clear = (raw: unknown) => {
    const event = raw as Partial<PermissionDecisionEvent> | undefined;
    const requestId =
      event && typeof event.requestId === "string" ? event.requestId : undefined;
    if (!requestId || !pending.has(requestId)) {
      return;
    }
    pending.delete(requestId);
    pi.events.emit(HERDR_BLOCKED_EVENT, { active: false });
  };

  pi.events.on(DECISION_CHANNEL, clear);

  // Fail safe: if a session is torn down while a prompt is still outstanding
  // (resolved without a decision event, aborted, etc.), release every pending
  // block so the pane does not stay red forever.
  pi.on("session_shutdown", () => {
    for (const _requestId of pending) {
      pi.events.emit(HERDR_BLOCKED_EVENT, { active: false });
    }
    pending.clear();
  });
}
