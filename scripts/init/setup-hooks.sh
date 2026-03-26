#!/usr/bin/env bash
# =============================================================================
# setup-hooks.sh — Install CADRE Git Hooks
#
# Usage:
#   bash scripts/bash/setup-hooks.sh
#
# Installs CADRE hooks into .git/hooks/
# Preserves existing hooks (sources them first, then extends)
# =============================================================================

set -euo pipefail

ORIG_CWD="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
GIT_HOOKS_DIR="$(git rev-parse --git-dir 2>/dev/null)/hooks"

if [[ -z "$GIT_HOOKS_DIR" ]] || [[ "$GIT_HOOKS_DIR" == "/hooks" ]]; then
    echo "Error: Not a git repository" >&2
    exit 1
fi

echo "=== CADRE Git Hooks Setup ==="
echo "Hooks directory: $GIT_HOOKS_DIR"
echo ""

mkdir -p "$GIT_HOOKS_DIR"

# -----------------------------------
# pre-push
# -----------------------------------
HOOK_NAME="pre-push"
HOOK_FILE="$GIT_HOOKS_DIR/$HOOK_NAME"
BACKUP_FILE="$HOOK_FILE.cadre.bak"

echo "Installing $HOOK_NAME hook..."

if [[ -f "$HOOK_FILE" ]]; then
    echo "  Existing hook found. Backing up."
    cp "$HOOK_FILE" "$BACKUP_FILE"
    {
        echo "#!/usr/bin/env bash"
        echo "# CADRE $HOOK_NAME hook - extended"
        echo 'if [[ -f "'"$BACKUP_FILE"'" ]]; then source "'"$BACKUP_FILE"'"; fi'
        echo ""
        cat <<'INNER'
echo "[CADRE] Running pre-push checks..."

# Run tests if package.json exists
if [[ -f "package.json" ]]; then
    echo "[CADRE] Running npm tests..."
    npm test --silent 2>/dev/null || { echo "[CADRE] Tests failed. Push rejected."; exit 1; }
fi

# Run lint if exists
if [[ -f ".eslintrc.js" ]] || [[ -f ".eslintrc.json" ]]; then
    echo "[CADRE] Running lint..."
    npx eslint --quiet . 2>/dev/null || { echo "[CADRE] Lint failed. Push rejected."; exit 1; }
fi

# Run Python tests if exists
if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
    echo "[CADRE] Running pytest..."
    python -m pytest --quiet 2>/dev/null || { echo "[CADRE] Tests failed. Push rejected."; exit 1; }
fi

echo "[CADRE] Pre-push checks passed."
INNER
    } > "$HOOK_FILE"
else
    cat > "$HOOK_FILE" <<'INNER'
#!/usr/bin/env bash
echo "[CADRE] Running pre-push checks..."

if [[ -f "package.json" ]]; then
    npm test --silent 2>/dev/null || { echo "[CADRE] Tests failed."; exit 1; }
fi

if [[ -f ".eslintrc.js" ]] || [[ -f ".eslintrc.json" ]]; then
    npx eslint --quiet . 2>/dev/null || { echo "[CADRE] Lint failed."; exit 1; }
fi

echo "[CADRE] Pre-push checks passed."
INNER
fi
chmod +x "$HOOK_FILE"
echo "  → pre-push installed"

# -----------------------------------
# post-push
# -----------------------------------
HOOK_NAME="post-push"
HOOK_FILE="$GIT_HOOKS_DIR/$HOOK_NAME"
BACKUP_FILE="$HOOK_FILE.cadre.bak"

echo "Installing $HOOK_NAME hook..."

