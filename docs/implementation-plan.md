> **2026-11-01最新:** この文書は以前の段階的な試作計画。最終目標はApp Store一般公開であり、完成までのG0〜G5と品質ゲートは[App Storeマスターロードマップ](app-store-roadmap.md) / [Issue #7](https://github.com/ishiishikou/pukupuku-aquarium/issues/7) に従う。Apple Developer Programは登録済み（ユーザー申告）。約100母問題の再利用＋レベル/日次実績を前提とし、大量の独立問題の無制限生成は不要。ブラウザ版の入力快適性は評価しない。なぞり・音・触覚はiPhone実機で必達。

# 次の実装計画

今は設計レビューと開発基盤を整える段階。以下の小さな試作をIssueで管理し、大規模実装・問題量産へ自動的に進めない。

別チャットの着手手順・環境確認・未検証事項は[引き継ぎ入口](handoff.md)。次はIssue #3で代表1問の体験を先に作り、確認後に5問へ広げる。

1. **原本受入と10問の独立再検証**: 2026-10-31に原本登録・JSON抽出・全解数・保存解照合・分岐なしの推理ログを整備。代表的なブラウザ操作を確認。やり直しの完了確認はツール停止により残る。
2. **5問の体験試作**: [制作・評価条件](five-puzzle-experience.md)に従う。短い導入3問を別に用意し、本編5問と任意の追加1問で自発的な継続を観察する。セル入力を基準に、説明ヒント・水槽表示・原版の案内不具合を改善。水位直接入力の広い比較より、終盤の乾燥一括完了の比較を優先する。
3. **同じ5問でiPhone触覚を評価**: 対応実機とビルド環境が依存条件。泡・音・振動の快さを水／乾燥別に比較する。ブラウザでは理解、実機では触る時間と自発的な継続を評価する。
4. **評価後に30問へ拡大**: 作問に必要な推論検査は先に使い、30問制作は5問の実機評価後に進む。気づきの連鎖と塗りの負担、難度の安定を数日に分けて確認。量産はさらにその後に判断する。

水路、静的な生き物制約は[比較案](design-review.md)に留め、実装バックログへ昇格させない。各Issueは目的・前提・未完了scope・完了条件を持ち、別チャットは最新状態を読んでから着手する。今回は定期実行やWorker登録を行わない。

## GitHubでの進捗

- [PR #1: 初期登録とレビュー](https://github.com/ishiishikou/pukupuku-aquarium/pull/1)
- [Issue #2: 原本受入・10問の再検証（操作確認の一部が残る）](https://github.com/ishiishikou/pukupuku-aquarium/issues/2)
- [Issue #3: 理解と入力の比較](https://github.com/ishiishikou/pukupuku-aquarium/issues/3)
- [Issue #4: iPhone触覚の比較](https://github.com/ishiishikou/pukupuku-aquarium/issues/4)
- [Issue #5: 30問の難度検証](https://github.com/ishiishikou/pukupuku-aquarium/issues/5)
