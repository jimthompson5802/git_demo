# Demo: Git workflows for data scientists (no notebooks)

This file is a step-by-step script you can follow during a live demo. Commands are copy/paste ready and assume you're using bash on macOS.

Safety first
- Run this demo in a disposable directory (example uses `~/git-demo`). Nothing in this demo will modify your other projects.

Prerequisites
- git installed
- Python 3 available (for running the tiny scripts in `src/`)

Start a disposable demo repo

```bash
# Create disposable folder and initialize git
mkdir -p ~/git-demo && cd ~/git-demo
git init

# Create a README and initial commit
echo "# Git demo" > README.md
git add README.md
git commit -m "Initial scaffold: README"
```

Learning objective: create a canonical `main` (actually `master`/`main` depending on your git defaults) branch with a baseline commit.


Ensure the tiny reproducible scripts exist in `src/`

This demo assumes the repository already contains the three tiny Python scripts in `src/`:

- `src/hello.py` — prints: Hello world
- `src/greet_variant.py` — prints: Hello from feature/greeting
- `src/experiment.py` — prints: Experiment run — seed=42 — OK

If you cloned this demo repo, these files are already present. If you're working from an empty demo folder, create or copy these files into `src/` before proceeding. You can verify presence with:

```bash
ls -la src
```

If the files are present and uncommitted, add and commit them now:

```bash
git add src
git commit -m "Add tiny deterministic demo scripts"
```

Verify reproducible outputs

```bash
python3 src/hello.py
python3 src/greet_variant.py
python3 src/experiment.py
```

Expected output (each on its own line):

```
Hello world
Hello from feature/greeting
Experiment run — seed=42 — OK
```

Learning objective: each commit contains files that produce deterministic outputs you can reproduce later.

Create two parallel branches (isolated workstreams)

```bash
# Branch A: greeting
git checkout -b feature/greeting
echo "Hello from feature/greeting (v1)" > src/greet_msg.txt
git add src/greet_msg.txt
git commit -m "feature/greeting: add message file"

# Switch back to main and create branch B
git checkout main
git checkout -b feature/experiment
echo "Experiment param=alpha" > src/experiment_params.txt
git add src/experiment_params.txt
git commit -m "feature/experiment: add params"
```

Learning objective: two separate branches hold unrelated changes; no conflicts yet.

Demonstrate local parallelism with worktrees (optional)

```bash
# Preferred: create a new worktree and a new branch there based off main
# This avoids the common failure mode where the branch is already checked out
# in the current worktree.
git checkout main
git worktree add ../wt-experiment -b feature/experiment main
# This creates a new working copy at ../wt-experiment with the branch
# `feature/experiment` checked out. Work in that directory independently.

# Alternative: if the branch already exists but is not checked out elsewhere,
# you can create a worktree that checks it out directly:
# git worktree add ../wt-experiment feature/experiment

# You now have two working copies: this directory (main or feature/greeting)
# and ../wt-experiment (feature/experiment).
```

Run the scripts in both working copies (open two terminals) to show independent states.

Note about a common failure mode

- If you try to `git worktree add` a branch that's already checked out in the
	current worktree, git will refuse with an error like:

	"fatal: 'feature/experiment' is already used by worktree at '/path/to/repo'"

- To avoid that, either create the branch in the new worktree with `-b` (as
	shown above), or ensure the branch is not currently checked out in this
	repository before creating the worktree.

Merge flow and intentional conflict

```bash
# Merge feature/greeting into main
git checkout main
git merge --no-ff feature/greeting -m "Merge feature/greeting"

# Now attempt to merge feature/experiment — create a deliberate conflict by editing the same file
echo "Shared line: change by main" > shared.txt
git add shared.txt && git commit -m "main: add shared file"

# Now on feature/experiment change the same file
git checkout feature/experiment
echo "Shared line: change by experiment" > shared.txt
git add shared.txt && git commit -m "feature/experiment: modify shared file"

# Try to merge feature/experiment into main to produce a conflict
git checkout main
git merge feature/experiment || true

# At this point git will report a conflict. Inspect status:
git status

# Resolve the conflict: open shared.txt, edit to a combined final value, then add and commit
echo "Shared line: resolved combined change" > shared.txt
git add shared.txt
git commit -m "Resolve conflict between main and feature/experiment"
```

Learning objective: show conflict detection, manual resolution, and the importance of re-running your quick reproducibility checks after merges.

Verify outputs after merge

```bash
python3 src/hello.py
python3 src/greet_variant.py
python3 src/experiment.py
```

Tagging a release

```bash
git tag -a v0.1 -m "demo v0.1"
git show v0.1
```

Reproducing an earlier state

```bash
# View commit history and pick a commit hash
git log --oneline
# Check out an older commit in detached HEAD to inspect files at that point
git checkout <commit-hash>
# Run the scripts as they existed at that commit (if the scripts existed there)
python3 src/hello.py
```

Wrap-up checklist

- You demonstrated isolated branches and local worktrees
- You reproduced deterministic outputs from scripts tied to commits
- You handled a merge conflict and re-verified outputs
- You created a tag for a demo release point

Cheat sheet (commands used)

- git init, git add, git commit
- git checkout -b <branch>
- git worktree add <path> <branch>
- git merge <branch>
- git status, git log --oneline
- git tag -a v0.1 -m "msg"

Troubleshooting tips
- If `git merge` stops with conflicts, `git status` shows conflicted files. Edit them, then `git add` and `git commit`.
- If you want to run the demo multiple times, delete `~/git-demo` and start again.

Optional next steps (for future demos)
- Add a CI check that runs `python3 src/*.py` on PRs
- Add tiny unit tests if you want automated verification
- Introduce data versioning (DVC) if you need to demonstrate dataset reproducibility
