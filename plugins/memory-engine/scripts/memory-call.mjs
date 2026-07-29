#!/usr/bin/env node
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const usage = `Usage:
  node memory-call.mjs <memory_write|memory_search|memory_recall|memory_export> '<json-arguments>'

Examples:
  node memory-call.mjs memory_search '{"type":"project-state","project":"my-project","limit":5}'
  node memory-call.mjs memory_write '{"type":"project-state","source":"wos-project","project":"my-project","title":"my-project-state","body":"..."}'
  node memory-call.mjs memory_export '{"project":"my-project","limit":100}'
`;

const [, , toolName, rawArgs] = process.argv;
if (!toolName || !rawArgs) {
  console.error(usage.trim());
  process.exit(2);
}

let toolArgs;
try {
  toolArgs = JSON.parse(rawArgs);
} catch (err) {
  console.error(`Invalid JSON arguments: ${err.message}`);
  process.exit(2);
}

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const pluginRoot = path.resolve(scriptDir, '..');
const serverPath = path.join(pluginRoot, 'mcp', 'server.js');
const sentinel = process.env.WOS_SENTINEL || path.join(process.env.USERPROFILE || process.env.HOME || '', '.codex', 'workflow-os.json');

const child = spawn(process.execPath, [serverPath], {
  env: { ...process.env, WOS_SENTINEL: sentinel },
  stdio: ['pipe', 'pipe', 'pipe'],
});

let stdoutBuffer = '';
let stderrBuffer = '';
let nextId = 1;
const pending = new Map();

child.stdout.on('data', (chunk) => {
  stdoutBuffer += chunk.toString();
  let idx;
  while ((idx = stdoutBuffer.indexOf('\n')) >= 0) {
    const line = stdoutBuffer.slice(0, idx).trim();
    stdoutBuffer = stdoutBuffer.slice(idx + 1);
    if (!line) continue;
    try {
      const msg = JSON.parse(line);
      if (msg.id && pending.has(msg.id)) {
        pending.get(msg.id)(msg);
        pending.delete(msg.id);
      }
    } catch (err) {
      stderrBuffer += `Non-JSON MCP stdout: ${line}\n`;
    }
  }
});

child.stderr.on('data', (chunk) => {
  stderrBuffer += chunk.toString();
});

function request(method, params = {}) {
  const id = nextId++;
  child.stdin.write(JSON.stringify({ jsonrpc: '2.0', id, method, params }) + '\n');
  return new Promise((resolve) => pending.set(id, resolve));
}

function notify(method, params = {}) {
  child.stdin.write(JSON.stringify({ jsonrpc: '2.0', method, params }) + '\n');
}

try {
  const init = await request('initialize', {
    protocolVersion: '2024-11-05',
    capabilities: {},
    clientInfo: { name: 'workflow-os-memory-call', version: '1.0.0' },
  });
  if (init.error) throw new Error(JSON.stringify(init.error));

  notify('notifications/initialized');

  const result = await request('tools/call', {
    name: toolName,
    arguments: toolArgs,
  });

  if (result.error) {
    console.error(JSON.stringify(result.error, null, 2));
    process.exitCode = 1;
  } else {
    console.log(JSON.stringify(result.result, null, 2));
  }
} catch (err) {
  console.error(err?.stack || String(err));
  process.exitCode = 1;
} finally {
  child.stdin.end();
  child.kill();
  if (stderrBuffer && process.exitCode) {
    console.error(stderrBuffer.trim());
  }
}
