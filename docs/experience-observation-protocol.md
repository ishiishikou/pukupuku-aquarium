# Five-puzzle observation protocol (Issue #3)

Date: 2026-11-02. Evidence source is the self-contained browser test at prototype/experience/index.html in PR #10.

## Before play

The test is a **deductive reasoning experiment**. Do not ask users to judge touch responsiveness, vibration or audio in the browser: those belong to native iPhone Issue #4. No one has been claimed to have completed this new nine-stage set yet.

- Use the three short intro puzzles when needed; a previously trained person can choose to skip them.
- Ask the participant to play without a time limit, with permission to stop at any moment.
- Do not tell them that the creator wants them to start the voluntary sixth, and do not intervene during the main five puzzles unless they explicitly request an explanation.
- Do not announce if an input is correct beyond the public counts and normal UI rules. The game never auto-fills answers.
- For an initial sample, test the project owner first and then approximately five first-time players. Their responses do not estimate market-wide retention.

## Observe without prompting

| Dimension | Record directly | Do not infer |
| --- | --- | --- |
| Discovery | What the player looked at before their first valid deduction; any self-described "aha!" | Silent pause = boredom, fast response = understanding |
| Rule comprehension | Confusion about tank boundary, same-height rule, gravity, water-count clues separately | Error implies all rules are unknown |
| Logical chain | Whether one confirmed cell led to another deduction, how many steps felt connected | Candidate elimination count = human insight count |
| Difficulty and frustration | Which puzzles felt harder/easier and why; hint use; changed strategy | One unique solution proves moderate difficulty |
| Input bookkeeping | Which steps were tedious after the logic was already clear | Browser marking pleasure is iPhone haptic approval |
| Voluntary continuation | After main puzzle five, whether "もう1問" or "今日はここまで" was selected, and optional sixth completion | Choosing the sixth proves weeks-long retention |
| Return interest | An unprompted return a few days later, if observed | Positive opinion alone predicts actual return |

## Neutral post-set questions

1. どのマスの答えに気づいたときが、一番面白かったですか？
2. よく分からなかった規則や水槽の境界はありましたか？
3. どこから難しすぎたり、単調に感じたりしましたか？
4. 5問のあと続けた／やめた理由は何でしたか？（選択後に聞く）

Avoid repeated "楽しいですか？" prompts while a puzzle is being solved.

## Recording template (participant ID should be a locally assigned pseudonym)

| participant | prior play? | intro used? | solved count (out of 5) | hinted puzzles | unexpected difficulty change | optional 6 chosen? | self-reported insight | issue to revise |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| (blank) | | | | | | | | |

Only share anonymized findings with the public repo. Do not store full recordings or personally identifying details there without explicit authorization. No automatic tracking server or public user analytics is installed.

## Decision after observation

- If the player enjoys *deduction* but dislikes recording many settled cells, evaluate terminal dry-fill help in the native swipe model; **do not infer** it is needed from click count alone.
- If tank boundaries or gravity remain confusing, revise tutorial visualization/hints and retest.
- If several main puzzles differ markedly in felt difficulty, tune puzzle selection; **do not** start creating 30/100 base puzzles yet.
- If five puzzles lead to spontaneous sixth choice *and* the iPhone touch/haptic implementation is comfortable, consider approving the next 30-puzzle calibration set under Issue #5.
- Either favorable or unfavorable findings complete the observation step. Success is not presumed from passing CI, and App Store launch remains a separate gate.
