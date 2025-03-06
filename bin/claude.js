#!/usr/bin/env node

// Simple wrapper script that calls the claude-code binary
const path = require("path");
const { spawn } = require("child_process");

// Find the path to the actual claude-code binary
const claudeCodePath = path.resolve(
  __dirname,
  "../node_modules/@anthropic-ai/claude-code/cli.mjs"
);

// Forward all arguments to the actual binary
const args = process.argv.slice(2);
const claudeProcess = spawn(claudeCodePath, args, { stdio: "inherit" });

// Handle process exit
claudeProcess.on("exit", (code) => {
  process.exit(code);
});
