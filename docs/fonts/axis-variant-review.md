# 第二轮异体字审核

本轮批准 53 条新增映射；此前的 1,402 条保持不变。仅使用原字体字形，文本码点不转换。

| 输入 | 显示字形 | 审核证据路径 |
| --- | --- | --- |
| 乡 | 郷 | 乡→鄉（OpenCC.STCharacters）；鄉→郷（Unihan.kZVariant） |
| 产 | 産 | 产→産（Unihan.kTraditionalVariant） |
| 俞 | 兪 | 俞→兪（Unihan.kSemanticVariant） |
| 俱 | 倶 | 俱→倶（OpenCC.JPShinjitaiCharacters.reverse） |
| 值 | 値 | 值→値（OpenCC.JPShinjitaiCharacters.reverse） |
| 偷 | 偸 | 偷→偸（Unihan.kSemanticVariant） |
| 勖 | 勗 | 勖→勗（Unihan.kSemanticVariant） |
| 吞 | 呑 | 吞→呑（Unihan.kSemanticVariant） |
| 吴 | 呉 | 吴→呉（Unihan.kZVariant） |
| 堇 | 菫 | 堇→菫（Unihan.kSemanticVariant） |
| 妒 | 妬 | 妒→妬（Unihan.kSemanticVariant） |
| 姊 | 姉 | 姊→姉（OpenCC.JPShinjitaiCharacters.reverse） |
| 娱 | 娯 | 娱→娯（Unihan.kZVariant） |
| 巢 | 巣 | 巢→巣（OpenCC.JPShinjitaiCharacters.reverse） |
| 帮 | 幇 | 帮→幇（Unihan.kSemanticVariant） |
| 徵 | 徴 | 徵→徴（OpenCC.JPShinjitaiCharacters.reverse） |
| 恿 | 慂 | 恿→慂（Unihan.kSemanticVariant） |
| 户 | 戸 | 户→戸（Unihan.kZVariant） |
| 戾 | 戻 | 戾→戻（OpenCC.JPShinjitaiCharacters.reverse） |
| 揭 | 掲 | 揭→掲（OpenCC.JPShinjitaiCharacters.reverse） |
| 晚 | 晩 | 晚→晩（OpenCC.JPShinjitaiCharacters.reverse） |
| 暨 | 曁 | 暨→曁（OpenCC.JPShinjitaiCharacters.reverse） |
| 朵 | 朶 | 朵→朶（Unihan.kSemanticVariant） |
| 查 | 査 | 查→査（OpenCC.JPShinjitaiCharacters.reverse） |
| 棂 | 櫺 | 棂→欞（OpenCC.STCharacters）；欞→櫺（Unihan.kSemanticVariant） |
| 榆 | 楡 | 榆→楡（OpenCC.JPShinjitaiCharacters.reverse） |
| 步 | 歩 | 步→歩（OpenCC.JPShinjitaiCharacters.reverse） |
| 每 | 毎 | 每→毎（OpenCC.JPShinjitaiCharacters.reverse） |
| 毗 | 毘 | 毗→毘（Unihan.kSemanticVariant） |
| 污 | 汚 | 污→汚（OpenCC.JPShinjitaiCharacters.reverse） |
| 沉 | 沈 | 沉→沈（Unihan.kSemanticVariant） |
| 涉 | 渉 | 涉→渉（OpenCC.JPShinjitaiCharacters.reverse） |
| 渴 | 渇 | 渴→渇（OpenCC.JPShinjitaiCharacters.reverse） |
| 痹 | 痺 | 痹→痺（OpenCC.JPShinjitaiCharacters.reverse） |
| 篡 | 簒 | 篡→簒（Unihan.kSemanticVariant） |
| 绝 | 絶 | 绝→絶（Unihan.kTraditionalVariant） |
| 胭 | 臙 | 胭→臙（Unihan.kSemanticVariant） |
| 荔 | 茘 | 荔→茘（OpenCC.JPShinjitaiCharacters.reverse） |
| 裤 | 袴 | 裤→褲（OpenCC.STCharacters）；褲→袴（Unihan.kSemanticVariant） |
| 账 | 帳 | 账→賬（OpenCC.STCharacters）；賬→帳（Unihan.kSemanticVariant） |
| 躲 | 躱 | 躲→躱（Unihan.kSemanticVariant） |
| 郄 | 郤 | 郄→郤（Unihan.kSemanticVariant） |
| 锈 | 銹 | 锈→鏽（OpenCC.STCharacters）；鏽→銹（Unihan.kSemanticVariant） |
| 锐 | 鋭 | 锐→鋭（Unihan.kTraditionalVariant） |
| 阱 | 穽 | 阱→穽（Unihan.kSemanticVariant） |
| 韧 | 靭 | 韧→韌（OpenCC.STCharacters）；韌→靭（Unihan.kSemanticVariant） |
| 颓 | 頽 | 颓→頽（Unihan.kTraditionalVariant） |
| 飚 | 飆 | 飚→飈（OpenCC.STCharacters）；飈→飆（Unihan.kSemanticVariant） |
| 骘 | 隲 | 骘→騭（OpenCC.STCharacters）；騭→隲（Unihan.kSemanticVariant） |
| 鳄 | 鰐 | 鳄→鱷（OpenCC.STCharacters）；鱷→鰐（Unihan.kSemanticVariant） |
| 鳖 | 鼈 | 鳖→鱉（OpenCC.STCharacters）；鱉→鼈（Unihan.kSemanticVariant） |
| 鸡 | 鷄 | 鸡→雞（OpenCC.STCharacters）；雞→鷄（Unihan.kSemanticVariant） |
| 麇 | 麕 | 麇→麕（Unihan.kSemanticVariant） |

每条映射的审核说明见 [批准表](../../tools/font-data/reviewed-variants.json)。来源与许可见 [数据说明](../../tools/font-data/README.md)。

## 暂不采用的代表性候选

- 别→別、发→發／髮、术→術：原简繁字典有一对多关系，保留歧义，不以字体恰好含某候选为理由决定词义。
- 你→祢／袮、您→祢／袮：仅有局部词义或古籍通假关系，不是现代代词的合适字形。
- 她→他：不能把现代女性代词显示为男性代词。
- 氵→水、忄→心、扌→手：偏旁部件不能机械替换成完整汉字。
- 嘿→默、氯→綠：语义或历史关系不足以证明适用于现代游戏文本。

完整剩余候选保存在 [覆盖报告](axis-coverage.json) 的 `audit.pending`；没有候选仅表示本轮数据未找到，不宣称已穷尽所有可能。
