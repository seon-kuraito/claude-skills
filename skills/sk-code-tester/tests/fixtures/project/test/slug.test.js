import { test } from "node:test";
import assert from "node:assert/strict";
import { slugify } from "../src/slug.js";

test("joins words with hyphens and lowers the case", () => {
  assert.equal(slugify("Hello World"), "hello-world");
});

test("drops punctuation and trims the ends", () => {
  assert.equal(slugify("  Hello, World!  "), "hello-world");
});
