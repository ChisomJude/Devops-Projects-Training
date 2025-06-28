# Beginner-Friendly CI/CD with Git and GitHub Actions

## ✅ Objectives

By the end of this lecture, you will understand:

* What CI/CD means
* Why we use Git for version control
* How GitHub Actions helps automate our workflow
* How to create a basic CI/CD pipeline using GitHub Actions
* What platforms exist for CI/CD

---

## 💪 What is CI/CD?

### CI: Continuous Integration

This means that whenever we push our code to GitHub, it will automatically be **checked** and **tested**. This helps us catch bugs early.

### CD: Continuous Delivery / Deployment

After the code passes the tests, it can be automatically **deployed** to a server, website, or app store.

**In short:** CI/CD helps us release code faster and with fewer errors.

---

## 📃 What is Git?

Git is a tool that helps you **track changes** in your code.

### Common Git Commands:

```bash
git init                 # Start tracking code in a folder
git add .                # Tell Git to track all changes
git commit -m "message"  # Save a snapshot with a message
git push origin main     # Upload your code to GitHub
```

---

## 🌐 What is GitHub Actions?

GitHub Actions is a tool inside GitHub that helps you **automate tasks**.

You write instructions in a file (a `.yml` file) that tells GitHub:

* When to run (like when you push code)
* What to do (like install Python, run tests, or deploy code)

---

## 💻 Platforms for CI/CD

There are several platforms you can use for CI/CD besides GitHub Actions:

| Platform                | Hosted/Install | Best For                        | Key Features                                                 |
| ----------------------- | -------------- | ------------------------------- | ------------------------------------------------------------ |
| **GitHub Actions**      | Hosted         | GitHub users                    | Built-in to GitHub, easy YAML config, community actions      |
| **GitLab CI/CD**        | Hosted/Self    | GitLab users                    | Auto DevOps, docker support, powerful built-in tools         |
| **CircleCI**            | Hosted         | Speed and flexibility           | Parallel jobs, caching, optimized pipelines                  |
| **Travis CI**           | Hosted         | Open-source projects            | Simple setup, integrated with GitHub                         |
| **Jenkins**             | Self-hosted    | Advanced and customizable needs | Highly configurable, plugins ecosystem, enterprise ready     |
| **Bitbucket Pipelines** | Hosted         | Bitbucket users                 | Simple YAML, Docker support, integrated with Atlassian tools |
| **Azure DevOps**        | Hosted         | Microsoft/Azure users           | End-to-end DevOps toolchain, enterprise-grade features       |
| **AWS CodePipeline**    | Hosted         | AWS-native deployments          | Deep AWS integration, pay-as-you-go, connects with CodeBuild |

You can choose based on your project type, team size, where your code is hosted, and required integrations.

---

## 📄 Your First Workflow File

Let’s create a GitHub Actions file that checks our Python code.

### 1. Create this folder and file in your repo:

```
.github/workflows/ci.yml
```

### 2. Paste this into the file:

```yaml
name: Simple CI  # Name of this workflow

on:
  push:
    branches:
      - main      # Only run this when we push to 'main' branch

jobs:
  build:
    runs-on: ubuntu-latest   # Use a Linux virtual machine to run the job

    steps:
      - name: Checkout code
        uses: actions/checkout@v3  # This pulls your code into the machine

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'  # Tell GitHub what version of Python you use

      - name: Install dependencies
        run: pip install -r requirements.txt  # Install the packages you need

      - name: Run tests
        run: pytest  # Run your test files to make sure your code works
```

---

## 🎓 Let’s Understand Each Line (Beginner Explanation)

```yaml
name: Simple CI
```

Give your workflow a name. This will appear in the GitHub Actions tab.

```yaml
on:
  push:
    branches:
      - main
```

This tells GitHub: "Run this workflow **every time we push code to the `main` branch**."

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
```

This creates a **job** called `build`. It will run on a virtual Ubuntu Linux machine.

```yaml
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
```

This **downloads your GitHub code** into the machine so it can be tested.

```yaml
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
```

This tells GitHub: "Please install Python 3.10 for me."

```yaml
      - name: Install dependencies
        run: pip install -r requirements.txt
```

This installs any Python packages your app needs.

```yaml
      - name: Run tests
        run: pytest
```

This runs your **test files** (like `test_app.py`) using the `pytest` tool.

---

## 🚀 Sample Python Project

### app.py

```python
def add(x, y):
    return x + y
```

### test\_app.py

```python
from app import add

def test_add():
    assert add(2, 3) == 5
```

### requirements.txt

```
pytest
```

When you push this code to GitHub, GitHub Actions will:

* Download your code
* Install pytest
* Run `test_app.py`
* Tell you if the test passed or failed

---

## 📚 Practice Exercise

1. Create a GitHub repo
2. Add a small Python function and test
3. Add a `.github/workflows/ci.yml` file
4. Push your code and watch GitHub Actions run!

---
## Basic YAML Structure for CI/CD Workflow (GitHub Actions)

Every GitHub Actions workflow follows this structure:

```yml
name: <Workflow Name>   # Optional, gives the workflow a name

on:                     # Triggers: when should this run?
  push:
    branches: [main]    # e.g., when you push to 'main' branch
  pull_request:         # or when a PR is opened

jobs:
  build:                # Job name
    runs-on: ubuntu-latest  # VM to run the job on

    steps:
      - name: Checkout code
        uses: actions/checkout@v3    # Pull your code from GitHub

      - name: Set up environment
        uses: actions/setup-node@v4  # Or setup-python, setup-java, etc.
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm install             # Or pip install, composer install...

      - name: Run tests
        run: npm test                # Or pytest, go test, etc.

```


