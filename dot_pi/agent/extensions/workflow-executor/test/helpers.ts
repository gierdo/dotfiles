import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);

export function getActivePiNodeModules(): string | null {
  try {
    const home = process.env.HOME || "";
    const versionFile = join(home, ".pi/agent/install/current-version");
    if (existsSync(versionFile)) {
      const version = readFileSync(versionFile, "utf-8").trim();
      const nm = join(home, ".pi/agent/install/releases", version, "node_modules");
      if (existsSync(nm)) return nm;
    }
  } catch {
    // Ignore error
  }
  return null;
}

export function loadYamlParser(): (text: string) => any {
  try {
    return require("yaml").parse;
  } catch {
    const nm = getActivePiNodeModules();
    if (nm) {
      return require(join(nm, "yaml")).parse;
    }
    throw new Error("Unable to resolve YAML parser: install 'yaml' or configure active Pi runtime");
  }
}

export function resolveWorkflowsDir(): string {
  const p1 = join(import.meta.dirname, "../../../../skills/workflow-executor/workflows");
  if (existsSync(p1)) return p1;
  const home = process.env.HOME || "";
  const p2 = join(home, ".pi/agent/skills/workflow-executor/workflows");
  if (existsSync(p2)) return p2;
  return join(process.cwd(), "skills/workflow-executor/workflows");
}
