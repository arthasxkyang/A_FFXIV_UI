#!/usr/bin/env python3
"""仅为 GB2312 缺字添加指向原有字形的 Unicode cmap 别名。"""
import argparse
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from axis_variants import routes, unihan, adobe_map
from fontTools.ttLib import TTFont
from fontTools.ttLib.tables.DefaultTable import DefaultTable

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'Media/Fonts/AxisRegular.ttf'
OUTPUT = ROOT / 'Media/Fonts/AxisRegular-CJKReuse.ttf'
DATA = ROOT / 'tools/font-data'
REPORT = ROOT / 'docs/fonts/axis-coverage.json'
SOURCE_SHA256 = '8a7db9cdaf207f1672ec1e527c5cd6889858a19d70d1d19b88718d455a1aa36a'


def dictionary(path):
    result = {}
    for line in path.read_text(encoding='utf-8').splitlines():
        if line and not line.startswith('#'):
            key, values = line.split('\t')
            result[key] = values.split()
    return result


def gb2312_hanzi():
    chars = []
    for high in range(0xB0, 0xF8):
        for low in range(0xA1, 0xFF):
            try:
                chars.append(bytes([high, low]).decode('gb2312'))
            except UnicodeDecodeError:
                pass
    assert len(chars) == 6763
    return sorted(chars, key=ord)


def plan(cmap, simplified, japanese, reviewed, variants=None, unicode=None):
    variants = variants or {}
    unicode = unicode or {}
    aliases, ambiguous, unavailable = [], [], []
    for char in gb2312_hanzi():
        if ord(char) in cmap:
            continue
        candidates = simplified.get(char, [])
        row = {'character': char, 'codepoint': f'U+{ord(char):04X}',
               'candidates': candidates}
        if char in variants and len(candidates) > 1:
            raise ValueError(f'禁止覆盖简繁歧义: {char}')
        if len(candidates) > 1:
            # 不能因为字体只含一个候选字形，就把语义歧义当成已经解决。
            ambiguous.append(row)
            continue
        target, basis = None, None
        if len(candidates) == 1 and ord(candidates[0]) in cmap:
            target, basis = candidates[0], 'OpenCC STCharacters unique'
        elif char in reviewed:
            review = reviewed[char]
            target = review['target']
            if (candidates != [review['traditional']]
                    or japanese.get(target) != candidates
                    or ord(target) not in cmap):
                raise ValueError(f'日式字形审核记录与字典或源字体不符: {char}')
            basis = review['reason']
        elif char in variants:
            review = variants[char]
            choice = {'target': review['target'], 'path': review['path']}
            if (choice not in routes(char, cmap, simplified, japanese, unicode)
                    or not review.get('reason')
                    or any(edge['kind'] == 'Unihan.kSpecializedSemanticVariant'
                           for edge in review['path'])):
                raise ValueError(f'异体字审核记录与官方数据不符: {char}')
            target, basis = review['target'], review['reason']
            row['evidence'] = review['path']
        if target:
            aliases.append(dict(row, target=target,
                                target_codepoint=f'U+{ord(target):04X}',
                                glyph=cmap[ord(target)], basis=basis))
        else:
            unavailable.append(row)
    applied = {row['character'] for row in aliases if 'evidence' in row}
    if applied != set(variants):
        raise ValueError('审核表含已存在、重复或未生效的映射')
    return aliases, ambiguous, unavailable


