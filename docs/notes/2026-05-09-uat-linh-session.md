# UAT session — Linh, Vietnamese N5 learner

Target: https://jpstudy-v2.web.app  
Date: 2026-05-09  
Persona: Linh, 22, Hanoi, JLPT N5 in 6 months

## Summary
- Best moment: Mình bấm kanji `学` và thấy ngay phần Han-Viet Tips liên quan, cảm giác “à cái này đúng thứ mình cần”.
- Worst moment: Ở mobile 414×896, màn hình chính gần như trống sau khi chờ, chỉ thấy thanh tab trên cùng.
- Overall verdict: App có nhiều nội dung học Nhật tốt, nhưng onboarding đang lẫn tiếng Anh/Nhật và vài luồng quan trọng bị ẩn nên mình dễ bỏ cuộc.

## Task-by-task notes

### T1. First impression
Screenshot: `docs/notes/uat-screenshots/t1-desktop-landing.png`

Mình thấy app mở vào màn chọn level, thương hiệu JP Study + biểu tượng kanji nhìn đúng app học tiếng Nhật. Nhưng UI đang bằng tiếng Anh dù mình là người Việt: “Welcome”, “Choose your level”, “Beginner fundamentals”, nên mình không chắc app có dành cho người Việt không. Mình sẽ bấm N5 đầu tiên vì đang học JLPT N5.

### T2. Learn hiragana
Screenshots: `docs/notes/uat-screenshots/t2-desktop-n5.png`, `docs/notes/uat-screenshots/t2-desktop-goal.png`, `docs/notes/uat-screenshots/t2-desktop-dashboard.png`

Mình muốn luyện hiragana nhưng không thấy nhãn “Kana”, “Hiragana”, “Bảng chữ cái” ở landing. Sau khi chọn N5, app hỏi goal; mình chọn “Practice Writing” vì có chữ Hiragana/Katakana/Kanji nhỏ bên dưới, nhưng app lại đưa mình tới quick win N4 Practice Writing với câu 見ます. Mình không tìm được nơi đánh dấu 5 kana “tôi đã thuộc”; dashboard cũng không phản ánh tiến độ kana nào. Bị khựng vì task rất cơ bản nhưng đường vào không rõ.

### T3. Take a quiz
Screenshot: `docs/notes/uat-screenshots/t3-desktop-quickwin.png`

Mình không thấy CTA tiếng Việt “học bằng quiz”; app tự đưa một câu hỏi quick win. Prompt “What does this mean?” rõ, đáp án dạng nút dễ hiểu, feedback đúng màu xanh và câu “Nice...” khá động viên. Tuy nhiên mình không thể chạy đủ 10 câu từ UI hiện tại vì không thấy nút Next/Again/summary sau câu đầu trong vùng nhìn thấy.

### T4. Sign in with email
Screenshots: `docs/notes/uat-screenshots/t4-desktop-auth-entry.png`, `docs/notes/uat-screenshots/t4-desktop-signin-dialog.png`, `docs/notes/uat-screenshots/t4-desktop-email-error.png`, `docs/notes/uat-screenshots/t4-desktop-google-attempt.png`

Mình tìm sign-in bằng avatar chữ J, khá hợp lý sau một lần đoán. Dialog sign-in rõ ràng, có Google và email/password. Khi nhập email giả `linh.fake@example.com` + mật khẩu sai rồi bấm Sign in, mình không thấy snackbar/error text hiện trên UI dù đã chờ; chỉ thấy form đứng yên. Bấm Google cũng không thấy popup mới xuất hiện trong phiên test, nên entry point có nhưng kết quả không rõ.

### T5. Find the Han-Viet aid
Screenshots: `docs/notes/uat-screenshots/t5-desktop-kanji.png`, `docs/notes/uat-screenshots/t5-desktop-kanji-detail.png`, `docs/notes/uat-screenshots/t5-desktop-hanviet-dropdown.png`, `docs/notes/uat-screenshots/t5-desktop-hanviet-reference.png`

Mình vào Kanji Hub và bấm `学` khá tự nhiên vì nó nằm ngay trong grid N5. Kanji detail hiện “Han-Viet Tips” và filter “Relevant to this kanji”; mở ra thấy rule “Initial c -> k -> kh -> gi...” và “Final c -> to -> ku”. Bấm More mở trang “Han-Viet Rules” và vẫn giữ modal `学`, làm mình hơi rối nhưng thấy reference đúng. Đây là luồng tốt nhất vì rule liên quan xuất hiện ngay trong detail.

### T6. Cross-feature: cloud sync
Screenshots: `docs/notes/uat-screenshots/t6-desktop-sync-settings.png`, `docs/notes/uat-screenshots/t6-desktop-manage-data.png`

