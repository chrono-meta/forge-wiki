#!/usr/bin/env python3
"""forge-wiki MCP server — READ-ONLY, zero dependencies (stdio JSON-RPC).

Governance shape: agents READ the wiki through MCP; they WRITE through git +
the PR/handoff gate (SPEC §3). This server therefore exposes no write tools —
that asymmetry is the product's write-protocol, not a missing feature.

Tools:
  wiki_index()                 -> INDEX.md content (curated pointers + derived recency)
  wiki_get(path)               -> one file's content (wiki-rooted paths only)
  wiki_search(query, section?) -> case-insensitive substring/word hits with file+line

Run: python3 bin/fw_mcp.py [wiki_root]   (default: cwd, must contain INDEX.md)
Register (Claude Code): claude mcp add forge-wiki -- python3 <abs>/bin/fw_mcp.py <wiki_root>
"""

import json
import re
import sys
from pathlib import Path

PROTOCOL = "2025-06-18"
MAX_FILE = 256 * 1024
MAX_HITS = 40

ROOT = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
HOME = next((ROOT / n for n in ("INDEX.md", "index.md") if (ROOT / n).exists()), None)
if HOME is None:
    sys.exit(f"fw_mcp: {ROOT} has no INDEX.md/index.md — not a wiki root")

TOOLS = [
    {"name": "wiki_index",
     "description": "Read the wiki home (INDEX.md / OKF index.md): curated canonical pointers + machine-derived recency index. Call this first.",
     "inputSchema": {"type": "object", "properties": {}}},
    {"name": "wiki_get",
     "description": "Read one wiki file by wiki-rooted relative path (e.g. 'signals/foo_2026-07-18.md').",
     "inputSchema": {"type": "object", "properties": {"path": {"type": "string"}}, "required": ["path"]}},
    {"name": "wiki_search",
     "description": "Case-insensitive text search across wiki markdown. Returns file:line hits. Optional section filter.",
     "inputSchema": {"type": "object", "properties": {"query": {"type": "string"}, "section": {"type": "string"}}, "required": ["query"]}},
]


def safe_resolve(rel: str) -> Path:
    # Path-traversal guard: the resolved target must stay inside ROOT.
    p = (ROOT / rel).resolve()
    if not str(p).startswith(str(ROOT) + "/") and p != ROOT:
        raise ValueError(f"path escapes wiki root: {rel}")
    if p.is_symlink():
        raise ValueError(f"symlinks not served: {rel}")
    return p


def tool_call(name: str, args: dict) -> str:
    if name == "wiki_index":
        return HOME.read_text(encoding="utf-8", errors="replace")[:MAX_FILE]
    if name == "wiki_get":
        p = safe_resolve(args["path"])
        if p.suffix.lower() not in (".md", ".txt"):
            raise ValueError("only .md/.txt files are served")
        if not p.is_file():
            raise ValueError(f"not found: {args['path']}")
        return p.read_text(encoding="utf-8", errors="replace")[:MAX_FILE]
    if name == "wiki_search":
        q = args["query"].lower()
        section = args.get("section")
        hits = []
        globs = (ROOT / section).rglob("*.md") if section else ROOT.rglob("*.md")
        for p in sorted(globs):
            if ".git" in p.parts:
                continue
            try:
                for i, ln in enumerate(p.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                    if q in ln.lower():
                        hits.append(f"{p.relative_to(ROOT)}:{i}: {ln.strip()[:160]}")
                        if len(hits) >= MAX_HITS:
                            return "\n".join(hits) + f"\n… (capped at {MAX_HITS})"
            except OSError:
                continue
        return "\n".join(hits) if hits else "(no hits)"
    raise ValueError(f"unknown tool {name}")


def reply(id_, result=None, error=None):
    msg = {"jsonrpc": "2.0", "id": id_}
    if error is not None:
        msg["error"] = {"code": -32000, "message": str(error)}
    else:
        msg["result"] = result
    sys.stdout.write(json.dumps(msg) + "\n")
    sys.stdout.flush()


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except json.JSONDecodeError:
            continue
        method, id_ = req.get("method"), req.get("id")
        if method == "initialize":
            reply(id_, {"protocolVersion": PROTOCOL,
                        "capabilities": {"tools": {}},
                        "serverInfo": {"name": "forge-wiki", "version": "0.1.0"}})
        elif method == "tools/list":
            reply(id_, {"tools": TOOLS})
        elif method == "tools/call":
            try:
                text = tool_call(req["params"]["name"], req["params"].get("arguments", {}))
                reply(id_, {"content": [{"type": "text", "text": text}]})
            except Exception as e:  # noqa: BLE001 — every tool error goes back to the client
                reply(id_, {"content": [{"type": "text", "text": f"error: {e}"}], "isError": True})
        elif id_ is not None:  # unknown request → empty result keeps clients moving
            reply(id_, {})


if __name__ == "__main__":
    main()
