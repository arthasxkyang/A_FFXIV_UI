"""枚举官方数据中的候选关系；候选不是可自动采用的字形映射。"""
import re
from pathlib import Path

DATA = Path(__file__).resolve().parent / 'font-data'


def unihan():
    values = {}
    for line in (DATA / 'Unihan_Variants.txt').read_text(encoding='utf-8').splitlines():
        if line and not line.startswith('#'):
            cp, prop, targets = line.split('\t')
            values.setdefault(chr(int(cp[2:], 16)), {})[prop] = [
                chr(int(target.split('<')[0][2:], 16)) for target in targets.split()]
    return values


def routes(char, cmap, simplified, japanese, unicode):
    result = []
    starts = [(char, [])]
    if len(simplified.get(char, [])) == 1 and simplified[char][0] != char:
        traditional = simplified[char][0]
        starts.append((traditional, [{'kind': 'OpenCC.STCharacters',
                                     'from': char, 'to': traditional}]))
    for source, path in starts:
        for target, old_forms in japanese.items():
            if source != target and source in old_forms and ord(target) in cmap:
                result.append({'target': target, 'path': path + [
                    {'kind': 'OpenCC.JPShinjitaiCharacters.reverse',
                     'from': source, 'to': target}]})
        for prop in ('kZVariant', 'kTraditionalVariant', 'kSemanticVariant',
                     'kSpecializedSemanticVariant'):
            for target in unicode.get(source, {}).get(prop, []):
                if target != source and ord(target) in cmap:
                    result.append({'target': target, 'path': path + [
                        {'kind': 'Unihan.' + prop, 'from': source, 'to': target}]})
    return sorted(result, key=lambda r: (r['target'], str(r['path'])))


def adobe_map():
    """只读横排字符映射，排除 codespace/notdef 区间。"""
    result, section = {}, None
    for line in (DATA / 'UniJIS-UTF32-H').read_text().splitlines():
        line = line.strip()
        if line.endswith('begincidchar'):
            section = 'char'
        elif line.endswith('begincidrange'):
            section = 'range'
        elif line in ('endcidchar', 'endcidrange'):
            section = None
        elif section == 'char':
            match = re.fullmatch(r'<([0-9a-f]+)>\s+(\d+)', line)
            if match:
                result[int(match[1], 16)] = f'cid{int(match[2]):05d}'
        elif section == 'range':
            match = re.fullmatch(r'<([0-9a-f]+)>\s+<([0-9a-f]+)>\s+(\d+)', line)
            if match:
                start, end, cid = int(match[1], 16), int(match[2], 16), int(match[3])
                for cp in range(start, end + 1):
                    result[cp] = f'cid{cid + cp - start:05d}'
    if len(result) < 15000:
        raise ValueError('Adobe CMap 不完整或解析异常')
    return result