Mình tìm backup bằng avatar → Settings/Me → Manage data, mất khoảng 3 click từ màn đang dùng; từ landing mới có thể mất 4 click nếu phải mở menu trước. Màn Data controls nói rõ “Auto backup” và “Account sync”, có giải thích cần sign in để cloud sync. Tuy nhiên label vẫn tiếng Anh và “Manual only” không giải thích ngay là giới hạn gì.

### T7. Recover from a wrong tab
Screenshot: `docs/notes/uat-screenshots/t5-desktop-kanji.png`

Từ Kanji Hub, mình bấm nhầm Handwriting/Flashcard-style area và vẫn ở cùng Kanji Hub, không bị kẹt. Back từ Han-Viet Rules quay về đúng vùng Kanji/previous view theo kỳ vọng trong desktop flow. Nhưng vì không tìm được Foundations hub/kana area, mình không thể xác nhận đúng task “from foundations hub”.

### T8. Mobile viewport 414×896
Screenshots: `docs/notes/uat-screenshots/t8-mobile-landing.png`, `docs/notes/uat-screenshots/t8-mobile-landing-afterwait.png`, `docs/notes/uat-screenshots/t8-mobile-kanji.png`

Ở mobile, landing sau 10 giây và thêm 5 giây vẫn trống: chỉ có nền pattern và top tab bar Roadmap/Memory/Kanji/Exams/More. Mình bấm Kanji tab, tab chuyển active nhưng nội dung vẫn trống. Đây là blocker lớn với người dùng Android như mình; mình sẽ nghĩ app bị lỗi hoặc chưa tải xong.

## Issues found, categorized

- **[CRITICAL] Mobile content blank** — mobile 414×896 landing/Kanji
  - What Linh expected: Thấy màn chọn N5 hoặc nội dung học.
  - What actually happened: Chỉ thấy tab bar, phần nội dung trống sau 15 giây.
  - Suggested fix: Render mobile content reliably.

- **[MAJOR] Hiragana path hidden** — desktop onboarding/Foundation task
  - What Linh expected: Có Kana/Hiragana/Bảng chữ cái rõ ràng.
  - What actually happened: Chọn Practice Writing dẫn tới quick win N4, không thấy toggle “tôi đã thuộc”.
  - Suggested fix: Add visible Kana entry.

- **[MAJOR] Email sign-in lacks visible error** — sign-in dialog
  - What Linh expected: Snackbar báo email chưa đăng ký/sai mật khẩu.
  - What actually happened: Form đứng yên, không có text lỗi nhìn thấy.
  - Suggested fix: Show persistent inline error.

- **[MAJOR] Google sign-in attempt unclear** — sign-in dialog
  - What Linh expected: Popup Google mở hoặc thông báo popup bị chặn.
  - What actually happened: Không thấy popup/feedback sau khi bấm.
  - Suggested fix: Confirm OAuth launch/failure.

- **[MAJOR] Language mismatch for Vietnamese user** — entire desktop run
  - What Linh expected: UI tiếng Việt hoặc tự nhận VI.
  - What actually happened: Hầu hết label tiếng Anh, vài heading tiếng Nhật.
  - Suggested fix: Default Vietnamese copy.

- **[MINOR] Han-Viet reference opens under modal** — Han-Viet Rules
  - What Linh expected: Trang rules rõ ràng, modal đóng hoặc không che.
  - What actually happened: Modal `学` vẫn phủ giữa trang rules.
  - Suggested fix: Close modal on More.

- **[MINOR] Onboarding selected N5 but quick win shows N4** — onboarding quick win
  - What Linh expected: N5 practice after choosing N5.
  - What actually happened: Header says “N4 | Practice Writing”.
  - Suggested fix: Preserve selected level.

- **[POLISH] “Me” profile labels feel generic** — settings/profile
  - What Linh expected: “Hồ sơ”, “Dữ liệu”, “Đồng bộ”.
  - What actually happened: “Me”, “Manage data”, “Progress”.
  - Suggested fix: Localize profile labels.

## Delights

- Han-Viet Tips inside `学` detail felt directly useful, not buried in docs.
- Kanji grid is visually clean; N5 kanji cards are easy to click.
- Correct-answer feedback in quick win uses a clear green border and encouraging text.
- Data controls separates local backup and account sync clearly once found.

## Top-3 changes to ship before sharing wider

1. Fix mobile blank content at 414×896; Linh’s real phone path is blocked.
2. Add an obvious Vietnamese “Hiragana/Kana nền tảng” entry with progress toggles.
3. Localize onboarding/auth/settings and show visible auth errors.
