#!/usr/bin/env bash
# test_status_reaches_index.sh — known-pair anchor for "a declared status reaches the READING surface".
#
# WHY (measured 2026-08-18, forge-wiki lineage)
#   An automated digest run had its web fetches blocked, so it landed a node carrying
#   `status: constrained` and no live signal. It did NOT fabricate citations — it declared the
#   degrade in frontmatter. But the derived index rendered the node as an ordinary digest: the
#   warning existed only in the body.
#
#   This wiki's own protocol is "read INDEX.md first; open only what it makes relevant". A status
#   that never reaches the index is therefore a slot with no consumer — the author believes the
#   degrade is declared, and the reader never sees it. Both derived surfaces (INDEX AUTO block and
#   llms.txt) must carry it; fixing one is a half-fix, and llms.txt is the surface AGENTS read.
#
# Lanes
#   P1  `status: constrained` → index line carries a marker
#   P2  same node → llms.txt carries it too (the second reading surface)
#   N1  CONTROL — a node with NO status gets NO marker (the fix must not tag everything)
#   N2  CONTROL — `status: DONE` keeps ⛔closed and is NOT double-marked
#   N3  CONTROL — a BODY line saying `status: x` must NOT leak into the index (frontmatter only).
#       Backported from the origin implementation (fh-be/scripts/index_sync.py), whose lane carried
#       it first: writing the parser there made "what if it leaks from the body?" visible.
#
# N1/N2 are the load-bearing lanes: "status is surfaced" is also satisfied by marking every node,
# which would make the marker meaningless. Exit 0 = 4/4.

set -u
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass=0; fail=0
_t() { if [ "$2" = "$3" ]; then echo "✅ $1"; pass=$((pass+1)); else echo "❌ $1 — got [$3] want [$2]"; fail=$((fail+1)); fi }

d=$(mktemp -d); mkdir -p "$d/signals"
# $2 is a whole frontmatter LINE or empty. Built with a here-doc rather than printf: passing
# "status: X\n" as a printf ARGUMENT does not expand the \n (only the FORMAT is expanded), which
# silently collapses frontmatter onto one line — that defect made this suite report a false
# failure on first run, and made N2 pass for the wrong reason (CLOSED_RE searches the whole text,
# so it still matched inside the collapsed line).
_node() {  # $1 name · $2 frontmatter line or "" · $3 description · $4 extra BODY line
  { echo "---"; echo "name: $1"; echo "type: note"
    [ -n "$2" ] && echo "$2"
    echo "description: $3"; echo "date: 2026-08-18"; echo "---"; echo; echo "# $1"
    [ -n "${4:-}" ] && echo "$4"
  } > "$d/signals/$1_2026-08-18_ctl.md"
}
_node probe "status: constrained" "probe node declaring a degrade status"
_node plain ""                    "control node with no status"
_node done  "status: DONE"        "closed note"
_node bodyonly ""                 "node whose BODY mentions a status" "status: leaked-from-body"
( cd "$d" && python3 "$REPO/bin/fw.py" init >/dev/null 2>&1 && python3 "$REPO/bin/fw.py" sync --write >/dev/null 2>&1 )

_line() { grep "^- \[$1" "$d/INDEX.md" 2>/dev/null | head -1; }
case "$(_line probe)" in *"constrained"*) r=yes ;; *) r=no ;; esac
_t "P1 index surfaces a declared status"            "yes" "$r"
case "$(grep '^- \[probe' "$d/llms.txt" 2>/dev/null)" in *"constrained"*) r=yes ;; *) r=no ;; esac
_t "P2 llms.txt surfaces it too (agent-read surface)" "yes" "$r"
case "$(_line plain)" in *"⚑"*) r=marked ;; *) r=clean ;; esac
_t "N1 control — no status means no marker"          "clean" "$r"
l="$(_line done)"; case "$l" in *"⛔closed"*) c=yes ;; *) c=no ;; esac
case "$l" in *"⚑"*) dbl=yes ;; *) dbl=no ;; esac
_t "N2 control — DONE stays ⛔closed, not doubled"    "yesno" "${c}${dbl}"

case "$(_line bodyonly)" in *"⚑"*) r=leaked ;; *) r=clean ;; esac
_t "N3 control — body 'status:' does not leak (frontmatter only)" "clean" "$r"

rm -rf "$d"
echo "── $pass passed · $fail failed"
[ "$fail" -eq 0 ]
