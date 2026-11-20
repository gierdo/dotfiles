import { DatabaseSync } from "node:sqlite";
import { loadYamlParser } from "./helpers.ts";

const parse = loadYamlParser();

// 1. Verify SQLite functionality
const db = new DatabaseSync(":memory:");
db.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT);");
db.prepare("INSERT INTO test (name) VALUES (?)").run("smoke");
const row = db.prepare("SELECT * FROM test").get() as { id: number; name: string } | undefined;
if (!row || row.name !== "smoke") {
  throw new Error("SQLite smoke test failed: row mismatch");
}

// 2. Verify YAML parsing functionality
const parsed = parse("key: value");
if (!parsed || parsed.key !== "value") {
  throw new Error("YAML parse smoke test failed: parsed content mismatch");
}

console.log("Smoke test passed: node:sqlite and yaml available.");
