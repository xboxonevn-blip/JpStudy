# Mental Models

## Phase 0 / Q1

Learning chi do duoc do khi ba dau vet noi duoc voi cung mot nguoi hoc: ho co quay lai on tap, co lam dung bai N5 sau khi on, va co thay buoi hoc du chat luong de tiep tuc. Hien tai app co vai dau vet rieng le trong may cua nguoi dung, nhung chua co "so cai" chung de noi 50 nguoi beta dang hoc tot hay chi dang bam nut. Vi vay viec dau tien la tao thang do chay duoc bang du lieu gia lap, roi moi gan telemetry that vao cung hop dong do.

## Phase 0 / Q1.2

Simulator dung duoc vi no bat chuong trinh do bang cung ngon ngu voi telemetry that: su kien review, quiz, va rating gan voi mot user. Neu 10 nguoi gia lap co the di qua cung duong tinh NS nhu du lieu GA4, minh co mot may do hoi quy on dinh truoc khi co nguoi hoc that. Diem yeu la no chua chung minh hanh vi hoc that; no chi chung minh ong do va duong ong khong bi vo.

## D2 / Q2.2

Content tag chi la bien bao, khong phai chat luong. Neu cau giai thich tieng Viet van noi "can doi chieu them" thi nguoi hoc khong hoc duoc gi, du tag co ghi approved. Cach do dung hon la lay mau co seed, cham theo rubric nguoi hoc co hieu hay khong, roi moi dung tag de uu tien sua nhanh hon.

## D2 / Q2.3

Lo trinh sach khong phai lo trinh hoc. Neu N3-N1 co du noi dung theo cap JLPT va noi dung do tot, app khong can bat buoc di tiep Minna. Nhung neu app de nguoi hoc tin rang ho dang theo tiep "duong Minna", thieu Minna Chukyu se thanh loi hua sai. Vi vay nhan route phai theo bang chung: level nao, nguon nao, muc tieu nao.

Coverage docs are part of product truth, not support collateral. If the catalog
UI unlocks data-backed routes but docs still say "coming soon" or "publisher
constraint" imprecisely, the app trains operators to debug a nonexistent data
gap. The durable rule is evidence-first labeling: shipped assets decide route
availability, publisher references explain scope, and negative findings prevent
over-claiming.

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

## D4 / Q4.P3

Nguoi hoc N2 on thi cap toc khong can app nhac hoc nhe moi ngay; ho can mot ban dieu khien cho nhieu gio lien tiep. Neu trang chu noi dung N2 nhung link thang lai roi ve N5, app khong con dang tin trong luc on thi. Va neu he thong khong biet "toi co 3 gio hom nay", no se de xuat mot ke hoach 14 phut dung cho thoi quen, sai cho cramming.

## D4 / Q4.P4

Nguoi hoc lon tuoi can it bat ngo hon nguoi tre: chu du lon, nut bam ro, va mot ly do hoc gan voi doi song. Tablet root cua app gan dat dieu nay, nhung neu cac cua phu roi ve N5 hoac onboarding khong co muc tieu du lich/giai tri, app van noi sai y dinh hoc. Voi nhom nay, "don gian va dung muc tieu" quan trong hon nhieu nhanh hoc.

## D4 / Q4.P5

Nguoi hoc N1 bo di rat nhanh neu app noi sai trinh do. Diem dang mung la noi dung doc N1 co that: khi state da dung, immersion co deck kho va annotation huu ich. Diem hong la duong den no khong dang tin: link thang roi ve N5, study hub khong day N1 len truoc, va "news" khong ton tai. Voi nguoi nang cao, discovery la chat luong san pham.

## D4 / Synthesis

Nhieu persona khong lam app phuc tap hon neu app co mot truc tin cay: dung nguoi hoc, dung cap do, dung muc tieu. Hien tai truc do bi gay o live deep link, nen moi persona tu N3 den N1 deu co the bi keo ve N5. Khi truc nay vung, cac khac biet moi co nghia: 15 phut, 3 gio, du lich, hay doc N1 deu la bien the cua cung mot cau hoi "hom nay toi can phien hoc nao?".

## D5 / Q5.1

