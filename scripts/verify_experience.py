"""Verify the nine visible experience puzzles without using stored solutions.
Run: python scripts/verify_experience.py
Only tests constraint consistency; perceived human ease/fun remains unverified.
"""
import itertools
import json
import math
import re
from collections import deque
from pathlib import Path

HTML = Path(__file__).resolve().parents[1] / "prototype/experience/index.html"


def load_puzzles():
    source = HTML.read_text(encoding="utf-8")
    match = re.search(r"const exercises=(\[.*?\]);\s*const \$=", source, re.S)
    if not match:
        raise AssertionError("Cannot locate actual browser problem data")
    encoded = re.sub(r"(?<=[{,])([a-zA-Z]+):", r'"\1":', match.group(1))
    return json.loads(encoded)


def connected(regions, name):
    n = len(regions)
    cells = {(r, c) for r in range(n) for c in range(n) if regions[r][c] == name}
    start = next(iter(cells))
    queue = deque([start])
    seen = {start}
    while queue:
        r, c = queue.popleft()
        for step in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            target = (r + step[0], c + step[1])
            if target in cells and target not in seen:
                seen.add(target)
                queue.append(target)
    return seen == cells


def build_domains(puzzle):
    regions = puzzle["regions"]
    n = len(regions)
    assert 3 <= n <= 8
    assert all(len(row) == n for row in regions)
    assert len(puzzle["rows"]) == len(puzzle["cols"]) == n
    assert sum(puzzle["rows"]) == sum(puzzle["cols"])
    result = {}
    for name in sorted(set("".join(regions))):
        assert connected(regions, name), f"Disconnected tank {name}"
        squares = {(r, c) for r in range(n) for c in range(n) if regions[r][c] == name}
        occupied_rows = sorted({r for r, _ in squares})
        # Every domain element is a complete legal water level for this tank.
        result[name] = [
            frozenset((r, c) for r, c in squares if r in occupied_rows[first_wet:])
            for first_wet in range(len(occupied_rows) + 1)
        ]
    return result


def enumerate_solutions(puzzle, domains):
    names = list(domains)
    n = len(puzzle["rows"])
    options_checked = math.prod(len(values) for values in domains.values())
    answers = []
    def rec(i, chosen, row_counts, col_counts):
        if i == len(names):
            if row_counts == puzzle["rows"] and col_counts == puzzle["cols"]:
                answers.append(frozenset(chosen))
            return
        for water in domains[names[i]]:
            rr = [row_counts[r] + sum(r0 == r for r0, _ in water) for r in range(n)]
            cc = [col_counts[c] + sum(c0 == c for _, c0 in water) for c in range(n)]
            if any(rr[r] > puzzle["rows"][r] for r in range(n)):
                continue
            if any(cc[c] > puzzle["cols"][c] for c in range(n)):
                continue
            rec(i + 1, chosen | water, rr, cc)
    rec(0, frozenset(), [0] * n, [0] * n)
    return options_checked, answers


def propagate_candidates(puzzle, domains):
    """Deterministic domain elimination by row/column min/max. No solution peeking or search branches."""
    n = len(puzzle["rows"])
    active = {name: list(values) for name, values in domains.items()}
    log = []
    names = list(active)
    for _ in range(100):
        changed = False
        for name in names:
            keep = []
            for water in active[name]:
                feasible = True
                for axis in (0, 1):
                    clues = puzzle["rows"] if axis == 0 else puzzle["cols"]
                    for pos in range(n):
                        count = lambda cells: sum((r if axis == 0 else c) == pos for r, c in cells)
                        mine = count(water)
                        other = [
                            [count(candidate) for candidate in active[other_name]]
                            for other_name in names if other_name != name
                        ]
                        minimum = mine + sum(min(x) for x in other)
                        maximum = mine + sum(max(x) for x in other)
                        if not minimum <= clues[pos] <= maximum:
                            feasible = False
                            break
                    if not feasible:
                        break
                if feasible:
                    keep.append(water)
            if not keep:
                raise AssertionError(f"{puzzle['id']}: no candidate remains")
            if len(keep) < len(active[name]):
                log.append([name, len(active[name]), len(keep)])
                active[name] = keep
                changed = True
        if not changed:
            break
    return all(len(x) == 1 for x in active.values()), log


def run():
    puzzles = load_puzzles()
    assert len(puzzles) == 9
    ids = [p["id"] for p in puzzles]
    assert len(set(ids)) == len(ids)
    assert [p["kind"] for p in puzzles] == ["導入"] * 3 + ["本編"] * 5 + ["追加"]
    reports = []
    for puzzle in puzzles:
        domains = build_domains(puzzle)
        product, solutions = enumerate_solutions(puzzle, domains)
        assert len(solutions) == 1, (puzzle["id"], len(solutions))
        resolved, steps = propagate_candidates(puzzle, domains)
        assert resolved, f"domain propagation stuck: {puzzle['id']}"
        n = len(puzzle["rows"])
        solution_rows = [
            "".join("1" if (r, c) in solutions[0] else "0" for c in range(n))
            for r in range(n)
        ]
        reports.append({
            "id": puzzle["id"], "water_level_candidates": product,
            "solution_count": len(solutions),
            "mechanical_domain_reductions": len(steps), "solution": solution_rows,
        })
    print(json.dumps(reports, ensure_ascii=False, indent=2))
    print("PASS: nine puzzles are connected, uniquely solvable, and resolved by mechanical domain propagation.")
    print("NOT CLAIMED: natural human no-guess steps, equivalent difficulty, fun, real-iPhone haptics.")
    return reports


if __name__ == "__main__":
    run()
