# 🔄 Separated CI/CD Workflow Architecture

## Overview

The CI/CD pipeline has been split into two separate, independent workflows:

1. **CI Workflow** (`ci.yml`) - Continuous Integration
2. **CD Workflow** (`cd.yml`) - Continuous Deployment

This separation provides clear distinction and prevents confusion between integration and deployment stages.

---

## 🔍 CI Workflow (Continuous Integration)

**File**: `.github/workflows/ci.yml`

### Purpose
Focuses on code quality, testing, and validation. Runs on every push and pull request.

### Triggers
- **Push** to `main` or `develop` branches
- **Pull Requests** to `main` or `develop` branches

### Jobs

#### 1. Build & Test Job
```yaml
Runs: Ubuntu latest
Java: Version 25
Maven Cache: Enabled

Steps:
1. Checkout code
2. Setup JDK 25 + Maven
3. Clean build (skip tests)
4. Run full test suite
5. Upload test artifacts
6. Upload code coverage
```

**Artifacts Generated**:
- Test reports (JUnit XML)
- Code coverage data
- Build logs

**Runtime**: ~5-10 minutes

#### 2. Security Scanning Job
```yaml
Runs: Ubuntu latest

Steps:
1. Checkout code
2. Run Trivy vulnerability scanner
3. Generate SARIF format report
4. Upload to GitHub Security tab
```

**Output**: Security vulnerability reports

**Runtime**: ~2-3 minutes

#### 3. Code Quality Analysis Job
```yaml
Runs: Ubuntu latest
Java: Version 25

Steps:
1. Checkout code
2. Setup JDK 25
3. Run SonarQube analysis (optional)
```

**Output**: Code quality metrics

**Runtime**: ~5-10 minutes (optional)

### Exit Conditions
- ✅ All tests pass → Workflow succeeds
- ✅ Security scan completes → Workflow succeeds
- ✅ Code quality check passes → Workflow succeeds
- ❌ Any test fails → Workflow stops (no deployment)
- ❌ Security issues found → Workflow continues but flagged
- ❌ Code quality issues found → Workflow continues but noted

### Success Criteria for CI
```
✅ Build completes without errors
✅ All unit tests pass
✅ All integration tests pass
✅ Security scan completes
✅ Code quality thresholds met
```

---

## 🚀 CD Workflow (Continuous Deployment)

**File**: `.github/workflows/cd.yml`

### Purpose
Handles deployment to staging and production environments. Triggered only when CI succeeds.

### Triggers
- Workflow completion of CI workflow
- Only on `main` branch (not develop)
- Only if CI workflow succeeded

### Workflow Structure

```
CI Workflow Completes (main branch)
    ↓
CI Success? 
    ├─ YES → Trigger CD Workflow
    └─ NO → Stop (no deployment)
    ↓
Deploy to Staging
    ├─ Build application
    ├─ Run deployment commands
    ├─ Health check
    └─ Notify result
    ↓
Staging Success?
    ├─ YES → Deploy to Production
    └─ NO → Stop (rollback staging)
    ↓
Deploy to Production
    ├─ Manual approval gate (optional)
    ├─ Build application
    ├─ Run deployment commands
    ├─ Health check
    └─ Notify result
    ↓
Send Summary Notification
```

### Jobs

#### 1. Deploy to Staging Job
```yaml
Runs: Ubuntu latest
Environment: staging

Conditions:
- Only if CI workflow succeeded
- Requires GitHub "staging" environment setup

Steps:
1. Checkout code
2. Setup JDK 25
3. Build application
4. Generate build metadata
5. Deploy to staging server
6. Run health checks
7. Notify deployment result
```

**Customization**: Update these lines in `cd.yml`:
```yaml
# TODO: Add your staging deployment commands here
# Example: scp target/JwtExample-*.jar user@staging-server:/opt/apps/
# Example: ssh user@staging-server 'systemctl restart jwt-example'
```

**Runtime**: Depends on deployment infrastructure

#### 2. Deploy to Production Job
```yaml
Runs: Ubuntu latest
Environment: production
Depends On: Staging deployment

Conditions:
- Only if staging deployment succeeded
- Requires GitHub "production" environment setup
- Optional manual approval gate

Steps:
1. Checkout code
2. Setup JDK 25
3. Build application
4. Generate build metadata
5. Optional approval check
6. Deploy to production server
7. Run health checks
8. Notify deployment result
```

