# D2 Spot Check N3 2026-05-16

Scope: 30 sampled N3 items after review-debt cleanup. This is a user-review sample, not a `vi-human-approved` claim.

| # | Area | Item | Before | After |
|---:|---|---|---|---|
| 1 | Grammar | 〜ことにする | Reviewed text | Diễn tả quyết định do chính người nói đưa ra. |
| 2 | Grammar | 〜ようにする | Reviewed text | Diễn tả nỗ lực duy trì một thói quen hoặc cố tránh điều gì đó. |
| 3 | Grammar | 〜つもりだ | Reviewed text | Diễn tả dự định hoặc ý định của người nói. |
| 4 | Grammar | 〜ことにしている | Reviewed text | Diễn tả thói quen do bản thân quyết định duy trì. |
| 5 | Vocab | 合わせる | Reviewed text | ghép lại; kết hợp; điều chỉnh; làm cho khớp |
| 6 | Vocab | 勇気 | Reviewed text | lòng can đảm; sự dũng cảm; sự táo bạo |
| 7 | Vocab | ハイキング | Reviewed text | đi bộ đường dài |
| 8 | Vocab | 穏やか | Reviewed text | bình tĩnh; nhẹ nhàng; yên tĩnh |
| 9 | Vocab | ところで | Reviewed text | Nhân tiện; cho dù; dù thế nào đi chăng nữa |
| 10 | Vocab | 鋭い | Reviewed text | nhọn; sắc nét |
| 11 | Vocab | 計画 | Reviewed text | kế hoạch; dự án; chương trình |
| 12 | Vocab | 慎重 | Reviewed text | sự thận trọng; cẩn trọng |
| 13 | Vocab | ずっと | Reviewed text | liên tục; xuyên suốt; rất nhiều |
| 14 | Vocab | 老い | Reviewed text | tuổi già; sự lão hóa |
| 15 | Vocab | 役割 | Reviewed text | vai trò; nhiệm vụ |
| 16 | Vocab | 適当 | Reviewed text | thích hợp; vừa phải; tùy tiện |
| 17 | Vocab | 一般 | Reviewed text | chung; phổ thông |
| 18 | Kanji | 作 | Reviewed text | HV=Tác; làm, tạo |
| 19 | Kanji | 法 | Reviewed text | HV=Pháp; phép, phương pháp |
| 20 | Kanji | 様 | Reviewed text | HV=Dạng; dáng vẻ, kiểu |
| 21 | Kanji | 冷 | Reviewed text | HV=Lãnh; lạnh, nguội |
| 22 | Kanji | 覚 | Reviewed text | HV=Giác; giác, nhớ, tỉnh |
| 23 | Kanji | 左 | Reviewed text | HV=Tả; bên trái |
| 24 | Kanji | 右 | Reviewed text | HV=Hữu; bên phải |
| 25 | Kanji | 更 | Reviewed text | HV=Canh; thêm nữa, đổi mới |
| 26 | Kanji | 参 | Reviewed text | HV=Tham; tham gia, đi đến |
| 27 | Kanji | 考 | Reviewed text | HV=Khảo; nghĩ, cân nhắc |
| 28 | Kanji | 進 | Reviewed text | HV=Tiến; tiến lên |
| 29 | Kanji | 決 | Reviewed text | HV=Quyết; quyết định |
| 30 | Kanji | 能 | Reviewed text | HV=Năng; năng lực |

Owner spot-check follow-up 2026-05-17: whole N3 Hajimete vocab was re-audited for repeated gloss fragments, no-space comma debt, and the reported meaning errors. The regression test now canonicalizes numbered/parenthetical gloss labels before duplicate detection.

| Item | Before | After |
|---|---|---|
| 全然 | (1) hoàn toàn; hoàn toàn; (2) không hề (với động từ phủ định) | hoàn toàn; không hề (với động từ phủ định) |
| 抱く | (sl) ôm; ôm; ôm ấp; giải trí | ôm; ôm ấp; mang trong lòng |
| 雰囲気 | bầu không khí (ví dụ như âm nhạc); tâm trạng; bầu không khí | bầu không khí; tâm trạng; sắc thái chung |
| 引っ張る | (1) kéo; vẽ; kéo căng; kéo; (2) kéo bóng (bóng chày) | kéo; kéo căng; lôi kéo; kéo bóng (bóng chày) |
| ミス | bỏ lỡ (lỗi; lỗi; thất bại); bỏ lỡ | lỗi; sai sót; thất bại; cô (Miss) |
| 跡 | (1) dấu vết; dấu vết; dấu hiệu; (2) di tích; tàn tích; (3) vết sẹo | dấu vết; dấu hiệu; di tích; tàn tích; vết sẹo |

Result: current audit reports N3 `machine=0`, `open-review=0`, and `flutter test test/data/upper_jlpt_content_integrity_test.dart --name "n3 vocab Vietnamese glosses have no duplicate comma debt"` passes.
