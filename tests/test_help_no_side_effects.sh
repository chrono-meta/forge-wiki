#!/usr/bin/env bash
# test_help_no_side_effects.sh — known-pair anchor for "--help must not mutate the tree".
#
# WHY (measured 2026-08-18)
#   `main()` read `cmd = args[0]`, and `-h`/`--help` was never a flag — just an ignored extra
#   argument. So `fw.py init --help` did not print help: it RAN init, creating INDEX.md,
#   AGENTS.md and signals/ in the current directory. It was found by someone typing exactly that
#   in this repo's ROOT while trying to learn the CLI, which turned a tool repo into a wiki
#   instance. Asking a tool what it does is the one request that must be free of consequences;
#   a help request that writes files teaches people not to ask.
#
# Lanes
#   P1  `init --help` prints usage and creates NOTHING (the exact reported case)
#   P2  bare `--help` prints usage (before the fix this fell through to "unknown subcommand")
#   P3  `-h` behaves the same as `--help` (both spellings are the convention)
#   N1  control — `init` WITHOUT --help still creates the wiki (the fix must not disarm init)
#
# Exit 0 = 4/4.  A failure here means help acquired a side effect again, or init stopped working.

set -u
FW="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/fw.py"
pass=0; fail=0
_t() { if [ "$2" = "$3" ]; then echo "✅ $1"; pass=$((pass+1)); else echo "❌ $1 — got [$3] want [$2]"; fail=$((fail+1)); fi }

_fresh() { d=$(mktemp -d); echo "$d"; }
_count() { find "$1" -mindepth 1 2>/dev/null | wc -l | tr -d ' '; }

# P1 — init --help: usage on stdout, zero entries created
d=$(_fresh); out=$(cd "$d" && python3 "$FW" init --help 2>&1); rc=$?
_t "P1a init --help exits 0"                 "0"  "$rc"
_t "P1b init --help creates nothing"         "0"  "$(_count "$d")"
case "$out" in *"Subcommands"*) u=yes ;; *) u=no ;; esac
_t "P1c init --help prints usage"            "yes" "$u"
rm -rf "$d"

# P2 — bare --help
d=$(_fresh); out=$(cd "$d" && python3 "$FW" --help 2>&1); rc=$?
case "$out" in *"Subcommands"*) u=yes ;; *) u=no ;; esac
_t "P2 bare --help prints usage, rc=0"       "yes0" "${u}${rc}"
rm -rf "$d"

# P3 — -h spelling
d=$(_fresh); out=$(cd "$d" && python3 "$FW" -h 2>&1); rc=$?
case "$out" in *"Subcommands"*) u=yes ;; *) u=no ;; esac
_t "P3 -h prints usage, creates nothing"     "yes00" "${u}${rc}$(_count "$d")"
rm -rf "$d"

# N1 — CONTROL: real init must still work. Without this lane, "help creates nothing" is also
# satisfied by an init that creates nothing, i.e. by breaking the tool.
d=$(_fresh); (cd "$d" && python3 "$FW" init >/dev/null 2>&1)
have=no; [ -f "$d/INDEX.md" ] && [ -d "$d/signals" ] && have=yes
_t "N1 control — plain init still creates the wiki" "yes" "$have"
rm -rf "$d"

echo "── $pass passed · $fail failed"
[ "$fail" -eq 0 ]
