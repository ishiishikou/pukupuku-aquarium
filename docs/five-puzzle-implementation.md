# Issue #3 — Browser experience trial (2026-11-02)

Files: prototype/experience/index.html (self-contained, offline) and scripts/verify_experience.py, scripts/browser-experience.cjs.

## Scope
- Three short tutorials (3×3): row/column totals, horizontal tank coupling, and gravity. Tutorials are skippable and deliberately excluded from the five-main-puzzle assessment.
- Five 5×5 main puzzles, plus an **optional sixth**.
- Every entered cell remains explicitly water, dry, or unknown. Buttons to undo, request reasoned hints in three stages, or restart. Continue/stop choices after a completed puzzle; **only after the fifth main puzzle** does the optional sixth represent the target observation.
- User progress saved offline via separate localStorage key. No analytics, private identifiers, cookies, ads, or remote services. The code cannot infer why someone chose to continue.
- Browser controls are temporary notes for puzzle deductions. No touch/feedback result substitutes for native iPhone Issue #4.

## Reproducible mathematics
The verification script extracts the actual problems from the HTML, confirms each region is connected, enumerates **all local tank water levels** without referencing a solution, and proves exactly one global assignment for every problem. It also applies deterministic tank-domain elimination against row/column min/max limits. This is **a machine-only deduction check**, not proof that first-time human players know or enjoy those deductions. All learned candidate reductions must be assessed against real steps and comprehension.
  
Command: python scripts/verify_experience.py

The browser smoke test launches installed Chrome and checks each puzzle's gameplay loop, all nine completions, voluntary sixth option, undo and three-step hint, saved progress and narrow widths.

## Research protocol
- First user to try independently without coaching, then small initial group (about five people). Do not mark a task complete merely because tests pass.
- Ask after the set which insight was enjoyable, which rule was confusing, whether long stretches of marking felt monotonous, and whether the voluntary sixth was actually chosen. Record what the player said, not inferred motivations from elapsed time.
- Check stable difficulty; current problems have different tank shapes and machine deduction footprints, but **no equal subjective difficulty has been demonstrated**. Five selected problems are **candidates**, not a final difficulty-calibrated product bank.
- Do not manufacture additional rewards to force a sixth choice, claim two variants are independent questions, or present browser touch as iOS haptics evidence.
- One native issue and one browser issue continue independently: #4 / #3.
