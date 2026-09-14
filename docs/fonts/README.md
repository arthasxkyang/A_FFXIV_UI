# AXIS 中文缺字复用

## 行为与边界

`AxisRegular-CJKReuse.ttf` 是从仓库的 `AxisRegular.ttf` 本地生成的衍生字体。仅添加 Unicode cmap 别名，不绘制、拼接或引入外部字形。输入文本仍是原来的简体字符，但新增码点显示其繁体或日式对应字形，因此可能出现简繁混排。

例如输入“龙”仍是 U+9F99，使用原字体“龍”（U+9F8D）的同一个字形。已有简体映射原样保留；字形轮廓、度量、字偶距等未改动表逐字节保留。衍生字体使用独立名称，原字体不覆盖。

本轮范围固定为 GB2312 的 6,763 个汉字。原字体的其他汉字、标点和特殊字符保留，不承诺 GB2312 以外的生僻字或完整繁体覆盖。

| 指标 | 数量 |
| --- | ---: |
| 原来覆盖 | 3,385（50.1%） |
| 新增唯一简繁对应 | 1,397 |
| 新增审核过的日式对应 | 5 |
| 补字后覆盖 | 4,787（70.8%） |
| 歧义条目，保持未映射 | 86 |
| 无可复用字形，保持未映射 | 1,890 |

未映射合计 1,976 个，使用衍生字体时仍可能显示缺字符号。此方案不能称为完整中文支持。字体加载成功也不意味着所有文本均有字形，客户端回退仅处理字体文件加载失败，不提供逐字符回退。

## 映射规则与审查

1. 已存在码点绝不覆盖。
2. 缺字在固定版本 OpenCC `STCharacters.txt` 中只有一个对应字，且源字体包含该字形时，加入别名。
3. 有多个对应字时列入 `ambiguous`，例如“发、术”；不取列表第一个，也不按字体中仅剩的候选猜测。
4. 繁体目标也缺失时，仅允许 [reviewed-japanese.json](../../tools/font-data/reviewed-japanese.json) 中逐项审核的五条规则：击→撃、岁→歳、缘→縁、说→説、阅→閲。
5. 其他缺字列入 `unavailable`，没有默认或近似字形兜底。

完整映射、歧义清单、无法补齐清单及 SHA-256 见 [axis-coverage.json](axis-coverage.json)。字典来源和许可见 [数据说明](../../tools/font-data/README.md)。源字体更换时构建会因哈希不符而中止，必须重新审核。

## 构建与验证

在仓库根目录，使用 Python 3.12 的独立环境：

```sh
python3 -m venv .venv-fonts
.venv-fonts/bin/python -m pip install -r tools/requirements-fonts.txt
.venv-fonts/bin/python tools/build_axis_font.py
.venv-fonts/bin/python -m unittest discover -s tests -v
.venv-fonts/bin/python tools/preview_axis_font.py
```

Windows 环境将 `.venv-fonts/bin/python` 换成 `.venv-fonts/Scripts/python.exe`。

构建产物为 `Media/Fonts/AxisRegular-CJKReuse.ttf`，构建同时更新覆盖报告；重复构建应生成相同字节。预览输出为 `docs/fonts/axis-preview.png`，该图片是离线 FreeType 渲染，不是游戏截图。

测试覆盖原始映射和未修改字体表、所有新增字形的像素及字宽一致性、歧义排除、覆盖统计、可重复构建、Lua 5.1 语法（忽略源文件开头的 UTF-8 BOM）、语言选择和文件加载失败回退，以及七处文本接入和 TOC 顺序。

## WoW 接入与验收

`General/Fonts.lua` 先于其他界面模块加载。在 `zhCN`、`zhTW` 下，目标、目标的目标、焦点、宠物、玩家施法、玩家蓄力施法、目标施法共七处文字使用衍生字体；其他语言继续使用原指定字体。数字、装饰文字和游戏原始文本不转换。

缺少或无法加载衍生字体时，尝试 `STANDARD_TEXT_FONT`，再次失败则尝试原指定字体。首次失败只提示一次。必须将完整插件安装到 `Interface/AddOns/FFXIV_UI`；添加字体后完全重启游戏，再验证 `/reload`。

本机未连接 WoW 客户端，以下项目为主线合并前的必需人工验收，未执行不得标记通过：

- zhCN / zhTW：七处文本分别验证普通中文、上述映射样本、长名字、中英混排；截图注明客户端版本和语言。
- 普通施法、引导、蓄力施法、目标切换、宠物召唤、焦点切换、进入战斗和退出战斗。
- 常用 UI 缩放和长文本下的字高、基线、宽度与重叠；如出现重叠，应在任务分支据截图修复。
- 无新增 Lua 报错；重启、`/reload` 后仍能显示。
- 移走本地生成字体文件时验证客户端字体回退和单次提示；测试后恢复文件。
- enUS：原字体风格不变；“发、术”等歧义缺字保持清单中的已知限制，不能误判为已修复。

## 字体许可与发布

源字体元数据为 `Copyright © 2001 Isao Suzuki. All Rights Reserved.`，字体族为 `AXIS Std`；仓库未提供允许修改和重新分发的许可说明。`OS/2.fsType=4` 是字体嵌入标志，不能据此认定已取得修改、再分发授权。

原字体文件保留。生成脚本、字典、规则、覆盖报告和接入代码可审查；衍生 TTF 与离线预览图片为本地产物，已忽略，不随 Git 推送。对外发布衍生字体前，应取得并记录适用许可。这里只记录查明的元数据，不作许可已获确认的声明。