FSRS khong chi la cong thuc tinh ngay tiep theo. No la mot may trang thai: hoc moi, on lai, hoc lai, buoc nao trong vong lap ngan, va khi nao moi tot nghiep sang lich dai han. Neu bo trang thai do, app co the van cho ra so ngay hop ly tren giay, nhung nguoi hoc bam "quen" lai khong gap lai the ngay luc can nhat. Vi vay do retention ma scheduler sai trang thai se lam minh tin nham rang nguoi hoc dang nho.

## D5 / Q5.2

Streak chi co nghia khi no tra loi ro "ngay nao duoc tinh la hoc". Neu tu vung tinh, bai grammar khong tinh, test tinh, game tinh, thi streak khong con la thoi quen hoc ma la thoi quen di qua dung module. Muon dung streak de hieu retention, app can mot chinh sach ngay duy nhat: ranh gio nao, hoat dong nao tinh, miss mot ngay xu ly ra sao, va moi module deu ghi vao cung mot so cai.

## D5 / Q5.3

XP chi la mot ngon ngu dong vien khi moi man hinh hieu no giong nhau. Neu Learn hien `+XP` nhung dashboard khong tang, con game/test lai tang, nguoi hoc se thay he thong khong cong bang va minh cung khong doc duoc `todayXp` nhu cong hoc. Vi vay truoc khi dung XP cho analytics hay leaderboard, app can mot chinh sach tien te ro: nguon nao la XP tai khoan, nguon nao chi la diem phien hoc, va gioi han nao ngan viec cay diem thay vi hoc.

## D5 / Q5.4

Onboarding ngan la tot neu no chi mo cua vao app. Nhung neu app dung cau tra loi do de hua "toi se hoc theo muc tieu cua ban", thi cau tra loi phai di tiep vao duong hoc dau tien, ke hoach ngay, va telemetry. Hien tai nguoi hoc chon JLPT, doc, hay viet, nhung phan lon he thong van hoi "cap do nao, co gi den han" thay vi "hom nay ban can on thi, doc tin, di du lich, hay hoc bang chu". Vi vay ca nhan hoa that can mot profile nho hon la them nhieu card chung.

## D5 / Q5.5

Sua loi chi work khi co mot so cai duy nhat noi "loi nay con hay da xong". Voi tu vung va kanji, so cai do la `user_mistakes`: sai thi tang so lan can sua, dung thi giam dan. Voi grammar, app dang co hai so cai: mot cai hien ghost, mot cai nut "da nam" xoa. Neu nguoi hoc lam dung ma ghost van con, cam giac khong phai la hoc kho ma la app khong tin minh. Truoc khi lam ghost thong minh hon, phai lam ghost dung mot nguon su that.

## D5 / Q5.6

Tien quyet hoc tap nen la loi khuyen truoc khi la cai khoa. App co the biet mot tu gom nhung chu kanji nao, va co the mo phien tap kanji theo danh sach ID. Nhung neu kho kanji chi bao phu tron ven khoang mot phan ba tu co kanji, khoa duong hoc se bien lo hong noi dung thanh loi hoc cua nguoi dung. Buoc dung hon la goi y "on may chu nay truoc", do nguoi hoc co chap nhan khong, roi xem lan thu lai co tot hon khong.

## D6 / Q6.1

Card khong can giong nhau het, nhung can biet minh dang dung loai nao. Man hinh hub can the thong tin lon va dep; trang chu can panel day du thong tin ma khong phinh; bai tap can o prompt/choice co mau trang thai. Neu khong dat ten ba ho nay, moi module se tu ve them mot kieu card moi va nguoi hoc phai hoc lai ngon ngu UI. Neu dat ten ro, khac biet tro thanh y do thay vi troi dat.

## D6 / Q6.2

Trang trong khong phai luc nao cung la loi. Neu khong co diem yeu nao, bien mat la on; neu khong co bai hoc vi data chua nap, bien mat lai lam nguoi hoc nghi app kem. Vi vay empty state can chia hai loai: cho noi dung chinh thi phai noi ro "khong co gi, vi sao, bam dau tiep"; cho panel phu thi chi duoc an khi da chac la trang thai tot. Cai quan trong la nguoi hoc phan biet duoc "da xong" voi "bi mat du lieu".

