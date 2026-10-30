"""Small-board exhaustive Aquarium checker; Python standard library only.

Enumerates tank levels, not the embedded answer. No human difficulty claim.
JSON input is one puzzle or a list. All cells must belong to connected tanks.
"""
import argparse
import itertools
import json
import math
from pathlib import Path


def validate(p):
    grid, rows, cols = p['regions'], p['rows'], p['cols']
    h, w = len(rows), len(cols)
    if not h or not w or len(grid) != h or any(len(r) != w for r in grid):
        raise ValueError('Invalid rectangular dimensions')
    if any(type(n) is not int or not 0 <= n <= w for n in rows):
        raise ValueError('Invalid row clue')
    if any(type(n) is not int or not 0 <= n <= h for n in cols):
        raise ValueError('Invalid column clue')
    if sum(rows) != sum(cols):
        raise ValueError('Row and column totals differ')
    tanks = {}
    for r in range(h):
        for c in range(w):
            label = grid[r][c]
            if not isinstance(label, str) or not label.strip():
                raise ValueError('Invalid tank label')
            tanks.setdefault(label, set()).add((r, c))
    for cells in tanks.values():
        seen = {next(iter(cells))}
        todo = list(seen)
        while todo:
            r, c = todo.pop()
            for nxt in ((r-1, c), (r+1, c), (r, c-1), (r, c+1)):
                if nxt in cells and nxt not in seen:
                    seen.add(nxt)
                    todo.append(nxt)
        if seen != cells:
            raise ValueError('Disconnected tank; canals are not supported')
    return h, w, tanks


def solve(p, budget=2_000_000):
    h, w, tanks = validate(p)
    candidates = []
    for cells in tanks.values():
        levels = sorted({r for r, _ in cells})
        candidates.append([set()] + [{(r, c) for r, c in cells if r >= level}
                                     for level in levels])
    combinations = math.prod(map(len, candidates))
    if combinations > budget:
        raise ValueError(f'{combinations} combinations exceed budget {budget}; not verified')
    solutions = []
    for selected in itertools.product(*candidates):
        wet = set().union(*selected)
        if [sum((r, c) in wet for c in range(w)) for r in range(h)] != p['rows']:
            continue
        if [sum((r, c) in wet for r in range(h)) for c in range(w)] != p['cols']:
            continue
        solutions.append([''.join('1' if (r, c) in wet else '0' for c in range(w))
                          for r in range(h)])
    return combinations, solutions


def report(p):
    combinations, solutions = solve(p)
    supplied = p.get('solution')
    return {'id': p.get('id'), 'level_combinations': combinations,
            'solution_count': len(solutions),
            'unique': len(solutions) == 1,
            'supplied_solution_valid': supplied in solutions if supplied is not None else None,
            'solutions': solutions[:2], 'human_solvability': 'not measured'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('path', type=Path)
    args = parser.parse_args()
    data = json.loads(args.path.read_text(encoding='utf-8-sig'))
    puzzles = data if isinstance(data, list) else [data]
    if not puzzles:
        raise SystemExit('No puzzles: not verified')
    results = [report(p) for p in puzzles]
    print(json.dumps(results, ensure_ascii=False, indent=2))
    raise SystemExit(0 if all(r['unique'] and r['supplied_solution_valid'] is not False
                             for r in results) else 1)
