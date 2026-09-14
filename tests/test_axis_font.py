import hashlib
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from fontTools.ttLib import TTFont
from PIL import ImageFont
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('builder', ROOT / 'tools/build_axis_font.py')
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)


class FontTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.output = Path(cls.temp.name) / 'font.ttf'
        cls.report = Path(cls.temp.name) / 'report.json'
        cls.result = builder.build(cls.output, cls.report)
        cls.source = TTFont(builder.SOURCE)
        cls.font = TTFont(cls.output)

    @classmethod
    def tearDownClass(cls):
        cls.source.close()
        cls.font.close()
        cls.temp.cleanup()

    def test_original_mappings_and_outline_tables_preserved(self):
        for before, after in zip(self.source['cmap'].tables, self.font['cmap'].tables):
            for cp, glyph in before.cmap.items():
                self.assertEqual(after.cmap[cp], glyph)
        for tag in self.source.reader.keys():
            if tag not in ('cmap', 'name', 'head'):
                self.assertEqual(self.source.reader[tag], self.font.reader[tag], tag)
        self.assertEqual(hashlib.sha256(builder.SOURCE.read_bytes()).hexdigest(),
                         builder.SOURCE_SHA256)

    def test_aliases_point_only_to_original_glyphs(self):
        original = self.source.getBestCmap()
        for row in self.result['aliases']:
            cp, target = ord(row['character']), ord(row['target'])
            self.assertNotIn(cp, original)
            self.assertIn(target, original)
            for table in self.font['cmap'].tables:
                if table.isUnicode():
                    self.assertEqual(table.cmap[cp], original[target])
        self.assertEqual(self.source.getGlyphOrder(), self.font.getGlyphOrder())

    def test_ambiguities_and_unavailable_remain_unmapped(self):
        original, patched = self.source.getBestCmap(), self.font.getBestCmap()
        for row in self.result['ambiguous'] + self.result['unavailable']:
            self.assertNotIn(ord(row['character']), patched)
        self.assertIn('发', [r['character'] for r in self.result['ambiguous']])
        self.assertIn('术', [r['character'] for r in self.result['ambiguous']])
        # 已有字形不因一简多繁关系而重映射。
        self.assertEqual(patched[ord('后')], original[ord('后')])

    def test_coverage_partition_and_report(self):
        result = self.result
        expected = {'total': 6763, 'original_covered': 3385, 'added': 1402,
                    'covered_after': 4787, 'ambiguous': 86, 'no_reusable_glyph': 1890}
        self.assertEqual(result['counts'], expected)
        self.assertEqual(json.loads(builder.REPORT.read_text()), result)
        scope = builder.gb2312_hanzi()
        self.assertEqual(sum(ord(c) in self.font.getBestCmap() for c in scope), 4787)

    def test_reproducible(self):
        output = self.output.with_name('second.ttf')
        report = self.report.with_name('second.json')
        builder.build(output, report)
        self.assertEqual(output.read_bytes(), self.output.read_bytes())
        self.assertEqual(report.read_bytes(), self.report.read_bytes())

    def test_freetype_load_and_alias_render(self):
        face = ImageFont.truetype(str(self.output), 32)
        original = ImageFont.truetype(str(builder.SOURCE), 32)
        for row in self.result['aliases']:
            self.assertEqual(bytes(face.getmask(row['character'])),
                             bytes(original.getmask(row['target'])))
            self.assertEqual(face.getlength(row['character']),
                             original.getlength(row['target']))


class LuaTests(unittest.TestCase):
    def runtime(self):
        return LuaRuntime(unpack_returned_tuples=True)

    def test_lua51_syntax_all_modules(self):
        lua = self.runtime()
        compile_only = lua.eval('function(s, name) local f,e=loadstring(s,name); assert(f,e) end')
        for path in ROOT.rglob('*.lua'):
            compile_only(path.read_text(encoding='utf-8-sig'), str(path.relative_to(ROOT)))

    def test_locale_selection_failure_fallback_and_warning(self):
        for locale, failing, expected in (
            ('zhCN', [], ['reuse']), ('zhTW', [], ['reuse']),
            ('enUS', [], ['original']), ('jaJP', [], ['original']),
            ('zhCN', ['reuse'], ['reuse', 'standard']),
            ('zhCN', ['reuse', 'standard'], ['reuse', 'standard', 'original']),
        ):
            with self.subTest(locale=locale, failing=failing):
                lua = self.runtime()
                calls, warnings = [], []
                lua.globals().GetLocale = lambda: locale
                lua.globals().STANDARD_TEXT_FONT = 'standard'
                lua.globals().print = lambda text: warnings.append(text)
                ns, fs = lua.table(), lua.table()
                def set_font(_self, path, size, flags):
                    kind = 'reuse' if path.endswith('AxisRegular-CJKReuse.ttf') else path
                    calls.append(kind)
                    self.assertEqual(size, 20)
                    self.assertEqual(flags, 'OUTLINE')
                    return kind not in failing
                fs.SetFont = set_font
                lua.execute((ROOT / 'General/Fonts.lua').read_text(), 'FFXIV_UI', ns)
                self.assertTrue(ns.ApplyTextFont(fs, 'original', 20, 'OUTLINE'))
                self.assertEqual(calls, expected)
                ns.ApplyTextFont(fs, 'original', 20, 'OUTLINE')
                self.assertEqual(len(warnings), 1 if 'reuse' in failing else 0)

    def test_toc_and_seven_text_sites(self):
        toc = (ROOT / 'FFXIV_UI.toc').read_text()
        self.assertLess(toc.index('General/Fonts.lua'), toc.index('General/FFXIV_UI_Menu.lua'))
        sites = [p for folder in ('PlayerFrames', 'TargetFrames')
                 for p in (ROOT / folder).glob('*.lua') if 'ns.ApplyTextFont(' in p.read_text()]
        self.assertEqual(len(sites), 7)
        for path in sites:
            self.assertTrue(path.read_text().startswith('local _, ns = ...'))


if __name__ == '__main__':
    unittest.main()
