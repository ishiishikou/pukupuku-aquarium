"""Extract original JSON without executing HTML; independently solve and trace logic."""
import hashlib
import json
from pathlib import Path
from verify import report, validate

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'prototype/original/pukupuku-aquarium-demo.html'


def extract():
    text = SOURCE.read_text(encoding='utf-8')
    raw, _ = json.JSONDecoder().raw_decode(text.split('const puzzles=', 1)[1])
    result = []
    for number, p in enumerate(raw, 1):
        n = p['n']
        grid = [[None] * n for _ in range(n)]
        for index, region in enumerate(p['regions']):
            r, c, h, w = (region[key] for key in ('r', 'c', 'h', 'w'))
            assert all(type(x) is int for x in (r, c, h, w))
            assert h > 0 and w > 0 and 0 <= r < r+h <= n and 0 <= c < c+w <= n
            for rr in range(r, r+h):
                for cc in range(c, c+w):
                    assert grid[rr][cc] is None, 'Overlapping tanks'
                    grid[rr][cc] = chr(65 + index)
        assert all(cell is not None for row in grid for cell in row), 'Uncovered cell'
        assert len(set(p['water'])) == len(p['water'])
        assert all(type(i) is int and 0 <= i < n*n for i in p['water'])
        assert not p['givens'], 'Givens require explicit support'
        result.append({'id': f'original-{number:02}', 'regions': [''.join(row) for row in grid],
                       'rows': p['rows'], 'cols': p['cols'],
                       'solution': [''.join('1' if r*n+c in p['water'] else '0' for c in range(n))
                                    for r in range(n)]})
    assert len(result) == 10
    return result


def trace(p):
    """No answer access, guesses, backtracking or global solution enumeration.

    First use line saturation and pairwise water physics. If stalled, use
    per-tank candidate contribution bounds on a single row/column.
    """
    h, w, tanks = validate(p)
    known, steps = {}, []
    lines = [(f'行{r+1}', {(r,c) for c in range(w)}, p['rows'][r]) for r in range(h)]
    lines += [(f'列{c+1}', {(r,c) for r in range(h)}, p['cols'][c]) for c in range(w)]
    domains = {name: [set()] + [{cell for cell in cells if cell[0] >= level}
                for level in sorted({r for r,c in cells})] for name,cells in tanks.items()}

    def assign(cells, value, reason, rule):
        fresh = sorted(cell for cell in cells if cell not in known)
        assert all(known.get(cell, value) == value for cell in cells)
        if not fresh:
            return False
        known.update({cell:value for cell in fresh})
        steps.append({'rule':rule, 'reason':reason, 'state':'水' if value else '×',
                      'cells': [[r+1,c+1] for r,c in fresh]})
        return True

    while len(known) < h*w:
        progress = False
        for name, cells, target in lines:
            wet = sum(known.get(c) == 1 for c in cells)
            unknown = cells - known.keys()
            assert wet <= target <= wet+len(unknown)
            if wet == target:
                progress = assign(unknown, 0, f'{name}: 必要{target}、水確定{wet}なので残りは×', 'line')
            elif wet + len(unknown) == target:
                progress = assign(unknown, 1, f'{name}: 必要{target}、水確定{wet}、未確定{len(unknown)}なので残りは水', 'line')
            if progress:
                break
        if progress:
            continue
        for name, cells in tanks.items():
            for r,c in sorted(cells):
                if (r,c) not in known:
                    continue
                value = known[r,c]
                affected = {cell for cell in cells if cell[0] >= r} if value else {cell for cell in cells if cell[0] <= r}
                progress = assign(affected, value, f'水槽{name}の{r+1}行{c+1}列から同じ高さと' + ('下' if value else '上') + 'へ伝播', 'physics')
                if progress:
                    break
            if progress:
                break
        if progress:
            continue
        for name,cells in tanks.items():
            domains[name] = [d for d in domains[name] if all((cell in d) == bool(v) for cell,v in known.items() if cell in cells)]
            assert domains[name]
        for line_name, line, target in lines:
            for name in tanks:
                others = [key for key in tanks if key != name]
                low = sum(min(len(d & line) for d in domains[key]) for key in others)
                high = sum(max(len(d & line) for d in domains[key]) for key in others)
                kept = [d for d in domains[name] if low <= target-len(d & line) <= high]
                assert kept
                if len(kept) < len(domains[name]):
                    removed = len(domains[name])-len(kept)
                    domains[name] = kept
                    steps.append({'rule':'bounds', 'reason':f'{line_name}: 必要{target}、他水槽の寄与範囲{low}〜{high}。水槽{name}の候補{removed}件を除外', 'cells':[]})
                    for cell in sorted(tanks[name]):
                        values = {int(cell in d) for d in kept}
                        if len(values) == 1:
                            assign({cell}, values.pop(), f'水槽{name}の残存候補が一致', 'candidate')
                    progress = True
                    break
            if progress:
                break
        if not progress:
            break
    if len(known) == h*w:
        for _, cells, target in lines:
            assert sum(known[cell] for cell in cells) == target
        for cells in tanks.values():
            for a in cells:
                for b in cells:
                    assert a[0] != b[0] or known[a] == known[b]
                    assert a[0] >= b[0] or known[a] <= known[b]
    return {'solved':len(known)==h*w, 'assigned':len(known),
            'unresolved':[[r+1,c+1] for r in range(h) for c in range(w) if (r,c) not in known],
            'steps':steps,
            'board':[''.join(str(known.get((r,c), '?')) for c in range(w)) for r in range(h)]}


if __name__ == '__main__':
    puzzles = extract()
    output = ROOT / 'verification'
    output.mkdir(exist_ok=True)
    (output / 'original-puzzles.json').write_text(json.dumps(puzzles, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    reports = []
    trace_md = ['# 原版10問の推理ログ', '', '各セル座標は1始まり。保存解を見ず、行列の残数→水平・上下伝播→水位候補の寄与範囲の順に適用。推論の束を1ステップと数える。人の所要時間・理解度を示すものではない。', '']
    for p in puzzles:
        result = report(p)
        logical = trace({k:v for k,v in p.items() if k != 'solution'})
        assert result['unique'] and result['supplied_solution_valid']
        assert not logical['solved'] or logical['board'] == p['solution']
        result['logic'] = logical
        reports.append(result)
        trace_md += [f"## {p['id']}", '', f"確定 {logical['assigned']}/{len(p['rows'])*len(p['cols'])}。", '']
        for i, step in enumerate(logical['steps'], 1):
            cells = ', '.join(f'r{r}c{c}' for r,c in step['cells'])
            trace_md.append(f"{i}. {step['reason']}。" + (f" {cells} → {step['state']}" if cells else ''))
        trace_md += ['', '```text', *logical['board'], '```', '']
        print(p['id'], result['level_combinations'], result['solution_count'], logical['solved'], len(logical['steps']), sorted({s['rule'] for s in logical['steps']}))
    payload = {'source':'prototype/original/pukupuku-aquarium-demo.html',
               'sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(), 'results':reports}
    (output / 'original-results.json').write_text(json.dumps(payload, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    (ROOT / 'docs/original-logic-traces.md').write_text('\n'.join(trace_md)+'\n', encoding='utf-8')
