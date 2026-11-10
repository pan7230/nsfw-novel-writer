# 文档记忆结构与小说导出（references/export_format.md）

开启"文档记忆"后，每回合整理以下文件（存于 `nsfw-novel-runs/<slug>/`）：

```
nsfw-novel-runs/
  <slug>/
    00-game-bible.md        世界观 / 设定
    01-protagonist.md       主角
    02-character-ledger.md  角色卡汇总
    03-relationship-web.md  关系网（阶段 / 好感 / 欲望立场）
    04-plot-threads.md      伏笔 / 线索
    05-timeline.md          时间线
    turns/
      turn-001.md           每回合记录
      turn-002.md
    chapters/
      chapter-001.md        章节正文
    exports/
      novel-draft.md        导出的连续小说
```

## 导出小说
结束时执行 `导出小说`：
1. 把 `turns/` 与 `chapters/` 按 `05-timeline.md` 合并为连贯叙事；
2. 统一人称与文风，去掉【系统面板】【行动选项】等元信息；
3. 输出 `exports/novel-draft.md`。

> 文档记忆可避免长篇小说中人物关系、伏笔、时间线被遗忘或跳线。
