#!/usr/bin/env bash
# =============================================================================
# assert-red.sh — CADRE Red Phase Gate
#
# Usage: bash scripts/bash/assert-red.sh <pytest_path> [pytest_args...]
#
# Purpose:
#   Verify that contract tests are FAILING before implementation agents are
#   spawned (Phase 3+). If all tests pass, it means implementation leaked
#   into Phase 2 — gate blocks and reports an incident.
#
# CADRE Invariants: I-10 (Evidence-Based Readiness), Constitution IV (Test-First)
#
# Exit codes:
#   0 — Red phase confirmed (failures > 0), safe to proceed to Phase 3
#   1 — Gate failed: all tests pass or pytest couldn't run
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/assert-red.sh <test_path> [pytest_args...]${NC}"
  exit 1
fi

shift || true  # remaining args passed to pytest

echo -e "${YELLOW}🔴 CADRE Red Phase Gate — checking: $TARGET${NC}"

# Run pytest, capture output
set +e
output=$(python3 -m pytest "$TARGET" "$@" 2>&1)
pytest_exit=$?
set -e

# Parse failures and errors
failures=$(echo "$output" | grep -cE "^FAILED" || true)
errors=$(echo "$output" | grep -cE "^ERROR" || true)
passed=$(echo "$output" | grep -oE "[0-9]+ passed" | grep -oE "[0-9]+" || echo "0")
total_bad=$((failures + errors))

echo "$output" | tail -5

echo ""

if [[ $total_bad -gt 0 ]]; then
  echo -e "${GREEN}✅ Red phase confirmed: $total_bad failing test(s), $passed passing${NC}"
  echo -e "${GREEN}   Safe to spawn Phase 3 (implementation) agents.${NC}"
  exit 0
else
  echo -e "${RED}❌ RED PHASE GATE BLOCKED${NC}"
  echo -e "${RED}   All tests pass ($passed passed, 0 failures).${NC}"
  echo -e "${RED}   Implementation likely leaked into Phase 2.${NC}"
  echo ""
  echo -e "${YELLOW}📋 INC: Log this as an incident — @agent skipped Red phase.${NC}"
  echo -e "${YELLOW}   Root cause: agent received full spec context and implemented early.${NC}"
  echo -e "${YELLOW}   Fix: use context-starvation (provide only api-contract.md, not data-model).${NC}"
  exit 1
fi
