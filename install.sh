#!/usr/bin/env bash
# stetkeep installer — thin wrapper over lib/install.js (v0.3+)
#
# If you cloned the repo: this runs the Node installer directly.
# If you have npm: prefer `npx stetkeep install` or `npm i -g stetkeep` instead.
#
# Usage:
#   bash install.sh                     # default coexist mode
#   bash install.sh --mode fresh        # empty project
#   bash install.sh --mode merge        # append Protocols section to CLAUDE.md
#   bash install.sh --force             # overwrite existing
#   bash install.sh --dry-run           # simulate, no changes
#   bash install.sh /path/to/project    # target another folder

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v node >/dev/null 2>&1; then
    echo "ERROR: node not found."
    echo "stetkeep requires Node.js 20+ (already bundled with Claude Code)."
    echo "Install from https://nodejs.org/ or via your package manager."
    exit 1
fi

# Pass all args to the Node CLI as 'install' subcommand
exec node "$SCRIPT_DIR/bin/stetkeep.js" install "$@"
