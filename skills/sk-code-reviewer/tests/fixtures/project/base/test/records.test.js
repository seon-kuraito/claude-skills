import { test } from "node:test";
import assert from "node:assert/strict";
import { listRecords } from "../src/records.js";

test("lists records newest first", () => {
  assert.deepEqual(
    listRecords().map((row) => row.date),
    ["2026-01-03", "2026-01-02"],
  );
});