## D6 / Q6.3

Loading khong chi la cai vong tron cho dep. O man hinh chinh, no la loi hua rang app dang lam gi do cu the cho nguoi hoc: nap ngan hang cau hoi, nap deck dung cap, hay tinh ke hoach hom nay. Neu chi hien spinner, nguoi hoc khong biet cho cai gi; neu panel bien mat, ho khong biet la da xong hay bi mat du lieu. Vi vay loading state can theo muc do quan trong: route khoa phien hoc phai noi ro dang nap gi, panel phu co the yen lang hon nhung khong duoc giau loi.

## D6 / Q6.4

Loi can noi cho nguoi hoc biet nen lam gi tiep, khong phai noi stack trace. Neu bam on tap ma gap `Exception`, nguoi hoc khong co hanh dong nao ngoai thoat app; neu panel bien mat thi ho khong biet co loi. Loi nho sau mot hanh dong co the hien snackbar, nhung loi chan ca man hinh hoc can co thong diep than thien, nut thu lai, va neu can thi log rieng cho minh debug.

## D6 / Q6.5

Tuong phan khong chi la "nhin co dep khong"; no quyet dinh nguoi hoc co doc duoc loi giai thich nho hay khong. Chu chinh va menu dang on, nen app khong hong toan cuc. Diem yeu nam o chu phu: hint, caption, chip canh bao, nhan trang thai nho. Neu cac dong nay mo qua, nguoi hoc van thay man hinh dep nhung mat boi canh de quyet dinh buoc tiep theo. Vi vay sua dung la sua token nho truoc, khong doi ca theme.

## D6 / Q6.6

Nut nho khong phai luc nao cung sai; vung bam nho moi sai. App co the giu icon gon trong thanh cong cu, nhung hitbox phai van du lon cho ngon tay. Cac luong chinh nhu menu duoi, quiz, grid kanji dang tuong doi an toan. Loi nam o nhung noi minh co tinh "lam gon": shrinkWrap, constraint bang 0, nut 36px, chip tu ve. Vi vay chinh sach dung la them san 44px cho vung cham, khong phong to ca giao dien.

## D6 / Q6.7

Dark mode co hai muc: bat duoc va song duoc. App da bat duoc: theme co dark palette, setting luu duoc, test co qua. Nhung song duoc nghia la moi man hinh chinh deu khong co the sang bat ngo, input/button/chip co cung ngon ngu, va anh chup toi khong lam nguoi hoc bi lech mat. Hien tai dark mode la mot nen mong tot, chua phai loi hua parity.

## D7 / Q7.1

Performance khong chi la file JS to hay nho. Build web da qua, JS gzip chua phai tham hoa, nhung lan vao dau tien lai keo qua nhieu tai nguyen va nhieu file grammar. Neu nguoi hoc mo app tren mang yeu, moi file nho van thanh rat nhieu lan cho. Vi vay budget dau tien nen dem "route nay can bao nhieu request va bao nhieu JSON", khong chi dem tong MB cua build.

## D8 / Q8.1

Release readiness khong dong nghia voi "build duoc". Mot ban build co the qua, nhung live channel cu, tai lieu shipping sai flag App Check, CSP doc lech config, va smoke test cu van lam minh tin nham. Dung hon la xem release nhu mot hop dong: source nao dang len live, len target nao, build bang flag nao, test nao phai xanh, va sau deploy phai do lai route/perf tren dung URL.

## D8 Compliance / Q8.1

Quyen rieng tu va dieu khoan khong phai la file nam dau do trong repo; chung la mot phan cua hanh trinh nguoi dung. Neu nguoi hoc dang dang nhap Google, bat cloud backup, hay bat dau onboarding ma khong thay minh dong y voi gi va du lieu duoc dung ra sao, app khong co "consent surface". Sua dung la lam route va link nho, ro, do duoc bang test; noi dung phap ly co the can review rieng, nhung cai cua vao phai ton tai trong san pham truoc.

