# CI/CD with Git and GitHub Actions 


## What is CI/CD?

CI/CD stands for **Continuous Integration** and **Continuous Delivery (or Deployment)**. These are practices that help development teams ship code faster, more reliably, and with fewer bugs.

### Continuous Integration (CI)

Every time a developer pushes code to a shared repository (like GitHub), the code is automatically built and tested. This catches bugs early before they reach production. Think of it as a quality checkpoint that runs every single time someone makes a change.

Without CI, teams discover bugs late -- sometimes only after deploying broken code to users. With CI, the moment you push code, automated tests run and tell you immediately if something is wrong.

### Continuous Delivery (CD)

Once your code passes all automated tests, it is automatically prepared for release. In **Continuous Delivery**, the code is packaged and ready to be deployed at any time, but a human still clicks the "deploy" button. In **Continuous Deployment** (the more advanced version), the code goes straight to production without any manual intervention.

### The CI/CD Pipeline

A pipeline is the full automated journey your code takes from commit to deployment. A typical pipeline looks like this:

```
Developer pushes code
        |
        v
   Code is pulled and built
        |
        v
   Automated tests run
        |
        v
   Code is packaged (e.g., Docker image)
        |
        v
   Deployed to staging or production
```

Every stage acts as a gate. If any stage fails, the pipeline stops and the team is notified.

---

## Why CI/CD Matters

**Without CI/CD**, developers merge code manually, run tests on their own machines (or skip them), and deploy by hand. This leads to inconsistent environments, missed bugs, and stressful deployments.

**With CI/CD**, all of this is automated. Tests run on a clean, consistent environment every time. Deployments are repeatable and predictable. The result is faster feedback, fewer production bugs, and developers who can focus on writing code instead of managing releases.

In real-world teams, CI/CD is not optional -- it is a standard part of professional software development.

---

## Understanding Git (The Foundation)

Git is the version control system that tracks every change you make to your code. GitHub is a platform that hosts your Git repositories online and provides tools like GitHub Actions on top of them. You cannot use GitHub Actions without Git, so understanding the basics is essential.

### Core Git Commands

**Initialize a repository.** This creates a `.git` folder in your project directory and starts tracking changes.

```bash
git init
```

**Stage your changes.** Before saving a snapshot, you tell Git which files to include. The `.` means "everything that changed."

```bash
git add .
```

**Commit your changes.** A commit is a saved snapshot of your code at a specific point in time. The message describes what you changed.

```bash
git commit -m "Add login feature"
```

**Push to GitHub.** This uploads your local commits to your remote repository on GitHub.

```bash
git push origin main
```

**Pull the latest changes.** If other people are working on the same repo, this downloads their changes to your local machine.

```bash
git pull origin main
```

**Create and switch to a branch.** Branches let you work on features without affecting the main codebase.

```bash
git checkout -b feature/new-dashboard
```

**Merge a branch back into main.** Once your feature is ready and tested, you bring it into the main branch.

```bash
git checkout main
git merge feature/new-dashboard
```

### The Git Workflow That Triggers CI/CD

This is the typical flow that connects Git to CI/CD:

1. You create a branch and make changes.
2. You push the branch to GitHub.
3. You open a Pull Request (PR).
4. GitHub Actions detects the push or PR and runs your workflow (tests, builds, etc.).
5. If all checks pass, the PR is approved and merged.
6. The merge to `main` triggers another workflow that deploys the code.

This is exactly how professional teams work. The CI/CD pipeline acts as an automated gatekeeper.

---

## What is GitHub Actions?

GitHub Actions is GitHub's built-in automation platform. It lets you define workflows that run automatically in response to events in your repository -- like pushing code, opening a pull request, creating a release, or even on a scheduled timer.

You define these workflows in YAML files stored inside your repository at `.github/workflows/`. When an event happens, GitHub spins up a virtual machine (called a **runner**), executes the steps you defined, and reports the results back to you.

The key advantage of GitHub Actions is that it lives right inside GitHub. There is nothing extra to install, no external service to configure, and no separate dashboard to monitor. Everything happens in one place.

---

## Core Concepts You Must Know

Before writing any workflow, you need to understand these five building blocks. Every GitHub Actions workflow is built from them.

### Workflow

A workflow is the entire automated process defined in a single YAML file. A repository can have multiple workflows. For example, one for running tests and another for deploying.

### Event (Trigger)

