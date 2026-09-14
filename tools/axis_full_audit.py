"""对上一轮 1923 缺字全量登记；未读字典的条目绝不标为语义核实。"""
import hashlib
import json
from collections import Counter
from axis_variants import DATA, full_routes


def audit(cmap, simplified, japanese, unicode, variants, reviews):
    from build_axis_font import plan
    previous, ambiguous, unavailable = plan(
        cmap, simplified, japanese,
        json.loads((DATA / 'reviewed-japanese.json').read_text(encoding='utf-8')), variants, unicode)
    decisions = json.loads((DATA / 'dictionary-audit-decisions.json').read_text(encoding='utf-8'))
    rows, candidate_chars = [], set()
    for old in sorted(ambiguous + unavailable, key=lambda r: r['character']):
        char = old['character']
        options = full_routes(char, cmap, simplified, japanese, unicode)
        if options:
            candidate_chars.add(char)
            if char not in decisions:
                raise ValueError(f'新增候选尚未登记审核: {char}')
            decision = decisions[char]
            if (decision.get('decision') not in ('approved', 'rejected', 'insufficient')
                    or not decision.get('reason')):
                raise ValueError(f'审核结论无效: {char}')
        else:
            decision = {'decision': 'no_candidate', 'reason': '固定数据及限定检索路径未找到源字体可达字形；不代表所有历史资料都不存在异体。', 'sources': []}
        rows.append(dict(old, routes=options, **decision))
    if candidate_chars != set(decisions):
        raise ValueError('审核条目与本轮候选集合不一致')
    if {c: r for c, r in decisions.items() if r['decision'] == 'approved'} != reviews:
        raise ValueError('字典批准表与全量审核决定不一致')
    return {
        'baseline': '591b07cdf80e75f66eb4b2ec18538812fc3c1570',
        'date': '2026-09-15',
        'scope': '上一轮 1923 个 GB2312 缺字；原 1455 条映射回归验证，不宣称逐条重读其字典释义。',
        'method': '固定 OpenCC、Unihan 17；原字及每个繁体候选的一跳 JP/Unihan 异体；不递归传播语义。',
        'limitations': '全量候选筛查及决定登记完成；insufficient 尚未完成语义核实。已有外部释义通过网页检索读取，sources 空列表表示未取得可引用字典正文。',
        'dictionary_fetch': {'provider': '中央研究院字义比较直接批量请求',
                             'attempted_pairs': 294, 'read': 0, 'http_401': 294,
                             'result': '停止直连；失败请求不作为证据。少量网页检索可读词条另列 sources。'},
        'data_sha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in
                        (DATA / 'STCharacters.txt', DATA / 'JPShinjitaiCharacters.txt', DATA / 'Unihan_Variants.txt')},
        'counts': dict(total=len(rows), with_candidates=len(candidate_chars),
                       **dict(sorted(Counter(r['decision'] for r in rows).items()))),
        'characters': rows,
    }


def write_audit(result, folder):
    (folder / 'axis-full-audit.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    labels = {'approved': '采用', 'rejected': '不采用', 'insufficient': '证据不足'}
    lines = ['# 剩余汉字全量审计', '', result['scope'], '', result['method'], '', result['limitations'], '',
             '统计：' + '；'.join(f'{k}={v}' for k, v in result['counts'].items()) + '。', '',
             '294 组字义比较的批量直连均返回 HTTP 401，未计为已读证据。下表链接为另外通过网页检索取得的释义，理由为项目审查概述。', '',
             '无候选字符逐字记录在 [完整 JSON](axis-full-audit.json)。未映射字见 [每行 30 字清单](axis-missing-30.txt)。', '',
             '| 字 | 源字体可达字形 | 决定 | 理由与已读来源 |', '| --- | --- | --- | --- |']
    for row in result['characters']:
        if not row['routes']:
            continue
        targets = '、'.join(sorted({r['target'] for r in row['routes']}))
        links = ' '.join(f'[依据{i+1}]({url})' for i, url in enumerate(row['sources']))
        lines.append(f"| {row['character']} | {targets} | {labels[row['decision']]} | {row['reason']} {links} |")
    (folder / 'axis-full-audit.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
