# forge-wiki

**[English](README.md)** · **[한국어](README.ko.md)** · **[日本語](README.ja.md)** · 中文

为 LLM 智能体 — 以及与它们协作的人 — 打造的内置治理的 Markdown Wiki。

大多数智能体知识工具走向两个极端:要么是全自动记忆(mem0、Zep、Letta — 根本没有
审批概念),要么是人工策展服务。forge-wiki 坚守中间地带:
**智能体来写,人来把关,索引自我维护。**

## 三项设计承诺

1. **内容靠策展,新鲜度靠推导。** `INDEX.md` 中的 `AUTO-INDEX` 块由 frontmatter 和
   文件名日期再生成 — 该块的合并冲突通过再生成解决,而非手工合并。经并发多写入者
   模拟验证(见 `tests/` — 最多 50 个写入者,含破坏注入)。
2. **兼容 OKF v0.1。** 文件为 Markdown + YAML frontmatter(`type`、`description`)、
   保留 `index.md`、链接即关系边 — 任何 OKF 消费者都能读取,无锁定。
3. **作用域写入,门控合并。** 每个写入者只拥有自己的文件;跨作者变更是提案
   (PR/交接),而非静默编辑。HITL 不是功能开关,而是写入协议本身。人工门的存在
   是为了叠加**品味** — 个人与组织的判断 — 而不是抓缺陷:功能完整性是机器层的职责,
   在触达评审者之前已由模拟验证。

## 快速开始

```sh
cd your-knowledge-repo
python3 bin/fw.py init          # Phase-0 审计 + 非覆盖式脚手架
# 将 Markdown 文件放入分区目录(signals/, notes/, ...)
python3 bin/fw.py sync --write  # 再生成新鲜度索引
python3 bin/fw.py doctor        # 新鲜度 + 失效指针报告
```

`INDEX.md` 出现合并冲突时:任取一方,运行 `fw.py heal --write`。完事。

## 子命令

| cmd | 作用 | 失败方向 |
|---|---|---|
| `init` | 状态审计 + 脚手架(绝不覆盖) | 已有文件则拒绝 |
| `sync [--write]` | 再生成 AUTO-INDEX 块 | 默认 dry-run |
| `heal [--write]` | 清理冲突标记/重复块后 sync | 策展区冲突留给人 |
| `lint` | frontmatter 报告 | 只报告,绝不改写 |
| `doctor` | 新鲜度 + 失效指针报告 | 仅建议 |
| `check` | 索引漂移门 | 漂移时 exit 1(CI 阻断) |

## 状态

v0.1 — 提炼自一个每日运营一年的私有运营者 Wiki(900+ 文件、多机器)。`tests/` 中的
并发模拟是所有健壮性声明的回归锚:模拟未测量的,这里不做声明。

## 分发表面

- `llms.txt` — 每次 `sync --write` 时生成(与索引同为推导物)。
- `bin/fw_mcp.py` — 零依赖只读 MCP 服务器(`wiki_index` / `wiki_get` / `wiki_search`)。
  读取走 MCP,写入走 git + 门控 — 这种不对称不是缺失的功能,而是写入协议本身。
  `claude mcp add forge-wiki -- python3 <abs>/bin/fw_mcp.py <wiki_root>`

完整契约见 `SPEC.md`。
