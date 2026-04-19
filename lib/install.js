// mdbrain installer — cross-platform, stdlib-only
// Ports install.sh / install.ps1 to Node.

import fs from 'node:fs/promises';
import path from 'node:path';
import { existsSync, statSync } from 'node:fs';
import { log } from './utils.js';

const BOOTSTRAP_SNIPPET = `

## 🧠 Protocol bootstrap (mdbrain)

For every code task, read these before acting: \`BRAIN.md\`, \`CRAFT.md\`, \`PERF.md\`.
They define routing, anti-pattern detection, performance discipline, and the Safety Net.
The mechanical Safety Net (\`.claude/hooks/safety-net.sh\`) runs independently and will
block edits to protected paths regardless of in-session context.

Run \`/brain-scan\` at session start to see the MD ecosystem map.
`;

const MERGE_SECTION = `


---

## mdbrain Integration (auto-appended)

This project uses the \`mdbrain\` protocol system.

### MD Pipeline
- **BRAIN.md** — MD pipeline router (entry point for every command)
- **CRAFT.md** — code artistry / refactor protocol
- **PERF.md** — performance optimization (measurement-based)

### First command
\`\`\`
/brain-scan
\`\`\`

### Coexistence
- \`memory/\` — recognized as project memory extension
- other \`.md\` files — classified as Legacy, never modified
- \`.craftignore\` / \`.perfignore\` — exclusion paths

### Constraints
- Respect \`@craft-ignore\` / \`@perf-optimized\` markers
- Honor Safety Net interrupts at all times

---
`;

const CRAFTIGNORE_DEFAULT = `# CRAFT refactor exclusion paths (gitignore-style)
generated/**
vendor/**
node_modules/**
dist/**
build/**
.next/**
*.generated.ts
*.pb.js
`;

const PERFIGNORE_DEFAULT = `# PERF optimization exclusion paths
generated/**
node_modules/**
dist/**
build/**
.next/**
tests/**
scripts/**
*.min.js
`;

// Source → destination mapping inside a user project
const COPY_MAP = [
  // Root-level protocol files
  { src: 'BRAIN.md',           dst: 'BRAIN.md' },
  { src: 'CRAFT.md',           dst: 'CRAFT.md' },
  { src: 'PERF.md',            dst: 'PERF.md' },
  { src: 'ARCHITECTURE.md',    dst: 'ARCHITECTURE.md' },
  { src: 'BOOTSTRAP_GUIDE.md', dst: 'BOOTSTRAP_GUIDE.md' },
  // .claude tree (plugin components get copied INTO user's .claude/)
  { src: 'agents',                      dst: '.claude/agents',                      dir: true },
  { src: 'commands',                    dst: '.claude/commands',                    dir: true },
  { src: 'hooks',                       dst: '.claude/hooks',                       dir: true, excludeFiles: ['hooks.json'] },
  { src: '.claude/rules',               dst: '.claude/rules',                       dir: true },
  { src: '.claude/settings.example.json', dst: '.claude/settings.example.json' }
];

async function pathExists(p) {
  try { await fs.access(p); return true; } catch { return false; }
}

async function copyFile(src, dst, { dryRun, force }) {
  if (!existsSync(src)) {
    log.warn(`source missing: ${src}`);
    return 'warn';
  }
  if (existsSync(dst) && !force) {
    log.skip(`skip (exists): ${path.relative(process.cwd(), dst)}`);
    return 'skip';
  }
  if (!dryRun) {
    await fs.mkdir(path.dirname(dst), { recursive: true });
    await fs.copyFile(src, dst);
  }
  log.copy(`copy: ${path.relative(process.cwd(), dst)}`);
  return 'copy';
}

async function copyDir(srcDir, dstDir, { dryRun, force, excludeFiles = [] }) {
  if (!existsSync(srcDir)) return { copied: 0, skipped: 0 };
  let copied = 0, skipped = 0;
  const entries = await fs.readdir(srcDir, { withFileTypes: true });
  if (!dryRun) await fs.mkdir(dstDir, { recursive: true });
  for (const entry of entries) {
    if (excludeFiles.includes(entry.name)) continue;
    const srcPath = path.join(srcDir, entry.name);
    const dstPath = path.join(dstDir, entry.name);
    if (entry.isDirectory()) {
      const sub = await copyDir(srcPath, dstPath, { dryRun, force, excludeFiles });
      copied += sub.copied;
      skipped += sub.skipped;
    } else {
      const result = await copyFile(srcPath, dstPath, { dryRun, force });
      if (result === 'copy') copied++;
      else if (result === 'skip') skipped++;
    }
  }
  return { copied, skipped };
}

