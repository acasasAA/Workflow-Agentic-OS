#!/usr/bin/env node
// Workflow OS — memory-engine MCP server
//
// Exposes three tools over stdio:
//   memory.write  — write a note (markdown + frontmatter) to the vault and index it
//   memory.search — FTS5 query, optional type/project/since filters, returns snippets
//   memory.recall — fetch a full note by id (filename)
//
// Vault layout: <data_root>/vault/<type>/<YYYY-MM>/<slug>.md
// Index:        <data_root>/.index/memory.db (regenerable; see scripts/reindex.ps1)
//
// Discovery: reads ~/.codex/workflow-os.json for data_root.

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import Database from 'better-sqlite3';
import matter from 'gray-matter';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';
import crypto from 'crypto';

// ─── Bootstrap ──────────────────────────────────────────────────────────────

const VALID_TYPES = new Set([
  'project-state', 'checkpoint', 'decision', 'worklog',
  'session-summary', 'reference', 'preference'
]);

const SENTINEL = process.env.WOS_SENTINEL || path.join(os.homedir(), '.codex/workflow-os.json');

async function readSentinel() {
  try {
    const raw = await fs.readFile(SENTINEL, 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    throw new Error(`workflow-os sentinel not found at ${SENTINEL}; run bootstrap.ps1 first`);
  }
}

const sentinel = await readSentinel();
const DATA_ROOT = sentinel.data_root;
if (!DATA_ROOT) throw new Error('sentinel missing data_root');

const VAULT = path.join(DATA_ROOT, 'vault');
const INDEX_DIR = path.join(DATA_ROOT, '.index');
const INDEX_PATH = path.join(INDEX_DIR, 'memory.db');

await fs.mkdir(VAULT, { recursive: true });
await fs.mkdir(INDEX_DIR, { recursive: true });

// ─── SQLite ─────────────────────────────────────────────────────────────────

const db = new Database(INDEX_PATH);
db.pragma('journal_mode = WAL');

db.exec(`
  CREATE TABLE IF NOT EXISTS notes (
    id          TEXT PRIMARY KEY,         -- relative path from vault root
    type        TEXT NOT NULL,
    project     TEXT,
    source      TEXT NOT NULL,
    created     TEXT NOT NULL,            -- ISO-8601
    frontmatter TEXT NOT NULL,            -- full JSON of frontmatter
    body        TEXT NOT NULL,
    sha256      TEXT NOT NULL
  );
  CREATE INDEX IF NOT EXISTS idx_notes_type    ON notes(type);
  CREATE INDEX IF NOT EXISTS idx_notes_project ON notes(project);
  CREATE INDEX IF NOT EXISTS idx_notes_created ON notes(created);

  CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
    id UNINDEXED,
    body,
    content='notes',
    content_rowid='rowid'
  );

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

// ─── Helpers ────────────────────────────────────────────────────────────────

const slugify = (s) =>
  String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 60) || 'note';

const yearMonth = (iso) => iso.slice(0, 7);

const sha256 = (s) => crypto.createHash('sha256').update(s).digest('hex');

const upsertStmt = db.prepare(`
  INSERT INTO notes (id, type, project, source, created, frontmatter, body, sha256)
  VALUES (@id, @type, @project, @source, @created, @frontmatter, @body, @sha256)
  ON CONFLICT(id) DO UPDATE SET
    type = excluded.type,
    project = excluded.project,
    source = excluded.source,
    created = excluded.created,
    frontmatter = excluded.frontmatter,
    body = excluded.body,
    sha256 = excluded.sha256
`);

// ─── Tool implementations ───────────────────────────────────────────────────

async function memoryWrite(args) {
  const { type, project = null, source, body, frontmatter_extras = {}, title = null } = args;

  if (!VALID_TYPES.has(type)) {
    throw new Error(`invalid type: ${type}. allowed: ${[...VALID_TYPES].join(', ')}`);
  }
  if (!source) throw new Error('source is required');
  if (!body) throw new Error('body is required');

  const created = new Date().toISOString();
  const slug = slugify(title || `${type}-${created.replace(/[:.]/g, '-')}`);
  const rel = path.posix.join(type, yearMonth(created), `${slug}.md`);
  const full = path.join(VAULT, rel);

  const fm = { source, created, type, project, ...frontmatter_extras };
  const content = matter.stringify(body.trim() + '\n', fm);

  await fs.mkdir(path.dirname(full), { recursive: true });
  await fs.writeFile(full, content, 'utf8');

  upsertStmt.run({
    id: rel,
    type,
    project,
    source,
    created,
    frontmatter: JSON.stringify(fm),
    body,
    sha256: sha256(content),
  });

  return { id: rel, path: full };
}

const searchStmt = db.prepare(`
  SELECT n.id, n.type, n.project, n.source, n.created, n.frontmatter,
         snippet(notes_fts, 1, '«', '»', '…', 16) AS snippet
  FROM notes n
  JOIN notes_fts f ON f.rowid = n.rowid
  WHERE notes_fts MATCH @q
    AND (@type    IS NULL OR n.type    = @type)
    AND (@project IS NULL OR n.project = @project)
    AND (@since   IS NULL OR n.created >= @since)
  ORDER BY n.created DESC
  LIMIT @limit
`);

const filterStmt = db.prepare(`
  SELECT n.id, n.type, n.project, n.source, n.created, n.frontmatter,
         substr(n.body, 1, 200) AS snippet
  FROM notes n
  WHERE (@type    IS NULL OR n.type    = @type)
    AND (@project IS NULL OR n.project = @project)
    AND (@since   IS NULL OR n.created >= @since)
  ORDER BY n.created DESC
  LIMIT @limit
`);

function memorySearch(args) {
  const { query = null, type = null, project = null, since = null, limit = 20 } = args;
  const rows = query
    ? searchStmt.all({ q: query, type, project, since, limit })
    : filterStmt.all({ type, project, since, limit });
  return rows.map((r) => ({
    id: r.id,
    type: r.type,
    project: r.project,
    source: r.source,
    created: r.created,
    frontmatter: JSON.parse(r.frontmatter),
    snippet: r.snippet,
  }));
}

const recallStmt = db.prepare('SELECT id, type, project, source, created, frontmatter, body FROM notes WHERE id = ?');

async function memoryRecall(args) {
  const { id } = args;
  if (!id) throw new Error('id is required');
  const row = recallStmt.get(id);
  if (!row) return null;
  return {
    id: row.id,
    type: row.type,
    project: row.project,
    source: row.source,
    created: row.created,
    frontmatter: JSON.parse(row.frontmatter),
    body: row.body,
  };
}

// ─── MCP server wiring ──────────────────────────────────────────────────────

const server = new Server(
  { name: 'memory-engine', version: '0.1.0' },
  { capabilities: { tools: {} } }
);

const tools = [
  {
    name: 'memory_write',
    description: 'Write a memory note to the vault and index it. Body must be markdown; frontmatter is constructed from required fields plus frontmatter_extras pass-through.',
    inputSchema: {
      type: 'object',
      required: ['type', 'source', 'body'],
      properties: {
        type:    { type: 'string', enum: [...VALID_TYPES] },
        source:  { type: 'string', description: 'Plugin name or "user".' },
        body:    { type: 'string', description: 'Markdown body of the note.' },
        project: { type: 'string', description: 'Project slug; null for non-project notes.' },
        title:   { type: 'string', description: 'Optional title used for the filename slug.' },
        frontmatter_extras: { type: 'object', description: 'Additional frontmatter fields (e.g. phase, blockers, jira_key).' }
      }
    }
  },
  {
    name: 'memory_search',
    description: 'Search the memory index. Provide a FTS5 query, or filters only (type/project/since) for browse-style lookups. Returns up to `limit` snippets ordered by created_at desc.',
    inputSchema: {
      type: 'object',
      properties: {
        query:   { type: 'string', description: 'FTS5 query. Omit to filter-only.' },
        type:    { type: 'string', description: 'Filter by note type.' },
        project: { type: 'string', description: 'Filter by project slug.' },
        since:   { type: 'string', description: 'ISO-8601 lower bound on created.' },
        limit:   { type: 'integer', default: 20 }
      }
    }
  },
  {
    name: 'memory_recall',
    description: 'Fetch a full note by id (its relative path from the vault root). Returns frontmatter + body.',
    inputSchema: {
      type: 'object',
      required: ['id'],
      properties: { id: { type: 'string' } }
    }
  }
];

server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools }));

server.setRequestHandler(CallToolRequestSchema, async (req) => {
  const { name, arguments: args = {} } = req.params;
  try {
    let result;
    if (name === 'memory_write')       result = await memoryWrite(args);
    else if (name === 'memory_search') result = memorySearch(args);
    else if (name === 'memory_recall') result = await memoryRecall(args);
    else throw new Error(`unknown tool: ${name}`);
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  } catch (err) {
    return { content: [{ type: 'text', text: `ERROR: ${err.message}` }], isError: true };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
