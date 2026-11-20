import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { createRequire } from "node:module";
import { validateDefinition } from "../runner/validator.ts";
import { loadYamlParser, resolveWorkflowsDir } from "./helpers.ts";

const parse = loadYamlParser();

test("all 8 shipped workflow YAML definitions are structurally valid (ISC 1, 2)", () => {
  const workflowsDir = resolveWorkflowsDir();
  const entries = readdirSync(workflowsDir, { withFileTypes: true })
    .filter(e => e.isDirectory())
    .map(e => e.name)
    .sort();

  assert.equal(entries.length, 8, "Expected 8 shipped workflows");

  for (const name of entries) {
    const yamlPath = join(workflowsDir, name, `${name}.yaml`);
    const raw = readFileSync(yamlPath, "utf-8");
    const def = parse(raw);
    const result = validateDefinition(def);
    assert.equal(
      result.valid,
      true,
      `Workflow '${name}' failed validation: ${result.errors.join("; ")}`
    );
  }
});
