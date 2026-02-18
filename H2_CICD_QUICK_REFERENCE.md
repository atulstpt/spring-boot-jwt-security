# Quick Reference: H2 Console & CI/CD

## 🗄️ H2 Console Access

**URL**: `http://localhost:8080/h2-console`

**Credentials**:
- Driver: `org.h2.Driver`
- URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (empty)

---

## 🔄 CI/CD Workflow

**Status**: ✅ Enabled

**Triggers**:
- `push` to `main` or `develop`
- `pull_request` to `main` or `develop`

**Jobs**:
1. **Build** - Compile & test
2. **Security Scan** - Trivy vulnerability scanning
3. **Code Quality** - SonarQube analysis (optional)

**View Results**: GitHub → Actions tab

---

## 🤖 Dependabot Configuration

**Status**: ✅ Enabled

**Update Schedule**:
- **Maven**: Weekly (Monday, 3:00 UTC)
- **GitHub Actions**: Weekly (Monday, 3:00 UTC)

**Features**:
- Auto-creates PRs for dependency updates
- Auto-creates PRs for security patches
- Auto-rebases PRs
- Labels: `dependencies`, `maven`, `github-actions`

**View Updates**: GitHub → Pull Requests tab

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `.github/workflows/ci-cd.yml` | GitHub Actions pipeline |
| `.github/dependabot.yml` | Dependabot configuration |
| `src/main/resources/application.yml` | Spring Boot config (H2 enabled) |
| `H2_AND_CICD_SETUP.md` | Detailed setup guide |

---

## 🚀 First-Time Setup

1. Push code to GitHub
2. Go to **Settings → Actions** → Allow all actions
3. Go to **Settings → Code security** → Enable Dependabot
4. (Optional) Add SonarQube secrets if needed

---

## 📊 Useful Commands

```bash
# Build locally
mvn clean package

# Run tests
mvn test

# Run with H2 console enabled
mvn spring-boot:run

# View dependencies tree
mvn dependency:tree
```

---

## 🔐 Optional GitHub Secrets

```
SONAR_HOST_URL      # SonarQube instance URL
SONAR_LOGIN         # SonarQube token
CODECOV_TOKEN       # Codecov integration token
```

Set these in: **Settings → Secrets and variables → Actions**

---

## 📞 Monitoring

### GitHub Actions Dashboard
- All workflow runs visible in **Actions** tab
- Per-job logs available for debugging
- Artifacts (test reports) downloadable

### Dependabot Activity
- View all dependency PRs in **Pull Requests** tab
- Filter by `dependencies` label
- Security alerts appear in **Security** tab

### H2 Console
- Access during development: `localhost:8080/h2-console`
- View live database state
- Execute custom SQL queries

---

## ⚠️ Important Notes

- H2 console enabled only in **dev** profile
- Dependabot security updates create PRs automatically
- CI/CD runs on every push/PR to protected branches
- SonarQube integration is optional (will skip if secrets not set)


