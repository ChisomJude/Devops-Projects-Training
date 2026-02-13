# Git and GitHub -- The Complete Beginner's Guide

## What is Version Control?

Imagine you are writing a report. You save it as `report_v1.docx`, then make changes and save `report_v2.docx`, then `report_final.docx`, then `report_final_FINAL.docx`. You have been there. Everyone has.

Version control solves this problem for code. It is a system that records every change you make to your files over time, so you can go back to any previous version, see who changed what, and collaborate with others without overwriting each other's work.

Without version control, teams working on the same codebase would constantly overwrite each other's changes, lose work, and have no way to trace when or why a bug was introduced. With version control, every change is tracked, every version is preserved, and multiple people can work on the same project simultaneously without chaos.

Git is the most widely used version control system in the world. It is used by individual developers, startups, and every major tech company.

---

## What is Git?

Git is a **distributed version control system** created by Linus Torvalds in 2005 (the same person who created Linux). It runs on your local machine and tracks every change you make to your project files.

The word "distributed" is important. It means every developer has a **complete copy** of the entire project history on their own machine. You do not need an internet connection to use Git. You can commit changes, create branches, view history, and do almost everything offline. You only need the internet when you want to share your changes with others.

Git works by taking snapshots of your project every time you "commit." Each snapshot records the state of every file at that moment. Git does not store duplicate copies of unchanged files -- it is smart enough to reference the previous version, making it extremely efficient.

---

## What is GitHub?

GitHub is a **web-based platform** that hosts Git repositories online. Think of it as a social network for code. It takes Git's local version control and adds a collaborative layer on top: you can share repositories, review each other's code, track bugs, manage projects, and automate workflows.

GitHub is not the only platform that hosts Git repositories. GitLab and Bitbucket are alternatives. But GitHub is by far the most popular, with over 100 million developers and the largest open-source community in the world.

Key things GitHub adds on top of Git: a visual web interface for browsing code and history, Pull Requests for code review, Issues for tracking bugs and feature requests, GitHub Actions for CI/CD automation, GitHub Pages for hosting static websites, and a massive ecosystem of integrations.

---

## Git vs GitHub -- The Difference

This is one of the most common points of confusion for beginners, so let it be absolutely clear.

**Git** is the tool. It runs on your computer. It tracks changes to your files. It works entirely offline. You interact with it through the terminal (command line).

**GitHub** is the platform. It lives on the internet. It stores your Git repositories in the cloud so others can access them. It adds collaboration features that Git alone does not have.

You can use Git without GitHub. You cannot use GitHub without Git (because GitHub is built on top of Git).

An analogy: Git is like Microsoft Word's "Track Changes" feature. GitHub is like Google Drive where you upload your Word document so others can see it and collaborate.

---

## Installing Git

### On Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install git
```

### On macOS

Git comes pre-installed on most Macs. If not, install it via Homebrew:

```bash
brew install git
```

### On Windows

Download the installer from [git-scm.com](https://git-scm.com/downloads) and run it. During installation, accept the defaults. This installs Git along with Git Bash, a terminal that lets you use Unix-style commands on Windows.

### Verify Installation

After installing, open your terminal and run:

```bash
git --version
```

You should see something like `git version 2.43.0`. The exact number does not matter as long as the command works.

---

## Configuring Git for the First Time

Before you start using Git, you need to tell it who you are. This information is attached to every commit you make, so your team knows who made each change.

```bash
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"
```

The `--global` flag means this applies to all repositories on your machine. If you want different credentials for a specific project, run the same commands without `--global` inside that project's folder.

### Set Your Default Branch Name

By convention, the default branch is now called `main` (it used to be `master`). Set this so every new repository you create uses `main`:

```bash
git config --global init.defaultBranch main
```

### Set Your Default Editor

Git sometimes opens a text editor (for example, during a merge). By default, it uses Vim, which can be confusing for beginners. You can change it:

```bash
git config --global core.editor "nano"       # Simple terminal editor
git config --global core.editor "code --wait" # VS Code
```

### Verify Your Configuration

```bash
git config --list
```

This shows all your Git settings.

---

## Core Concepts You Must Understand

Before running any commands, internalize these concepts. They are the mental model that makes everything else click.

### Repository (Repo)

A repository is a project folder that Git is tracking. It contains your project files plus a hidden `.git` folder where Git stores all its tracking data (history, branches, configuration). When you hear "repo," think "project."

### Commit

A commit is a snapshot of your project at a specific point in time. Every commit has a unique ID (a long hash like `a1b2c3d4`), a message describing what changed, the author's name, and a timestamp. Commits are the building blocks of your project's history. You can think of each commit as a save point in a video game -- you can always go back to it.

### Branch

A branch is an independent line of development. The default branch is `main`. When you create a new branch, you are creating a copy of the current state of the code where you can make changes without affecting `main`. When your changes are ready, you merge the branch back. Branches are what allow teams to work on multiple features simultaneously.

### Remote

A remote is a version of your repository that lives somewhere else, usually on GitHub. Your local repo and the remote repo stay in sync through `push` (uploading your changes) and `pull` (downloading others' changes). The default remote is conventionally named `origin`.

### HEAD

HEAD is a pointer to the commit you are currently on. Most of the time, HEAD points to the latest commit on your current branch. When you switch branches, HEAD moves to point to the latest commit on the new branch.

---

## The Three Stages of Git

This is one of the most important concepts in Git. Every file in a Git repository exists in one of three stages.

### 1. Working Directory

This is your actual project folder -- the files you see and edit. When you modify a file, the change exists only in your working directory. Git knows the file changed, but it has not recorded it yet.

### 2. Staging Area (Index)

The staging area is a holding zone between your working directory and the repository. When you run `git add`, you move changes from the working directory to the staging area. This is where you prepare your next commit. You decide exactly which changes to include.

The staging area exists because you do not always want to commit everything at once. Maybe you changed five files but only want to commit three of them right now. The staging area gives you that control.

### 3. Repository (Commit History)

When you run `git commit`, everything in the staging area is saved as a permanent snapshot in the repository. This commit becomes part of your project's history and can never be accidentally lost (as long as you do not explicitly delete it).

### The Flow

```
Working Directory  -->  Staging Area  -->  Repository
                                        
   (edit files)      (git add)          (git commit)
