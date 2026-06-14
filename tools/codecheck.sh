#!/usr/bin/env bash
# Run before every handoff. Exit non-zero on any failure.
# Usage: ./tools/codecheck.sh

set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

FAILED=0

step() {
    echo ""
    echo "==> $1"
}

run_or_skip() {
    local tool="$1"
    shift
    if command -v "$tool" >/dev/null 2>&1; then
        "$@" || FAILED=1
    else
        echo "SKIP: $tool not found"
    fi
}

step "Lint (gdlint)"
run_or_skip gdlint gdlint scripts/ tests/

step "Format check (gdformat)"
run_or_skip gdformat gdformat --check scripts/ tests/

step "Headless boot smoke"
if command -v godot >/dev/null 2>&1; then
    godot --headless --path "$PROJECT_ROOT" --quit-after 1 || FAILED=1
elif command -v godot4 >/dev/null 2>&1; then
    godot4 --headless --path "$PROJECT_ROOT" --quit-after 1 || FAILED=1
else
    echo "SKIP: godot not found on PATH"
fi

step "Unit tests"
if command -v godot >/dev/null 2>&1 && [[ -f addons/gdUnit4/bin/GdUnitCmdTool.gd ]]; then
    godot --headless --path "$PROJECT_ROOT" \
        -s --remote-debug "tcp://127.0.0.1:0" \
        res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
        -a tests/ \
        --ignoreHeadlessMode || FAILED=1
else
    echo "SKIP: GdUnit4 not installed or godot unavailable"
fi

echo ""
if [[ "$FAILED" -ne 0 ]]; then
    echo "codecheck FAILED"
    exit 1
fi

echo "codecheck passed"
exit 0
