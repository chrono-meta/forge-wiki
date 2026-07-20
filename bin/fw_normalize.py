#!/usr/bin/env python3
"""wiki_normalize.py — 옵시디언 문법 중 '변환 가능한 것'을 GFM-safe 형태로 바꾼다. 멱등.

왜: 옵시디언은 표준 링크 [text](path.md) 를 그대로 읽고 그래프/백링크도 만든다.
    위키링크는 *선호*지 요구가 아니다. 그래서 교집합을 통째로 언어로 삼을 수 있다.
    변환 불가한 것(dataview·canvas·블록ID)은 여기서 안 건드리고 lint 가 막는다.
Usage: python3 scripts/wiki_normalize.py [files...]   (없으면 knowledge/ 전체)
"""
import re, sys, pathlib

# ⚠️ ROOT 는 __file__ 기준이면 안 된다 — 도구로 다른 위키에 돌릴 때 forge-wiki 자기 디렉터리를
# 뒤지게 되어 링크 대상을 못 찾는다(실측 2026-07-21). 대상 파일에서 위로 올라가며 결정한다.
def _root_for(p: "pathlib.Path"):
    p = p.resolve()
    for d in [p if p.is_dir() else p.parent, *(p.parents)]:
        if (d / "knowledge").is_dir() or (d / ".git").is_dir():
            return d
    return pathlib.Path.cwd()

ROOT = pathlib.Path.cwd()  # main() 에서 대상 기준으로 재설정된다
def _scan_root():
    """knowledge/ 가 있으면 그것, 없으면 wiki 루트 전체. 미러/원본 양쪽에서 동작하게."""
    k = ROOT / "knowledge"
    return k if k.is_dir() else ROOT

GFM_CALLOUTS = {"NOTE", "TIP", "IMPORTANT", "WARNING", "CAUTION"}
CALLOUT_MAP = {  # 비-GFM 콜아웃 → 가장 가까운 5종
    "INFO": "NOTE", "ABSTRACT": "NOTE", "SUMMARY": "NOTE", "TLDR": "NOTE",
    "QUESTION": "TIP", "HELP": "TIP", "FAQ": "TIP", "HINT": "TIP", "EXAMPLE": "TIP",
    "SUCCESS": "IMPORTANT", "CHECK": "IMPORTANT", "DONE": "IMPORTANT", "QUOTE": "NOTE", "CITE": "NOTE",
    "BUG": "CAUTION", "DANGER": "CAUTION", "ERROR": "CAUTION", "FAILURE": "CAUTION", "MISSING": "CAUTION",
    "TODO": "WARNING", "ATTENTION": "WARNING",
}

def find_target(stem, base):
    """[[note]] 의 note 를 실제 파일 경로로 해석. 못 찾으면 None (lint 가 잡게 둔다)."""
    for p in _scan_root().rglob("*.md"):
        if p.stem == stem:
            try: return pathlib.Path(*([".."] * 0)).joinpath(p).relative_to(base.parent) if False else \
                       pathlib.PurePosixPath(__import__("os").path.relpath(p, base.parent))
            except Exception: return None
    return None

def normalize(text, path):
    # ![[image.png]] → ![image](assets/image.png)
    def emb_asset(m):
        name = m.group(1).strip()
        return f"![{pathlib.PurePosixPath(name).stem}](assets/{name})"
    text = re.sub(r"!\[\[([^\]|]+\.(?:png|jpe?g|gif|svg|webp))\]\]", emb_asset, text, flags=re.I)

    # ![[note]] → [note](path)  (트랜스클루전은 불가능 — 링크로 강등, 정직하게)
    def emb_note(m):
        stem = m.group(1).split("#")[0].strip()
        t = find_target(stem, path)
        return f"[{stem}]({t})" if t else m.group(0)
    text = re.sub(r"!\[\[([^\]]+)\]\]", emb_note, text)

    # [[note|alias]] / [[note]] → [alias|note](path)
    def wl(m):
        inner = m.group(1)
        target, _, alias = inner.partition("|")
        stem = target.split("#")[0].strip()
        label = (alias or stem).strip()
        t = find_target(stem, path)
        return f"[{label}]({t})" if t else m.group(0)
    text = re.sub(r"(?<!!)\[\[([^\]]+)\]\]", wl, text)

    # 비-GFM 콜아웃 → 5종
    def co(m):
        kind = m.group(1).upper()
        if kind in GFM_CALLOUTS: return m.group(0)
        return m.group(0).replace(m.group(1), CALLOUT_MAP.get(kind, "NOTE"), 1)
    text = re.sub(r"^>\s*\[!([A-Za-z]+)\][-+]?", co, text, flags=re.M)

    # ==highlight== → **bold**
    text = re.sub(r"==([^=\n]+)==", r"**\1**", text)
    return text

def main():
    global ROOT
    args = [pathlib.Path(a) for a in sys.argv[1:]]
    ROOT = _root_for(args[0] if args else pathlib.Path.cwd())
    files = args or list(_scan_root().rglob("*.md"))
    changed = 0
    for f in files:
        if not f.exists() or f.suffix != ".md": continue
        src = f.read_text(encoding="utf-8")
        out = normalize(src, f)
        if out != src:
            f.write_text(out, encoding="utf-8"); changed += 1; print(f"normalized: {f}")
    print(f"-- normalize: {changed} file(s) changed --")

if __name__ == "__main__":
    main()