```

This three-stage process is what makes Git powerful. It gives you granular control over what gets saved and when.

---

## Essential Git Commands (With Explanations)

### Starting a New Repository

```bash
git init
```

This creates a new Git repository in the current folder. It adds a hidden `.git` directory that contains all of Git's tracking data. Run this once when starting a new project. You do not run `git init` inside a folder that is already a Git repository.

### Checking the Status of Your Repo

```bash
git status
```

This is the command you will run most often. It tells you which files have been modified, which are staged for commit, which are untracked (new files Git does not know about yet), and which branch you are on. Get in the habit of running `git status` before and after every operation.

### Staging Changes

```bash
# Stage a specific file
git add filename.py

# Stage multiple specific files
git add file1.py file2.py file3.py

# Stage all changes in the current directory and subdirectories
git add .

# Stage all changes in the entire repository
git add -A
```

`git add` moves changes from the working directory to the staging area. It does not save them permanently yet. Think of it as putting items in a box before sealing it.

The difference between `git add .` and `git add -A` is subtle: `git add .` stages changes in the current directory and below, while `git add -A` stages changes across the entire repository regardless of where you are.

### Committing Changes

```bash
git commit -m "Add user authentication feature"
```

This takes everything in the staging area and saves it as a permanent snapshot. The `-m` flag lets you write the commit message inline. Every commit must have a message. If you run `git commit` without `-m`, Git opens your configured text editor so you can write a longer message.

**Writing good commit messages matters.** Your future self and your teammates will read these. A message like "fix stuff" is useless. A message like "Fix null pointer error in payment processing module" is clear and helpful.

### Staging and Committing in One Step

```bash
git commit -am "Update login validation logic"
```

The `-a` flag automatically stages all **modified and deleted** files before committing. It does not stage new (untracked) files. This is a shortcut for when you want to commit all changes quickly.

### Viewing Differences

```bash
# See what changed in your working directory (not yet staged)
git diff

# See what is staged and ready to be committed
git diff --staged

# See differences between two branches
git diff main feature-branch
```

`git diff` shows you the exact lines that were added or removed. Green lines (prefixed with `+`) are additions. Red lines (prefixed with `-`) are deletions.

### Removing Files

```bash
# Remove a file from Git tracking AND delete it from disk
git rm filename.py

# Remove a file from Git tracking but keep it on disk
git rm --cached filename.py
```

The `--cached` option is useful when you accidentally committed a file (like a config file with passwords) and want Git to stop tracking it without deleting the actual file.

### Renaming or Moving Files

```bash
git mv old_name.py new_name.py
```

This renames the file and stages the change in one step. It is equivalent to running `mv`, `git rm`, and `git add` separately.

---

## Branching -- The Most Important Git Feature

Branching is what makes Git truly powerful. A branch lets you diverge from the main line of development and work independently without affecting anyone else.

### Why Branches Matter

Imagine you and two teammates are all working on the same project. Without branches, every change anyone makes immediately affects everyone. One person's half-finished feature could break another person's work.

With branches, each person works on their own branch. The `main` branch stays stable and deployable. When a feature is complete and tested, it gets merged back into `main`.

### Creating a Branch

```bash
# Create a new branch
git branch feature/user-login

