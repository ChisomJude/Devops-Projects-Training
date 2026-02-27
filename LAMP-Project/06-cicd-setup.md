# Section 06 — CI/CD with GitHub Actions

> **Goal:** Set up a GitHub Actions pipeline so that every time you push code to the `main` branch, it automatically tests the app, builds a Docker image, pushes it to DockerHub, and deploys it to your web server.

---

##  What Is CI/CD?

| Term | What it means | Real world analogy |
|------|--------------|-------------------|
| **CI** (Continuous Integration) | Automatically test your code on every push | Factory quality check before the product ships |
| **CD** (Continuous Deployment) | Automatically deploy if tests pass | Conveyor belt ships the product straight to the warehouse |

Without CI/CD: developer writes code → manually tests → manually SSHes into server → manually restarts app. Every. Single. Time.

With CI/CD: developer writes code → pushes to GitHub → **everything else is automatic**.

---

## Step 1 — Add GitHub Secrets

Secrets are how we store sensitive values (passwords, keys) in GitHub without putting them in our code.

1. Go to your GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**

2. Add each of these:

   | Secret Name | Value |
   |-------------|-------|
   | `DOCKERHUB_USERNAME` | Your DockerHub username |
   | `DOCKERHUB_TOKEN` | DockerHub access token (see below) |
   | `EC2_SSH_KEY` | Contents of your `lamp-key.pem` file |
   | `WEB_SERVER_IP` | Public IP of your web server EC2 |
   | `DB_HOST` | Private IP of your DB server EC2 |
   | `DB_NAME` | `lampdb` |
   | `DB_USER` | `lampuser` |
   | `DB_PASSWORD` | The MySQL password you set in Section 03 |

3. Add this **Variable** (not a secret — it's not sensitive):
   - Go to **Variables tab → New repository variable**
   - Name: `EC2_USER`, Value: `ubuntu`

>  **How to get a DockerHub token:**
> DockerHub → Account Settings → Security → New Access Token → give it a name → copy the token.
> Use this instead of your password — if it gets exposed, you can revoke just the token.

---

## Step 2 — Get Your SSH Key Content

The `EC2_SSH_KEY` secret needs to contain the **full content** of your `.pem` file, including the header and footer lines.

```bash
# On your local machine, print the key content
cat ~/Downloads/lamp-key.pem
```

Copy the entire output — it should look like:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA...
(many lines)
...abc123==
-----END RSA PRIVATE KEY-----
```

Paste that entire thing as the value of the `EC2_SSH_KEY` secret.

---

## Step 3 — Add the Workflow File to Your Repo

Your repo should have this file (it's already written for you):

```
your-repo/
├── app.py
├── Dockerfile
├── requirements.txt
├── .env.example
└── .github/
    └── workflows/
        └── deploy.yml         ← this is the CI/CD pipeline
```

The `deploy.yml` file is in your project files. Make sure it's committed:

```bash
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

---

## Step 4 — Watch the Pipeline Run

1. Go to your GitHub repo → **Actions tab**
2. You should see a workflow run triggered by your push
3. Click it to see the live progress

The pipeline has 3 jobs:

```
test  ──────► build  ──────► deploy
  │              │               │
 Run           Build           SSH into
 tests         Docker          EC2 and
               image           restart
               push to         container
               DockerHub
```

Each job must pass before the next one starts. If tests fail, nothing gets deployed.

---

## Step 5 — Understand Each Job

### Job 1: test
```yaml
- Installs Python
- Installs your requirements
- Runs a quick test on / and /health routes
- If this fails → pipeline stops, nothing is deployed 
```

### Job 2: build
```yaml
- Logs into DockerHub using your secrets
- Builds the Docker image from your Dockerfile
- Pushes it to DockerHub as: yourusername/lamp-demo:latest
```

### Job 3: deploy
```yaml
- Sets up SSH using your EC2_SSH_KEY secret
- SSHes into your web server
- Pulls the new image from DockerHub
- Stops the old container
- Starts a new container with all DB credentials passed as -e flags
- Waits 8 seconds, then hits /health to confirm the app is running
```

---

## Step 6 — Trigger a Deployment

Make a small change to test the full pipeline:

```bash
# Edit app.py - change the title or add a line to the homepage
# Then:
git add app.py
git commit -m "Test CI/CD pipeline deployment"
git push origin main
```

Watch the Actions tab — within 2-3 minutes, your change should be live at:
```
http://<WEB_SERVER_PUBLIC_IP>
```

---

## Step 7 — What the Pipeline Looks Like

```
┌─────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS                        │
│                                                          │
│  git push to main                                        │
│         │                                                │
│         ▼                                                │
│  ┌─────────────┐                                         │
│  │   JOB: test │                                         │
│  │             │                                         │
│  │ • Install   │                                         │
│  │   Python    │                                         │
│  │ • Run tests │                                         │
│  │             │                                         │
│  │ PASS ──────────────────────────────┐                  │
│  │ FAIL → stop ❌                     │                  │
│  └─────────────┘                      │                  │
│                                       ▼                  │
│                              ┌──────────────┐            │
│                              │  JOB: build  │            │
│                              │              │            │
│                              │ • Build img  │            │
│                              │ • Push to    │            │
│                              │   DockerHub  │            │
│                              │              │            │
│                              │ PASS ──────────────────┐  │
│                              └──────────────┘         │  │
│                                                       ▼  │
│                                             ┌──────────┐ │
│                                             │  deploy  │ │
│                                             │          │ │
│                                             │ SSH → EC2│ │
│                                             │ docker   │ │
│                                             │ pull     │ │
│                                             │ docker   │ │
│                                             │ run      │ │
│                                             │ /health ✅│ │
│                                             └──────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Common Issues

**Pipeline fails at "Set up SSH key":**
Check that `EC2_SSH_KEY` secret contains the full key content including `-----BEGIN...-----END` lines.

**Pipeline fails at "Deploy to EC2" with "Connection refused":**
Check that port 22 is open in `lamp-web-sg` for the GitHub Actions runner IPs. Easiest fix: temporarily open port 22 to `0.0.0.0/0` for the demo, then lock it back down.

**Health check fails (exit code 1):**
Container started but app isn't responding. Check container logs: `sudo docker logs lamp-app` on the web server.

---

>  CI/CD is live! Move on to **[Section 07 → Testing Everything](./07-testing.md)**
