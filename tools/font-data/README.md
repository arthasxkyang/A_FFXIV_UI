# 字体映射数据来源

- 上游：[OpenCC](https://github.com/BYVoid/OpenCC)
- 固定提交：`c363a7ba51d487950982bd8a589211ffbfd95ba1`
- `STCharacters.txt`、`JPShinjitaiCharacters.txt` 原样复制自该提交的 `data/dictionary/`。
- 上游字典使用 Apache-2.0，许可全文见 [OpenCC-LICENSE](OpenCC-LICENSE)。此许可仅针对字典，不授予 AXIS 字体修改或分发权。
- `reviewed-japanese.json` 是本项目审核的五条日式字形复用关系；构建时还会交叉核对 OpenCC 的日文新旧字对应和源字体实际覆盖。

构建只用单字对应，不做词语转换。一对多条目即使仅有一个候选字形存在，也不会自动采用。更新上游字典或源字体后必须重新审核映射、覆盖报告和预览。