# Create a new branch AND switch to it immediately
git checkout -b feature/user-login

# Modern alternative (Git 2.23+)
git switch -c feature/user-login
```

When you create a branch, it starts as an exact copy of whatever branch you were on. From that point forward, the two branches diverge independently.

### Switching Between Branches

```bash
# Classic syntax
git checkout main

# Modern syntax (Git 2.23+)
git switch main
```

When you switch branches, Git updates all the files in your working directory to match the state of that branch. It is like teleporting between parallel universes of your code.

**Important:** You should commit or stash your changes before switching branches. If you have uncommitted changes, Git may prevent you from switching or may carry those changes to the new branch, which can cause confusion.

### Listing Branches

```bash
# List local branches (current branch has an asterisk)
git branch

# List all branches including remote ones
git branch -a

# List branches with their latest commit
git branch -v
```

### Deleting a Branch

```bash
# Delete a branch that has been merged
git branch -d feature/user-login

# Force delete a branch (even if not merged -- use with caution)
git branch -D feature/user-login
```

### Renaming a Branch

```bash
# Rename the branch you are currently on
git branch -m new-name

# Rename a specific branch
git branch -m old-name new-name
```

### Branch Naming Conventions

Professional teams follow naming conventions to keep branches organized. Common patterns include:

```
feature/user-authentication    -- New features
bugfix/fix-payment-crash       -- Bug fixes
hotfix/security-patch          -- Urgent production fixes
release/v2.1.0                 -- Release preparation
chore/update-dependencies      -- Maintenance tasks
```

The forward slash creates a visual grouping. This is a convention, not a Git requirement.

---

## Merging Branches

Once you finish working on a branch, you bring those changes back into another branch (usually `main`). This is called merging.

### Basic Merge

```bash
# Step 1: Switch to the branch you want to merge INTO
git checkout main

# Step 2: Merge the feature branch into main
git merge feature/user-login
```

This takes all the commits from `feature/user-login` and integrates them into `main`.

### Types of Merges

**Fast-Forward Merge.** This happens when `main` has not changed since you created the feature branch. Git simply moves the `main` pointer forward to the latest commit on the feature branch. No new commit is created. The history is a straight line.

```
Before:
main:    A -- B
                \
feature:         C -- D

After (fast-forward):
main:    A -- B -- C -- D
```

**Three-Way Merge.** This happens when both branches have new commits since they diverged. Git creates a new "merge commit" that combines both lines of work.

```
Before:
main:    A -- B -- E
                \
feature:         C -- D

After (three-way merge):
main:    A -- B -- E -- M  (M is the merge commit)
                \       /
feature:         C -- D
```

### Merge vs Rebase

An alternative to merging is rebasing. Instead of creating a merge commit, `git rebase` replays your branch's commits on top of the target branch, creating a linear history.

```bash
# While on your feature branch:
git rebase main
```

```
Before:
main:    A -- B -- E
                \
feature:         C -- D

After rebase:
main:    A -- B -- E
                     \
feature:              C' -- D'  (same changes, new commits)
```

The result is a cleaner, linear history. The trade-off is that rebase rewrites commit history (creates new commit hashes), so you should **never rebase commits that have already been pushed and shared with others**. Use rebase for local cleanup before pushing. Use merge for shared branches.

---

## Handling Merge Conflicts

A merge conflict happens when two branches modify the **same lines** of the **same file**. Git cannot decide which version to keep, so it asks you to resolve it manually.

### What a Conflict Looks Like

When a conflict occurs, Git marks the conflicting sections in the file:

```
def get_greeting():
<<<<<<< HEAD
    return "Hello, World!"
=======
    return "Hi there!"
>>>>>>> feature/new-greeting
```

The section between `<<<<<<< HEAD` and `=======` is the version on your current branch. The section between `=======` and `>>>>>>> feature/new-greeting` is the version from the branch you are merging in.

### How to Resolve a Conflict

1. **Open the file** and find the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).

2. **Choose which version to keep**, or combine both, or write something entirely new. Delete the conflict markers when you are done.

```python
def get_greeting():
    return "Hi there!"   # Chose the incoming version