if [[ -f "$HOOK_FILE" ]]; then
    cp "$HOOK_FILE" "$BACKUP_FILE"
    {
        echo "#!/usr/bin/env bash"
        echo 'if [[ -f "'"$BACKUP_FILE"'" ]]; then source "'"$BACKUP_FILE"'"; fi'
        echo ""
        cat <<'INNER'
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [[ "$BRANCH" == micro/* ]]; then
    echo "[CADRE] Microbranch pushed: $BRANCH"
fi
INNER
    } > "$HOOK_FILE"
else
    cat > "$HOOK_FILE" <<'INNER'
#!/usr/bin/env bash
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [[ "$BRANCH" == micro/* ]]; then
    echo "[CADRE] Microbranch pushed: $BRANCH"
fi
INNER
fi
chmod +x "$HOOK_FILE"
echo "  → post-push installed"

# -----------------------------------
# post-checkout
# -----------------------------------
HOOK_NAME="post-checkout"
HOOK_FILE="$GIT_HOOKS_DIR/$HOOK_NAME"
BACKUP_FILE="$HOOK_FILE.cadre.bak"

if [[ -f "$HOOK_FILE" ]]; then
    cp "$HOOK_FILE" "$BACKUP_FILE"
    {
        echo "#!/usr/bin/env bash"
        echo 'if [[ -f "'"$BACKUP_FILE"'" ]]; then source "'"$BACKUP_FILE"'"; fi'
        echo ""
        cat <<'INNER'
PREV_BRANCH=$1
NEW_BRANCH=$2
if [[ "$NEW_BRANCH" == micro/* ]]; then
    echo "[CADRE] Switched to microbranch: $NEW_BRANCH"
fi
if [[ "$NEW_BRANCH" == sprint/* ]]; then
    echo "[CADRE] Switched to sprint branch: $NEW_BRANCH"
fi
INNER
    } > "$HOOK_FILE"
else
    cat > "$HOOK_FILE" <<'INNER'
#!/usr/bin/env bash
PREV_BRANCH=$1
NEW_BRANCH=$2
if [[ "$NEW_BRANCH" == micro/* ]]; then
    echo "[CADRE] Switched to microbranch: $NEW_BRANCH"
fi
if [[ "$NEW_BRANCH" == sprint/* ]]; then
    echo "[CADRE] Switched to sprint branch: $NEW_BRANCH"
fi
INNER
fi
chmod +x "$HOOK_FILE"
echo "  → post-checkout installed"

# -----------------------------------
# post-commit
# -----------------------------------
HOOK_NAME="post-commit"
HOOK_FILE="$GIT_HOOKS_DIR/$HOOK_NAME"
BACKUP_FILE="$HOOK_FILE.cadre.bak"

if [[ -f "$HOOK_FILE" ]]; then
    cp "$HOOK_FILE" "$BACKUP_FILE"
    {
        echo "#!/usr/bin/env bash"
        echo 'if [[ -f "'"$BACKUP_FILE"'" ]]; then source "'"$BACKUP_FILE"'"; fi'
        echo ""
        cat <<'INNER'
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [[ "$BRANCH" == micro/* ]]; then
    echo "[CADRE] Microbranch committed: $BRANCH"
fi
INNER
    } > "$HOOK_FILE"
else
    cat > "$HOOK_FILE" <<'INNER'
#!/usr/bin/env bash
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [[ "$BRANCH" == micro/* ]]; then
    echo "[CADRE] Microbranch committed: $BRANCH"
fi
INNER
fi
chmod +x "$HOOK_FILE"
echo "  → post-commit installed"

# -----------------------------------
# post-merge
# -----------------------------------
HOOK_NAME="post-merge"
HOOK_FILE="$GIT_HOOKS_DIR/$HOOK_NAME"
BACKUP_FILE="$HOOK_FILE.cadre.bak"

if [[ -f "$HOOK_FILE" ]]; then
    cp "$HOOK_FILE" "$BACKUP_FILE"
    {
        echo "#!/usr/bin/env bash"
        echo 'if [[ -f "'"$BACKUP_FILE"'" ]]; then source "'"$BACKUP_FILE"'"; fi'
        echo ""
        cat <<'INNER'
MERGED_BRANCH=$1
if [[ "$MERGED_BRANCH" == sprint/* ]]; then
    echo "[CADRE] Sprint branch merged!"
fi
INNER
    } > "$HOOK_FILE"
else
    cat > "$HOOK_FILE" <<'INNER'
#!/usr/bin/env bash
MERGED_BRANCH=$1
if [[ "$MERGED_BRANCH" == sprint/* ]]; then
    echo "[CADRE] Sprint branch merged!"
fi
INNER
fi
chmod +x "$HOOK_FILE"
echo "  → post-merge installed"

echo ""
echo "✅ CADRE hooks installed:"
echo "  - pre-push:    tests + lint (blocks if fail)"
echo "  - post-push:   microbranch notification"
echo "  - post-checkout: branch switch notification"
echo "  - post-commit: commit notification"
echo "  - post-merge:  sprint merge notification"
echo ""
echo "Existing hooks preserved and sourced."
