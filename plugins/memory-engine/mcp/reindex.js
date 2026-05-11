#!/usr/bin/env node
// Workflow OS — memory-engine reindex helper
// Walks the vault, parses frontmatter, rewrites the SQLite index from scratch.
// Invoked by scripts/reindex.ps1.

import Database from 'better-sqlite3';
import matter from 'gray-matter';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';
import crypto from 'crypto';

const SENTINEL = process.env.WOS_SENTINEL || path.join(os.homedir(), '.codex/workflow-os.json');
const sentinel = JSON.parse(await fs.readFile(SENTINEL, 'utf8'));
const DATA_ROOT = sentinel.data_root;
const VAULT = path.join(DATA_ROOT, 'vault');
const INDEX_PATH = path.join(DATA_ROOT, '.index/memory.db');

await fs.mkdir(path.dirname(INDEX_PATH), { recursive: true });
const db = new Database(INDEX_PATH);
db.pragma('journal_mode = WAL');

db.exec(`
  DROP TABLE IF EXISTS notes_fts;
  DROP TABLE IF EXISTS notes;
  CREATE TABLE notes (
    id TEXT PRIMARY KEY, type TEXT NOT NULL, project TEXT,
    source TEXT NOT NULL, created TEXT NOT NULL,
    frontmatter TEXT NOT NULL, body TEXT NOT NULL, sha256 TEXT NOT NULL
  );
  CREATE INDEX idx_notes_type    ON notes(type);
  CREATE INDEX idx_notes_project ON notes(project);
  CREATE INDEX idx_notes_created ON notes(created);
  CREATE VIRTUAL TABLE notes_fts USING fts5(id UNINDEXED, body, content='notes', content_rowid='rowid');
  CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
    INSERT INTO notes_fts(rowid, id, body) VALUES (new.rowid, new.id, new.body);
  END;
`);

const insert = db.prepare(`
  INSERT INTO notes (id, type, project, source, created, frontmatter, body, sha256)
  VALUES (@id, @type, @project, @source, @created, @frontmatter, @body, @sha256)
`);

async function* walk(dir) {
  for (const entry of await fs.readdir(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(full);
    else if (entry.isFile() && entry.name.endsWith('.md')) yield full;
  }
}

let count = 0;
for await (const full of walk(VAULT)) {
  const rel = path.relative(VAULT, full).replaceAll('\\', '/');
  if (rel.startsWith('.obsidian/')) continue;
  const raw = await fs.readFile(full, 'utf8');
  const parsed = matter(raw);
  const fm = parsed.data || {};
  if (!fm.type || !fm.source || !fm.created) continue; // skip notes without required frontmatter
  insert.run({
    id: rel,
    type: fm.type,
    project: fm.project || null,
    source: fm.source,
    created: fm.created,
    frontmatter: JSON.stringify(fm),
    body: parsed.content,
    sha256: crypto.createHash('sha256').update(raw).digest('hex'),
  });
  count++;
}

console.log(`Indexed ${count} notes into ${INDEX_PATH}`);
db.close();
