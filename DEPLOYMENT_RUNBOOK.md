# Deployment Runbook - JWT Example Application

## Overview

This runbook provides step-by-step instructions for deploying the JWT Example application to staging and production environments.

**Current Date:** February 18, 2026
**Application:** JWT Authentication Example
**Version:** 1.0.0

---

## Table of Contents

1. [Emergency Contacts](#emergency-contacts)
2. [Pre-Deployment Checklist](#pre-deployment-checklist)
3. [Staging Deployment](#staging-deployment)
4. [Production Deployment](#production-deployment)
5. [Post-Deployment Verification](#post-deployment-verification)
6. [Rollback Procedures](#rollback-procedures)
7. [Troubleshooting](#troubleshooting)

---

## Emergency Contacts

| Role | Name | Email | Phone | Availability |
|------|------|-------|-------|--------------|
| On-Call Engineer | [Name] | [Email] | [Phone] | 24/7 |
| DevOps Lead | [Name] | [Email] | [Phone] | Business Hours |
| Project Lead | [Name] | [Email] | [Phone] | Business Hours |
| Database Admin | [Name] | [Email] | [Phone] | On-Call |

**Escalation Path:**
1. Contact on-call engineer
2. If unresponsive in 15 min, contact DevOps lead
3. If unresponsive in 30 min, contact project lead

**Incident Slack Channel:** #incidents
**War Room URL:** [Conference call link]

---

## Pre-Deployment Checklist

### Before Starting Deployment

```bash
# 1. Verify you're deploying the right code
git log --oneline -5

# 2. Check that CI pipeline passed
# Go to: https://github.com/YOUR_ORG/JwtExample/actions

# 3. Confirm deployment date/time with team
# Schedule: [DEPLOYMENT_DATE] at [TIME] UTC

# 4. Notify stakeholders
# Message template: "Deploying build #[NUMBER] to [ENV] at [TIME]"

# 5. Prepare rollback plan (save this: git rev-parse HEAD)
CURRENT_SHA=$(git rev-parse HEAD)
echo "Rollback SHA: $CURRENT_SHA"
```

### Required Approvals

- [ ] Code review approved
- [ ] QA testing complete
- [ ] Business owner approval (for production)
- [ ] Security team approval (for production)

---

## Staging Deployment

### Timeline

- **Start:** [HH:MM UTC]
- **Expected Duration:** 15-20 minutes
- **End:** [HH:MM UTC]

### Step 1: Trigger CI/CD Pipeline

**Via GitHub UI:**

1. Navigate to: https://github.com/YOUR_ORG/JwtExample/actions
2. Click "CI (Continuous Integration) - Production Ready"
3. Click "Run workflow"
4. Select branch: `develop`
5. Click "Run workflow"
6. Wait for CI to complete (~15-20 minutes)
7. Verify: All jobs passed ✓

**Via GitHub CLI:**

```bash
gh workflow run ci-production.yml \
  --ref develop \
  --repo YOUR_ORG/JwtExample
```

### Step 2: Monitor CI Pipeline

```bash
# Watch workflow progress
gh run list \
  --workflow=ci-production.yml \
  --repo YOUR_ORG/JwtExample \
  --limit 1

# View detailed logs
gh run view <RUN_ID> --log \
  --repo YOUR_ORG/JwtExample
```

**Expected status:** ✓ PASSED

### Step 3: Verify Build Artifacts

```bash
# Download and verify JAR
gh run download <RUN_ID> \
  --name jar-artifacts-25 \
  --repo YOUR_ORG/JwtExample

# Check file
ls -lh jar-artifacts-25/
```

### Step 4: Trigger Staging Deployment

The CD pipeline should trigger automatically after CI success on `develop` branch.

**Manual trigger (if needed):**

```bash
gh workflow run cd-production.yml \
  --ref develop \
  --repo YOUR_ORG/JwtExample
```

### Step 5: Monitor Staging Deployment

```bash
# Watch deployment progress
gh run view <DEPLOYMENT_RUN_ID> --log \
  --repo YOUR_ORG/JwtExample
```

**Watch for status:**
- [ ] Artifact preparation: SUCCESS
- [ ] Staging deployment: SUCCESS
- [ ] Health checks: PASSED
- [ ] Smoke tests: PASSED

### Step 6: Verify Staging Environment

```bash
# Test health endpoint
curl -v http://staging-jwt-example.example.com/api/health

# Expected response:
# HTTP/1.1 200 OK
# {"status":"UP","components":{...}}

# Test authentication endpoint
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}' \
  http://staging-jwt-example.example.com/api/auth/signup

# Expected response: 200 or 400 with proper error message (not 500)
```

### Step 7: Run Integration Tests (Optional)

```bash
# If your CI includes integration tests
./scripts/integration-tests.sh staging

# Expected: All tests pass
```

### Staging Deployment Complete

✓ Staging environment is now updated and verified

**Next steps:**
1. Notify QA team
2. Allow 30 minutes for smoke testing
3. Wait for QA sign-off before production
4. If issues found, go to [Troubleshooting](#troubleshooting)

---

## Production Deployment

### Pre-Production Window

**Recommended deployment windows:**
- Tuesday - Thursday
- 09:00 - 15:00 UTC
- Avoid Fridays and weekends

**Required conditions:**
- [ ] Staging deployment verified successful
- [ ] QA team approved
- [ ] 2+ hours until business peak
- [ ] On-call team available
- [ ] Monitoring dashboards ready
- [ ] Rollback plan documented

### Step 1: Get Approval

**Send approval request:**

```
TO: [DevOps Team], [Project Lead]
SUBJECT: Prod Deployment Approval - Build #[NUMBER]

Requesting approval to deploy build #[NUMBER] to production.

Details:
- Branch: main
- Commit: [SHA]
- Changes: [Brief summary]
- Risk Level: [Low/Medium/High]
- Rollback Plan: [Reference to rollback procedure]
- Staging Status: ✓ Verified

Approval Link: https://github.com/YOUR_ORG/JwtExample/actions
```

### Step 2: Trigger Production Deployment

**Verify prerequisite:**
```bash
# Ensure main branch has all staging changes
git log --oneline -5 main
git log --oneline -5 develop
# main should be equal to or ahead of develop
```

**Trigger via GitHub:**

1. Navigate to: https://github.com/YOUR_ORG/JwtExample/actions
2. Click "CD (Continuous Deployment) - Production Ready"
3. Click "Run workflow"
4. CD pipeline will automatically deploy to staging first
5. Then pause waiting for production approval

### Step 3: Approve Production Deployment

When CD workflow reaches production step:

1. GitHub will show "Pending deployments"
2. Review deployment details:
   - Build number
   - Commit SHA
   - Changes summary
3. Click "Approve and deploy"
4. Enter approval reason
5. Click "Approve deployment"

### Step 4: Monitor Production Deployment

```bash
# Watch real-time deployment
gh run view <PROD_DEPLOYMENT_RUN_ID> --log

# Key steps to monitor:
# - Artifact download: Should complete in <2min
# - Pre-deployment validation: Should pass
# - Database migrations: If applicable
# - Application start: Should complete in <5min
# - Health checks: Must pass within 5 attempts
# - Smoke tests: Should run without errors
```

### Step 5: Verify Production Environment

```bash
# Critical verifications (in this order)
echo "=== Production Deployment Verification ==="

# 1. Health check
echo "1. Checking application health..."
curl -f http://jwt-example.example.com/api/health
# Expected: HTTP 200

# 2. Database connectivity
echo "2. Checking database..."
curl -f http://jwt-example.example.com/api/auth/health/db
# Expected: HTTP 200

# 3. Authentication test
echo "3. Testing authentication..."
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}' \
  http://jwt-example.example.com/api/auth/login
# Expected: HTTP 200 or 401 (auth error, not 500)

# 4. Protected endpoints
echo "4. Verifying protected endpoints..."
TOKEN=$(curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"user","password":"pass"}' \
  http://jwt-example.example.com/api/auth/login | jq -r '.token')

curl -H "Authorization: Bearer $TOKEN" \
  http://jwt-example.example.com/api/users/me
# Expected: HTTP 200 or 403 (permission error, not 500)
```

**Expected results:**
- [ ] Application responds to requests
- [ ] No error logs in first 5 minutes
- [ ] Response times normal (<1 second)
- [ ] Database queries returning results
- [ ] No authentication failures
- [ ] All critical endpoints accessible

### Step 6: Monitor Metrics

**Watch dashboard for next 30 minutes:**

```bash
# Monitor via your monitoring tool (DataDog, New Relic, etc.)
# Watch these metrics:

# 1. Error Rate
#    - Expected: < 0.1%
#    - Alert if: > 1%

# 2. Response Time (p95)
#    - Expected: < 500ms
#    - Alert if: > 2000ms

# 3. Memory Usage
#    - Expected: < 70% of max
#    - Alert if: > 85%

# 4. Throughput
#    - Expected: Normal traffic pattern
#    - Alert if: 0 requests (app down)

# 5. Database Query Time
#    - Expected: < 100ms avg
#    - Alert if: > 500ms
```

### Step 7: User Communication

**If deployment successful:**

```
TO: Users / Customers
SUBJECT: System Update Complete

The JWT Example service has been successfully updated to version [VERSION].

New features:
- [Feature 1]
- [Feature 2]

The service is now fully operational. Thank you for your patience.
```

**If deployment failed - See Rollback Procedures below**

---

## Post-Deployment Verification

### Immediate (0-5 minutes)

- [ ] Application started without errors
- [ ] Health check endpoint responding
- [ ] No spike in error logs
- [ ] Database connections established
- [ ] No unusual resource usage

### Short-term (5-30 minutes)

- [ ] All API endpoints responding correctly
- [ ] Authentication system working
- [ ] No user-reported issues
- [ ] Error rate stable
- [ ] Performance metrics normal

### Extended (30 min - 4 hours)

- [ ] Run comprehensive test suite:

```bash
./scripts/smoke-tests.sh production

# Expected: All tests pass
# If fails: Review logs and consider rollback
```

- [ ] Monitor error patterns
- [ ] Monitor performance trends
- [ ] Collect user feedback
- [ ] Verify backup completion

### Long-term (4+ hours)

- [ ] Generate deployment report
- [ ] Update documentation
- [ ] Archive logs
- [ ] Schedule post-mortem if issues
- [ ] Update change log

---

## Rollback Procedures

### When to Rollback

Initiate rollback if:
- [ ] Critical application errors
- [ ] Database corruption detected
- [ ] Security vulnerability discovered
- [ ] Service unavailable for >5 minutes
- [ ] Error rate > 5%
- [ ] Data loss detected

### Emergency Rollback (Quick)

**Duration:** ~5-10 minutes

```bash
# 1. ALERT: Declare incident
echo "🚨 INCIDENT DECLARED - Initiating rollback"
# Notify: #incidents channel, on-call team

# 2. Get previous version
git log --oneline -10
PREVIOUS_COMMIT=$(git rev-parse HEAD~1)

# 3. Trigger CD for previous version
gh workflow run cd-production.yml \
  --ref main \
  --repo YOUR_ORG/JwtExample

# 4. At the approval step:
# Click "Approve deployment" for rollback

# 5. Monitor rollback progress
gh run view <ROLLBACK_RUN_ID> --log

# 6. Verify restoration
curl http://jwt-example.example.com/api/health

# 7. Confirm with team
echo "✓ Rollback complete - System restored to previous version"
```

### Backup-Based Rollback (Safest)

**Duration:** ~10-20 minutes (depending on backup size)

```bash
# 1. SSH to production server
ssh prod_user@prod.example.com

# 2. Stop application
sudo systemctl stop jwt-example

# 3. Restore from backup
cd /opt/apps
sudo cp jwt-example.jar.backup jwt-example.jar

# 4. Verify permissions
sudo chown app:app jwt-example.jar

# 5. Start application
sudo systemctl start jwt-example

# 6. Check health
sleep 10
curl http://localhost:8080/api/health

# 7. Check logs
sudo tail -f /var/log/jwt-example.log
```

### Database Rollback (If Needed)

```bash
# 1. Contact DBA immediately
echo "Database rollback required - contacting DBA"

# 2. DBA executes restore:
# From pgAdmin or command line:
# psql -U jwt_user -d jwt_example < /backups/jwt_example_pre_deployment.sql

# 3. Verify database integrity
psql -U jwt_user -d jwt_example -c "SELECT COUNT(*) FROM users;"

# 4. Test application connectivity
curl http://jwt-example.example.com/api/health
```

### Post-Rollback Steps

```bash
# 1. Verify system stability
./scripts/smoke-tests.sh production
# All tests must PASS

# 2. Investigate root cause
# Review error logs from failed deployment
# Document findings

# 3. Notify stakeholders
echo "Rollback completed. System restored to previous version."
echo "Investigating root cause of deployment failure."

# 4. Fix and redeploy
# - Fix the issue in code
# - Test in staging thoroughly
# - Plan redeployment for next window
```

---

## Troubleshooting

### Issue: CI Pipeline Fails

**Symptoms:** CI job marked as failed

**Resolution:**

```bash
# 1. View detailed logs
gh run view <CI_RUN_ID> --log

# 2. Identify failed step (look for ❌)

# 3. Common causes:
#    - Maven build error → Fix pom.xml
#    - Test failure → Fix test or code
#    - Security scan failure → Review finding
#    - Compilation error → Fix code

# 4. Test locally
mvn clean package

# 5. Push fix to branch
git add .
git commit -m "Fix CI failure: [issue]"
git push origin develop

# 6. Re-run CI
# New push automatically triggers CI
```

### Issue: Health Checks Timeout

**Symptoms:** Deployment succeeds but health check fails

**Resolution:**

```bash
# 1. SSH to server
ssh prod_user@prod.example.com

# 2. Check application status
sudo systemctl status jwt-example
# Should show: active (running)

# 3. Check application logs
sudo tail -f /var/log/jwt-example.log
# Look for error messages

# 4. Test endpoint manually
curl -v http://localhost:8080/api/health

# 5. If application won't start, try:
sudo systemctl restart jwt-example
sleep 15
curl http://localhost:8080/api/health

# 6. If still failing, check:
# - Disk space: df -h
# - Memory: free -h
# - Port conflict: sudo lsof -i :8080
# - File permissions: ls -la /opt/apps/

# 7. If unresolvable, initiate rollback
```

### Issue: Database Connection Fails

**Symptoms:** Application starts but can't query database

**Resolution:**

```bash
# 1. Verify database is accessible
psql -h prod-db.example.com -U jwt_user -d jwt_example -c "SELECT 1;"

# 2. Check connection string in config
sudo cat /opt/apps/application.yml | grep -A5 datasource

# 3. Verify credentials are correct
# Compare with secrets in GitHub: Settings → Secrets

# 4. Check database is accepting connections
# On database server: sudo systemctl status postgresql

# 5. Check firewall rules
# Verify port 5432 is open: netstat -tulpn | grep 5432

# 6. If network issue, try:
# - Restart application to reconnect
# - Or initiate rollback if persistent
```

### Issue: Memory Leak Detected

**Symptoms:** Memory usage steadily increasing

**Resolution:**

```bash
# 1. Monitor memory growth
free -h  # Check every minute for 10 minutes

# 2. If confirmed leak:
# Option 1 (temporary): Restart application
sudo systemctl restart jwt-example

# Option 2 (permanent): Rollback to previous version
# Follow rollback procedure above

# 3. Contact development team with:
# - Timestamp of leak detection
# - Memory growth rate
# - Application logs
# - Heap dumps if available

# 4. Plan code review to find leak
```

### Issue: "Permission Denied" Errors

**Symptoms:** Deployment succeeds but application can't write files

**Resolution:**

```bash
# 1. Check file permissions
ls -la /opt/apps/

# 2. Check owner
# Should be: app:app (or whatever user runs app)

# 3. Fix permissions
sudo chown -R app:app /opt/apps
sudo chmod 755 /opt/apps

# 4. Restart application
sudo systemctl restart jwt-example

# 5. Verify
curl http://localhost:8080/api/health
```

### Issue: Secret/Credential Error

**Symptoms:** "Invalid JWT secret" or authentication failures

**Resolution:**

```bash
# 1. Verify secret is set in environment
echo $JWT_SECRET  # Should output something (not empty)

# 2. Check GitHub secrets
# Settings → Secrets and variables → Actions
# Verify JWT_SECRET exists

# 3. Check it's configured in environment variables
# Check: /opt/apps/start.sh or systemd service

# 4. Verify secret value matches
# (Should match what's in GitHub)

# 5. If changed, redeploy with new secret
# Update GitHub secret → Redeploy
```

---

## Post-Incident Review

After any deployment issue:

```bash
# 1. Schedule post-mortem
# When: Within 24 hours
# Who: Dev team, DevOps, QA, Product

# 2. Document findings
cat > post-mortem-[DATE].md << EOF
# Post-Mortem: [Incident Title]

## Timeline
[When did issue start]
[When was it detected]
[When was it resolved]

## Root Cause
[What went wrong]

## Impact
[How many users affected]
[How long outage lasted]

## Resolution
[What was done to fix it]

## Prevention
[What will prevent this next time]

## Action Items
- [ ] Fix in code
- [ ] Add test
- [ ] Update documentation
EOF

# 3. Create follow-up tickets
# Add to issue tracker with "deployment-lessons-learned" label

# 4. Update runbook if needed
# Make adjustments based on what you learned
```

---

## Quick Reference

### Emergency Contacts
- On-Call: [Phone/Slack]
- DevOps: [Phone/Slack]
- Database: [Phone/Slack]

### Key URLs
- GitHub Actions: https://github.com/YOUR_ORG/JwtExample/actions
- Monitoring Dashboard: [Your monitoring URL]
- Application - Staging: http://staging-jwt-example.example.com
- Application - Production: http://jwt-example.example.com

### Important Commands

```bash
# Check status
curl http://jwt-example.example.com/api/health

# View logs
ssh prod_user@prod.example.com
tail -f /var/log/jwt-example.log

# Restart (emergency)
ssh prod_user@prod.example.com
sudo systemctl restart jwt-example

# Rollback
git log main --oneline -5  # Find previous version
gh workflow run cd-production.yml --ref main  # Redeploy previous
```

### Escalation Procedure

1. **Detection** (First 2 minutes)
   - Alert Slack #incidents
   - Page on-call engineer

2. **Investigation** (Next 5 minutes)
   - Identify root cause
   - Decide: fix forward or rollback

3. **Resolution** (Next 15-30 minutes)
   - Execute rollback or fix
   - Verify system stability

4. **Communication** (Ongoing)
   - Update status page
   - Notify users if outage > 5 minutes
   - Document in incident tracker

5. **Follow-up** (Within 24 hours)
   - Post-mortem meeting
   - Root cause analysis
   - Action items and prevention

---

**Document Version:** 1.0
**Last Updated:** February 18, 2026
**Next Review:** 3 months from deployment

---

For questions or updates to this runbook, contact: [DevOps Team Email]

