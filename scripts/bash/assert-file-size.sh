#!/usr/env bash
# assert-file-size.sh — CADRE Micro-Module Enforcement
# Usage: bash assert-file-size.sh <FILE> [MAX_LINES=150]
#
# Exits 0 if file is within limit, 1 if oversized.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FILE="${1:-}"
MAX_LINES="${2:-150}"

if [[ -z "$FILE" ]]; then
  echo "Usage: bash assert-file-size.sh <FILE> [MAX_LINES]"
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo -e "${RED}❌ File not found: $FILE${NC}"
  exit 1
fi

ACTUAL=$(wc -l < "$FILE")

if (( ACTUAL > MAX_LINES )); then
  echo -e "${RED}❌ VIOLATION: $FILE is ${ACTUAL} lines (max: ${MAX_LINES})${NC}"
  exit 1
else
  echo -e "${GREEN}✅ $FILE: ${ACTUAL}/${MAX_LINES} lines${NC}"
  exit 0
fi
