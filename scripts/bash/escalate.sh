#!/usr/bin/env bash
# =============================================================================
# escalate.sh — CADRE Escalation Record Creator
#
# Usage: bash scripts/bash/escalate.sh <ESCALATION_ID> "<issue summary>" [severity]
#
# Purpose:
#   Create a structured escalation record when a conflict or decision
#   exceeds the authority of the current role. Archi and Inta use this
#   to escalate to Super.
#
# CADRE Invariants: I-06 (Human Final Authority), I-08 (N&S Communication)
#
# Severity: critical | high | medium (default: high)
#
# Exit codes:
#   0 — record created
#   1 — invalid args
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ESCALATION_ID="${1:-}"
SUMMARY="${2:-}"
SEVERITY="${3:-high}"

if [[ -z "$ESCALATION_ID" || -z "$SUMMARY" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/escalate.sh <ESCALATION_ID> \"<issue summary>\" [severity]${NC}"
  echo -e "   Severity: critical | high | medium (default: high)"
  echo -e "   Example: bash scripts/bash/escalate.sh ESC-001 \"Contract conflict: api-contract.md vs cli assumption\" critical"
  exit 1
fi

if [[ ! "$SEVERITY" =~ ^(critical|high|medium)$ ]]; then
  echo -e "${YELLOW}⚠️  Invalid severity '$SEVERITY' — defaulting to 'high'${NC}"
  SEVERITY="high"
fi

DATE=$(date -u +"%Y-%m-%d")
DATETIME=$(date -u +"%Y-%m-%d %H:%M UTC")

# Find escalations directory (project root or feature dir)
ESCALATIONS_DIR="escalations"
mkdir -p "$ESCALATIONS_DIR"

RECORD_FILE="${ESCALATIONS_DIR}/${ESCALATION_ID}.md"

if [[ -f "$RECORD_FILE" ]]; then
  echo -e "${RED}❌ Escalation record already exists: $RECORD_FILE${NC}"
  exit 1
fi

cat > "$RECORD_FILE" << EOF
# Escalation Record: ${ESCALATION_ID}

**Date**: ${DATE}
**Status**: open
**Severity**: ${SEVERITY}

---

## Initiator

- **Role**: ${USER:-agent}
- **From phase**: [P8-execution / P8b-review / P8c-integration]
- **Task ref**: [T00X or N/A]

## Issue

### What happened

${SUMMARY}

### Why it can't be resolved at current level

[Fill in: what authority is needed that current role doesn't have]

### Impact if unresolved

[Fill in: what breaks, what is blocked, what risk exists]

## Options

| Option | Description | Trade-off |
|--------|-------------|-----------|
| A | [option] | [pro / con] |
| B | [option] | [pro / con] |

**Recommended**: Option [X] — [one sentence why]

---

## Resolution

**Resolved by**:
**Date**:
**Decision**:
**Rationale**:

### Actions required

- [ ] [action 1] → [@owner] by [date]

---

## Audit trail

| Date | Actor | Action |
|------|-------|--------|
| ${DATETIME} | ${USER:-agent} | Escalation opened: ${SUMMARY} |
EOF

echo -e "${YELLOW}⚠️  ESCALATION CREATED: ${ESCALATION_ID} [${SEVERITY}]${NC}"
echo -e "${YELLOW}   ${SUMMARY}${NC}"
echo -e "${YELLOW}   File: ${RECORD_FILE}${NC}"
echo ""
echo -e "${CYAN}📋 Next steps:${NC}"
echo -e "   1. Fill in 'Why it can't be resolved' and 'Impact' sections"
echo -e "   2. Propose options with trade-offs"
echo -e "   3. Notify Super: review ${RECORD_FILE} and make decision"
echo -e "   4. Super updates Resolution section and signs off"
