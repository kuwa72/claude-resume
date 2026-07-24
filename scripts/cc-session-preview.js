#!/usr/bin/env node
// Print a readable transcript preview of a Claude Code session jsonl, for fzf --preview.
const fs = require("fs");

const SKIP_PREFIX = /^(<command-|<local-command|<system-reminder|Caveat:)/;
const MAX_MESSAGES = 40;
const MAX_CHARS = 220;

const file = process.argv[2];
if (!file) process.exit(0);

let content;
try {
  content = fs.readFileSync(file, "utf8");
} catch {
  process.exit(0);
}

const msgs = [];
for (const line of content.split("\n")) {
  if (!line) continue;
  let o;
  try {
    o = JSON.parse(line);
  } catch {
    continue;
  }
  if ((o.type === "user" || o.type === "assistant") && o.message) {
    const c = o.message.content;
    let t =
      typeof c === "string"
        ? c
        : Array.isArray(c)
          ? c
              .map((x) =>
                x.text || (x.type === "tool_use" ? `[tool: ${x.name}]` : ""),
              )
              .join(" ")
          : "";
    t = t.replace(/\s+/g, " ").trim();
    if (!t || SKIP_PREFIX.test(t)) continue;
    const tag = o.type === "user" ? "▶ USER" : "  claude";
    msgs.push(`${tag}: ${t.slice(0, MAX_CHARS)}`);
  }
}

console.log(msgs.slice(0, MAX_MESSAGES).join("\n\n"));
