#!/usr/bin/env bash
# Run all AirTraffic unit tests
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
G3="${G3:-$HOME/repos/AIRL/g3}"

if [[ ! -x "$G3" ]]; then
    echo "Error: g3 compiler not found at $G3"
    echo "Build it: cd ~/repos/AIRL && bash scripts/build-g3.sh"
    exit 1
fi

PASS=0
FAIL=0

run_test() {
    local test_file="$1"
    local test_name="$(basename "$test_file" .airl)"
    echo -n "  $test_name... "

    # Compile test binary
    local test_bin="/tmp/airtraffic_test_$test_name"
    if ! "$G3" \
        "$ROOT_DIR/src/transport.airl" \
        "$ROOT_DIR/src/jsonrpc.airl" \
        "$ROOT_DIR/src/schema.airl" \
        "$ROOT_DIR/src/airtraffic.airl" \
        "$test_file" \
        -o "$test_bin" > /tmp/airtraffic_build_$test_name.log 2>&1; then
        echo "FAIL (build error)"
        cat /tmp/airtraffic_build_$test_name.log
        FAIL=$((FAIL + 1))
        return
    fi

    # Run test
    local output
    if output=$("$test_bin" 2>&1); then
        # Check for EXPECT comments in the test file
        local expected=$(grep '^;; EXPECT:' "$test_file" | sed 's/;; EXPECT: *//')
        if [[ -n "$expected" ]]; then
            if echo "$output" | grep -qF "$expected"; then
                echo "PASS"
                PASS=$((PASS + 1))
            else
                echo "FAIL (expected: $expected)"
                echo "    got: $output"
                FAIL=$((FAIL + 1))
            fi
        else
            echo "PASS"
            PASS=$((PASS + 1))
        fi
    else
        echo "FAIL (runtime error)"
        echo "    $output"
        FAIL=$((FAIL + 1))
    fi

    rm -f "$test_bin"
}

echo "=== AirTraffic Tests ==="

for test_file in "$SCRIPT_DIR"/*_test.airl; do
    [[ -f "$test_file" ]] && run_test "$test_file"
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
