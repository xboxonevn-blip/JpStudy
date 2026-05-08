# Drive kanji beginner content audit

Scan date: 2026-05-08

User constraint: publisher web pages were not fetched. Only the downloaded Drive files and local repository data were used.

## Drive files checked

- `214_bo_thu_[thocodehoctiengnhat].pdf`: 214 radical lesson sheet. Local repo already has `assets/data/support/kanji/radicals_214.json` with 214 entries.
- `214_bo_thu_tong_hop_[thocodehoctiengnhat].pdf`: radical summary sheet. No extra runtime data found beyond the 214 radical set.
- `Quizlet.docx`: external study links only. No app runtime data imported.
- `Quy tắc chuyển âm Hán Việt sang âm On.docx`: title plus publisher-site link only. Link skipped per user constraint.
- `Hiragana_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured hiragana chart.
- `Hiragana_am_ghep_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured hiragana compound chart.
- `katakana_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured katakana chart.
- `Katakana_am_ghep_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured katakana compound chart.
- `Link video học bảng chữ cái.docx`: external video link only. No app runtime data imported.
- `file_luyen_them.pdf`: no extractable text; treated as a practice sheet, not imported.

## Added

- `assets/data/content/kana/kana_chart.json`
- Hiragana entries: 71; hiragana compounds: 33
- Katakana entries: 71; katakana compounds: 33

## Still missing

- Full Hán Việt to On-yomi rule content. The Drive DOCX did not contain the rules, only a link that was intentionally not accessed.
