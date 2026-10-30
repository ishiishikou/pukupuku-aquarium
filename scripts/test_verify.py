"""Independent cell-mask oracle and negative controls for the review checker."""
import itertools
import json
from pathlib import Path
import unittest
from verify import solve, validate


class VerificationTests(unittest.TestCase):
    def test_tutorial_against_cell_oracle(self):
        p = json.loads((Path(__file__).resolve().parents[1] / 'examples/tutorial.json').read_text())
        h, w, tanks = validate(p)
        found = []
        for bits in itertools.product((0, 1), repeat=h*w):
            if [sum(bits[r*w:(r+1)*w]) for r in range(h)] != p['rows']:
                continue
            if [sum(bits[r*w+c] for r in range(h)) for c in range(w)] != p['cols']:
                continue
            valid = True
            for cells in tanks.values():
                for r, c in cells:
                    for rr, cc in cells:
                        if (r == rr and bits[r*w+c] != bits[rr*w+cc]) or (
                            r < rr and bits[r*w+c] > bits[rr*w+cc]):
                            valid = False
            if valid:
                found.append([''.join(map(str, bits[r*w:(r+1)*w])) for r in range(h)])
        self.assertEqual(found, [p['solution']])
        self.assertEqual(solve(p), (288, found))

    def test_nonunique(self):
        self.assertEqual(len(solve({'regions':['AB','CD'], 'rows':[1,1], 'cols':[1,1]})[1]), 2)

    def test_impossible_with_equal_totals(self):
        self.assertEqual(solve({'regions':['AA','AA'], 'rows':[2,0], 'cols':[1,1]})[1], [])

    def test_reject_disconnected(self):
        with self.assertRaisesRegex(ValueError, 'Disconnected'):
            solve({'regions':['AB','BA'], 'rows':[1,1], 'cols':[1,1]})

    def test_budget_is_not_a_proof(self):
        with self.assertRaisesRegex(ValueError, 'not verified'):
            solve({'regions':['AB','CD'], 'rows':[1,1], 'cols':[1,1]}, budget=1)


if __name__ == '__main__':
    unittest.main()
