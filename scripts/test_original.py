import unittest
from audit_original import extract, trace
from verify import solve


class OriginalTests(unittest.TestCase):
    def test_each_deduction_agrees_with_independent_unique_solution(self):
        for p in extract():
            with self.subTest(puzzle=p['id']):
                _, solutions = solve(p)
                self.assertEqual(solutions, [p['solution']])
                logic = trace({k:v for k,v in p.items() if k != 'solution'})
                self.assertTrue(logic['solved'])
                for step in logic['steps']:
                    for r,c in step['cells']:
                        self.assertEqual(solutions[0][r-1][c-1], '1' if step['state']=='水' else '0')

    def test_ambiguous_board_is_not_guessed(self):
        p = {'regions':['AB','CD'], 'rows':[1,1], 'cols':[1,1]}
        result = trace(p)
        self.assertFalse(result['solved'])
        self.assertEqual(result['assigned'], 0)

    def test_impossible_board_is_not_claimed_solved(self):
        with self.assertRaises(AssertionError):
            trace({'regions':['AA','AA'], 'rows':[2,0], 'cols':[1,1]})


if __name__ == '__main__':
    unittest.main()
