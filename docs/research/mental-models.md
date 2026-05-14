# Mental Models

## Phase 0 / Q1

Learning chi do duoc do khi ba dau vet noi duoc voi cung mot nguoi hoc: ho co quay lai on tap, co lam dung bai N5 sau khi on, va co thay buoi hoc du chat luong de tiep tuc. Hien tai app co vai dau vet rieng le trong may cua nguoi dung, nhung chua co "so cai" chung de noi 50 nguoi beta dang hoc tot hay chi dang bam nut. Vi vay viec dau tien la tao thang do chay duoc bang du lieu gia lap, roi moi gan telemetry that vao cung hop dong do.

## Phase 0 / Q1.2

Simulator dung duoc vi no bat chuong trinh do bang cung ngon ngu voi telemetry that: su kien review, quiz, va rating gan voi mot user. Neu 10 nguoi gia lap co the di qua cung duong tinh NS nhu du lieu GA4, minh co mot may do hoi quy on dinh truoc khi co nguoi hoc that. Diem yeu la no chua chung minh hanh vi hoc that; no chi chung minh ong do va duong ong khong bi vo.

## D2 / Q2.2

Content tag chi la bien bao, khong phai chat luong. Neu cau giai thich tieng Viet van noi "can doi chieu them" thi nguoi hoc khong hoc duoc gi, du tag co ghi approved. Cach do dung hon la lay mau co seed, cham theo rubric nguoi hoc co hieu hay khong, roi moi dung tag de uu tien sua nhanh hon.

## D2 / Q2.3

Lo trinh sach khong phai lo trinh hoc. Neu N3-N1 co du noi dung theo cap JLPT va noi dung do tot, app khong can bat buoc di tiep Minna. Nhung neu app de nguoi hoc tin rang ho dang theo tiep "duong Minna", thieu Minna Chukyu se thanh loi hua sai. Vi vay nhan route phai theo bang chung: level nao, nguon nao, muc tieu nao.

## D2 / Q2.4

Lien ket noi dung khong chi la co file vocab va file kanji. Muon goi y "hoc kanji nay truoc tu nay", app phai biet chu nao nam trong tu nao, chu do da co bai kanji nao, va nguoi hoc da hoc chua. Hien tai grammar gan voi vi du kha tot, nhung kanji-vocab moi la do thi thua; nen no dung de tim lo hong, chua dung de khoa duong hoc.

## D2 / Q2.5

Dem so tu va so kanji la hai cau hoi khac nhau. App co the co hon 10 ngan tu cong don, nhung neu chi co 889 kanji thi khong the noi la bao phu N1 kanji. Voi nguoi hoc, thieu kanji lam tu vung kho nho va kho doc; vi vay volume vocab tot chi la mot nua cua bai toan.

## D2 / Q2.6

Nguon dung khong dong nghia voi dong du lieu da day du. Neu Unihan co trong credits, dieu do chi noi "ta biet nen doi chieu voi dau"; no khong dam bao moi hang kanji trong app da co Han-Viet. Voi nguoi hoc, o trong truong Han-Viet con te hon mot loi nho: no lam tinh nang tro nho tro thanh khong dang tin.

## D3 / Q3.1-Q3.3

Co du key ngon ngu khong co nghia la co mot he ngon ngu san sang. `app_language.dart` co du 3 ngon ngu, nhung copy tieng Viet lai nam rai rac o nhieu file khac, nen nguoi sua chu khong co mot mat phang duy nhat de kiem soat thuat ngu. Muon chat luong tieng Viet tot len nhanh, truoc het phai gom duoc ban do: chu nao o dau, thuoc UI hay du lieu, va co bi loi ma hoa khong.

## D3 / Q3.4

Sau khi sua ma hoa, loi tieng Viet khong con nam chu yeu o dau sac hay dau hoi bi vo nua. Van de lon hon la app dang noi nua tieng Viet nua ngon ngu san pham: `block`, `lane`, `review`, `workspace`. Nguoi hoc van co the hieu tung cau, nhung moi tu vay muon nay lam UI kem tu nhien va kho nho hon. Vi vay don thuat ngu tan suat cao se co loi hon sua tung dau cau rieng le.

## D3 / Q3.5

ARB giai quyet workflow dich thuat dai han, nhung khong phai nut that beta luc nay. `AppLanguage` dang dong vai tro ngon ngu app, font/theme, provider state, va ca cach model hien thi du lieu. Neu keo tat ca sang ARB ngay, minh se sua hang ngan diem goi truoc khi biet nguoi hoc that vung nao dau nhat. Cach tot hon la don cac cum copy rui ro cao, giu enum cho beta, roi chi pilot ARB o phan shell khi plural/ICU that su chung minh co loi.

## D3 / Q3.6

So nhieu it khi lam tieng Viet bi sai ngu phap, nhung no lam tieng Anh lo ngay: `1 items`, `1 questions`, `1 strokes`. Vi vay plural khong phai ly do de doi ca he thong ngon ngu, ma la ly do de gom cac nhan dem ve mot cho. Neu helper dem xu ly dung tieng Anh, tieng Viet va tieng Nhat co the giu dang ngan gon, con sau nay ARB/ICU chi can thay helper bang key tuong ung.

## D4 / Q4.P2

Mot nguoi hoc N3 ban ron khong quan tam route nao la "duong chuan"; ho bam link nao thi app phai nho dung N3 o link do. Neu cap do chi duoc nap khi vao trang chu, moi deep link thanh mot canh cua bi hong va nguoi hoc thay noi dung N5/N4 sai voi minh. Mobile cung vay: neu nut bat dau nam duoi bottom nav, mot cu cham sai da lam mat ca phien hoc ngan.