def build(output=OUTPUT, report=REPORT):
    digest = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
    if digest != SOURCE_SHA256:
        raise ValueError('源字体已变化，必须重新审核映射，不能沿用旧的覆盖报告')
    font = TTFont(SOURCE, recalcTimestamp=False)
    original = font.getBestCmap()
    simplified = dictionary(DATA / 'STCharacters.txt')
    japanese = dictionary(DATA / 'JPShinjitaiCharacters.txt')
    unicode = unihan()
    variants = json.loads((DATA / 'reviewed-variants.json').read_text(encoding='utf-8'))
    aliases, ambiguous, unavailable = plan(
        original, simplified, japanese,
        json.loads((DATA / 'reviewed-japanese.json').read_text(encoding='utf-8')),
        variants, unicode)
    # 对剩余字保留全部检索到的候选，但不因有候选就自动采用。
    cmap = adobe_map()
    glyphs = set(font.getGlyphOrder())
    pending = []
    for row in sorted(ambiguous + unavailable, key=lambda row: row['codepoint']):
        char = row['character']
        options = routes(char, original, simplified, japanese, unicode)
        exact = cmap.get(ord(char))
        if options or exact in glyphs:
            pending.append({'character': char, 'candidates': options,
                            'adobe_exact_glyph': exact if exact in glyphs else None,
                            'status': '需逐字审核，禁止仅凭相似、同音或局部词义复用'})
    # FontTools 可让多个子表共享同一个 cmap 字典；先全部复制再修改。
    for table in font['cmap'].tables:
        table.cmap = dict(table.cmap)
    for table in font['cmap'].tables:
        if table.isUnicode():
            for row in aliases:
                cp = ord(row['character'])
                if cp in table.cmap:
                    raise ValueError(f'禁止覆盖原有映射: {row["character"]}')
                table.cmap[cp] = row['glyph']
    names = {1: 'AXIS CJK Reuse', 2: 'Regular',
             3: 'AXIS-CJK-Reuse-1.1-' + digest[:12],
             4: 'AXIS CJK Reuse Regular', 6: 'AxisCJKReuse-Regular',
             16: 'AXIS CJK Reuse', 17: 'Regular', 18: 'AXIS CJK Reuse Regular'}
    # 使用独立字体身份；版权、商标等原始元数据保持不变。
    for record in font['name'].names:
        if record.nameID in names:
            record.string = names[record.nameID].encode(record.getEncoding())
    output.parent.mkdir(parents=True, exist_ok=True)
    # 避免 FontTools 重编译 CFF 等未修改表，逐字节保留字形与度量数据。
    for tag in list(font.reader.keys()):
        if tag not in ('cmap', 'name', 'head'):
            table = DefaultTable(tag)
            table.data = font.reader[tag]
            font[tag] = table
    font.save(output)
    font.close()
    result = {
        'source_sha256': digest,
        'output_sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
        'opencc_commit': 'c363a7ba51d487950982bd8a589211ffbfd95ba1',
        'dictionary_sha256': {name: hashlib.sha256((DATA / name).read_bytes()).hexdigest()
                              for name in ('STCharacters.txt', 'JPShinjitaiCharacters.txt',
                                           'reviewed-japanese.json', 'reviewed-variants.json',
                                           'Unihan_Variants.txt', 'UniJIS-UTF32-H')},
        'scope': 'GB2312 6763 Han characters; original mappings preserved',
        'counts': {'total': 6763,
                   'original_covered': 6763 - len(aliases) - len(ambiguous) - len(unavailable),
                   'added': len(aliases),
                   'covered_after': 6763 - len(ambiguous) - len(unavailable),
                   'ambiguous': len(ambiguous), 'unresolved_no_approved_mapping': len(unavailable)},
        'audit': {'unihan_version': '17.0.0',
                  'adobe_commit': 'f5cf3bca7fdfeaceb77aa82847e974f2306c20b4',
                  'adobe_exact_remaining': sum(r['adobe_exact_glyph'] is not None for r in pending),
                  'remaining_with_candidates': len(pending),
                  'remaining_without_candidates_in_audited_sources':
                      len(ambiguous) + len(unavailable) - len(pending),
                  'pending': pending},
        'aliases': aliases, 'ambiguous': ambiguous, 'unavailable': unavailable,
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    missing_chars = sorted(row['character'] for row in ambiguous + unavailable)
    (report.parent / 'axis-missing-30.txt').write_text(
        '\n'.join(''.join(missing_chars[i:i + 30])
                  for i in range(0, len(missing_chars), 30)) + '\n', encoding='utf-8')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=OUTPUT)
    parser.add_argument('--report', type=Path, default=REPORT)
    args = parser.parse_args()
    print(json.dumps(build(args.output, args.report)['counts'], ensure_ascii=False))
