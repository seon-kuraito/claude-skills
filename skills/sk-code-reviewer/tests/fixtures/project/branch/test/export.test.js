import { test } from "node:test";
import assert from "node:assert/strict";
import { ExporterFactory } from "../src/export.js";
import { columns } from "../src/records.js";

test("renders the header in column order", () => {
  const csv = ExporterFactory.create("csv").doIt([], columns);
  assert.equal(csv, "日期,標題,金額\n");
});
