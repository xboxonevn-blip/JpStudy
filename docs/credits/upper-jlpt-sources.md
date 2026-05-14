# Upper JLPT Source Credits

This app uses source-imported upper JLPT seed data with attribution.

## Hanabira

- Repository: https://github.com/tristcoil/hanabira.org
- Data imported:
  - `backend/express/json_data/grammar_ja_JLPT_N1_0001.json`
  - `backend/express/json_data/grammar_ja_JLPT_N2_0001.json`
  - `backend/express/json_data/wordsTanos_openai_JLPT_N1_tanos_vocab_list.json`
  - `backend/express/json_data/wordsTanos_openai_JLPT_N2_tanos_vocab_list.json`
- Code license: MIT.
- Content/source note from README: in-house and third-party content is Creative Commons; Tanos lists are credited as Creative Commons BY.

## Usage Notes

- Official JLPT sample/workbook PDFs are used only as format references and are not copied into app content.
- Imported English meanings are retained from source data.
- N2/N1 Vietnamese vocabulary meanings and grammar explanations are internal draft translations from the imported English glosses.
- Vietnamese websites/dictionaries/courses are not bulk-copied into the app unless a compatible license or explicit permission is verified.
- Vietnamese explanations/meanings marked `needs-vi-editorial` or `needs-human-review` require human review before removing the tag.

## Publisher Scope References

These references are used to document route scope and learner-facing copy. They
are not bulk-import sources.

- 3A Corporation catalogue series page: https://www.3anet.co.jp/en/series.html
  - Used to verify the Minna no Nihongo elementary I/II series framing.
- 3A Corporation catalogue page: https://www.3anet.co.jp/en/catalogue.html
  - Used to verify 3A's broader catalog structure, including elementary,
    intermediate, advanced, and JLPT preparation categories.
- Shin Kanzen Master N3 vocabulary audio page:
  https://www.3anet.co.jp/shinkanzen_wb_n3/audio/ja_ctgy02.html
  - Used as a publisher-hosted reference for the Shin Kanzen vocabulary route.
- ASK Publishing order sheet:
  https://ask-books.com/shoten_order/J_1.pdf
  - Used as a publisher-hosted reference for ASK's JLPT vocabulary titles,
    including Hajimete no Nihongo Noryoku Shiken Tango entries.

## Manual QA References

- Vietnamese grammar pages found online may be used for human comparison only, not bulk import, until licensing is verified.
- Candidate QA references include JLPT Vietnam/JLPT Sensei Vietnam, Mazii grammar pages, JLPT Sensei, JLPT Global, and Practice Japanese.
- Official JLPT sample texts, Aozora Bunko public-domain prose, NHK News Easy, and public reading-practice pages may be used as format/difficulty references only; N2/N1 immersion passages in this app are original JpStudy text.

## Unicode Unihan

- Source: https://www.unicode.org/Public/UCD/latest/ucd/Unihan.zip
- Data imported for derived N2/N1 kanji metadata:
  - `Unihan_IRGSources.txt` → `kTotalStrokes`
  - `Unihan_Readings.txt` → `kVietnamese`
- Usage: stroke counts and Vietnamese Sino-Xenic readings are used to check/update derived kanji metadata. Missing values remain in `docs/reports/upper-jlpt-kanji-unihan-review.csv` for manual review.
