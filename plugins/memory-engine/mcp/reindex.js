#!/usr/bin/env node
// Workflow OS — memory-engine legacy import helper
// Walks an existing markdown vault, parses frontmatter, and imports old notes
// into the canonical SQLite store. This is a migration/DR bridge, not the normal
// memory source of truth.

import Database from 'better-sqlite3';
import matter from 'gray-matter';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';
import crypto from 'crypto';

const SENTINEL = process.env.WOS_SENTINEL || path.join(os.homedir(), '.codex/workflow-os.json');
const sentinel = JSON.parse(await fs.readFile(SENTINEL, 'utf8'));
const DATA_ROOT = sentinel.data_root;
if (!DATA_ROOT) throw new Error('sentinel missing data_root');
async function resolveVaultPath() {
  if (sentinel.vault_path) return sentinel.vault_path;

  const localPath = path.join(DATA_ROOT, '.agent', 'local.json');
  try {
    const local = JSON.parse(await fs.readFile(localPath, 'utf8'));
    if (local.vault_path) return local.vault_path;
  } catch {
    // local.json is created during onboarding; fall back for bootstrap/pre-onboarding.
  }

  return path.join(DATA_ROOT, 'vault');
}

const VAULT = process.env.WOS_LEGACY_VAULT || await resolveVaultPath();
const INDEX_PATH = path.join(DATA_ROOT, '.index/memory.db');

await fs.mkdir(path.dirname(INDEX_PATH), { recursive: true });
const db = new Database(INDEX_PATH);
db.pragma('journal_mode = WAL');

db.exec(`
  CREATE TABLE IF NOT EXISTS notes (
    id TEXT PRIMARY KEY, type TEXT NOT NULL, project TEXT,
    source TEXT NOT NULL, created TEXT NOT NULL,
    frontmatter TEXT NOT NULL, body TEXT NOT NULL, sha256 TEXT NOT NULL
  );
  CREATE INDEX IF NOT EXISTS idx_notes_type    ON notes(type);
  CREATE INDEX IF NOT EXISTS idx_notes_project ON notes(project);
  CREATE INDEX IF NOT EXISTS idx_notes_created ON notes(created);
  CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(id UNINDEXED, body, content='notes', content_rowid='rowid');
  CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
    INSERT INTO notes_fts(rowid, id, body) VALUES (new.rowid, new.id, new.body);
  END;
  CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON notes BEGIN
    INSERT INTO notes_fts(notes_fts, rowid, id, body) VALUES('delete', old.rowid, old.id, old.body);
  END;
  CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes BEGIN
    INSERT INTO notes_fts(notes_fts, rowid, id, body) VALUES('delete', old.rowid, old.id, old.body);
    INSERT INTO notes_fts(rowid, id, body) VALUES (new.rowid, new.id, new.body);
  END;
`);

const insert = db.prepare(`
  INSERT OR IGNORE INTO notes (id, type, project, source, created, frontmatter, body, sha256)
  VALUES (@id, @type, @project, @source, @created, @frontmatter, @body, @sha256)
`);

async function* walk(dir) {
  try {
    await fs.access(dir);
  } catch {
    throw new Error(`legacy vault not found at ${dir}`);
  }

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
  const id = `legacy/${rel.replace(/\.md$/i, '')}`;
  insert.run({
    id,
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

console.log(`Imported ${count} legacy markdown notes from ${VAULT} into ${INDEX_PATH}`);
db.close();