async function scanProject(projectDir) {
  const fingerprints = {
    claudeMd:     await pathExists(path.join(projectDir, 'CLAUDE.md')),
    brainMd:      await pathExists(path.join(projectDir, 'BRAIN.md')),
    craftMd:      await pathExists(path.join(projectDir, 'CRAFT.md')),
    perfMd:       await pathExists(path.join(projectDir, 'PERF.md')),
    memory:       await pathExists(path.join(projectDir, 'memory')),
    claudeDir:    await pathExists(path.join(projectDir, '.claude')),
    craftignore:  await pathExists(path.join(projectDir, '.craftignore')),
    perfignore:   await pathExists(path.join(projectDir, '.perfignore'))
  };

  // Detect legacy MD files (anything .md at root that's not ours)
  let otherMds = [];
  try {
    const entries = await fs.readdir(projectDir, { withFileTypes: true });
    const ours = new Set([
      'CLAUDE.md', 'BRAIN.md', 'CRAFT.md', 'PERF.md',
      'ARCHITECTURE.md', 'BOOTSTRAP_GUIDE.md', 'CLAUDE.template.md',
      'CHANGELOG.md', 'CONTRIBUTING.md', 'README.md'
    ]);
    for (const e of entries) {
      if (e.isFile() && e.name.endsWith('.md') && !ours.has(e.name)) {
        otherMds.push(e.name);
      }
    }
  } catch {}

  return { fingerprints, otherMds };
}

