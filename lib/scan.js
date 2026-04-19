// stetkeep scan — read-only ecosystem map
// Lists MD files in the project and classifies them.

import fs from 'node:fs/promises';
import path from 'node:path';
import { existsSync } from 'node:fs';
import { log } from './utils.js';

const KNOWN_PROTOCOLS = new Set(['BRAIN.md', 'CRAFT.md', 'PERF.md']);
const KNOWN_DOCS = new Set([
  'ARCHITECTURE.md', 'BOOTSTRAP_GUIDE.md', 'CLAUDE.template.md',
  'CHANGELOG.md', 'CONTRIBUTING.md', 'README.md'
]);
const MEMORY_FILES = new Set(['CLAUDE.md']);

async function pathExists(p) {
  try { await fs.access(p); return true; } catch { return false; }
}

async function listMdFiles(dir, maxDepth = 2, depth = 0) {
  if (depth > maxDepth || !existsSync(dir)) return [];
  const results = [];
  const entries = await fs.readdir(dir, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.name.startsWith('.') || entry.name === 'node_modules') continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      const sub = await listMdFiles(full, maxDepth, depth + 1);
      results.push(...sub);
    } else if (entry.name.endsWith('.md')) {
      results.push(path.relative(dir, full));
    }
  }
  return results;
}

export async function scan({ projectDir }) {
  projectDir = path.resolve(projectDir);
  if (!existsSync(projectDir)) {
    log.error(`target folder not found: ${projectDir}`);
    process.exit(1);
  }

  const allMds = [];
  const entries = await fs.readdir(projectDir, { withFileTypes: true });
  for (const e of entries) {
    if (e.isFile() && e.name.endsWith('.md')) allMds.push(e.name);
  }

  // Also look at docs/ one level deep
  const docsDir = path.join(projectDir, 'docs');
  if (existsSync(docsDir)) {
    const docsMds = await listMdFiles(docsDir, 1);
    docsMds.forEach(p => allMds.push(`docs/${p}`));
  }

  // Memory folder
  const memoryDir = path.join(projectDir, 'memory');
  const memoryMds = existsSync(memoryDir) ? await listMdFiles(memoryDir, 1) : [];

  const protocols = [], memory = [], legacy = [];
  for (const f of allMds) {
    const name = path.basename(f);
    if (KNOWN_PROTOCOLS.has(name))      protocols.push(f);
    else if (MEMORY_FILES.has(name))    memory.push(f);
    else                                 legacy.push(f);
  }
  memoryMds.forEach(m => memory.push(`memory/${m}`));

  // Safety Net status
  const safety = {
    craftignore: existsSync(path.join(projectDir, '.craftignore')),
    perfignore:  existsSync(path.join(projectDir, '.perfignore')),
    hook:        existsSync(path.join(projectDir, '.claude/hooks/safety-net.sh')),
    agents:      existsSync(path.join(projectDir, '.claude/agents')),
    commands:    existsSync(path.join(projectDir, '.claude/commands')),
    rules:       existsSync(path.join(projectDir, '.claude/rules')),
    settings:    existsSync(path.join(projectDir, '.claude/settings.json'))
  };

  // Output
  log.header(`MD Ecosystem Map — ${projectDir}`);
  log.blank();
  log.info(`Protocols:`);
  if (protocols.length) {
    protocols.forEach(p => log.info(`  ├─ ${p}`));
  } else {
    log.info(`  (none — run \`stetkeep install\`)`);
  }
  log.blank();

  log.info(`Memory (context):`);
  if (memory.length) {
    memory.forEach(m => log.info(`  ├─ ${m}`));
  } else {
    log.info(`  (none)`);
  }
  log.blank();

  log.info(`Legacy (read-only, never modified):`);
  if (legacy.length) {
    legacy.slice(0, 15).forEach(l => log.info(`  └─ ${l}`));
    if (legacy.length > 15) log.info(`     ... (+${legacy.length - 15} more)`);
  } else {
    log.info(`  (none)`);
  }
  log.blank();

  log.info(`Safety Net status:`);
  log.info(`  .craftignore:                 ${safety.craftignore ? '✓ present' : '✗ missing'}`);
  log.info(`  .perfignore:                  ${safety.perfignore  ? '✓ present' : '✗ missing'}`);
  log.info(`  .claude/hooks/safety-net.sh:  ${safety.hook        ? '✓ present' : '✗ missing'}`);
  log.info(`  .claude/agents/:              ${safety.agents      ? '✓ present' : '✗ missing'}`);
  log.info(`  .claude/commands/:            ${safety.commands    ? '✓ present' : '✗ missing'}`);
  log.info(`  .claude/rules/:               ${safety.rules       ? '✓ present' : '✗ missing'}`);
  log.info(`  .claude/settings.json:        ${safety.settings    ? '✓ present' : '⚠ not activated (cp .claude/settings.example.json .claude/settings.json)'}`);
  log.blank();

  log.info(`Suggested next steps:`);
  if (!protocols.length) {
    log.info(`  1. stetkeep install   — install the protocols`);
  } else if (!safety.settings) {
    log.info(`  1. cp .claude/settings.example.json .claude/settings.json`);
    log.info(`  2. Launch claude → /brain-scan`);
  } else {
    log.info(`  1. Launch claude → /brain-scan`);
    log.info(`  2. Or: /craft-audit, /perf-audit`);
  }
  log.blank();
}
