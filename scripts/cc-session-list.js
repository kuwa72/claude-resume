#!/usr/bin/env node
// List Claude Code sessions for one or more project dirs as TSV.
// Output columns (tab-separated): jsonlPath, sessionId, cwd, "YYYY-MM-DD HH:MM", firstPrompt
const fs = require("fs");
const path = require("path");

const SKIP_PREFIX = /^(<command-|<local-command|<system-reminder|Caveat:)/;

function firstPromptAndCwd(file) {
  let prompt = "";
  let cwd = "";
  let content;
  try {
    content = fs.readFileSync(file, "utf8");
  } catch {
    return { prompt, cwd };
  }
  const lines = content.split("\n");
  for (const line of lines) {
    if (!line) continue;
    let o;
    try {
      o = JSON.parse(line);
    } catch {
      continue;
    }
    if (!cwd && o.cwd) cwd = o.cwd;
    if (!prompt && o.type === "user" && o.message) {
      const c = o.message.content;
      let t =
        typeof c === "string"
          ? c
          : Array.isArray(c)
            ? c.map((x) => x.text || "").join(" ")
            : "";
      t = t.replace(/\s+/g, " ").trim();
      if (t && !SKIP_PREFIX.test(t)) prompt = t;
    }
    if (prompt && cwd) break;
  }
  return { prompt, cwd };
}

function pad(n) {
  return String(n).padStart(2, "0");
}

const dirs = process.argv.slice(2);
const entries = [];
for (const dir of dirs) {
  let names;
  try {
    names = fs.readdirSync(dir);
  } catch {
    continue;
  }
  for (const name of names) {
    if (!name.endsWith(".jsonl")) continue;
    const p = path.join(dir, name);
    let st;
    try {
      st = fs.statSync(p);
    } catch {
      continue;
    }
    entries.push({ p, id: name.replace(/\.jsonl$/, ""), mtime: st.mtimeMs });
  }
}

entries.sort((a, b) => b.mtime - a.mtime);

for (const e of entries) {
  const { prompt, cwd } = firstPromptAndCwd(e.p);
  const d = new Date(e.mtime);
  const date = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
  console.log(
    [e.p, e.id, cwd || "", date, (prompt || "(no prompt)").slice(0, 120)].join(
      "\t",
    ),
  );
}