```

3. **Stage the resolved file.**

```bash
git add filename.py
```

4. **Complete the merge.**

```bash
git commit -m "Resolve merge conflict in get_greeting function"
```

### Aborting a Merge

If a conflict is too complex and you want to start over:

```bash
git merge --abort
```

This cancels the merge and returns everything to the state it was in before you started.

### Preventing Conflicts

Pull frequently from the shared branch so your branch does not drift too far. Keep branches short-lived and focused on a single feature. Communicate with your team about who is working on which files.

---

## Working With Remote Repositories

A remote repository is a version of your project hosted on a server (like GitHub). It is how you share your code with others and keep backups of your work.

### Adding a Remote

```bash
git remote add origin https://github.com/yourusername/your-repo.git
```

`origin` is the conventional name for your primary remote. You can name it anything, but almost everyone uses `origin`. The URL points to the GitHub repository.

### Viewing Remotes

```bash
# List remote names
git remote

# List remotes with their URLs
git remote -v
```

### Pushing Changes to GitHub

```bash
# Push your current branch to the remote
git push origin main

# Push and set upstream (so future pushes only need 'git push')
git push -u origin main
```

The first time you push a branch, use `-u` (or `--set-upstream`). This creates a tracking relationship between your local branch and the remote branch. After that, you can just run `git push` without specifying the remote and branch name.

### Pulling Changes From GitHub

```bash
git pull origin main
```

`git pull` does two things in sequence: it runs `git fetch` (downloads new data from the remote) and then `git merge` (integrates those changes into your current branch). If someone else pushed changes to `main` on GitHub, `git pull` brings those changes to your local machine.

### Fetch vs Pull

```bash
# Fetch: download remote data but do NOT merge it
git fetch origin

# Pull: download remote data AND merge it
git pull origin main
```

`git fetch` is the safe version. It downloads updates so you can inspect them before merging. `git pull` is the convenient version that does both at once. Use `fetch` when you want to see what changed before integrating it.

### Pushing a New Branch to GitHub

```bash
# Create a branch locally, push it to GitHub
git checkout -b feature/new-dashboard
# ... make changes, commit ...
git push -u origin feature/new-dashboard
```

This creates the branch on GitHub and sets up tracking.

### Deleting a Remote Branch

```bash
git push origin --delete feature/old-branch
```

This removes the branch from GitHub. Your local copy remains until you delete it with `git branch -d`.

---

## Connecting Git to GitHub

### Creating a New Repository on GitHub

1. Go to [github.com](https://github.com) and sign in.
2. Click the **+** icon in the top right, then **New repository**.
3. Give it a name, choose public or private, and optionally add a README.
4. Click **Create repository**.

GitHub will show you commands to connect your local project. The two most common scenarios:

### Scenario 1: You Have an Existing Local Project

```bash
cd your-project-folder
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/your-repo.git
git push -u origin main
```

### Scenario 2: You Want to Download an Existing GitHub Repo

```bash
git clone https://github.com/yourusername/your-repo.git
cd your-repo
```

`git clone` downloads the entire repository including all history, branches, and files. It also automatically sets up `origin` pointing to the GitHub URL.

---

## Cloning, Forking, and Pull Requests

These three concepts are central to how collaboration works on GitHub.

### Cloning

Cloning creates a local copy of a remote repository on your machine.

```bash
git clone https://github.com/someuser/some-repo.git
```

You clone when you want to work on a repository you have access to (your own or your team's). You get a full copy with all branches and history.

### Forking

Forking creates a copy of someone else's repository **under your own GitHub account**. The fork lives on GitHub, not on your local machine. You then clone your fork to work on it locally.

Forking is used when you want to contribute to a project you do not own. You cannot push directly to someone else's repository, but you can fork it, make changes in your fork, and then ask the original owner to accept your changes through a pull request.

```
Original repo (owned by someone else)
        |
        | Fork (creates a copy under your account)
        v
Your fork (your-username/repo-name)
        |
        | Clone (download to your machine)
        v
Your local copy
```

### Pull Requests (PRs)

A Pull Request is a proposal to merge changes from one branch into another. On GitHub, pull requests are the primary mechanism for code review and collaboration.

The typical workflow is:

1. Create a branch for your feature.
2. Make your changes and push the branch to GitHub.
3. Open a Pull Request on GitHub comparing your branch to `main`.
4. Teammates review your code, leave comments, and request changes.
5. You address the feedback by pushing more commits to the same branch.
6. Once approved, the PR is merged into `main`.

Pull requests are not a Git feature -- they are a GitHub (and similar platform) feature. They provide a structured way to review code, discuss changes, and maintain quality before anything reaches the main branch.

### Contributing to Open Source (The Full Flow)

```bash
# 1. Fork the repo on GitHub (click the Fork button)

# 2. Clone YOUR fork
git clone https://github.com/your-username/forked-repo.git
cd forked-repo

# 3. Add the original repo as "upstream" so you can stay in sync
git remote add upstream https://github.com/original-owner/original-repo.git

# 4. Create a feature branch
git checkout -b fix/typo-in-readme

# 5. Make changes, stage, and commit
git add .
git commit -m "Fix typo in README installation instructions"

