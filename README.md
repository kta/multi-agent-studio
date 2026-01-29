# multi-agent-studio

<div align="center">

**Professional AI Team Orchestration with Claude Code**

*Efficiently manage multiple AI agents in a professional team structure*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai)
[![tmux](https://img.shields.io/badge/tmux-required-green)](https://github.com/tmux/tmux)

[English](README.md) | [日本語](README_ja.md)

</div>

---

## What is this?

**multi-agent-studio** is a system that runs multiple Claude Code instances simultaneously, orchestrating them as a Silicon Valley-style professional team.

**Why use it?**
- Execute 4 AI workers in parallel with a single command
- No waiting - issue next commands while tasks run in background
- AI remembers your preferences across sessions (Memory MCP)
- Real-time progress tracking via status board

```
  Product Owner (You)
           │
           ▼ Instructions
    ┌──────────────┐
    │      PM      │  ← Project Manager (Orchestration & Delegation)
    └──────┬───────┘
           │ YAML Files + tmux
     ┌──┬──┴──┬──┐
     │E1│E2 E3│ D │  ← Team Members (Parallel Execution)
     └──┴─────┴──┘
   Engineer 1-3  Designer
```

---

## 🚀 Quick Start

### 🍎 Mac Users

<table>
<tr>
<td width="60">

**Step 1**

</td>
<td>

📥 **Download Repository**

[Download ZIP](https://github.com/yohey-w/multi-agent-studio/archive/refs/heads/main.zip) and extract to `~/multi-agent-studio`

*Or use git:* `git clone https://github.com/yohey-w/multi-agent-studio.git ~/multi-agent-studio`

</td>
</tr>
<tr>
<td>

**Step 2**

</td>
<td>

💻 **Open Terminal and run:**

```bash
cd ~/multi-agent-studio
./install.sh
```

The installer handles everything automatically.

</td>
</tr>
<tr>
<td>

**Step 3**

</td>
<td>

✅ **Done!** 5 AI agents are now running.

</td>
</tr>
</table>

#### 📅 Daily Startup (After Initial Installation)

Open **Terminal** and run:

```bash
cd ~/multi-agent-studio
./startup.sh
```

---

---

## Team Structure

| Role | Description | Count |
|------|-------------|-------|
| 🎯 PM | Project Manager - Receives instructions, delegates tasks | 1 (Opus) |
| 👨‍💻 Engineer | Engineers - Development, testing, infrastructure | 3 (Sonnet) |
| 🎨 Designer | Designer - UI/UX, documentation | 1 (Sonnet) |

**Total: 5 Agents**

### tmux Session Configuration

- `team` - 5 pane configuration
  - `team:0.0` → PM (Opus)
  - `team:0.1` → Engineer 1 (Sonnet)
  - `team:0.2` → Engineer 2 (Sonnet)
  - `team:0.3` → Engineer 3 (Sonnet)
  - `team:0.4` → Designer (Sonnet)

---

## 📝 Basic Usage

### Step 1: Connect to tmux Session

```bash
tmux attach-session -t team
```

Or use alias:
```bash
pmt
```

### Step 2: Give Instructions to PM

In the PM pane (large pane on the left), give instructions:

```
Create a README for Project X.
Include setup instructions and quick start guide for beginners.
```

PM will:
1. Understand and decompose the task
2. Assign to team members
3. Update status.md

Team members execute work in parallel.

### Step 3: Check Progress

```bash
cat status.md
```

Or in another terminal:
```bash
watch -n 5 cat ~/multi-agent-studio/status.md
```

---

## 🗂️ Directory Structure

```
multi-agent-studio/
├── startup.sh                  # Daily startup script
├── setup.sh                    # Compatibility wrapper
├── install.sh                  # Mac installer
├── CLAUDE.md                   # System overview
├── README.md / README_ja.md    # Documentation
│
├── instructions/               # Agent instructions
│   ├── pm.md                   # PM instructions
│   ├── team.md                 # Team member common instructions
│   ├── engineer.md             # Engineer supplement
│   └── designer.md             # Designer supplement
│
├── config/
│   ├── settings.yaml           # Language settings, etc.
│   └── projects.yaml           # Project list
│
├── queue/
│   ├── assignments.yaml        # PM→Team assignments
│   ├── tasks/                  # Member-specific task files
│   │   ├── engineer1.yaml
│   │   ├── engineer2.yaml
│   │   ├── engineer3.yaml
│   │   └── designer.yaml
│   └── reports/                # Report files
│       ├── engineer1_report.yaml
│       ├── engineer2_report.yaml
│       ├── engineer3_report.yaml
│       └── designer_report.yaml
│
├── status/
│   └── master_status.yaml      # Overall status
│
├── memory/
│   ├── global_context.md       # Global context
│   └── pm_memory.jsonl         # Memory MCP
│
├── context/                    # Project-specific context
├── skills/                     # Generated skills
└── status.md                   # Status board
```

---

## 🎯 Real-World Examples

### Example 1: Technical Research

```
You: "Compare React, Vue, and Svelte frameworks.
      Focus on performance, learning curve, and ecosystem."

PM: Decomposes into 3 tasks
  ├─ Engineer 1 → React research
  ├─ Engineer 2 → Vue research
  └─ Engineer 3 → Svelte research

→ 3 engineers start research simultaneously
→ After 15 minutes, all reports complete
→ PM consolidates and updates status.md
```

### Example 2: Web App Development

```
You: "Create a ToDo app.
      Use React + TypeScript + TailwindCSS."

PM: Decomposes tasks
  ├─ Engineer 1 → Backend API
  ├─ Engineer 2 → Frontend implementation
  ├─ Engineer 3 → Test creation
  └─ Designer → UI/UX design

→ 4 members work in parallel
→ PM manages progress integration
```

---

## ⚙️ Configuration

### Language Settings

`config/settings.yaml`:

```yaml
language: ja  # ja, en, es, zh, ko, fr, de, etc.
```

- **ja**: Business polite Japanese only
- **Others**: Japanese + translation in parentheses

### Project Management

Define projects in `config/projects.yaml`:

```yaml
projects:
  - id: project-x
    name: "Project X"
    description: "New web app development"
    context_file: "context/project-x.md"
```

### Skills

Repetitive patterns are automatically suggested as skill candidates.

---

## 🔧 Troubleshooting

### Can't connect to tmux session

```bash
# Check session list
tmux list-sessions

# If session doesn't exist, restart
./startup.sh
```

### Agent not responding

```bash
# Check tmux pane status
tmux capture-pane -t team:0.0 -p | tail -20

# Restart if needed
tmux kill-session -t team
./startup.sh
```

---

## 📚 Advanced Features

### Memory MCP

- AI retains memory across sessions
- `memory/global_context.md`: System-wide settings & preferences
- `memory/pm_memory.jsonl`: Memory MCP data

### Context Management

Store project-specific information in `context/{project}.md`:

```markdown
# Project X Context

## Tech Stack
- Frontend: React + TypeScript
- Backend: Node.js + Express
- Database: PostgreSQL

## Coding Standards
- Use ESLint + Prettier
- 80%+ test coverage required
```

### Skill Generation

When repetitive patterns are detected, PM suggests skill creation:

```yaml
skill_candidate:
  name: "api-endpoint-generator"
  description: "Auto-generate RESTful API endpoints"
  found: true
```

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

## 🙏 Acknowledgments

- [Claude Code](https://claude.ai) by Anthropic
- [tmux](https://github.com/tmux/tmux)
- [Memory MCP](https://github.com/anthropics/anthropic-quickstarts/tree/main/mcp-memory)

---

## 📞 Support

- Issues: [GitHub Issues](https://github.com/yohey-w/multi-agent-studio/issues)
- Discussions: [GitHub Discussions](https://github.com/yohey-w/multi-agent-studio/discussions)

---

<div align="center">

**Multi-Agent Studio** - Professional AI Team Orchestration

Made with ❤️ by the community

</div>