**Customization**: Update these lines in `cd.yml`:
```yaml
# TODO: Add your production deployment commands here
# Example: scp target/JwtExample-*.jar user@prod-server:/opt/apps/
# Example: ssh user@prod-server 'systemctl restart jwt-example'
```

**Runtime**: Depends on deployment infrastructure

#### 3. Notify Job
```yaml
Runs: Ubuntu latest
Depends On: All deployment jobs

Outputs:
- Overall deployment status
- Staging result
- Production result
- Link to workflow run
```

### Exit Conditions
- ✅ Staging deployed successfully → Deploy to production
- ✅ Production deployed successfully → Workflow succeeds
- ❌ Staging deployment fails → Stop (no production deployment)
- ❌ Production deployment fails → Alert (staging already live)

---

## 📊 Workflow Comparison

### CI Workflow
| Aspect | Details |
|--------|---------|
| **Triggers** | Push to main/develop, PRs to main/develop |
| **Runs On** | Ubuntu latest |
| **Duration** | ~10-15 minutes |
| **Branches** | main, develop |
| **When Runs** | Every push/PR |
| **Purpose** | Test & validate code |
| **Success** | All tests & scans pass |
| **Failure** | CI stops, no deployment |

### CD Workflow
| Aspect | Details |
|--------|---------|
| **Triggers** | CI workflow completion |
| **Runs On** | Ubuntu latest |
| **Duration** | Depends on deployment |
| **Branches** | main only |
| **When Runs** | After CI succeeds |
| **Purpose** | Deploy to environments |
| **Success** | Deployed to staging & production |
| **Failure** | Stops at first failure |

---

## 🔗 Workflow Dependencies

```
┌────────────────────────────────────┐
│  Developer Push to main/develop    │
└──────────────┬─────────────────────┘
               │
               ▼
┌────────────────────────────────────┐
│  CI Workflow Triggered             │
│  - Build & Test                    │
│  - Security Scanning               │
│  - Code Quality Analysis           │
└──────────────┬─────────────────────┘
               │
        ┌──────┴──────┐
        │             │
    SUCCESS       FAILURE
        │             │
        ▼             ▼
    CD Triggered   Stop (No Deploy)
        │
        ▼
┌────────────────────────────────────┐
│  CD Workflow Triggered             │
│  - Deploy to Staging               │
│  - Deploy to Production (if ok)    │
│  - Send Notifications              │
└────────────────────────────────────┘
```

---

## 📁 File Structure

```
.github/
├── workflows/
│   ├── ci.yml              ← Continuous Integration
│   └── cd.yml              ← Continuous Deployment
└── dependabot.yml          ← Dependency Management
```

---

## 🎯 Benefits of Separation

### 1. **Clear Responsibility**
- CI = Quality, Testing, Validation
- CD = Deployment, Environment Management

### 2. **Better Control**
- CI runs on all branches
- CD runs only on main (production-ready)
- Can deploy without full rebuild

### 3. **Independent Failures**
- CI failure doesn't block CD
- CD failure doesn't stop CI
- Easier debugging and monitoring

### 4. **Flexible Deployment**
- Can trigger CD manually if needed
- Can skip CD for develop branch
- Can add approval gates to production

### 5. **Better Monitoring**
- Separate logs for each workflow
- Clear distinction in GitHub Actions tab
- Easier to track issues

### 6. **Security Benefits**
- Production secrets in CD only
- CI doesn't need deployment credentials
- Cleaner audit trail

---

## 🔐 GitHub Environments (Recommended)

To fully leverage the separated workflows, set up GitHub environments:

### Step 1: Create Staging Environment
1. Go to **Settings → Environments**
2. Click **New environment**
3. Name: `staging`
4. Add deployment branches: `main`
5. Add secrets:
   - `STAGING_SERVER` - Your staging server
   - `STAGING_USER` - SSH user
   - `STAGING_KEY` - SSH private key

### Step 2: Create Production Environment
1. Go to **Settings → Environments**
2. Click **New environment**
3. Name: `production`
4. Add deployment branches: `main`
5. Optional: Require reviewers for deployment
6. Add secrets:
   - `PROD_SERVER` - Your production server
   - `PROD_USER` - SSH user
   - `PROD_KEY` - SSH private key