Firebase API key restriction la mot lop chan o cua Google API, khac voi App Check. Neu key bi goi tu origin la, Google tra `API_KEY_HTTP_REFERRER_BLOCKED` truoc khi den logic Auth; neu origin hop le, request moi tiep tuc va co the loi binh thuong nhu `MISSING_ID_TOKEN`. Vi vay test dung la gui mot request khong tao user voi referrer gia: thay 403 thi biet lop key dang chan, nhung van phai giu App Check, Storage rules, quota va monitoring vi moi lop chan mot kieu abuse khac nhau.

Auth authorized domains la hop dong giua Firebase Console va nhung origin duoc phep mo luong dang nhap. Source chi cho biet app dang mong doi domain nao; no khong chung minh Console da xoa `localhost` hay OAuth client da dung. Vi vay release gate phai co mot buoc manual ro rang: production project chi giu domain public can dung, local auth thi chuyen sang project dev.

CI tot khong chi la "co test". No phai bao ve dung rui ro cua giai doan hien tai. Voi JpStudy, workflow da bat duoc loi source co ban: string guard, analyze, test, build web, storage rules. Nhung beta risk lai nam o live channel: build co dung flag App Check khong, deploy dung target khong, URL that co load dung route khong, perf co vuot budget khong. Vi vay CI nen tien hoa tu local gate sang release gate co target, budget va post-deploy probe.

Perf budget dau tien khong can do tat ca. Neu Lighthouse chua chay duoc, van co the chan hoi quy bang nhung thu chac chan do duoc: `main.dart.js`, wasm, tong asset, tong JSON. Budget nay giong can nang: no khong noi nguoi hoc co cam thay nhanh khong, nhung no bao ngay khi app nang len bat thuong. Buoc tiep theo moi la do route that: bao nhieu request, bao nhieu JSON bi keo truoc khi can, va live CDN nen anh huong ra sao.

Seed du lieu la mot phan cua performance contract. Neu startup tu dong nap ca N1-N5 "cho chac", app se trong dung tren may dev nhung keo qua nhieu file tren mang yeu. Cach dung hon la startup chi nap cap do nguoi hoc dang hoc, con route nao can cap do khac phai noi ro "toi can N3/N4" va lazy-seed dung cap do do. Nhu vay performance va correctness cung di chung mot quy tac: moi truy van noi dung phai co level ro rang.

Sau khi bo all-level seed, con lai mot cau hoi chat hon: root co can grammar khong? Neu nguoi hoc chi mo home de xem ke hoach ngay, keo 25 bai grammar N5 va 25 file vi du van la qua som. Level-scoped la tang an toan dau tien; route-scoped moi la performance that. App nen nap "N5 grammar" khi route grammar/lesson can, khong phai khi shell vua song.

Perf gate tot phai do dung hanh vi nguoi hoc gap: mo trang dau tien. Tong MB build cho biet app nang, nhung resource smoke cho biet root da keo nhung gi truoc khi can. Khi CI dem request va chan grammar JSON o root, moi lan ai them seed/ngam fetch moi se bi bat ngay thay vi doi UAT thay cham.

## D2 / Q2.7

Du lieu phien am va du lieu giai nghia la hai lop khac nhau. Unihan co the noi "bo nay doc Han-Viet la gi", nhung khong noi cach giai thich tieng Viet nao dep, gon, va dung cho nguoi hoc. Bang 214 bo thu hien tai tron hai lop do tu raw ASCII, nen mot dong co the vua dung am dau vua co gloss gay nhieu, hoac sai am dau nhung trong van co ve hop ly. Sua dung la tach audit: Unihan bat loi nhan Han-Viet, con gloss can nguon/editorial rieng.

## D1 / Q1.4

Telemetry co hai cong tac rieng: quyen truy cap va dong du lieu. `SELECT 1` chung minh service account, OAuth, va BigQuery job da dung; no khong chung minh GA4 dang xuat bang su kien. Neu dataset `analytics_536663906` chua ton tai, moi bao cao NS deu chi la gia lap du co credentials tot. Vi vay gate dung la: auth smoke truoc, dataset inventory sau, roi moi chay query su kien that.

## Kanji / Radical Headers

