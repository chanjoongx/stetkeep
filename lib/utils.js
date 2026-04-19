// Minimal logging helpers — no external deps.
// ANSI color codes work on modern terminals; gracefully ignored by older ones.

const c = {
  reset:  '\x1b[0m',
  dim:    '\x1b[2m',
  red:    '\x1b[31m',
  green:  '\x1b[32m',
  yellow: '\x1b[33m',
  cyan:   '\x1b[36m',
  magenta:'\x1b[35m'
};

const supportsColor = process.stdout.isTTY && process.env.NO_COLOR !== '1';
const paint = (color, s) => supportsColor ? `${c[color]}${s}${c.reset}` : s;

export const log = {
  header: msg => console.log(paint('cyan', msg)),
  info:   msg => console.log(msg),
  copy:   msg => console.log(paint('green', `  ${msg}`)),
  merge:  msg => console.log(paint('green', `  ${msg}`)),
  skip:   msg => console.log(paint('dim', `  ${msg}`)),
  warn:   msg => console.log(paint('yellow', `⚠ ${msg}`)),
  error:  msg => console.error(paint('red', `✗ ${msg}`)),
  blank:  ()  => console.log(''),
  rule:   ()  => console.log(paint('dim', '─'.repeat(37)))
};