# 6. Push to YOUR fork
git push -u origin fix/typo-in-readme

# 7. Go to GitHub and open a Pull Request from your fork to the original repo
```

To keep your fork up to date with the original:

```bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

## The .gitignore File

Not every file in your project should be tracked by Git. Compiled binaries, dependency folders, environment files with secrets, OS-generated files, and IDE configuration files should all be excluded. The `.gitignore` file tells Git which files and folders to ignore.

### Creating a .gitignore File

Create a file named `.gitignore` in the root of your repository:

```bash
touch .gitignore
```

### Common .gitignore Patterns

```gitignore
# Environment variables and secrets -- NEVER commit these
.env
.env.local
*.pem

# Python
__pycache__/
*.pyc
*.pyo
venv/
.venv/
*.egg-info/

# Node.js
node_modules/
npm-debug.log
yarn-error.log

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
Thumbs.db

# Build outputs
dist/
build/
*.o
*.exe

# Logs
*.log
logs/

# Docker
docker-compose.override.yml

# Terraform
*.tfstate
*.tfstate.backup
.terraform/
```

### Important Rules

**`.gitignore` only works on untracked files.** If you already committed a file and then add it to `.gitignore`, Git will continue tracking it. You must explicitly remove it from tracking first:

```bash
git rm --cached filename
git commit -m "Stop tracking filename"
```

