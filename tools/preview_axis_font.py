#!/usr/bin/env python3
"""生成原字体与复用字体的离线对比图；不能代替 WoW 渲染验收。"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
image = Image.new('RGB', (1400, 590), '#20242b')
draw = ImageDraw.Draw(image)
label = ImageFont.truetype(str(ROOT / 'Media/Fonts/MavenPro-Regular.ttf'), 23)
fonts = [ImageFont.truetype(str(ROOT / 'Media/Fonts' / name), 36)
         for name in ('AxisRegular.ttf', 'AxisRegular-CJKReuse.ttf')]
samples = [
    ('Names / spells (same input text)', '目标 龙骑士 猎人 宠物 治疗 阅读'),
    ('Additional reviewed variants', '步 每 涉 吞 户 产 绝 鸡'),
    ('Unresolved ambiguous characters (expected missing)', '发 术 历 获'),
]
draw.text((32, 22), 'Original AXIS', font=label, fill='#ffffff')
draw.text((725, 22), 'AXIS CJK Reuse', font=label, fill='#ffffff')
for i, (title, sample) in enumerate(samples):
    y = 90 + i * 150
    draw.text((32, y), title, font=label, fill='#aab4c4')
    for x, font in zip((32, 725), fonts):
        draw.text((x, y + 48), sample, font=font, fill='#fff2d5')
draw.text((32, 552), 'Offline FreeType preview - not an in-game screenshot', font=label, fill='#aab4c4')
output = ROOT / 'docs/fonts/axis-preview.png'
image.save(output)
print(output)
