# GitHub Copilot Agent Workspace

## Install Instructions

1. Clone the repository and move its contents into the local agents folder in one cross-platform command:

```bash
git clone https://github.com/MythEclipse/gh-copilot-agent.git && node -e "const {execSync}=require('child_process'); const os=require('os'); const path=require('path'); const fs=require('fs'); const src='gh-copilot-agent'; const dst=path.join(os.homedir(), '.copilot', 'agents'); const copy=(src,dst)=>{ if (!fs.existsSync(dst)) fs.mkdirSync(dst,{recursive:true}); for (const name of fs.readdirSync(src,{withFileTypes:true})){ const s=path.join(src,name.name); const d=path.join(dst,name.name); if (name.isDirectory()) copy(s,d); else if (name.isFile()) fs.copyFileSync(s,d); }}; copy(src,dst);"
```

2. Confirm the agent files are present in `~/.copilot/agents`.

## Notes

- This directory holds the local agent definitions used by the Copilot environment.
- Update the files in `~/.copilot/agents` as needed for custom behavior.
