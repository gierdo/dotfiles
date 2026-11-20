import { writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";
import type { DatabaseSync } from "node:sqlite";
import { getRun } from "./db.ts";

interface VisitRow {
  id: number;
  state_id: string;
  visit_index: number;
  entered_at: string;
  exited_at: string | null;
}

interface TransitionRow {
  id: number;
  from_state: string;
  to_state: string;
  outcome_id: string | null;
  reason: string | null;
  revision: number;
  created_at: string;
}

interface ApprovalRow {
  id: number;
  target_state: string;
  reason: string | null;
  status: string;
  created_at: string;
}

export function renderMarkdownJournal(db: DatabaseSync, runId: string): string {
  const run = getRun(db, runId);
  if (!run) {
    throw new Error(`Run '${runId}' not found`);
  }

  const visits = db.prepare(`
    SELECT id, state_id, visit_index, entered_at, exited_at
    FROM state_visits
    WHERE run_id = ?
    ORDER BY visit_index ASC, id ASC
  `).all(runId) as unknown as VisitRow[];

  const transitions = db.prepare(`
    SELECT id, from_state, to_state, outcome_id, reason, revision, created_at
    FROM transitions
    WHERE run_id = ?
    ORDER BY id ASC
  `).all(runId) as unknown as TransitionRow[];

  const approvals = db.prepare(`
    SELECT id, target_state, reason, status, created_at
    FROM pending_approvals
    WHERE run_id = ?
    ORDER BY id ASC
  `).all(runId) as unknown as ApprovalRow[];

  const lines: string[] = [
    `# Workflow: ${run.workflow} (${run.task})`,
    "",
    `- Run ID: \`${run.id}\``,
    `- Status: \`${run.status}\``,
    `- Revision: ${run.revision}`,
    `- Definition fingerprint: \`${run.definition_fingerprint.slice(0, 16)}...\``,
    `- Created: ${run.created_at}`,
    `- Updated: ${run.updated_at}`,
  ];

  if (run.status === "paused" && run.pause_reason) {
    lines.push(`- Pause Reason: ${run.pause_reason}`);
  }

  lines.push("", "---", "");

  for (let i = 0; i < visits.length; i++) {
    const v = visits[i];
    lines.push(`## State: \`${v.state_id}\` (Visit #${v.visit_index})`);
    lines.push(`Entered at: ${v.entered_at}`);
    if (v.exited_at) {
      lines.push(`Exited at: ${v.exited_at}`);
    }

    // Match transition exiting this visit
    const tr = transitions[i];
    if (tr && tr.from_state === v.state_id) {
      lines.push("");
      lines.push(`## Transition: \`${tr.from_state}\` -> \`${tr.to_state}\``);
      if (tr.outcome_id) {
        lines.push(`Outcome: \`${tr.outcome_id}\``);
      }
      if (tr.reason) {
        lines.push(`Reason: ${tr.reason}`);
      }
    }

    lines.push("");
  }

  if (approvals.length > 0) {
    lines.push("## Approval History", "");
    for (const app of approvals) {
      lines.push(`- Gate: \`${app.target_state}\` | Status: \`${app.status}\` | Reason: ${app.reason ?? "none"} (${app.created_at})`);
    }
    lines.push("");
  }

  if (run.status === "completed" || run.status === "aborted") {
    lines.push(`### Terminal Outcome: \`${run.status}\``, "");
  }

  return lines.join("\n");
}

export function syncMarkdownJournal(db: DatabaseSync, runId: string, outputPath: string): void {
  const content = renderMarkdownJournal(db, runId);
  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, content, "utf-8");
}
