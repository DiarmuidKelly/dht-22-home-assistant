# Branch Protection Setup

This document explains the ruleset configuration for the `main` branch.

## Current Ruleset Configuration

The repository uses a GitHub Ruleset named **"PR on to main"** with the following configuration:

### Target
- **Branch pattern**: `refs/heads/main`
- **Enforcement**: Must be set to `Active` (not `Disabled`)

### Rules Enabled

#### 1. Pull Request Requirements
- **Required approvals**: 0 (maintainer can merge own PRs)
- **Dismiss stale reviews on push**: Yes
- **Require code owner review**: No
- **Require conversation resolution**: No
- **Allowed merge methods**: Squash and Rebase only

#### 2. Required Status Checks
- **Status check**: `Validate PR Title Format` (must pass before merge)
- **Strict mode**: Yes (branch must be up to date)
- **Enforce on creation**: No (allows branch creation without checks)

#### 3. Branch Protection
- **Prevent deletion**: Yes
- **Prevent force pushes**: Yes (non-fast-forward protection)
- **Require linear history**: Yes

#### 4. Bypass Actors
- **None** - No one can bypass these rules

## What This Means

✅ **External contributors:**
- Fork the repository
- Create feature branches in their fork
- Submit Pull Requests
- Repository owner reviews and merges

✅ **Repository owner (you):**
- Create feature branches in the repository
- Submit Pull Requests
- Merge own PRs (no approval needed)

❌ **Protections enforced:**
- No direct pushes to `main` (even repository owner)
- All changes must go through Pull Requests
- PR titles must be valid (`Validate PR Title Format` check)
- Branch must be up-to-date with main before merging
- Linear history enforced (no merge commits)
- Repository owner can merge own PRs without approval

🚀 **Automated workflow:**
- When PR is merged → Release automatically created
- Version bump determined from PR title
- Changelog auto-generated from commits

## Setup Instructions

### 1. Commit the CODEOWNERS file

```bash
git add .github/CODEOWNERS
git commit -m "chore: add CODEOWNERS file"
git push origin main  # Do this before enabling the ruleset!
```

### 2. Enable the Ruleset

1. Go to: **Settings** → **Rules** → **Rulesets**
2. Find: **"PR on to main"**
3. Change enforcement: **Disabled** → **Active**
4. Save

### 3. Configure Merge Methods

Go to: **Settings** → **General** → **Pull Requests**

Enable:
- ✅ **Allow squash merging** (recommended)
- ✅ **Allow rebase merging** (alternative)

Disable:
- ❌ **Allow merge commits** (breaks linear history)

## Testing the Ruleset

### Test 1: Direct push blocked
```bash
git push origin main
```
**Expected**: ❌ Remote rejected - must use Pull Request

### Test 2: PR with invalid title
Create PR with title: `some random changes`

**Expected**:
- ❌ `validate-pr-title` check fails
- Bot comments with error message

### Test 3: PR with valid title
Create PR with title: `[PATCH] fix sensor reading`

**Expected**:
- ✅ `Validate PR Title Format` check passes
- Ready to merge (no approval needed for owner)

### Test 4: Merge triggers release
Merge the PR

**Expected**:
- ✅ Release workflow runs
- ✅ New version created
- ✅ GitHub release published

## Exported Ruleset (Reference)

Your current ruleset configuration (exported from GitHub):

```json
{
  "name": "PR on to main",
  "target": "branch",
  "source_type": "Repository",
  "source": "DiarmuidKelly/dht-22-home-assistant",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": ["refs/heads/main"]
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": true,
        "required_reviewers": [],
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false,
        "automatic_copilot_code_review_enabled": false,
        "allowed_merge_methods": ["squash", "rebase"]
      }
    },
    {
      "type": "required_linear_history"
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "do_not_enforce_on_create": true,
        "required_status_checks": [
          {
            "context": "Validate PR Title Format",
            "integration_id": 15368
          }
        ]
      }
    }
  ],
  "bypass_actors": []
}
```

## Troubleshooting

**"Validate PR Title Format" check not appearing**
- Create a test PR first to trigger the workflow
- Wait a few minutes for GitHub to register the check
- Check Actions tab to see if workflow ran
- Ensure `.github/workflows/pr-validation.yml` has proper permissions

**Can't merge own PR**
- Verify `required_approving_review_count` is set to `0`
- Verify `require_code_owner_review` is set to `false`
- GitHub doesn't allow PR authors to approve their own PRs

**Want to temporarily disable**
- Settings → Rules → Rulesets → Edit → Change to "Disabled"
- Remember to re-enable when done!

## Workflow Summary

**For repository owner:**
```
Create branch → Push → Create PR → Validate PR Title Format check runs
                                            ↓
                                      PR title valid?
                                            ↓
                                       Merge PR
                                            ↓
                                pr-release.yml triggers
                                            ↓
                                  Auto-create release
```

**For external contributors:**
```
Fork repo → Create branch → Push to fork → Create PR → Validate PR Title Format
                                                              ↓
                                                        PR title valid?
                                                              ↓
                                                   Owner reviews & merges
                                                              ↓
                                                  pr-release.yml triggers
                                                              ↓
                                                    Auto-create release
```

## Related Files

- `.github/CODEOWNERS` - Defines code owners
- `.github/workflows/pr-validation.yml` - Validates PR titles
- `.github/workflows/pr-release.yml` - Creates releases on merge
- `CONTRIBUTING.md` - Contribution guidelines
