#!/usr/bin/env node
// stet is a shorthand alias for stetkeep.
// This proxy forwards invocation to stetkeep's real CLI entry point.
// Canonical package: https://www.npmjs.com/package/stetkeep

import { spawn } from 'node:child_process';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const stetkeepBin = require.resolve('stetkeep/bin/stetkeep.js');

const child = spawn(process.execPath, [stetkeepBin, ...process.argv.slice(2)], {
  stdio: 'inherit',
});

child.on('exit', (code, signal) => {
  if (signal) process.kill(process.pid, signal);
  else process.exit(code ?? 0);
});
