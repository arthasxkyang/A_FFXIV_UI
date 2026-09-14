#!/usr/bin/env python3
"""输出补绘字形总览及实际字号混排预览；灰字仅作结构参考，不参与字体生成。"""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from axis_drawings import RECIPES
from build_axis_drawn import ROOT, OUTPUT


def preview(font_path=OUTPUT,reference=None):
    face=ImageFont.truetype(str(font_path),100)
    label=ImageFont.truetype(str(ROOT/'Media/Fonts/MavenPro-Regular.ttf'),20)
    ref=ImageFont.truetype(str(reference),30) if reference else None
    chars=sorted(RECIPES);paths=[]
    for page in range(2):
        image=Image.new('RGB',(1500,1100),'white');draw=ImageDraw.Draw(image)
        draw.text((20,5),'AXIS-style constructed simplified glyphs / Gray: reference / Black: new outline',font=label,fill='#666')
        for i,char in enumerate(chars[page*32:(page+1)*32]):
            x=i%8*185+15;y=i//8*250+45
            if ref:draw.text((x,y),char,font=ref,fill='#999')
            draw.text((x,y+38),char,font=face,fill='black')
            draw.text((x,y+170),f'U+{ord(char):04X}',font=label,fill='#666')
        path=ROOT/f'docs/fonts/axis-drawn-preview-{page+1}.png';image.save(path);paths.append(path)
    image=Image.new('RGB',(1200,630),'#20242b');draw=ImageDraw.Draw(image)
    draw.text((25,20),'Mixed original AXIS, reused glyphs and new simplified outlines',font=label,fill='white')
    for i,size in enumerate((16,24,32,48)):
        face=ImageFont.truetype(str(font_path),size)
        draw.text((25,80+i*130),f'{size}px',font=label,fill='#aaa')
        draw.text((100,75+i*130),'目标发起攻击 获得药水 钟声与签名 仓库休闲',font=face,fill='#fff2d5')
    path=ROOT/'docs/fonts/axis-drawn-preview-ui.png';image.save(path);paths.append(path)
    return paths

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--reference',type=Path)
    args=parser.parse_args()
    for path in preview(reference=args.reference):print(path)
