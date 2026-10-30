"""Representative 5x5 independent checks (no saved answer used as a constraint)."""
import json
from pathlib import Path
import unittest

from verify import report, solve, validate

PATH = Path(__file__).resolve().parents[1] / "examples/representative-5x5.json"


def row_col_only_unknowns(p):
    """Count unresolved cells using row/column completion alone, ignoring all tank rules."""
    h, w = len(p["rows"]), len(p["cols"])
    board = [[-1] * w for _ in range(h)]
    while True:
        changed = False
        for axis, clues in (("row", p["rows"]), ("col", p["cols"])):
            for i, total in enumerate(clues):
                cells = ([(i, j) for j in range(w)] if axis == "row"
                         else [(j, i) for j in range(h)])
                filled = sum(board[r][c] == 1 for r, c in cells)
                unknown = [(r, c) for r, c in cells if board[r][c] == -1]
                remaining = total - filled
                if unknown and remaining in (0, len(unknown)):
                    for r, c in unknown:
                        board[r][c] = int(remaining != 0)
                    changed = True
        if not changed:
            break
    return sum(value == -1 for line in board for value in line)


class RepresentativeTests(unittest.TestCase):
    def test_unique_valid_solution(self):
        p = json.loads(PATH.read_text(encoding="utf-8"))
        validate(p)
        count, solutions = solve(p)
        self.assertEqual(count, 2592)
        self.assertEqual(solutions, [p["solution"]])
        self.assertEqual(report(p)["solution_count"], 1)

    def test_tank_reasoning_is_needed_by_basic_line_propagation(self):
        p = json.loads(PATH.read_text(encoding="utf-8"))
        self.assertEqual(row_col_only_unknowns(p), 9)

    def test_visible_hints_are_sound_for_the_puzzle(self):
        p = json.loads(PATH.read_text(encoding="utf-8"))
        self.assertEqual(p["rows"], [0, 3, 4, 3, 5])
        self.assertEqual(p["cols"], [2, 2, 4, 4, 3])
        self.assertEqual(p["regions"][1][3:], "CC")
        self.assertEqual(p["regions"][2][1:4], "DDD")
        self.assertEqual(p["regions"][3][:2], "FF")
        self.assertEqual(p["solution"][1], "00111")
        self.assertEqual(p["solution"][2], "11110")
        self.assertEqual(p["solution"][3], "00111")


if __name__ == "__main__":
    unittest.main()