An event is what causes a workflow to run. Common triggers include pushing code, opening a pull request, publishing a release, or running on a cron schedule.

### Job

A job is a group of steps that run on the same runner (virtual machine). A workflow can have multiple jobs, and by default they run in parallel. You can configure them to run sequentially if one depends on another.

### Step

A step is a single task within a job. It can either run a shell command (using `run`) or call a pre-built action (using `uses`). Steps within a job always run sequentially, one after the other.

### Runner

A runner is the machine that executes your job. GitHub provides hosted runners (Ubuntu, Windows, macOS) for free (with usage limits). You can also set up your own self-hosted runners on your own servers.

### How They Fit Together

```
Workflow (the YAML file)
  |
  |-- Event: "on push to main"
  |
  |-- Job: build
  |     |-- Step 1: Checkout code
  |     |-- Step 2: Install dependencies
  |     |-- Step 3: Run tests
  |
  |-- Job: deploy (depends on build)
        |-- Step 1: Checkout code
        |-- Step 2: Deploy to server
```

---

## YAML -- The Language of Workflows

GitHub Actions workflows are written in YAML (YAML Ain't Markup Language). YAML is a human-readable data format that uses indentation to define structure. If you have never written YAML before, here are the rules you must follow.

**Indentation matters.** YAML uses spaces (never tabs) to define hierarchy. Standard practice is 2 spaces per level.

```yaml
parent:
  child: value
  another_child: value
```

**Key-value pairs** are the basic unit. A key followed by a colon and a value.

```yaml
name: My Workflow
runs-on: ubuntu-latest
```

**Lists** use a dash followed by a space.

```yaml
branches:
  - main
  - develop
```

**Multi-line strings** use the pipe character `|` when you need to run multiple shell commands in one step.

```yaml
run: |
  echo "First command"
  echo "Second command"
  npm install
```

**Comments** start with `#`.

```yaml
# This is a comment
name: CI Pipeline  # This is also a comment
```

A single wrong indentation will break your entire workflow. When in doubt, use a YAML linter or validator before pushing.

---

## Workflow File

Every workflow file lives in `.github/workflows/` and has a `.yml` or `.yaml` extension. Here is the skeleton that every workflow follows, with every section explained.

```yaml
# -------------------------------------------------------
# 1. NAME: What this workflow is called in the Actions tab
# -------------------------------------------------------
name: CI Pipeline

# -------------------------------------------------------
# 2. TRIGGER: When this workflow should run
# -------------------------------------------------------
on:
  push:
    branches: [ main, develop ]    # Run on push to these branches
  pull_request:
    branches: [ main ]             # Run when a PR targets main
  schedule:
    - cron: '0 6 * * 1'           # Run every Monday at 6:00 AM UTC
  workflow_dispatch:                # Allow manual trigger from GitHub UI

# -------------------------------------------------------
# 3. ENVIRONMENT VARIABLES (optional, available to all jobs)
# -------------------------------------------------------
env:
  APP_ENV: production
  NODE_VERSION: '20'

# -------------------------------------------------------
# 4. JOBS: The actual work
# -------------------------------------------------------
jobs:

  # --- First job ---
  test:
    runs-on: ubuntu-latest         # The runner (virtual machine)
    
    steps:
      - name: Checkout code        # Step name (shows in logs)
        uses: actions/checkout@v4  # Uses a pre-built marketplace action

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:                      # Inputs passed to the action
          node-version: ${{ env.NODE_VERSION }}

      - name: Install dependencies
        run: npm install           # Runs a shell command directly

      - name: Run tests
        run: npm test

  # --- Second job (depends on first) ---
  deploy:
    needs: test                    # Only runs if 'test' job passes
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'  # Only on main branch

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to production
        run: echo "Deploying application..."
```

### Explanation of Each Section

**`name`** is the display name. It shows up in the GitHub Actions tab so you can identify your workflow at a glance.

**`on`** defines triggers. You can trigger on `push`, `pull_request`, `schedule` (cron syntax), `workflow_dispatch` (manual run), `release`, and many more. You can combine multiple triggers in one workflow.

**`env`** sets environment variables that are available to every job and step in the workflow. You can also set env at the job level or step level for more targeted scope.

**`jobs`** contains all the jobs. Each job has an ID (like `test` or `deploy`), runs on a specified runner, and contains a list of steps.

**`needs`** creates a dependency between jobs. In the example above, the `deploy` job will not run unless the `test` job succeeds.

**`if`** adds a conditional. The deploy job only runs when the push is to the `main` branch, not on feature branches or pull requests.

**`uses`** calls a pre-built action from the GitHub Marketplace or another repository. The format is `owner/repo@version`.

**`run`** executes a shell command directly on the runner. Use the pipe `|` for multiple commands.

**`with`** passes inputs to a marketplace action. Each action defines what inputs it accepts.

---

## Essential GitHub Actions Commands and Syntax

This section covers the syntax and commands you will use most frequently when writing workflows.

### Trigger Events

```yaml
# Push to specific branches
on:
  push:
    branches: [ main, develop ]
    paths:
      - 'src/**'              # Only trigger if files in src/ changed
    paths-ignore:
      - '**.md'               # Ignore changes to markdown files

# Pull request events
on:
  pull_request:
    types: [ opened, synchronize, reopened ]

# Manual trigger with inputs
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

# Scheduled runs (cron syntax: minute hour day month weekday)
on:
  schedule:
    - cron: '30 5 * * 1-5'   # 5:30 AM UTC, Monday through Friday
```

### Environment Variables and Secrets

```yaml
# Workflow-level env (available everywhere)
env:
  DATABASE_URL: postgres://localhost/mydb

jobs:
  build:
    runs-on: ubuntu-latest
    
    # Job-level env
    env:
      CI: true

    steps:
      - name: Use a secret
        run: echo "Deploying..."
        env:
          # Secrets are set in: Repo Settings > Secrets and variables > Actions
          API_KEY: ${{ secrets.API_KEY }}
          # NEVER hardcode secrets in your YAML file
```

### Contexts and Expressions

GitHub Actions provides context objects you can use in expressions.

```yaml
# Access event data
${{ github.event_name }}          # "push", "pull_request", etc.
${{ github.ref }}                 # "refs/heads/main"
${{ github.sha }}                 # Full commit SHA
${{ github.actor }}               # Username who triggered the workflow
${{ github.repository }}          # "owner/repo-name"

# Use in conditionals
if: github.ref == 'refs/heads/main'
if: github.event_name == 'pull_request'
if: contains(github.event.head_commit.message, '[skip ci]')

# Access job outputs
${{ needs.build.outputs.version }}

# Access secrets
${{ secrets.DOCKER_TOKEN }}
```

### Caching Dependencies

Caching speeds up your workflows significantly by avoiding re-downloading dependencies on every run.

```yaml
- name: Cache node modules
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Uploading and Downloading Artifacts

Artifacts let you share files between jobs or download them after a workflow finishes.

```yaml
# Upload in one job
- name: Upload test results
  uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: ./reports/

# Download in another job
- name: Download test results
  uses: actions/download-artifact@v4
  with:
    name: test-results
```

### Matrix Strategy

A matrix lets you run the same job across multiple configurations (e.g., different OS versions, language versions).

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ ubuntu-latest, windows-latest ]
        python-version: [ '3.10', '3.11', '3.12' ]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: pytest
```

This creates 6 parallel jobs (2 OS options multiplied by 3 Python versions).

### Job Dependencies and Outputs

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image_tag: ${{ steps.tag.outputs.tag }}
    steps:
      - name: Generate tag
        id: tag
        run: echo "tag=v1.0.${{ github.run_number }}" >> $GITHUB_OUTPUT

  deploy:
    needs: build               # Waits for build to finish
    runs-on: ubuntu-latest
    steps:
      - name: Use the tag
        run: echo "Deploying ${{ needs.build.outputs.image_tag }}"
```

---

## Using the GitHub Actions Marketplace

The GitHub Actions Marketplace is a library of thousands of pre-built actions created by GitHub, verified publishers, and the community. Instead of writing complex shell scripts from scratch, you can use these actions like building blocks.

### How to Find Actions

Go to [github.com/marketplace?type=actions](https://github.com/marketplace?type=actions) and search for what you need. Actions are referenced in your workflow using the `uses` keyword.

### How to Read an Action Reference

```yaml
uses: actions/checkout@v4
#     |       |        |
#     |       |        +-- Version tag (always pin to a major version)
#     |       +----------- Action name (the repository name)
#     +------------------- Owner (GitHub org or username)
```

The version tag is critical. Always pin to at least a major version (`@v4`) to avoid breaking changes. For maximum security, you can pin to a full commit SHA.

### Most Common Marketplace Actions 

**actions/checkout@v4** -- This is used in almost every workflow. It clones your repository code onto the runner so that subsequent steps can access your files. Without this, the runner has no access to your code.

```yaml
- name: Checkout code
  uses: actions/checkout@v4
```

**actions/setup-python@v5** -- Installs a specific version of Python on the runner. The runner has some tools pre-installed, but this ensures you get the exact version you need.

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'
```

**actions/setup-node@v4** -- Same concept, but for Node.js. Installs the specified version and makes `node` and `npm` available.

```yaml
- name: Set up Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'
```

**actions/cache@v4** -- Caches directories (like `node_modules` or pip cache) between workflow runs so you do not re-download everything each time. This can cut minutes off your pipeline.

```yaml
- name: Cache pip
  uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```

**actions/upload-artifact@v4 and actions/download-artifact@v4** -- Upload files (like test reports or build outputs) from one job and download them in another, or access them from the Actions UI after the run completes.

**docker/login-action@v3** -- Logs into a container registry (Docker Hub, GitHub Container Registry, AWS ECR, etc.) so you can push images.

```yaml
- name: Login to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

**docker/build-push-action@v5** -- Builds a Docker image and pushes it to a registry in a single step. Supports multi-platform builds and advanced caching.

```yaml
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    push: true
    tags: myuser/myapp:latest
```

### The `with` Keyword

Every marketplace action defines its own set of inputs. You pass values to these inputs using `with`. Always check the action's README on GitHub to see what inputs are available and which are required.

```yaml
- uses: actions/setup-python@v5
  with:                            # 'with' passes inputs to the action
    python-version: '3.11'         # This input is defined by the action
    cache: 'pip'                   # Another optional input
```

### Best Practices for Marketplace Actions

Use only verified or well-maintained actions. Check the action's repository for recent commits, open issues, and the number of stars. Always pin versions -- never use `@main` or `@master` in production workflows. Read the action's documentation before using it; the README on GitHub will list all available inputs, outputs, and usage examples.

---

## Sample Workflow: Python Application

This is a production-ready CI workflow for a Python project. It installs dependencies, runs linting, and executes tests.

### Project Structure

```
my-python-app/
  app.py
  test_app.py
  requirements.txt
  .github/
    workflows/
      ci.yml
```

### app.py

```python
def add(x, y):
    return x + y

def multiply(x, y):
    return x * y
```

### test_app.py

```python
from app import add, multiply

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0

def test_multiply():
    assert multiply(3, 4) == 12
    assert multiply(0, 5) == 0
```

### requirements.txt

```
pytest
flake8
```

### .github/workflows/ci.yml

```yaml
name: Python CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: [ '3.10', '3.11', '3.12' ]

    steps:
      # Step 1: Pull the repo code onto the runner
      - name: Checkout repository
        uses: actions/checkout@v4

      # Step 2: Install the specified Python version
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      # Step 3: Cache pip packages so future runs are faster
      - name: Cache pip dependencies
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
          restore-keys: |
            ${{ runner.os }}-pip-

      # Step 4: Install project dependencies
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      # Step 5: Lint the code to catch style and syntax issues
      - name: Lint with flake8
        run: |
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          flake8 . --count --max-line-length=120 --statistics

      # Step 6: Run the test suite
      - name: Run tests
        run: pytest --verbose
```

### What Happens When You Push

1. GitHub detects the push to `main` or `develop`.
2. Three parallel jobs are created (one for each Python version in the matrix).
3. Each job checks out your code, installs the right Python, caches dependencies, lints the code with flake8, and runs pytest.
4. The results appear in the Actions tab. A green checkmark means all tests passed. A red X means something failed, and you can click into the logs to see exactly which step broke.

---

## Sample Workflow: Dockerized Application

This workflow builds a Docker image, runs a container from it to verify it works, and then pushes the image to Docker Hub.

### Prerequisites

Before this workflow can run, you need to set two secrets in your GitHub repository. Go to your repo on GitHub, then **Settings > Secrets and variables > Actions > New repository secret**. Add:

- `DOCKERHUB_USERNAME` -- Your Docker Hub username
- `DOCKERHUB_TOKEN` -- An access token from Docker Hub (go to Docker Hub > Account Settings > Security > New Access Token)

### Project Structure

```
my-docker-app/
  app.py
  Dockerfile
  requirements.txt
  .github/
    workflows/
      docker-ci.yml
```

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
```

### .github/workflows/docker-ci.yml

```yaml
name: Docker CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  IMAGE_NAME: your-dockerhub-username/my-docker-app

jobs:

  build-and-test:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Get the code
      - name: Checkout repository
        uses: actions/checkout@v4

      # Step 2: Set up Docker Buildx for advanced build features
      # Buildx is Docker's extended build tool. It supports caching,
      # multi-platform builds, and other optimizations.
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Step 3: Log into Docker Hub using your stored secrets
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Step 4: Build the Docker image and push it to Docker Hub
      # The 'tags' field determines the image name and tag on Docker Hub.
      # The 'cache-from' and 'cache-to' lines enable layer caching,
      # which makes subsequent builds significantly faster.
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.event_name == 'push' }}
          tags: |
            ${{ env.IMAGE_NAME }}:latest
            ${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      # Step 5: Verify the image works by running it
      - name: Test Docker image
        run: |
          docker run -d --name test-container -p 5000:5000 ${{ env.IMAGE_NAME }}:latest
          sleep 5
          docker ps | grep test-container
          docker logs test-container
          docker stop test-container
```

### Key Details

The `push` field in the build step uses an expression: `${{ github.event_name == 'push' }}`. This means the image is only pushed to Docker Hub on actual pushes to main, not on pull requests. During PRs, the image is built (to verify it compiles) but not pushed.

The `${{ github.sha }}` tag ensures every image is uniquely tagged with the commit hash, so you can always trace a running container back to the exact code that built it.

---

## Sample Workflow: Using Self-Hosted (Private) Runners

### What is a Self-Hosted Runner?

By default, GitHub Actions runs your jobs on GitHub's cloud servers (hosted runners). A self-hosted runner is a machine you own and manage -- it could be a server in your data center, an EC2 instance on AWS, or even a machine under your desk.

### Why Use Self-Hosted Runners?

You would use a self-hosted runner when you need access to internal resources (databases, APIs, servers behind a firewall), when you need specific hardware (GPUs, custom OS configurations), when you want to avoid GitHub's free-tier usage limits, or when your organization's security policies require code to be built on company-controlled infrastructure.

### How to Set One Up

1. Go to your GitHub repository (or organization) **Settings > Actions > Runners > New self-hosted runner**.
2. Choose the OS (Linux, Windows, or macOS).
3. GitHub provides a set of commands to run on your machine. These download the runner agent, configure it, and register it with your repository.
4. Start the runner service. It will now listen for jobs.

The setup commands look roughly like this (GitHub generates the exact ones for you):

```bash
# Download the runner package
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.x.x/actions-runner-linux-x64-2.x.x.tar.gz
tar xzf actions-runner-linux-x64.tar.gz

# Configure (uses a token from your repo settings)
./config.sh --url https://github.com/your-org/your-repo --token YOUR_TOKEN

# Start the runner
./run.sh
```

### Assigning Labels

When you configure a self-hosted runner, you can assign labels to it. Labels are how your workflow knows which runner to use.

```bash
./config.sh --url https://github.com/your-org/your-repo --token YOUR_TOKEN --labels gpu,linux,production
```

### Workflow Using a Self-Hosted Runner

```yaml
name: Deploy with Self-Hosted Runner

on:
  push:
    branches: [ main ]

jobs:

  # Job 1: Run tests on GitHub's hosted runner (clean environment)
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install and test
        run: |
          pip install -r requirements.txt
          pytest --verbose

  # Job 2: Deploy on your own server (self-hosted runner)
  deploy:
    needs: test                          # Only runs if tests pass
    runs-on: [ self-hosted, linux, production ]
    # The 'runs-on' field accepts a list of labels.
    # The job will be picked up by a runner that has ALL of these labels.

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to server
        run: |
          echo "Deploying from self-hosted runner..."
          cd /opt/my-application
          git pull origin main
          docker compose down
          docker compose up -d --build

      - name: Verify deployment
        run: |
          sleep 10
          curl -f http://localhost:5000/health || exit 1
          echo "Deployment verified successfully."
```

### How `runs-on` Works for Self-Hosted Runners

When you write `runs-on: [ self-hosted, linux, production ]`, GitHub looks for a registered runner that has all three labels: `self-hosted`, `linux`, and `production`. If no runner matches all labels, the job queues until one becomes available.

The `self-hosted` label is automatically applied to every self-hosted runner. The other labels (`linux`, `production`, `gpu`, etc.) are ones you define during setup.

### Important Considerations

Self-hosted runners do not start from a clean slate like hosted runners do. Your runner retains files, installed packages, and state between jobs. This means you need to manage cleanup yourself, or use Docker-based workflows on your runner to ensure isolation.

Security is critical. Never use self-hosted runners on public repositories, because anyone who opens a pull request could execute arbitrary code on your machine. Self-hosted runners are best suited for private repositories within an organization.

---

## CI/CD Platforms at a Glance

GitHub Actions is not the only CI/CD platform. Here is a comparison of the most widely used options so you can make informed decisions.

| Platform | Type | Best For | Notable Strengths |
|---|---|---|---|
| GitHub Actions | Hosted | Teams using GitHub | Native GitHub integration, massive marketplace, free for public repos |
| GitLab CI/CD | Hosted or Self-Hosted | Teams using GitLab | Auto DevOps, built-in container registry, powerful built-in features |
| Jenkins | Self-Hosted | Enterprises needing full control | Extremely customizable, thousands of plugins, mature ecosystem |
| CircleCI | Hosted | Speed-focused teams | Excellent caching, parallelism, optimized pipelines |
| Travis CI | Hosted | Open-source projects | Simple config, good GitHub integration |
| Azure DevOps | Hosted | Microsoft/Azure shops | Full DevOps toolchain, enterprise-grade, deep Azure integration |
| AWS CodePipeline | Hosted | AWS-native deployments | Tight AWS integration, connects with CodeBuild and CodeDeploy |
| Bitbucket Pipelines | Hosted | Teams using Bitbucket | Simple YAML config, integrated with Atlassian tools (Jira, Confluence) |

If your code lives on GitHub, GitHub Actions is the natural starting point. If you need heavy customization or are in a large enterprise with specific compliance requirements, Jenkins or GitLab CI might be more appropriate.

---

## Common Mistakes Beginners Make

**Forgetting to create the `.github/workflows/` directory.** The workflow file must be at exactly `.github/workflows/your-file.yml`. If the folder structure is wrong, GitHub will not detect your workflow.

**Indentation errors in YAML.** YAML is whitespace-sensitive. A single misplaced space can break your entire workflow. Use 2 spaces per indentation level consistently, and never use tabs.

**Hardcoding secrets in the YAML file.** Never put passwords, API keys, or tokens directly in your workflow file. Always use GitHub Secrets (`${{ secrets.YOUR_SECRET }}`). Your YAML file is committed to version control, which means anyone with repo access can see it.

**Not pinning action versions.** Using `uses: actions/checkout@main` means your workflow could break any time the action is updated. Always pin to a version tag like `@v4`.

**Ignoring the Actions tab.** After pushing your workflow, go to the **Actions** tab in your GitHub repo to see the run. Click into failed steps to read the logs. The logs tell you exactly what went wrong.

**Not testing locally first.** Before relying on CI to catch issues, make sure your code, tests, and commands work on your local machine. If `pytest` fails locally, it will fail in CI too.

---

## Where to Go From Here

This guide covers the foundation. Here are the official resources to deepen your knowledge:

- **GitHub Actions Documentation** -- [docs.github.com/en/actions](https://docs.github.com/en/actions) -- The complete official reference for everything GitHub Actions: workflow syntax, contexts, expressions, hosted runner specs, and more.

- **GitHub Actions Marketplace** -- [github.com/marketplace?type=actions](https://github.com/marketplace?type=actions) -- Browse thousands of pre-built actions for any task you can imagine.

- **Workflow Syntax Reference** -- [docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) -- The complete YAML syntax specification. This is the page to bookmark.

- **Self-Hosted Runner Setup** -- [docs.github.com/en/actions/hosting-your-own-runners](https://docs.github.com/en/actions/hosting-your-own-runners) -- Detailed instructions for setting up and managing your own runners.

- **GitHub Skills** -- [skills.github.com](https://skills.github.com) -- Free interactive courses directly from GitHub, including hands-on CI/CD exercises.

- **Docker Documentation** -- [docs.docker.com](https://docs.docker.com) -- Essential if you are containerizing your applications as part of your CI/CD pipeline.

---

*Found this helpful, please give this repo a STAR*
