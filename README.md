# Git for Data Scientists — Mini Demo

This repository is a tiny demo scaffold to teach git workflows for data scientists without notebooks.

Goals
- Demonstrate isolated workstreams using branches and worktrees
- Show reproducibility by tying simple deterministic script outputs to commits
- Practice collaboration flows, merges, and conflict resolution

What is included (created by the assistant on request)
- `src/` — three tiny Python scripts that print deterministic messages
- `docs/demo_git_sequence.md` — step-by-step commands to run during a live demo
- `.gitignore` — basic ignores for Python macOS

How to run the scripts locally
```bash
python3 src/hello.py
python3 src/greet_variant.py
python3 src/experiment.py
```

When you're ready to run the full git demo, follow the script in `docs/demo_git_sequence.md`.

---
Notes: no tests, no Docker, and no data versioning are included — this keeps the demo minimal and fast.
