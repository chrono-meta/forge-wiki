#!/usr/bin/env bash
# wiki_dialect_lint.sh — BAN 층. 변환 불가한 옵시디언 문법을 차단한다(exit 1).
# ⚠️ 이건 denylist 다 — 새 옵시디언 문법은 목록에 추가되기 전까지 조용히 통과한다(명시된 잔여).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
# knowledge/ 가 있으면 그것, 없으면 루트 — 미러/원본 양쪽 동작
DIR="${1:-}"; [ -z "$DIR" ] && { [ -d knowledge ] && DIR=knowledge || DIR=.; }
fail=0
_hit(){ echo "FAIL  $1"; fail=1; }

[ -d "$DIR" ] || { echo "UNMEASURED  $DIR 부재 — 검사 대상 없음(공허 PASS 금지)"; exit 0; }
N=$(find "$DIR" -name '*.md' | wc -l | tr -d ' ')
[ "${N:-0}" -eq 0 ] && { echo "UNMEASURED  $DIR 에 마크다운 0건"; exit 0; }

grep -rn '\[\[' "$DIR" --include='*.md' 2>/dev/null | head -5 | while read -r l; do echo "      $l"; done
grep -rq '\[\[' "$DIR" --include='*.md' 2>/dev/null && _hit "잔존 위키링크 [[...]] — 노멀라이저를 돌리거나 대상 파일이 없다"
grep -rqE '```(dataview|dataviewjs|base)' "$DIR" --include='*.md' 2>/dev/null && _hit "dataview/base 블록 — 지식이 파일 안에 존재하지 않게 된다"
grep -rq '%%' "$DIR" --include='*.md' 2>/dev/null && _hit "%%주석%% — 편집 중엔 숨고 발행 시 노출되는 누출 모양"
grep -rqE '(^|\s)\^[a-zA-Z0-9]{6,}\s*$' "$DIR" --include='*.md' 2>/dev/null && _hit "블록 ID ^abc123 — 외부에서 해석 불가"
grep -rqE '==[^=]+==' "$DIR" --include='*.md' 2>/dev/null && _hit "==하이라이트== — GitHub 에서 리터럴로 보인다"
find "$DIR" -name '*.canvas' 2>/dev/null | grep -q . && _hit ".canvas — 산문이 아니라 좌표다. 에이전트가 못 읽는다"
find "$DIR" -name '* *' 2>/dev/null | grep -q . && _hit "파일명 공백 — %20 churn + 일부 호스트에서 깨짐"
BAD=$(grep -rhoE '^>\s*\[!([A-Za-z]+)\]' "$DIR" --include='*.md' 2>/dev/null \
      | sed -E 's/.*\[!([A-Za-z]+)\]/\1/' | tr 'a-z' 'A-Z' | sort -u \
      | grep -vE '^(NOTE|TIP|IMPORTANT|WARNING|CAUTION)$' || true)
[ -n "$BAD" ] && _hit "GFM 외 콜아웃: $(echo $BAD | tr '\n' ' ')"

echo "-- dialect lint: $([ "$fail" -eq 0 ] && echo PASS || echo FAIL) ($N files) --"
exit "$fail"
