# CADRE Testing Notes — SpecForge

## Issues Found During Testing

### 1. Branch Naming: master vs main
**Problem:** SpecForge uses `master`, CADRE defaults to `main`
**Fix:** sprint-branch.sh needs to detect:
```bash
# Detect main branch
if git show-ref --verify --quiet refs/heads/main; then
    MAIN_BRANCH=main
elif git show-ref --verify --quiet refs/heads/master; then
    MAIN_BRANCH=master
else
    echo "Error: Cannot find main branch"
    exit 1
fi
```

### 2. Uncommitted Changes
**Problem:** Cannot switch branches with dirty working directory
**Fix:** sprint-branch.sh should:
1. Check for uncommitted changes
2. Warn user: "Stash or commit changes before creating sprint branch"
3. Exit if dirty

### 3. .gitignore
**Problem:** Some projects already have .gitignore
**Fix:** Check if CADRE entries exist before adding

## CADRE Improvements Needed

### sprint-branch.sh
- [ ] Detect master vs main
- [ ] Check for uncommitted changes
- [ ] Better error handling

### General
- [ ] Test on clean project first
- [ ] Document: sprint branch = only on clean state
- [ ] Or: auto-stash before branch

## Test Results

### SpecForge State
- Branch: 003-artifact-editor (detached from commits)
- Has active work
- Not ideal for sprint branch test

### Recommended Test Setup
1. Create new test epic
2. Run on clean project with no active work
3. Test I1-I6 flow
