#!/usr/bin/env python3
"""在复用字体基础上增加常用一简多繁缺字的独立简体轮廓。"""
import argparse
import hashlib
import json
import tempfile
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.ttLib.tables.DefaultTable import DefaultTable
from fontTools.pens.recordingPen import RecordingPen
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.t2CharStringPen import T2CharStringPen
import build_axis_font as base
from axis_drawings import RECIPES, draw
from axis_outline_geometry import geometry, emit

ROOT=base.ROOT
OUTPUT=ROOT/'Media/Fonts/AxisRegular-CJKDrawn.ttf'
REPORT=ROOT/'docs/fonts/axis-drawn-coverage.json'


def common_characters():
    chars=''.join((base.DATA/'TGH2013-Level1.txt').read_text(encoding='utf-8').split())
    if len(chars)!=3500 or len(set(chars))!=3500:
        raise ValueError('一级常用字表数量或唯一性异常')
    return chars


def build(output=OUTPUT, report=REPORT):
    with tempfile.TemporaryDirectory() as folder:
        temp=Path(folder)
        previous=base.build(temp/'reuse.ttf',temp/'coverage.json')
        font=TTFont(temp/'reuse.ttf',recalcTimestamp=False)
        # 已有轮廓引用只能来自原 AXIS，不能从本轮已拼装字继续递归取轮廓。
        source=TTFont(base.SOURCE,recalcTimestamp=False)
        common=common_characters()
        eligible={r['character'] for r in previous['ambiguous'] if r['character'] in common}
        if set(RECIPES)!=eligible:
            raise ValueError('补绘范围必须恰为尚未获准复用的常用一简多繁缺字')
        cmap=font.getBestCmap()
        if any(ord(c) in cmap for c in eligible):
            raise ValueError('不能覆盖已有字形')
        top=font['CFF '].cff.topDictIndex[0]
        private=top.FDArray[0].Private
        index=top.CharStrings.charStringsIndex
        for i in range(len(index)):
            index[i]  # 保存全部原 Type2 字节码，再追加新字形。
        order=font.getGlyphOrder()[:];added=[]
        vertical=font['vmtx'].metrics if 'vmtx' in font else None
        for table in font['cmap'].tables:
            table.cmap=dict(table.cmap)
        for char in sorted(eligible):
            record=RecordingPen();draw(source,char,record)
            shape=geometry(record)
            if shape.is_empty or not shape.is_valid:
                raise ValueError('无效补绘轮廓: '+char)
            clean=RecordingPen();emit(shape,clean)
            bounds=BoundsPen(None);clean.replay(bounds)
            x0,y0,x1,y1=bounds.bounds
            if not (-50<=x0<x1<=1050 and -180<=y0<y1<=920):
                raise ValueError(f'补绘越界: {char} {bounds.bounds}')
            name=f'cid{len(order):05d}'
            pen=T2CharStringPen(1000,None);clean.replay(pen)
            charstring=pen.getCharString(private=private,globalSubrs=font['CFF '].cff.GlobalSubrs)
            index.append(charstring);top.CharStrings.charStrings[name]=len(order)
            top.FDSelect.gidArray.append(0);order.append(name)
            font['hmtx'].metrics[name]=(1000,round(x0))
            if vertical is not None:
                origin=font['VORG'].defaultVertOriginY if 'VORG' in font else 880
                vertical[name]=(1000,round(origin-y1))
            for table in font['cmap'].tables:
                if table.isUnicode():table.cmap[ord(char)]=name
            old=next(r for r in previous['ambiguous'] if r['character']==char)
            added.append({'character':char,'codepoint':f'U+{ord(char):04X}',
                          'glyph':name,'traditional_candidates':old['candidates'],
                          'reason':'没有已批准且适合无上下文显示的日式/异体映射；补绘简体结构，避免选择某一繁体词义。',
                          'method':'原 AXIS 完整部件轮廓组合及项目手绘笔画；缩放后补偿细笔画，合并交叠轮廓。',
                          'bounds':list(bounds.bounds),'advance':1000})
        font.setGlyphOrder(order);top.charset=order;top.CIDCount=len(order)
        # 新 CID 不属于 Adobe Japan1 标准；使用自定义字集声明。
        top.ROS=('AXISCJK','Custom',0)
        font['CFF '].cff.fontNames=['AxisCJKDrawn-Regular']
        top.FullName='AXIS CJK Drawn Regular';top.FamilyName='AXIS CJK Drawn'
        top.FDArray[0].FontName='AxisCJKDrawn-Regular'
        font['maxp'].numGlyphs=len(order);font['hhea'].numberOfHMetrics=len(order)
        if vertical is not None:font['vhea'].numberOfVMetrics=len(order)
        names={1:'AXIS CJK Drawn',2:'Regular',3:'AXIS-CJK-Drawn-1.0-'+previous['source_sha256'][:12],
               4:'AXIS CJK Drawn Regular',6:'AxisCJKDrawn-Regular',16:'AXIS CJK Drawn',
               17:'Regular',18:'AXIS CJK Drawn Regular'}
        for record in font['name'].names:
            if record.nameID in names:record.string=names[record.nameID].encode(record.getEncoding())
        for tag in list(font.reader.keys()):
            if tag not in ('cmap','CFF ','maxp','hmtx','hhea','vmtx','vhea','head','name'):
                table=DefaultTable(tag);table.data=font.reader[tag];font[tag]=table
        output.parent.mkdir(parents=True,exist_ok=True);font.save(output)
        patched=font.getBestCmap()
        missing=[c for c in common if ord(c) not in patched]
        gb_missing=[c for c in base.gb2312_hanzi() if ord(c) not in patched]
        result={'scope':'TGH2013 一级3500常用字中，上一轮剩余一简多繁61字',
                'status':'离线绘制与检查完成；不代表原厂设计或游戏验收通过',
                'source_sha256':previous['source_sha256'],
                'reuse_font_sha256':previous['output_sha256'],
                'output_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),
                'drawing_input_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in
                    (ROOT/'tools/axis_drawings.py',ROOT/'tools/axis_outline_geometry.py',base.DATA/'TGH2013-Level1.txt')},
                'counts':{'drawn':len(added),'common_total':3500,'common_before':3500-len(missing)-len(added),
                          'common_after':3500-len(missing),'common_missing':len(missing),
                          'gb2312_after':6763-len(gb_missing),'gb2312_missing':len(gb_missing)},
                'drawings':added,'common_missing':missing,'gb2312_missing':gb_missing}
        report.parent.mkdir(parents=True,exist_ok=True)
        report.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        for name,chars in [('axis-drawn-common-missing-30.txt',missing),('axis-drawn-gb2312-missing-30.txt',gb_missing)]:
            (report.parent/name).write_text('\n'.join(''.join(chars[i:i+30]) for i in range(0,len(chars),30))+'\n',encoding='utf-8')
        font.close();source.close()
        return result

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,default=OUTPUT)
    parser.add_argument('--report',type=Path,default=REPORT)
    args=parser.parse_args();print(json.dumps(build(args.output,args.report)['counts'],ensure_ascii=False))
