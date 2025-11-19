# Branch Protection Setup

This document explains the ruleset configuration for the `main` branch.

## Current Ruleset Configuration

The repository uses a GitHub Ruleset named **"PR on to main"** with the following configuration:

### Target
- **Branch pattern**: `refs/heads/main`
- **Enforcement**: Must be set to `Active` (not `Disabled`)

### Rules Enabled

#### 1. Pull Request Requirements
- **Required approvals**: 1
- **Dismiss stale reviews on push**: Yes
- **Require code owner review**: Yes (requires `.github/CODEOWNERS` file)
- **Require conversation resolution**: Yes
- **Allowed merge methods**: Squash and Rebase only

#### 2. Required Status Checks
- **Status check**: `validate-pr-title` (must pass before merge)
- **Strict mode**: Yes (branch must be up to date)
- **Enforce on creation**: Yes

#### 3. Branch Protection
- **Prevent deletion**: Yes
- **Prevent force pushes**: Yes (non-fast-forward protection)
- **Require linear history**: Yes

#### 4. Bypass Actors
- **None** - No one can bypass these rules

## What This Means

✅ **Anyone can contribute:**
- Fork the repository
- Create feature branches
- Submit Pull Requests

❌ **Protections enforced:**
- No direct pushes to `main` (even repository owner)
- All changes must go through Pull Requests
- PR titles must be valid (`validate-pr-title` check)
- Only code owner (@DiarmuidKelly) can approve PRs
- PRs require 1 approval before merge
- All conversations must be resolved
- Linear history enforced (no merge commits)

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
- ✅ `validate-pr-title` check passes
- Ready to merge (after approval)

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
  "enforcement": "disabled",  // Change this to "active"
  "conditions": {
    "ref_name": {
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
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["squash", "rebase"]
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          {
            "context": "validate-pr-title"
          }
        ]
      }
    },
    {
      "type": "required_linear_history"
    }
  ],
  "bypass_actors": []
}
```

## Troubleshooting

**"Require code owner review" not working**
- Make sure `.github/CODEOWNERS` file is committed to main branch
- GitHub needs to detect the file before the option works

**"validate-pr-title" check not appearing**
- Create a test PR first to trigger the workflow
- Wait a few minutes for GitHub to register the check
- Check Actions tab to see if workflow ran

**Want to temporarily disable**
- Settings → Rules → Rulesets → Edit → Change to "Disabled"
- Remember to re-enable when done!

## Workflow Summary

```
Developer Creates PR → validate-pr-title runs
                              ↓
                        PR title valid?
                              ↓
                    Code owner approves
                              ↓
                         Merge PR
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
