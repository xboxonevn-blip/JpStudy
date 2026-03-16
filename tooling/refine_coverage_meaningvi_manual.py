#!/usr/bin/env python3
"""Manual refinement for newly added kanji-coverage vocab meanings (Vi)."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VOCAB_ROOT = ROOT / "assets" / "data" / "archive" / "vocab"
REPORT_PATH = ROOT / "docs" / "reports" / "n4n5-coverage-meaningvi-manual-refine-report.json"


MEANING_VI_OVERRIDES = {
    # N4
    "n4_l27_v063": "mê mải, say mê",
    "n4_l27_v064": "chăn nuôi, gây nuôi",
    "n4_l28_v061": "vĩ đại",
    "n4_l28_v062": "bầu cử",
    "n4_l29_v064": "hủy diệt hoàn toàn",
    "n4_l29_v065": "ô nhiễm",
    "n4_l29_v066": "tiêu dùng, chi tiêu",
    "n4_l29_v067": "trượt kỳ thi, lưu ban",
    "n4_l29_v068": "bế mạc",
    "n4_l30_v069": "hàng cây",
    "n4_l30_v070": "hoàn tiền, hoàn quỹ",
    "n4_l30_v071": "thực vật",
    "n4_l30_v072": "quyết định",
    "n4_l30_v073": "trang trí",
    "n4_l31_v051": "liên tiếp, nối tiếp",
    "n4_l32_v070": "tĩnh chỉ, đứng yên",
    "n4_l36_v064": "hô hấp",
    "n4_l36_v065": "không đáng tin cậy",
    "n4_l37_v055": "mười vạn (100.000)",
    "n4_l37_v056": "một ít, đôi chút",
    "n4_l37_v057": "bắt đầu mưa hoặc tuyết rơi",
    "n4_l39_v060": "phá sản",
    "n4_l39_v061": "thi thể",
    "n4_l39_v062": "thịt nướng yakiniku",
    "n4_l40_v068": "đo lường",
    "n4_l41_v075": "khó khăn, gian nan",
    "n4_l41_v076": "đơn nguyện vọng, đơn yêu cầu",
    "n4_l42_v076": "đóng gói, bao bì",
    "n4_l42_v077": "mặc đồ dày, mặc ấm",
    "n4_l42_v078": "sôi sục",
    "n4_l42_v079": "dòng máu lai, lai chủng",
    "n4_l42_v080": "lờ mờ, tối mờ",
    "n4_l42_v081": "sản xuất hàng loạt",
    "n4_l43_v043": "gia tăng",
    "n4_l43_v044": "giảm bớt",
    "n4_l44_v053": "tiếng khóc",
    "n4_l44_v054": "cơn buồn ngủ",
    "n4_l44_v055": "nét mặt tươi cười",
    "n4_l45_v052": "đả kích, cú đánh",
    "n4_l45_v053": "bỏ phiếu",
    "n4_l45_v054": "nghi vấn, câu hỏi",
    "n4_l46_v047": "phá hủy",
    "n4_l47_v051": "hài kịch",
    "n4_l47_v052": "quát tháo",
    "n4_l47_v053": "bi kịch",
    "n4_l47_v054": "tập thể, nhóm",
    "n4_l47_v055": "điều kỳ lạ, kỳ tích",
    "n4_l48_v039": "đơn trình báo, thông báo",
    "n4_l48_v040": "chim di trú",
    "n4_l49_v045": "hầu hạ, phục vụ",
    # N5
    "n5_l02_v061": "ngàn dặm, quãng đường xa",
    "n5_l03_v054": "thượng nguồn sông",
    "n5_l07_v062": "nợ, khoản vay",
    "n5_l07_v063": "nhà cho thuê",
    "n5_l08_v075": "thời cổ đại",
    "n5_l10_v054": "trái phải, tả hữu",
    "n5_l11_v069": "khoa tai mũi họng",
    "n5_l11_v070": "dấu chân",
    "n5_l13_v054": "đồng cảm, cảm thông",
    "n5_l15_v042": "có lẽ, chắc là",
    "n5_l15_v043": "ngắn hạn",
    "n5_l15_v044": "khinh suất, hấp tấp",
    "n5_l16_v071": "tuyên bố",
    "n5_l16_v072": "đau đầu",
    "n5_l16_v073": "diện mạo, nét mặt",
    "n5_l17_v047": "suốt từ đầu đến cuối",
    "n5_l17_v048": "kết thúc",
    "n5_l18_v041": "vận hành, chạy (xe cộ)",
    "n5_l20_v036": "cửa chớp chống bão",
    "n5_l20_v037": "lở tuyết",
    "n5_l21_v054": "phân biệt, phân loại",
    "n5_l21_v055": "dân làng",
    "n5_l21_v056": "góc phố",
    "n5_l21_v057": "văn phòng tỉnh",
}


def main() -> int:
    updated = 0
    missing_vocab_ids = set(MEANING_VI_OVERRIDES.keys())
    changes = []

    for level in ("n5", "n4"):
        for lesson_dir in sorted((VOCAB_ROOT / level).glob("lesson_*")):
            sense_path = lesson_dir / "sense.json"
            if not sense_path.exists():
                continue
            rows = json.loads(sense_path.read_text(encoding="utf-8"))
            if not isinstance(rows, list):
                continue
            changed = False
            for row in rows:
                if not isinstance(row, dict):
                    continue
                vocab_id = str(row.get("vocabId") or "").strip()
                override = MEANING_VI_OVERRIDES.get(vocab_id)
                if not override:
                    continue
                missing_vocab_ids.discard(vocab_id)
                old = str(row.get("meaningVi") or "").strip()
                if old == override:
                    continue
                row["meaningVi"] = override
                changed = True
                updated += 1
                if len(changes) < 200:
                    changes.append(
                        {
                            "file": str(sense_path.relative_to(ROOT)),
                            "vocabId": vocab_id,
                            "old": old,
                            "new": override,
                        }
                    )
            if changed:
                sense_path.write_text(
                    json.dumps(rows, ensure_ascii=False, indent=2) + "\n",
                    encoding="utf-8",
                )

    report = {
        "summary": {
            "overridesDeclared": len(MEANING_VI_OVERRIDES),
            "rowsUpdated": updated,
            "missingVocabIds": sorted(missing_vocab_ids),
        },
        "sampleChanges": changes,
    }
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(report["summary"], ensure_ascii=False))
    print(f"Report: {REPORT_PATH.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