**GitHub provides templates.** When creating a new repository on GitHub, you can select a `.gitignore` template for your language (Python, Node, Java, etc.). You can also browse templates at [github.com/github/gitignore](https://github.com/github/gitignore).

**Patterns use glob syntax.** `*` matches any characters, `**` matches directories at any depth, `!` negates a pattern (force-include a file), and `/` at the start anchors to the repo root.

```gitignore
# Ignore all .log files
*.log

# But keep this specific one
!important.log

# Ignore the build folder only at the root, not in subdirectories
/build
```

---

## Git Stash -- Saving Work Without Committing

Sometimes you are in the middle of working on something and need to switch branches urgently, but your changes are not ready to commit. Git stash temporarily shelves your changes so you can work on something else, then come back and restore them later.

### Stashing Your Changes

```bash
git stash
```

This takes all your modified tracked files and staged changes, saves them on a stack, and reverts your working directory to the last commit. Your work is safe but hidden.

### Stashing With a Message

```bash
git stash push -m "Work in progress: login form validation"
```

Adding a message helps you remember what each stash contains, especially if you accumulate multiple stashes.

### Viewing Your Stashes

```bash
git stash list
```

Output looks like:

```
stash@{0}: On feature/login: Work in progress: login form validation
stash@{1}: WIP on main: a1b2c3d Update README
```

### Restoring Stashed Changes

```bash
# Apply the most recent stash and keep it in the stash list
git stash apply

# Apply the most recent stash and remove it from the stash list
git stash pop

# Apply a specific stash
git stash apply stash@{1}
```

The difference between `apply` and `pop`: `apply` restores the changes but keeps the stash as a backup. `pop` restores the changes and deletes the stash entry.

### Dropping a Stash

```bash
# Delete a specific stash
git stash drop stash@{0}

# Delete ALL stashes
git stash clear
```

---

## Undoing Mistakes in Git

Everyone makes mistakes. Git provides several ways to undo changes, depending on how far along those changes are.

### Undo Changes in the Working Directory (Before Staging)

```bash
# Discard changes to a specific file (restore it to the last commit)
git checkout -- filename.py

# Modern syntax (Git 2.23+)
git restore filename.py

# Discard ALL changes in the working directory
git restore .
```

This is irreversible. The changes are gone because they were never staged or committed.

### Unstage a File (After git add, Before Commit)

```bash
# Remove a file from the staging area, but keep the changes in working directory
git reset HEAD filename.py

# Modern syntax
git restore --staged filename.py
```

The file goes back to "modified but not staged." Your changes are preserved.

### Undo the Last Commit (Keep Changes)

```bash
git reset --soft HEAD~1
```

This undoes the most recent commit but keeps all the changes in the staging area. It is as if you never ran `git commit`. This is useful when you committed too early or need to modify the commit.

### Undo the Last Commit (Discard Changes)

```bash
git reset --hard HEAD~1
```

This undoes the last commit AND discards all the changes. The code is gone. Use this only when you are absolutely sure you do not need those changes.

### Amend the Last Commit

```bash
# Fix the commit message
git commit --amend -m "Corrected commit message"

# Add a forgotten file to the last commit
git add forgotten_file.py
git commit --amend --no-edit
```

`--amend` modifies the most recent commit instead of creating a new one. **Never amend commits that have already been pushed and shared with others**, because it rewrites history.

### Revert a Commit (Safe for Shared History)

```bash
git revert a1b2c3d4
```

Unlike `reset`, `revert` does not delete the original commit. It creates a **new commit** that undoes the changes introduced by the specified commit. This is safe to use on shared branches because it does not rewrite history.

### Summary: When to Use What

| Situation | Command | Safe for shared branches? |
|---|---|---|
| Discard working directory changes | `git restore filename` | Yes (nothing was shared) |
| Unstage a file | `git restore --staged filename` | Yes |
| Undo last commit, keep changes | `git reset --soft HEAD~1` | No |
| Undo last commit, discard changes | `git reset --hard HEAD~1` | No |
| Fix last commit message | `git commit --amend` | No |
| Undo a specific commit safely | `git revert <commit-hash>` | Yes |

---

## Git Log and History

Git keeps a complete record of every commit ever made. The `git log` command lets you browse this history.

### Basic Log

```bash
git log
```

This shows a detailed list of commits in reverse chronological order (newest first), including the commit hash, author, date, and message. Press `q` to exit.

### Compact Log (One Line Per Commit)

```bash
git log --oneline
```

This shows a shortened hash and the commit message on a single line. Much easier to scan.

```
a1b2c3d Add user authentication
e4f5g6h Fix database connection bug
i7j8k9l Initial commit
```

### Visual Branch Graph

```bash
git log --oneline --graph --all
```

This displays a visual representation of how branches diverge and merge. The `--all` flag shows all branches, not just the current one.

### Filter by Author

```bash
git log --author="Chisom"
```

### Filter by Date

```bash
git log --after="2025-01-01" --before="2025-06-01"
```

### Filter by File

```bash
git log -- filename.py
```

This shows only commits that modified the specified file.

### See What Changed in Each Commit

```bash
# Show the actual code changes (diff) for each commit
git log -p

# Show which files changed and how many lines were added/removed
git log --stat
```

### Show a Specific Commit

```bash
git show a1b2c3d4
```

This displays the full details and diff of a single commit.

---

## Tags and Releases

Tags are labels you attach to specific commits, typically used to mark release versions. Unlike branches, tags do not move -- they permanently point to one specific commit.

### Creating a Tag

```bash
# Lightweight tag (just a label)
git tag v1.0.0

# Annotated tag (includes a message, author, and date -- recommended)
git tag -a v1.0.0 -m "First stable release"
```

Annotated tags are preferred because they contain metadata and can be verified.

### Tagging a Past Commit

```bash
git tag -a v0.9.0 -m "Beta release" a1b2c3d4
```

### Listing Tags

```bash
git tag

# Filter by pattern
git tag -l "v2.*"
```

### Pushing Tags to GitHub

Tags are not pushed automatically. You must push them explicitly.

```bash
# Push a specific tag
git push origin v1.0.0

# Push all tags
git push origin --tags
```

### GitHub Releases

On GitHub, you can create a **Release** from a tag. Releases add release notes, changelogs, and downloadable assets (like compiled binaries) on top of the tag. Go to your repo on GitHub, click **Releases** in the right sidebar, then **Create a new release**.

---

## GitHub Features Every Developer Should Know

GitHub is much more than a place to store code. Here are the features that matter most.

### Issues

Issues are how you track bugs, feature requests, and tasks. Every issue has a title, description, labels (like `bug`, `enhancement`, `help wanted`), and can be assigned to team members. You can reference issues in commit messages using `#issue-number` (e.g., `Fix login crash #42`), and GitHub will automatically link them.

### Projects

GitHub Projects is a Kanban-style board for organizing issues and tasks into columns like "To Do," "In Progress," and "Done." It helps teams visualize their workflow.

### GitHub Pages

GitHub Pages lets you host a static website directly from a GitHub repository for free. It is commonly used for documentation, portfolios, and project landing pages. You enable it in your repo's Settings under the Pages section.

### Gists

A Gist is a quick way to share code snippets. Each gist is a Git repository, so it has version history. Use it for sharing small scripts, configuration files, or code examples.

### GitHub Actions

GitHub's built-in CI/CD platform. You define automated workflows in YAML files that run in response to events like pushes, pull requests, and schedules. This is covered in depth in the companion guide: **CI/CD with Git and GitHub Actions -- The Complete Beginner's Guide**.

### Code Owners

A `CODEOWNERS` file in your repository specifies which team members are automatically requested as reviewers for changes to specific files or directories. For example, any change to the `/backend` folder could automatically request a review from the backend team.

### Branch Protection Rules

In your repo Settings, you can set rules for branches like `main`: require pull request reviews before merging, require status checks (CI) to pass, prevent force pushes, and require signed commits. These rules ensure that no one can push broken or unreviewed code directly to your production branch.

### GitHub CLI (gh)

GitHub offers a command-line tool called `gh` that lets you interact with GitHub without leaving your terminal.

```bash
# Install (varies by OS -- see cli.github.com)
# Create a pull request
gh pr create --title "Add login feature" --body "Implements user authentication"

# List open issues
gh issue list

# Clone a repo
gh repo clone owner/repo-name
```

---

## Git Workflows Used by Teams

Individual developers can commit directly to `main`. Teams need a structured workflow. Here are the most common ones.

### Feature Branch Workflow

This is the simplest team workflow and the most widely used. Every new feature or bug fix gets its own branch. When complete, a pull request is opened for review, and after approval, the branch is merged into `main`.

```
main:     A -- B -- C --------- M1 --------- M2
                     \         /              /
feature-1:            D -- E --              /
                                \           /
feature-2:                       F -- G -- H
```

This is what most small to mid-size teams use. It is simple, clean, and works well with GitHub's pull request system.

### Gitflow Workflow

Gitflow is a more structured workflow that uses specific branch types. It has a `main` branch (production-ready code), a `develop` branch (integration branch for features), `feature/*` branches, `release/*` branches (preparation for a new release), and `hotfix/*` branches (urgent production fixes).

```
main:       A ------------ R1 ------------ H1 -- R2
             \            /                /     /
develop:      B -- C -- D -- E -- F ------/-- G /
                    \      /                   /
feature:             X -- Y                   /
                                             /
hotfix:                                    H1
```

Gitflow works well for projects with scheduled releases (like mobile apps or enterprise software). It is overkill for projects that deploy continuously.

### Trunk-Based Development

In trunk-based development, everyone works directly on `main` (the "trunk") with very short-lived branches (often less than a day). Changes are small, frequent, and always integrated. This workflow relies heavily on CI/CD to catch issues immediately.

This is what large companies like Google use. It requires a mature testing culture and robust automation.

### Choosing a Workflow

For solo projects and learning: commit directly to `main`. For small teams: use the Feature Branch workflow. For larger teams with scheduled releases: consider Gitflow. For teams with strong CI/CD and frequent deployments: consider trunk-based development.

---

## SSH vs HTTPS -- Connecting to GitHub

When you push or pull from GitHub, you need to authenticate. There are two ways to do this.

### HTTPS

This is the simpler option. You use the repository's HTTPS URL and authenticate with a **Personal Access Token** (PAT). GitHub no longer accepts passwords for HTTPS.

```bash
git clone https://github.com/username/repo.git
# When prompted, enter your username and PAT
```

To create a PAT: go to GitHub **Settings > Developer settings > Personal access tokens > Generate new token**. Give it the `repo` scope at minimum.

To avoid entering your token every time, you can cache it:

```bash
git config --global credential.helper cache           # Caches for 15 minutes
git config --global credential.helper 'cache --timeout=3600'  # Caches for 1 hour
git config --global credential.helper store           # Saves permanently (plain text)
```

### SSH

SSH uses cryptographic key pairs. You generate a public/private key pair on your machine. You add the public key to your GitHub account. From then on, Git authenticates automatically without you typing anything.

**Step 1: Generate an SSH key.**

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Press Enter to accept the default file location. Optionally set a passphrase.

**Step 2: Start the SSH agent and add your key.**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Step 3: Copy your public key.**

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the output.

**Step 4: Add the key to GitHub.**

Go to GitHub **Settings > SSH and GPG keys > New SSH key**. Paste your public key and save.

**Step 5: Test the connection.**

```bash
ssh -T git@github.com
```

You should see a message like "Hi username! You've successfully authenticated."

**Step 6: Use SSH URLs for repos.**

```bash
git clone git@github.com:username/repo.git
```

If you already cloned with HTTPS, switch to SSH:

```bash
git remote set-url origin git@github.com:username/repo.git
```

### Which Should You Use?

For beginners, HTTPS with a PAT is simpler to set up. For daily use, SSH is more convenient because you never have to enter credentials after the initial setup. Most professional developers use SSH.

---

## Common Mistakes Beginners Make

**Committing sensitive information.** API keys, passwords, database credentials, and `.env` files should never be committed. Use `.gitignore` to exclude them. If you accidentally commit a secret, consider it compromised -- rotate the credential immediately and use `git filter-branch` or the BFG Repo-Cleaner to remove it from history.

**Not pulling before pushing.** If your teammate pushed changes and you try to push without pulling first, Git will reject your push. Always `git pull` before `git push` when working on shared branches.

**Working directly on main.** Always create a branch for your changes, even for small fixes. Direct commits to `main` bypass code review and risk introducing bugs to production.

**Writing vague commit messages.** Messages like "fix," "update," "wip," or "changes" are useless when you need to find a specific change six months later. Describe what changed and why.

**Committing large binary files.** Git is designed for text files (code). Large binaries (videos, datasets, compiled executables) bloat the repository permanently because Git keeps every version. Use Git LFS (Large File Storage) for binaries.

**Not using .gitignore from the start.** Add a `.gitignore` file before your first commit. It is much easier to prevent files from being tracked than to remove them from history later.

**Force pushing to shared branches.** `git push --force` overwrites the remote history. If someone else has pulled the original history, their repo will be out of sync. Never force push to `main` or any shared branch. If you must force push to your own feature branch, use `--force-with-lease` which is safer.

**Confusing git reset with git revert.** `reset` rewrites history (dangerous on shared branches). `revert` creates a new commit that undoes changes (safe everywhere). When in doubt, use `revert`.

---

## Git Command Cheat Sheet

### Setup

| Command | What It Does |
|---|---|
| `git init` | Initialize a new repository |
| `git clone <url>` | Download a remote repository |
| `git config --global user.name "Name"` | Set your name |
| `git config --global user.email "email"` | Set your email |

### Daily Workflow

| Command | What It Does |
|---|---|
| `git status` | Check the state of your files |
| `git add .` | Stage all changes |
| `git add <file>` | Stage a specific file |
| `git commit -m "message"` | Commit staged changes |
| `git push` | Upload commits to remote |
| `git pull` | Download and merge remote changes |
| `git diff` | View unstaged changes |
| `git diff --staged` | View staged changes |

### Branching

| Command | What It Does |
|---|---|
| `git branch` | List local branches |
| `git branch <name>` | Create a new branch |
| `git checkout <branch>` | Switch to a branch |
| `git checkout -b <name>` | Create and switch to a new branch |
| `git merge <branch>` | Merge a branch into current branch |
| `git branch -d <name>` | Delete a merged branch |

### Remote

| Command | What It Does |
|---|---|
| `git remote -v` | List remotes and URLs |
| `git remote add origin <url>` | Add a remote |
| `git push -u origin <branch>` | Push and set upstream |
| `git fetch` | Download remote data without merging |
| `git push origin --delete <branch>` | Delete a remote branch |

### Undoing Things

| Command | What It Does |
|---|---|
| `git restore <file>` | Discard working directory changes |
| `git restore --staged <file>` | Unstage a file |
| `git reset --soft HEAD~1` | Undo last commit, keep changes staged |
| `git reset --hard HEAD~1` | Undo last commit, discard changes |
| `git revert <hash>` | Create a commit that undoes a past commit |
| `git commit --amend` | Modify the last commit |

### Stash

| Command | What It Does |
|---|---|
| `git stash` | Temporarily save uncommitted changes |
| `git stash pop` | Restore the most recent stash |
| `git stash list` | View all stashes |
| `git stash drop stash@{n}` | Delete a specific stash |

### History

| Command | What It Does |
|---|---|
| `git log --oneline` | Compact commit history |
| `git log --graph --all` | Visual branch graph |
| `git log --author="name"` | Filter by author |
| `git show <hash>` | View a specific commit |

---

## Where to Go From Here

This guide covers every foundational concept and command you need. Here are the resources to continue learning.

- **Official Git Documentation** -- [git-scm.com/doc](https://git-scm.com/doc) -- The complete reference for every Git command, written by the Git team.

- **Pro Git Book (Free)** -- [git-scm.com/book](https://git-scm.com/book/en/v2) -- The definitive book on Git, available for free online. It covers everything from basics to advanced internals.

- **GitHub Docs** -- [docs.github.com](https://docs.github.com) -- Official documentation for everything GitHub: repositories, pull requests, Actions, Pages, and more.

- **GitHub Skills** -- [skills.github.com](https://skills.github.com) -- Free interactive courses from GitHub. Hands-on practice with real repositories.

- **Learn Git Branching (Interactive)** -- [learngitbranching.js.org](https://learngitbranching.js.org) -- A visual, interactive tutorial that lets you practice branching, merging, rebasing, and more in your browser. Highly recommended for visual learners.

- **GitHub CLI Documentation** -- [cli.github.com](https://cli.github.com) -- Documentation for the `gh` command-line tool.

- **CI/CD with GitHub Actions** -- If you are ready to automate your workflow, refer to the companion guide: **CI/CD with Git and GitHub Actions -- The Complete Beginner's Guide**.

---

*This guide was written as a beginner-friendly, comprehensive reference for Git and GitHub. Bookmark it, revisit it as you learn, and practice each concept in a real repository -- that is how it sticks.*
