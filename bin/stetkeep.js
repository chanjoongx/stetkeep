#!/usr/bin/env node
// stetkeep CLI entry
// Supports: install, scan, --version, --help

import { parseArgs } from 'node:util';
import { install } from '../lib/install.js';
import { scan } from '../lib/scan.js';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PKG_ROOT = path.resolve(__dirname, '..');
const pkg = JSON.parse(readFileSync(path.join(PKG_ROOT, 'package.json'), 'utf8'));

const HELP = `stetkeep v${pkg.version} — XML protocol framework for Claude Code

USAGE
  stetkeep install [path]       Install stetkeep into a project (default: cwd)
  stetkeep scan [path]          Scan project's MD ecosystem (read-only)
  stetkeep --version, -v        Print version
  stetkeep --help, -h           Print this help

INSTALL OPTIONS
  --mode <coexist|merge|fresh>   How to handle existing CLAUDE.md
                                  coexist (default): preserve, append bootstrap line
                                  merge            : same + add Protocols section
                                  fresh            : create from template (requires --force if exists)
  --force                        Overwrite existing protocol files
  --dry-run                      Simulate install without writing

EXAMPLES
  stetkeep install                       # install into current directory
  stetkeep install ~/my-project          # install into specific path
  stetkeep install --dry-run             # preview what would change
  stetkeep install --mode merge          # append Protocols section to CLAUDE.md
  stetkeep install --mode fresh --force  # overwrite everything with template

DOCS   https://github.com/chanjoongx/stetkeep
ISSUES https://github.com/chanjoongx/stetkeep/issues
`;

const command = process.argv[2];
const rest = process.argv.slice(3);

// Top-level flags before any subcommand
if (command === '--version' || command === '-v') {
  console.log(pkg.version);
  process.exit(0);
}

if (command === '--help' || command === '-h' || !command) {
  console.log(HELP);
  process.exit(0);
}

// Parse remaining args for the subcommand
let values, positionals;
try {
  ({ values, positionals } = parseArgs({
    args: rest,
    options: {
      mode:      { type: 'string',  default: 'coexist' },
      force:     { type: 'boolean', default: false },
      'dry-run': { type: 'boolean', default: false },
      help:      { type: 'boolean', short: 'h', default: false }
    },
    allowPositionals: true,
    strict: false
  }));
} catch (err) {
  console.error(`Argument error: ${err.message}`);
  process.exit(1);
}

if (values.help) {
  console.log(HELP);
  process.exit(0);
}

if (!['coexist', 'merge', 'fresh'].includes(values.mode)) {
  console.error(`Invalid --mode: ${values.mode} (expected coexist|merge|fresh)`);
  process.exit(1);
}

async function main() {
  switch (command) {
    case 'install':
    case 'i':
      await install({
        pkgRoot: PKG_ROOT,
        projectDir: positionals[0] || process.cwd(),
        mode: values.mode,
        force: values.force,
        dryRun: values['dry-run']
      });
      break;
    case 'scan':
    case 's':
      await scan({
        projectDir: positionals[0] || process.cwd()
      });
      break;
    default:
      console.error(`Unknown command: ${command}\n`);
      console.error('Run `stetkeep --help` for usage.');
      process.exit(1);
  }
}

main().catch(err => {
  console.error(`stetkeep: ${err.message}`);
  if (process.env.DEBUG) console.error(err.stack);
  process.exit(1);
});
