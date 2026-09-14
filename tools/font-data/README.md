# 字体映射数据来源

- 上游：[OpenCC](https://github.com/BYVoid/OpenCC)
- 固定提交：`c363a7ba51d487950982bd8a589211ffbfd95ba1`
- `STCharacters.txt`、`JPShinjitaiCharacters.txt` 原样复制自该提交的 `data/dictionary/`。
- 上游字典使用 Apache-2.0，许可全文见 [OpenCC-LICENSE](OpenCC-LICENSE)。此许可仅针对字典，不授予 AXIS 字体修改或分发权。
- `reviewed-japanese.json` 是本项目审核的五条日式字形复用关系；构建时还会交叉核对 OpenCC 的日文新旧字对应和源字体实际覆盖。

构建只用单字对应，不做词语转换。一对多条目即使仅有一个候选字形存在，也不会自动采用。更新上游字典或源字体后必须重新审核映射、覆盖报告和预览。

## 第二轮异体字审查

- `Unihan_Variants.txt` 原样提取自 [Unicode 17.0.0 Unihan.zip](https://www.unicode.org/Public/17.0.0/ucd/Unihan.zip)，保留文件头；许可见 [Unicode-LICENSE.txt](Unicode-LICENSE.txt)。字段含义见 [UAX #38](https://www.unicode.org/reports/tr38/tr38-39.html)。语义变体不一定适合直接替代字形，尤其禁止按 specialized semantic 关系替换现代代词或部件。
- `UniJIS-UTF32-H` 原样复制自 [Adobe cmap-resources](https://github.com/adobe-type-tools/cmap-resources) 的 `Adobe-Japan1-7/CMap/UniJIS-UTF32-H`，固定提交 `f5cf3bca7fdfeaceb77aa82847e974f2306c20b4`，BSD 许可原文保留在该文件头部。映射到 CID 后只检查源字体实际存在的字形，不能因为 CMap 包含某字就认为源字体也包含它。
- `reviewed-variants.json` 是本轮显式批准的 53 条映射及证据路径。原有 `reviewed-japanese.json` 五条保持不变。候选图不会自动扩大批准范围，改变字典后仍需复核批准表。
- 数据文件 SHA-256 固定记录于覆盖报告。数据许可证均不代表 AXIS 字体的修改或再分发许可。

## 全量字典审计

`reviewed-dictionary.json` 保存 15 条新批准映射、全部简繁候选快照、数据路径、释义判断与官方词条链接；`dictionary-audit-decisions.json` 保存 181 个候选字的全部决定。构建核验两表一致性，只有批准记录可加入字体。没有词条正文的记录明确标为证据不足或基于结构、语义冲突的排除，不冒充字典验证。

审计仅使用网页释义的项目概述与链接，不复制字典全文。自动候选不等于正确映射；证据来源及核查日期可逐条追溯。机器校验能够检查记录一致性，不能代替人工判断释义是否充分。

## 常用字范围

`TGH2013-Level1.txt` 来自 Unicode 17.0.0 Unihan.zip 的 `kTGH` 属性，提取 `2013:1` 至 `2013:3500`。已核对完整字表序号 1—8105 连续且无重复。该子集沿用本目录 Unicode 数据许可，不是按笔画排序截取 GB2312。[字段说明](https://www.unicode.org/reports/tr38/tr38-39.html#kTGH)；[教育部关于一级3500常用字集的说明](https://www.moe.gov.cn/jyb_xwfb/xw_fbh/moe_2069/s7135/s7562/s7564/201308/t20130827_156334.html)。
