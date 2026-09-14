A World of Warcraft user interface setup based on that of Final Fantasy XIV, updated for Midnight.

Available on Curse: https://www.curseforge.com/wow/addons/ffxiv-ui

and Wago: https://www.curseforge.com/wow/addons/masque-ffxiv

If you'd like to see it in action, check out: https://www.reddit.com/r/WowUI/comments/1rdz5od/final_fantasy_xiv_ui_addon_updated_for_midnight/

Use the custom Masque skin for the full effect

https://github.com/MojiTheMonk/Masque_FFXIV

If you like what I do, consider supporting me: https://ko-fi.com/mojithemonk

## 中文字形复用（开发中）

中文客户端的名称与施法文本支持本地生成的 `AxisRegular-CJKReuse.ttf`，复用原 AXIS 字体中的繁体/日式字形补充 1,455 个简体码点。显示可能简繁混排，GB2312 仍有 1,923 个字未覆盖。生成字体未随仓库分发；缺少文件时尝试客户端默认字体。

安装目录必须为 `Interface/AddOns/FFXIV_UI`。生成方法、完整映射、已知限制、许可状态和游戏验收清单见 [字体说明](docs/fonts/README.md)。添加新字体后请完全重启游戏。

## 开发与合并

以最新 `develop` 创建独立任务分支和工作树。完成字体构建、覆盖与 Lua 检查后，通过 PR 合并到 `develop`。完成字体说明中的真实 WoW 客户端验收，再通过 PR 合并到主线 `main`；实际分发衍生字体还需核实字体许可。此插件不设云服务部署环境，离线字体测试不等同于游戏验收。