Mot man hinh co the dung hai duong render cho cung mot khai niem. Filter chip "4 net" da di qua copy helper nen dung dau tieng Viet, con header group lai hardcode local nen thanh mojibake. Khi user thay mot cho dung mot cho sai, dung gia thuyet dau tien la "font" hay "data" chua du; phai trace tung duong chuoi. Quy tac tot hon: moi label lap lai nen co mot API copy chung, vi copy path chung chinh la test surface chung.

## D4 / P2-P5 Live Re-Test 2026-05-15

"Da co data" khong dong nghia voi "da mo cho nguoi hoc". Vocab live cho thay N4 co ca data, badge mo, CTA `Mo lane/Mo track`, va count that; N3/N2/N1 thi co card va ten track nhung van `Sap ra mat`, `Xem truoc`, `0 muc tu`, `0 Dang mo`. Vi vay moi tinh nang unlock can check bon lop rieng: content seed, catalog display, availability registry/CTA, va queue/review count. Thieu mot lop la nguoi hoc van thay bi khoa.

## D8 / Q8.4

Error monitoring cung la consent surface, khong chi la SDK. Neu gan Sentry vao `main` ma khong nhin consent, app se gui loi truoc khi nguoi hoc dong y; neu doi user bam chap nhan moi import code, crash dau tien van mat. Cach dung la tach ba lop: cau hinh DSN co hay khong, quyen gui theo consent/sign-in/Do Not Track, va co che bat SDK truoc `runApp` hoac bat muon sau khi quyen thay doi. Nhu vay beta co duong bat crash khi user cho phep, nhung mac dinh van im lang khi chua co DSN hoac chua co quyen.

## D8 / Q8.5

Deploy automation phai co che that bai dung luc, khong that bai vi secret chua duoc cap. Voi solo-dev `main`, workflow tot la: source CI phai bat loi moi commit; deploy job chi chay sau khi source CI xanh; neu thieu `FIREBASE_TOKEN` hoac App Check key thi skip co warning; neu co secret thi bat buoc deploy dung `hosting:jpstudy`, smoke primary/legacy, va do live resource + Lighthouse. Nhu vay repo da ma hoa release contract ma khong khoa duong commit trong luc credential setup con dang cho user.

## Auth / Anonymous Bootstrap

Anonymous Auth nen duoc xem nhu identity substrate, khong phai login UX. Neu app can UID de backup, migrate, gan support context, thi co the tao UID am tham sau Firebase/App Check init voi timeout ngan; UI van boot offline neu fail. Diem quan trong la tach ba viec: tao UID, di chuyen local progress len path dung owner, va sau nay moi thiet ke upgrade/link account. Cach tach nay giu onboarding khong ma sat nhung van tao duong an toan cho beta data.

## Textbook-Aligned Roadmap

Lo trinh nha sach nen la lop dinh huong, khong phai hard gate. N5/N4 co the bam Minna I/II vi app co asset that; N3-N1 phai chuyen sang Hajimete + Shin Kanzen vi do la du lieu dang ship. Khi tach "hom nay hoc gi" khoi "duong sach nao dang theo", home van giu nhịp hanh dong nhanh nhung nguoi hoc khong bi hieu sai ve pham vi giao trinh.

## D8 / Q8.7

Nut reset trong app va quyen xoa du lieu la hai viec khac nhau. `resetAnalyticsData()` chi yeu cau SDK xoa ma dinh danh phan tich cuc bo tren thiet bi, va tren web hien tai SDK Firebase con bao khong ho tro. Vi vay Data controls can co hanh dong ro rang cho nguoi hoc, nhung release gate dung van phai gom retention setting, GA user-deletion runbook, va BigQuery export TTL. Compliance tot la noi dung that cua he thong, khong phai chi mot nut trong UI.

## D1 / First Real GA4 Export

Dataset ton tai moi chi la cong tac mo duong ong. Lan xuat GA4 dau tien da chung minh BigQuery, TTL, va mapper query chay duoc, nhung chua co SRS, micro-quiz, hay quality rating thi North Star van bang 0 va khong noi gi ve hoc that. Measurement gate dung phai tach ba lop: export co bang, bang co dung su kien, va su kien co hanh vi hoc sau onboarding.