---

## 💻 Customizing CD Deployment

### For Docker Deployment
Replace deployment step in `cd.yml`:
```yaml
- name: Deploy to Staging (Docker)
  run: |
    docker pull ${{ env.DOCKER_REGISTRY }}/jwt-example:latest
    docker stop jwt-example || true
    docker run -d --name jwt-example -p 8080:8080 \
      ${{ env.DOCKER_REGISTRY }}/jwt-example:latest
```

### For Kubernetes Deployment
Replace deployment step in `cd.yml`:
```yaml
- name: Deploy to Staging (K8s)
  run: |
    kubectl apply -f k8s/deployment.yaml
    kubectl rollout status deployment/jwt-example
```

### For Cloud Platforms (AWS, GCP, Azure)
```yaml
- name: Deploy to AWS
  run: |
    aws elasticbeanstalk create-application-version \
      --application-name jwt-example \
      --version-label ${{ github.sha }}
    aws elasticbeanstalk update-environment \
      --environment-name jwt-example-staging \
      --version-label ${{ github.sha }}
```

---

## 🚨 Monitoring CI/CD Workflows

### View CI Results
1. Go to **Actions** tab
2. Filter by workflow: **CI (Continuous Integration)**
3. View latest runs
4. Check test reports in artifacts

### View CD Results
1. Go to **Actions** tab
2. Filter by workflow: **CD (Continuous Deployment)**
3. View deployment status
4. Check logs for deployment steps

### Troubleshooting

**CI Failed - Deployment Blocked**
```
Check:
1. Go to Actions → CI workflow
2. Review build logs
3. Look for test failures
4. Fix code and push again
CD will not run until CI passes
```

**CD Failed - Stuck in Staging**
```
Check:
1. Go to Actions → CD workflow
2. Review staging deployment logs
3. Check staging environment access
4. Fix deployment config
Production will not deploy until staging succeeds
```

---

## 📋 Workflow Checklist

- [ ] `ci.yml` created and working
- [ ] `cd.yml` created and customized
- [ ] GitHub environments configured (staging & production)
- [ ] Staging deployment commands added
- [ ] Production deployment commands added
- [ ] Health check URLs configured
- [ ] Deployment secrets added to GitHub
- [ ] Test workflow with dummy deployment
- [ ] Monitor CI runs in Actions tab
- [ ] Monitor CD runs in Actions tab

---

## 🎯 Next Steps

1. **Customize Deployment**
   - Edit `.github/workflows/cd.yml`
   - Add your staging deployment commands
   - Add your production deployment commands
   - Add health check URLs

2. **Configure GitHub Environments**
   - Create `staging` environment
   - Create `production` environment
   - Add deployment secrets

3. **Set Up Approval Gates** (Optional)
   - Go to Settings → Environments
   - Click `production` environment
   - Enable "Require reviewers" for production deployments

4. **Test the Pipeline**
   - Push to main branch
   - Watch CI run in Actions tab
   - Watch CD deploy after CI succeeds
   - Verify deployments in staging and production

5. **Monitor and Maintain**
   - Check CI results for each commit
   - Review CD deployment logs
   - Monitor health checks
   - Update deployment commands as needed

---

## 📚 Related Documentation

- `H2_AND_CICD_SETUP.md` - H2 Console setup
- `H2_CICD_CONFIGURATION_SUMMARY.md` - Full configuration guide
- `DEPLOYMENT_CHECKLIST.md` - Deployment verification
- `ARCHITECTURE_DIAGRAMS.md` - Visual architecture

---

## ✅ Key Points

✅ **CI Workflow**
- Runs on every push/PR
- Tests code quality & security
- Prevents broken code from deploying

✅ **CD Workflow**
- Runs only after CI succeeds
- Deploys to staging first
- Then to production
- Has manual approval option

✅ **Independence**
- Workflows are completely separate
- Can manage independently
- Clear responsibilities
- Better error handling

✅ **Customizable**
- Add your deployment commands
- Configure environments
- Set approval gates
- Add notifications

---

**Status**: ✅ **Ready to Use**

This separation provides a clean, professional CI/CD setup suitable for production deployments!