export async function install({ pkgRoot, projectDir, mode = 'coexist', force = false, dryRun = false }) {
  projectDir = path.resolve(projectDir);
  if (!existsSync(projectDir)) {
    log.error(`target folder not found: ${projectDir}`);
    process.exit(1);
  }
  if (!statSync(projectDir).isDirectory()) {
    log.error(`target is not a directory: ${projectDir}`);
    process.exit(1);
  }

  log.header(`mdbrain installer`);
  log.info(`   Source:  ${pkgRoot}`);
  log.info(`   Target:  ${projectDir}`);
  log.info(`   Mode:    ${mode}`);
  if (dryRun) log.info(`   DryRun:  active (no changes)`);
  log.blank();

  // ─────── Phase 1 — project scan ───────
  log.header(`Phase 1 — project scan`);
  const { fingerprints, otherMds } = await scanProject(projectDir);
  for (const [key, present] of Object.entries(fingerprints)) {
    log.info(`  ${key.padEnd(22)} ${present ? 'found' : '-'}`);
  }
  if (otherMds.length) {
    log.blank();
    log.info(`  Other MD files (${otherMds.length}):`);
    otherMds.slice(0, 10).forEach(name => log.info(`     - ${name}`));
    log.info(`     (will be classified as Legacy by BRAIN, never modified)`);
  }
  log.blank();

  // ─────── Phase 2 — conflict detection ───────
  if (fingerprints.claudeMd || fingerprints.memory) {
    log.warn(`Existing project detected`);
    if (fingerprints.claudeMd) log.info(`   - CLAUDE.md exists -> preserved (bootstrap appended in coexist/merge)`);
    if (fingerprints.memory)   log.info(`   - memory/ exists -> acknowledged as project memory extension`);
    if (fingerprints.claudeDir) log.info(`   - .claude/ exists -> new files added; existing preserved unless --force`);

    if (mode === 'fresh' && !force) {
      log.blank();
      log.error(`Fresh mode requested but existing files found. Options:`);
      log.info(`   1. --mode coexist (default, safe): add new files, append bootstrap`);
      log.info(`   2. --mode merge   : same + ensure Protocol section in CLAUDE.md`);
      log.info(`   3. --force        : overwrite (dangerous)`);
      process.exit(1);
    }
    log.blank();
  }

  // ─────── Phase 3 — install ───────
  log.header(`Phase 3 — install`);
  let copied = 0, skipped = 0, merged = 0;

  for (const entry of COPY_MAP) {
    const src = path.join(pkgRoot, entry.src);
    const dst = path.join(projectDir, entry.dst);
    if (entry.dir) {
      const result = await copyDir(src, dst, { dryRun, force, excludeFiles: entry.excludeFiles || [] });
      copied += result.copied;
      skipped += result.skipped;
    } else {
      const result = await copyFile(src, dst, { dryRun, force });
      if (result === 'copy') copied++;
      else if (result === 'skip') skipped++;
    }
  }

  // ─────── CLAUDE.md handling ───────
  const claudeSrc = path.join(pkgRoot, 'CLAUDE.template.md');
  const claudeDst = path.join(projectDir, 'CLAUDE.md');
  const claudeTemplateDst = path.join(projectDir, 'CLAUDE.template.md');

  if (fingerprints.claudeMd) {
    if (mode === 'coexist' || mode === 'merge') {
      const existing = await fs.readFile(claudeDst, 'utf8').catch(() => '');
      if (!/(mdbrain|BRAIN\.md)/i.test(existing)) {
        const snippet = mode === 'merge' ? MERGE_SECTION : BOOTSTRAP_SNIPPET;
        if (!dryRun) await fs.appendFile(claudeDst, snippet);
        log.merge(`append: CLAUDE.md bootstrap line added`);
        merged++;
      } else {
        log.skip(`skip: CLAUDE.md already references mdbrain`);
        skipped++;
      }
      // Also save a reference template aside
      if (!dryRun) await fs.copyFile(claudeSrc, claudeTemplateDst).catch(() => {});
      copied++;
    } else if (mode === 'fresh' && force) {
      const backup = `${claudeDst}.backup-${Date.now()}`;
      if (!dryRun) {
        await fs.rename(claudeDst, backup);
        await fs.copyFile(claudeSrc, claudeDst);
      }
      log.copy(`overwrite: CLAUDE.md (backup: ${path.basename(backup)})`);
      copied++;
    }
  } else {
    if (!dryRun) await fs.copyFile(claudeSrc, claudeDst);
    log.copy(`create: CLAUDE.md (from template, needs filling in)`);
    copied++;
  }

  // ─────── .craftignore / .perfignore ───────
  const craftIgnore = path.join(projectDir, '.craftignore');
  if (!fingerprints.craftignore) {
    if (!dryRun) await fs.writeFile(craftIgnore, CRAFTIGNORE_DEFAULT);
    log.copy(`create: .craftignore`);
    copied++;
  }
  const perfIgnore = path.join(projectDir, '.perfignore');
  if (!fingerprints.perfignore) {
    if (!dryRun) await fs.writeFile(perfIgnore, PERFIGNORE_DEFAULT);
    log.copy(`create: .perfignore`);
    copied++;
  }

  // ─────── Make bash hook executable (unix) ───────
  if (process.platform !== 'win32' && !dryRun) {
    const hook = path.join(projectDir, '.claude/hooks/safety-net.sh');
    if (existsSync(hook)) await fs.chmod(hook, 0o755).catch(() => {});
  }

  // ─────── Phase 4 — summary + next steps ───────
  log.blank();
  log.rule();
  log.header(`Install complete`);
  log.info(`   copied: ${copied}  |  merged: ${merged}  |  skipped: ${skipped}`);
  if (dryRun) log.info(`   (dry run — no changes applied)`);
  log.blank();

  log.info(`Next steps:`);
  log.blank();
  log.info(`  1. Wire the Safety Net hook (one-time):`);
  log.info(`     cp .claude/settings.example.json .claude/settings.json`);
  log.blank();
  if (fingerprints.claudeMd && mode === 'coexist') {
    log.info(`  2. Your existing CLAUDE.md was preserved. A bootstrap line was appended.`);
  } else if (!fingerprints.claudeMd) {
    log.info(`  2. Fill in CLAUDE.md with your project facts`);
  }
  log.blank();
  log.info(`  3. Launch Claude Code:`);
  log.info(`     claude`);
  log.blank();
  log.info(`  4. First command:`);
  log.info(`     /brain-scan`);
  log.blank();
  log.info(`  Docs: README.md, ARCHITECTURE.md, BOOTSTRAP_GUIDE.md`);
  log.blank();
}
