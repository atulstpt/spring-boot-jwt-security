# H2 Console & CI/CD Setup Guide

## H2 Console Configuration

The H2 console is now fully enabled in your Spring Boot application for development purposes. This allows you to view and manage the in-memory H2 database directly through a web interface.

### Accessing the H2 Console

1. **Start the application**: Run the Spring Boot application normally
2. **Navigate to**: `http://localhost:8080/h2-console`
3. **Database Details** (from `application.yml`):
   - **Driver Class**: `org.h2.Driver`
   - **JDBC URL**: `jdbc:h2:mem:testdb`
   - **User Name**: `sa`
   - **Password**: (leave empty)

### H2 Console Features

- **View Tables**: See all tables in the database
- **Run SQL Queries**: Execute custom SQL queries
- **Browse Data**: View and modify database records
- **Monitor Schema**: Check indexes, constraints, and relationships

### Configuration Details

The H2 console configuration in `application.yml`:

```yaml
h2:
  console:
    enabled: true          # Enable H2 web console
    path: /h2-console     # Access path
    settings:
      trace: false        # Disable trace logs
      web-allow-others: false  # Restrict to localhost for security
```

**Important**: H2 console is only enabled in the development profile and should be disabled in production.

---

## GitHub Actions CI/CD Pipeline

A complete CI/CD pipeline has been set up with the following components:

### Workflow Location

File: `.github/workflows/ci-cd.yml`

### Pipeline Jobs

#### 1. **Build Job**
- Runs on: `ubuntu-latest`
- Java Version: `25`
- Steps:
  - Checkout code
  - Set up JDK with Maven cache
  - Clean build (skip tests)
  - Run unit tests
  - Upload test reports as artifacts

#### 2. **Security Scan Job**
- Runs vulnerability scanning using Trivy
- Uploads results to GitHub's Security tab
- Provides SARIF format reports

#### 3. **Code Quality Job**
- Optional SonarQube integration
- Requires SonarQube secrets to be configured
- Can be extended for code coverage analysis

### Triggers

The pipeline runs on:
- **Push** to `main` or `develop` branches
- **Pull Requests** to `main` or `develop` branches

---

## Dependabot Configuration

A Dependabot configuration file has been created at `.github/dependabot.yml`

### Features

#### Maven Dependencies
- **Schedule**: Weekly (Mondays at 3:00 UTC)
- **Auto-rebase**: Enabled
- **Security Updates**: Automatic PR creation
- **Limits**: Up to 10 open PRs at once

#### GitHub Actions
- **Schedule**: Weekly updates
- **Limits**: Up to 5 open PRs at once
- **Auto-rebase**: Enabled

### Benefits

1. **Automatic Dependency Updates**: Receives PRs for new dependency versions
2. **Security Patches**: Automatic PRs for security vulnerabilities
3. **Testing**: Each PR runs through the CI/CD pipeline
4. **Labels & Reviews**: Automatically labeled and ready for review

---

## GitHub Secrets Configuration

For optional enhanced features, add these secrets in your GitHub repository settings:

### For SonarQube Integration (Optional)
```
SONAR_HOST_URL: https://your-sonarqube-instance.com
SONAR_LOGIN: your-sonarqube-token
```

### For Codecov Integration (Optional)
```
CODECOV_TOKEN: your-codecov-token
```

---

## First-Time Setup Steps

1. **Push to GitHub**: Ensure your repository is pushed to GitHub
2. **Enable GitHub Actions**: Go to repository Settings → Actions → Allow all actions
3. **Enable Dependabot**: Go to repository Settings → Code security and analysis → Enable Dependabot
4. **Configure Branch Protection**: Optional but recommended
   - Require CI/CD checks to pass before merging
   - Require pull request reviews

---

## Viewing CI/CD Results

### GitHub Actions
- Go to **Actions** tab in your repository
- See all workflow runs and their status
- View logs for each job and step

### Dependabot PRs
- Go to **Pull Requests** tab
- Filter by "dependencies" label
- Review and merge dependency updates

### Security Results
- Go to **Security** tab
- View vulnerability reports
- Check Trivy scan results

---

## Local Development with H2

### Sample Database Query Access
```bash
# While app is running:
curl http://localhost:8080/h2-console
```

### Monitoring Database Changes
1. Open H2 console in browser
2. Execute: `SELECT * FROM users;`
3. Watch real-time database changes as you interact with your API

---

## Troubleshooting

### H2 Console Not Loading
- Verify `spring.h2.console.enabled: true` in `application.yml`
- Check if using development profile
- Ensure H2 dependency is in `pom.xml`

### CI/CD Pipeline Failing
- Check GitHub Actions logs for specific errors
- Verify JDK version compatibility
- Ensure Maven is properly cached

### Dependabot PRs Not Creating
- Go to repository Settings → Code security and analysis
- Toggle Dependabot on/off to refresh
- Check that `.github/dependabot.yml` exists

---

## Next Steps

1. **Test the H2 Console**: Access it after starting the application
2. **Push Changes**: Commit and push to trigger the CI/CD pipeline
3. **Monitor Dependabot**: Watch for dependency update PRs
4. **Configure Secrets**: Set up SonarQube/Codecov for enhanced analysis

