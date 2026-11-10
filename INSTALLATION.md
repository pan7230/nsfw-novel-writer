# NSFW Novel Writer — 安装与迁移指南

本技能是**纯提示词/文档**技能，不需要 Python、不需要下载模型、不需要联网。安装 = 把文件夹放到 WorkBuddy 的技能目录。

---

## 一、已在本机（默认情况）
技能位于：`~/.workbuddy/skills/nsfw-novel-writer/`
WorkBuddy 启动时会自动识别，直接对话即可触发，无需额外操作。
若没识别到：重启 WorkBuddy 或在技能面板刷新/重新加载技能。

---

## 二、在新设备 / 另一台机器自行安装
1. 把整个 `nsfw-novel-writer/` 文件夹复制过去。
2. 放到目标机器的用户技能目录：
   - macOS / Linux：`~/.workbuddy/skills/nsfw-novel-writer/`
   - Windows：`C:\Users\<你的用户名>\.workbuddy\skills\nsfw-novel-writer\`
3. 文件夹内需包含：`SKILL.md`、`references/`（五个 .md）、`USAGE.md`、`EXAMPLES.md`、`README.md`、`INSTALLATION.md`、`_user_meta.json`。
4. 重启 WorkBuddy，对话中输入「开一个成人向小说」验证触发。

---

## 三、打包分享给朋友
```bash
cd ~/.workbuddy/skills
zip -r nsfw-novel-writer.zip nsfw-novel-writer
```
对方解压到自己的 `~/.workbuddy/skills/` 即可。

---

## 四、从本仓库结构理解（可选）
```
nsfw-novel-writer/
├── SKILL.md            # 必须：技能入口与说明（YAML 头 name/description）
├── references/         # 必须：被 SKILL.md 引用的细则文件
├── USAGE.md            # 可选：详细使用手册
├── EXAMPLES.md         # 可选：事例说明
├── README.md           # 可选：概览
├── INSTALLATION.md     # 可选：本文件
└── _user_meta.json     # 可选：安装注册信息
```

---

## 五、合规提醒
- 本技能仅面向成年用户（18+）的虚构创作。
- 遵守所在地法律法规；公开发布请自行承担内容审核与年龄验证责任。
- 技能内置护栏不可关闭：拒绝未成年、非自愿、违法内容。
