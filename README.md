# GitHub Copilot Agent Workspace

## Install Instructions

1. Clone the repository and move its contents into the local agents folder in one command:

```bash
git clone https://github.com/MythEclipse/gh-copilot-agent.git && rsync -a gh-copilot-agent/. ~/.copilot/agents/
```

2. Confirm the agent files are present in `~/.copilot/agents`.

## Notes

- This directory holds the local agent definitions used by the Copilot environment.
- Update the files in `~/.copilot/agents` as needed for custom behavior.
