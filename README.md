# GitHub Copilot Agent Workspace

## Install Instructions

1. Clone the repository and move its contents into the local agents folder in one cross-platform command:

```bash
git clone https://github.com/MythEclipse/gh-copilot-agent.git && node -e "const {execSync}=require('child_process'); const os=require('os'); const path=require('path'); const fs=require('fs'); const src='gh-copilot-agent'; const dst=path.join(os.homedir(), '.copilot', 'agents'); const copy=(src,dst)=>{ if (!fs.existsSync(dst)) fs.mkdirSync(dst,{recursive:true}); for (const name of fs.readdirSync(src,{withFileTypes:true})){ const s=path.join(src,name.name); const d=path.join(dst,name.name); if (name.isDirectory()) copy(s,d); else if (name.isFile()) fs.copyFileSync(s,d); }}; copy(src,dst);"
```

2. Confirm the agent files are present in `~/.copilot/agents`.

3. Run `setup-context-mode.sh` from the repository root to install and configure context-mode globally.

## Context-mode Setup

This workspace includes a one-shot context-mode bootstrap script and the required editor/hook files:

- `.vscode/mcp.json`
- `.github/hooks/context-mode.json`
- `setup-context-mode.sh`

To install context-mode and register the VS Code server/hook config, run:

```bash
./setup-context-mode.sh
```

If `context-mode` is already installed, the script will skip reinstalling it.

## Code Review Graph Integration

If you want Copilot to use the local `code-review-graph` knowledge graph, install it in `~/.copilot/code-review-graph` and then register it as an MCP server.

From the repository root:

```bash
cd ~/.copilot/code-review-graph
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip setuptools wheel
.venv/bin/python -m pip install -e .
.venv/bin/code-review-graph install --yes
.venv/bin/code-review-graph build
```

Then add this MCP server entry to your VS Code MCP config (or use the agents workspace `.vscode/mcp.json`):

```json
{
  "servers": {
    "code-review-graph": {
      "type": "stdio",
      "command": "/home/asephs/.copilot/code-review-graph/.venv/bin/code-review-graph",
      "args": ["serve"]
    }
  }
}
```

Restart VS Code after updating MCP config so the new server is picked up.

## Notes

- This directory holds the local agent definitions used by the Copilot environment.
- Update the files in `~/.copilot/agents` as needed for custom behavior.
- Global protocol source for all projects: `~/.copilot/agents/docs/PROTOCOL.md`.
- Project `docs/PROTOCOL.md` is optional overlay, not required for first run.

## Workflow V2 Quick Start

This workspace now uses a strict state-machine protocol in `docs/PROTOCOL.md`:

`DISCOVERED -> SPEC_READY -> CODED -> AUDIT_PASS -> TEST_PASS -> RELEASE_READY -> DONE`

Before implementation dispatch, complete dependency preflight in `docs/dependency-map.md`.

No manual setup is required in each project.
Orchestrator automatically bootstraps required workflow files on first run.

Protocol loading behavior in new projects:

1. Read global protocol from `~/.copilot/agents/docs/PROTOCOL.md`.
2. If project has `docs/PROTOCOL.md`, use it as overlay.
3. If rules conflict, stricter rule wins.

Machine-readable artifacts used by Orchestrator:

- `docs/handoff-envelope.schema.json`
- `docs/todo.template.md`
- `docs/workflow-state.template.json`
- `docs/quality-gates.template.json`
- `docs/handoff-log.template.jsonl`
- `docs/observability-template.md`

Runtime artifacts auto-created in target projects:

- `docs/todo.md`
- `docs/dependency-map.md`
- `docs/workflow-state.json`
- `docs/quality-gates.json`
- `docs/handoff-log.jsonl`
- `docs/observability.md`
