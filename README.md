A World of Warcraft user interface setup based on that of Final Fantasy XIV, updated for Midnight.

Available on Curse: https://www.curseforge.com/wow/addons/ffxiv-ui

and Wago: https://www.curseforge.com/wow/addons/masque-ffxiv

If you'd like to see it in action, check out: https://www.reddit.com/r/WowUI/comments/1rdz5od/final_fantasy_xiv_ui_addon_updated_for_midnight/

Use the custom Masque skin for the full effect

https://github.com/MojiTheMonk/Masque_FFXIV

If you like what I do, consider supporting me: https://ko-fi.com/mojithemonk

## 中文字形复用（开发中）

中文客户端的名称与施法文本优先使用本地生成的 `AxisRegular-CJKDrawn.ttf`：在原 AXIS 字形复用基础上，为常用一简多繁缺字新增 61 个简体轮廓。一级常用字覆盖 3,237/3,500（92.49%），仍缺 263 字；GB2312 仍缺 1,847 字。绘制方法和验收边界见 [简体补绘说明](docs/fonts/axis-simplified-drawing.md)。生成字体未随仓库分发；文件加载失败时依次尝试旧复用版和客户端字体。

安装目录必须为 `Interface/AddOns/FFXIV_UI`。生成方法、完整映射、已知限制、许可状态和游戏验收清单见 [字体说明](docs/fonts/README.md)。添加新字体后请完全重启游戏。

## 开发与合并

以最新 `develop` 创建独立任务分支和工作树。完成字体构建、覆盖与 Lua 检查后，通过 PR 合并到 `develop`。完成字体说明中的真实 WoW 客户端验收，再通过 PR 合并到主线 `main`；实际分发衍生字体还需核实字体许可。此插件不设云服务部署环境，离线字体测试不等同于游戏验收。
