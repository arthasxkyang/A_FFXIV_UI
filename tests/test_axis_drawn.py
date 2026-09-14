import json
import sys
import tempfile
import unittest
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.pens.boundsPen import BoundsPen
from PIL import ImageFont

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
import build_axis_drawn as drawn
import build_axis_font as base
from axis_drawings import RECIPES


class DrawnTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp=tempfile.TemporaryDirectory();cls.folder=Path(cls.temp.name)
        cls.path=cls.folder/'drawn.ttf';cls.report=cls.folder/'drawn.json'
        cls.result=drawn.build(cls.path,cls.report)
        cls.source=TTFont(base.SOURCE);cls.font=TTFont(cls.path)
    @classmethod
    def tearDownClass(cls):
        cls.source.close();cls.font.close();cls.temp.cleanup()

    def test_scope_counts_report_and_missing_lists(self):
        self.assertEqual(self.result['counts'],{'drawn':61,'common_total':3500,
            'common_before':3176,'common_after':3237,'common_missing':263,
            'gb2312_after':4916,'gb2312_missing':1847})
        old=json.loads(base.REPORT.read_text())
        self.assertEqual(set(RECIPES),{r['character'] for r in old['ambiguous']
                                     if r['character'] in drawn.common_characters()})
        self.assertEqual(self.result,json.loads(drawn.REPORT.read_text()))
        for name,chars in [('axis-drawn-common-missing-30.txt',self.result['common_missing']),
                           ('axis-drawn-gb2312-missing-30.txt',self.result['gb2312_missing'])]:
            lines=(self.folder/name).read_text().splitlines()
            self.assertTrue(all(len(x)==30 for x in lines[:-1]))
            self.assertEqual(''.join(lines),''.join(chars))
            self.assertEqual(len(set(chars)),len(chars))

    def test_original_glyph_programs_metrics_and_cmap_preserved(self):
        before=self.source['CFF '].cff.topDictIndex[0]
        after=self.font['CFF '].cff.topDictIndex[0]
        order=self.source.getGlyphOrder()
        self.assertEqual(order,self.font.getGlyphOrder()[:len(order)])
        self.assertEqual(after.ROS,('AXISCJK','Custom',0))
        for glyph in order:
            self.assertEqual(before.CharStrings[glyph].bytecode,after.CharStrings[glyph].bytecode,glyph)
            self.assertEqual(self.source['hmtx'][glyph],self.font['hmtx'][glyph],glyph)
            self.assertEqual(self.source['vmtx'][glyph],self.font['vmtx'][glyph],glyph)
        for table in self.source['cmap'].tables:
            matching=[t for t in self.font['cmap'].tables if
                      (t.platformID,t.platEncID,t.format)==(table.platformID,table.platEncID,table.format)]
            self.assertTrue(matching)
            for cp,glyph in table.cmap.items():self.assertEqual(matching[0].cmap[cp],glyph)
        for tag in self.source.reader.keys():
            if tag not in ('cmap','CFF ','maxp','hmtx','hhea','vmtx','vhea','head','name'):
                self.assertEqual(self.source.reader[tag],self.font.reader[tag],tag)
        for attr in ('defaultWidthX','nominalWidthX','BlueValues','LanguageGroup'):
            self.assertEqual(getattr(before.FDArray[0].Private,attr),getattr(after.FDArray[0].Private,attr))
        a,b=before.FDArray[0].Private.Subrs,after.FDArray[0].Private.Subrs
        self.assertEqual([x.bytecode for x in a],[x.bytecode for x in b])

    def test_original_and_reused_pixels_unchanged(self):
        original=ImageFont.truetype(str(base.SOURCE),24)
        updated=ImageFont.truetype(str(self.path),24)
        for cp in self.source.getBestCmap():
            char=chr(cp)
            self.assertEqual(bytes(original.getmask(char)),bytes(updated.getmask(char)),char)
            self.assertEqual(original.getlength(char),updated.getlength(char),char)
        previous=json.loads(base.REPORT.read_text())
        for row in previous['aliases']:
            self.assertEqual(bytes(original.getmask(row['target'])),
                             bytes(updated.getmask(row['character'])),row['character'])

    def test_drawings_are_unique_new_outlines_and_render_at_ui_sizes(self):
        original=set(self.source.getGlyphOrder());glyphs=self.font.getGlyphSet()
        names=[]
        for row in self.result['drawings']:
            name=row['glyph'];names.append(name)
            self.assertNotIn(name,original)
            self.assertEqual(self.font.getBestCmap()[ord(row['character'])],name)
            p=BoundsPen(None);glyphs[name].draw(p);self.assertIsNotNone(p.bounds)
            self.assertEqual(self.font['hmtx'][name][0],1000)
            for size in (16,24,40):
                face=ImageFont.truetype(str(self.path),size)
                self.assertTrue(any(face.getmask(row['character'])))
                self.assertEqual(face.getlength(row['character']),size)
        self.assertEqual(len(set(names)),61)

    def test_all_font_tables_and_cid_counts_are_consistent(self):
        font=TTFont(self.path)
        font.ensureDecompiled()
        count=len(font.getGlyphOrder());top=font['CFF '].cff.topDictIndex[0]
        self.assertEqual(count,9415)
        self.assertEqual(count,font['maxp'].numGlyphs)
        self.assertEqual(count,top.CIDCount)
        self.assertEqual(count,len(top.FDSelect.gidArray))
        self.assertEqual(count,len(font['hmtx'].metrics))
        self.assertEqual(count,len(font['vmtx'].metrics))
        font.close()

    def test_reproducible(self):
        second=self.folder/'second.ttf';report=self.folder/'second.json'
        drawn.build(second,report)
        self.assertEqual(second.read_bytes(),self.path.read_bytes())
        self.assertEqual(report.read_bytes(),self.report.read_bytes())

if __name__=='__main__':unittest.main()
