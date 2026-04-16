#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_DIR="$ROOT_DIR/.vscode"
GITHUB_HOOKS_DIR="$ROOT_DIR/.github/hooks"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required. Install Node.js/npm first."
  exit 1
fi

if ! command -v context-mode >/dev/null 2>&1; then
  echo "Installing context-mode globally..."
  npm install -g context-mode
else
  echo "context-mode already installed."
fi

mkdir -p "$VSCODE_DIR" "$GITHUB_HOOKS_DIR"

cat > "$VSCODE_DIR/mcp.json" <<'EOF'
{
  "servers": {
    "context-mode": {
      "command": "context-mode"
    }
  }
}
EOF

cat > "$GITHUB_HOOKS_DIR/context-mode.json" <<'EOF'
{
  "hooks": {
    "PreToolUse": [
      { "type": "command", "command": "context-mode hook vscode-copilot pretooluse" }
    ],
    "PostToolUse": [
      { "type": "command", "command": "context-mode hook vscode-copilot posttooluse" }
    ],
    "SessionStart": [
      { "type": "command", "command": "context-mode hook vscode-copilot sessionstart" }
    ]
  }
}
EOF

echo "context-mode installed and configuration files created:"
echo "  $VSCODE_DIR/mcp.json"
echo "  $GITHUB_HOOKS_DIR/context-mode.json"
