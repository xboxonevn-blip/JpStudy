#!/usr/bin/env python3
"""Upgrade thin grammar lessons and remove meta examples."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GRAMMAR_ROOT = ROOT / 'assets' / 'data' / 'content' / 'grammar'
EXAMPLE_ROOT = GRAMMAR_ROOT / 'examples'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'grammar-quality-upgrade-report.json'

SUPPLEMENTS = {
    'n5': {
        13: [('〜ませんか', '~ won’t you / shall we', 'Vます + ませんか', 'Dùng để mời hoặc rủ rê một cách lịch sự.', 'Used to make a polite invitation.', '週末、いっしょに映画を見に行きませんか。', 'Cuối tuần đi xem phim cùng nhau nhé?', 'Won’t you go see a movie together this weekend?')],
        15: [('Vてもかまいません', '~ may / it is okay to', 'Vて + もかまいません', 'Diễn tả xin phép hoặc cho phép làm gì.', 'Expresses permission or that something is acceptable.', 'ここで写真を撮ってもかまいませんか。', 'Tôi chụp ảnh ở đây có được không?', 'Is it okay if I take pictures here?')],
        21: [('〜と思っています', '~ am thinking / intend', 'V普通形 / A / Nだ + と思っています', 'Diễn tả suy nghĩ hoặc ý định đang duy trì.', 'Expresses an ongoing thought or intention.', '来年、日本へ留学しようと思っています。', 'Tôi đang dự định năm sau đi du học Nhật.', 'I am thinking of studying abroad in Japan next year.')],
        22: [
            ('V普通形 + N', 'relative clause with verbs', 'V普通形 + N', 'Dùng mệnh đề động từ để bổ nghĩa cho danh từ.', 'Uses a verb clause to modify a noun.', '昨日買った本はとても面白いです。', 'Cuốn sách tôi mua hôm qua rất thú vị.', 'The book I bought yesterday is very interesting.'),
            ('A / Nの + N', 'relative clause with adjectives/nouns', 'Aい / Aな / Nの + N', 'Dùng tính từ hoặc danh từ để bổ nghĩa cho danh từ.', 'Uses adjectives or nouns to modify a noun.', '親切な人が案内してくれました。', 'Một người tốt bụng đã chỉ đường cho tôi.', 'A kind person guided me.')
        ],
        23: [('〜前に', '~ before', 'V辞書 / Nの + 前に', 'Diễn tả làm việc gì trước một hành động hay thời điểm khác.', 'Expresses doing something before another action or time.', '寝る前に、少し日本語を勉強します。', 'Trước khi ngủ, tôi học tiếng Nhật một chút.', 'I study a little Japanese before going to bed.')],
        25: [('〜なら', '~ if / in that case', 'N / 普通形 + なら', 'Diễn tả giả định dựa trên thông tin vừa biết.', 'Expresses a conditional based on given information.', '時間がないなら、タクシーで行ったほうがいいです。', 'Nếu không có thời gian thì đi taxi sẽ tốt hơn.', 'If you do not have time, it would be better to go by taxi.')],
    },
    'n4': {
        26: [('〜んですが', '~ actually / I’d like to say', '普通形 + んですが', 'Dùng để mở đầu giải thích hoặc dẫn sang nhờ vả, hỏi han.', 'Used to introduce an explanation, request, or question.', 'ちょっと相談したいんですが、今いいですか。', 'Tôi có chút chuyện muốn bàn, bây giờ có được không?', 'I would like to discuss something; is now a good time?')],
        27: [('見える', '~ can be seen', 'N が 見える', 'Diễn tả thứ gì đó lọt vào tầm nhìn một cách tự nhiên.', 'Expresses that something can be seen naturally.', 'ここから海が見えます。', 'Từ đây có thể nhìn thấy biển.', 'You can see the sea from here.'), ('聞こえる', '~ can be heard', 'N が 聞こえる', 'Diễn tả âm thanh lọt vào tai một cách tự nhiên.', 'Expresses that something can be heard naturally.', '隣の部屋から音楽が聞こえます。', 'Từ phòng bên cạnh có thể nghe thấy nhạc.', 'I can hear music from the next room.')],
        28: [('〜間に', '~ while / during', 'Vている / Nの + 間に', 'Diễn tả việc gì xảy ra trong khoảng thời gian một trạng thái tiếp diễn.', 'Expresses something happening during a continuing state.', '音楽を聞いている間に、宿題をしました。', 'Trong lúc nghe nhạc, tôi làm bài tập.', 'I did my homework while listening to music.')],
        29: [('〜ちゃいました', '~ ended up doing (casual)', 'Vて + ちゃいました / じゃいました', 'Dạng khẩu ngữ của 〜てしまいました.', 'Casual spoken form of 〜てしまいました.', '電車で寝て、駅を乗り過ごしちゃいました。', 'Tôi ngủ quên trên tàu và lỡ quá ga mất rồi.', 'I fell asleep on the train and accidentally missed my stop.'), ('まだ〜ています', '~ still doing / still in state', 'まだ + Vています', 'Diễn tả trạng thái vẫn còn tiếp diễn.', 'Expresses that a state still continues.', '窓がまだ開いています。', 'Cửa sổ vẫn còn đang mở.', 'The window is still open.')],
        30: [('〜ておいてください', '~ please do in advance', 'Vて + おいてください', 'Nhờ ai chuẩn bị hoặc làm sẵn điều gì trước.', 'Used to ask someone to do something in advance.', '会議の前に、この資料を読んでおいてください。', 'Trước cuộc họp, xin hãy đọc trước tài liệu này.', 'Please read this document before the meeting.'), ('〜ておきます', '~ do in advance', 'Vて + おきます', 'Diễn tả tự mình chuẩn bị trước cho việc sau đó.', 'Expresses doing something in advance for later.', '旅行の前に、ホテルを予約しておきます。', 'Trước chuyến đi, tôi sẽ đặt khách sạn trước.', 'I will reserve the hotel before the trip.')],
        31: [('〜ことにする', '~ decide to do', 'V辞書 / Vない + ことにする', 'Diễn tả quyết định do bản thân đưa ra.', 'Expresses a personal decision.', '健康のために、毎日歩くことにしました。', 'Vì sức khỏe, tôi quyết định đi bộ mỗi ngày.', 'For my health, I decided to walk every day.')],
        32: [('〜でしょうか', '~ I wonder / could it be', '普通形 + でしょうか', 'Dùng để hỏi lịch sự hoặc nêu thắc mắc nhẹ nhàng.', 'Used for polite questions or soft uncertainty.', '明日は雨でしょうか。', 'Không biết mai có mưa không?', 'I wonder if it will rain tomorrow.')],
        34: [('〜前に', '~ before', 'V辞書 / Nの + 前に', 'Diễn tả làm gì trước hành động khác.', 'Expresses doing something before another action.', '出かける前に、戸を閉めてください。', 'Trước khi ra ngoài, hãy đóng cửa nhé.', 'Please close the door before you go out.')],
        35: [('〜たらどうですか', '~ why don’t you', 'Vたら + どうですか', 'Dùng để đưa ra lời khuyên.', 'Used to give advice.', '疲れているなら、少し休んだらどうですか。', 'Nếu mệt thì nghỉ một chút đi?', 'If you are tired, why don’t you rest a little?'), ('〜ても', '~ even if', 'Vて / Aくて / Nでも', 'Diễn tả giả định nhượng bộ: cho dù thế nào cũng.', 'Expresses concession: even if.', '雨でも、試合はあります。', 'Dù mưa thì trận đấu vẫn diễn ra.', 'Even if it rains, the match will be held.')],
        36: [('〜ように言います', '~ tell someone to do', 'V辞書 / Vない + ように言います', 'Diễn tả truyền đạt chỉ thị hoặc lời nhắc.', 'Expresses telling someone to do something.', '先生は学生に毎日復習するように言いました。', 'Giáo viên đã dặn học sinh mỗi ngày phải ôn bài.', 'The teacher told the students to review every day.')],
        37: [('迷惑の受け身', 'suffering passive', 'N は N に Vられます', 'Bị động diễn tả bị làm phiền hoặc gặp bất lợi.', 'Passive expressing inconvenience or suffering.', '私は友だちに秘密を言われて困りました。', 'Tôi bị bạn nói ra bí mật nên rất khó xử.', 'I was troubled because my friend revealed my secret.')],
        38: [('Vること', 'nominalized verb with こと', 'V辞書 + こと', 'Danh từ hóa động từ bằng こと.', 'Nominalizes a verb using こと.', '外国語を勉強することは楽しいです。', 'Việc học ngoại ngữ rất thú vị.', 'Studying foreign languages is fun.')],
        39: [('〜ために（理由）', '~ because of', 'Nの / 普通形 + ために', 'Diễn tả nguyên nhân trang trọng.', 'Expresses a formal reason.', '事故のために、道が込んでいます。', 'Vì tai nạn nên đường đang tắc.', 'Because of an accident, the road is crowded.'), ('〜おかげで', '~ thanks to', 'Nの / 普通形 + おかげで', 'Diễn tả nguyên nhân tốt.', 'Expresses a positive cause.', '先生のおかげで、合格できました。', 'Nhờ thầy cô mà tôi đã đỗ.', 'Thanks to my teacher, I passed.')],
        40: [('〜かどうか', '~ whether or not', '普通形 + かどうか', 'Dùng để diễn tả có hay không trong mệnh đề phụ.', 'Expresses whether or not in a subordinate clause.', '彼が来るかどうか分かりません。', 'Tôi không biết anh ấy có đến hay không.', 'I do not know whether he will come.')],
        41: [('〜てくださる', '~ kindly do for me', 'Vて + くださる', 'Kính ngữ của 〜てくれる.', 'Honorific form of 〜てくれる.', '先生が漢字の読み方を教えてくださいました。', 'Thầy đã chỉ cho tôi cách đọc kanji.', 'My teacher kindly taught me how to read the kanji.')],
        42: [('〜ために（理由）', '~ because of', 'Nの / 普通形 + ために', 'Diễn tả lý do theo văn phong trang trọng.', 'Expresses a reason in a formal tone.', '病気のために、旅行を中止しました。', 'Vì bệnh nên tôi hủy chuyến đi.', 'Because of illness, I canceled the trip.'), ('〜ように', '~ so that', 'V辞書 / Vない + ように', 'Diễn tả mục đích hướng đến trạng thái.', 'Expresses purpose aimed at a resulting state.', '忘れないように、メモしておきます。', 'Để không quên, tôi sẽ ghi chú lại.', 'I will make a note so that I do not forget.')],
        43: [('〜ていく', '~ continue to / go on', 'Vて + いく', 'Diễn tả sự thay đổi tiếp diễn từ hiện tại về sau.', 'Expresses change continuing from now on.', 'これから日本語をもっと勉強していきたいです。', 'Từ giờ tôi muốn tiếp tục học tiếng Nhật nhiều hơn.', 'From now on, I want to continue studying Japanese more.'), ('〜そうだ（様態）', '~ looks like', 'Vます / A / Aな + そうだ', 'Diễn tả cảm giác nhìn có vẻ như thế nào.', 'Expresses how something appears at first glance.', 'このケーキはおいしそうです。', 'Cái bánh này trông có vẻ ngon.', 'This cake looks delicious.')],
        44: [('〜く / 〜に なる', '~ become', 'Aく / Aなに / Nに + なる', 'Diễn tả sự thay đổi trạng thái.', 'Expresses a change of state.', 'だんだん暖かくなりました。', 'Trời dần dần ấm lên.', 'It gradually became warmer.')],
        45: [('〜とき（before/after distinction）', '~ when', 'Vる / Vた + とき', 'Bổ sung cách phân biệt thời điểm trước và sau hành động.', 'Adds the before/after timing distinction with とき.', '日本へ行くとき、友だちに電話しました。', 'Lúc đi Nhật, tôi đã gọi cho bạn.', 'When I was going to Japan, I called my friend.'), ('〜ても', '~ even if', 'Vて / Aくて / Nでも', 'Diễn tả nhượng bộ.', 'Expresses concession.', '忙しくても、運動します。', 'Dù bận tôi vẫn tập thể dục.', 'Even if I am busy, I exercise.')],
        46: [('〜ところだった', '~ was just about to / almost', 'V辞書 + ところだった', 'Diễn tả suýt nữa thì hoặc đang chuẩn bị làm.', 'Expresses almost doing or being just about to do something.', 'もう少しで電車に遅れるところでした。', 'Suýt nữa thì tôi đã muộn tàu.', 'I was just about to miss the train.')],
        47: [('〜らしい', '~ apparently / typical of', '普通形 / N + らしい', 'Diễn tả thông tin nghe được hoặc đặc tính điển hình.', 'Expresses hearsay or typical characteristics.', '彼は来月結婚するらしいです。', 'Nghe nói anh ấy tháng sau sẽ kết hôn.', 'Apparently he will get married next month.'), ('〜みたいです', '~ looks like', '普通形 / N + みたいです', 'Cách nói thân mật hơn của ようです.', 'A more casual way of saying ようです.', '外は雪みたいです。', 'Bên ngoài hình như có tuyết.', 'It looks like snow outside.')],
        48: [('〜させてください', '~ please let me do', 'V使役形 + てください', 'Xin phép được làm gì.', 'Used to ask permission to do something.', '私にも説明させてください。', 'Xin hãy cho tôi cũng được giải thích.', 'Please let me explain as well.')],
        49: [('お／ご〜になります', 'honorific pattern', 'お／ご + Vます-stem + になります', 'Một mẫu kính ngữ cơ bản.', 'A basic honorific pattern.', '少々お待ちになりますか。', 'Quý khách vui lòng chờ một chút được không ạ?', 'Would you please wait a moment?'), ('〜れます（尊敬）', 'honorific passive-like form', 'Vられます', 'Dùng như kính ngữ cho một số động từ.', 'Used as an honorific form for some verbs.', '社長はもう帰られました。', 'Giám đốc đã về rồi ạ.', 'The company president has already left.')],
        50: [('お／ご〜します', 'humble pattern', 'お／ご + Vます-stem + します', 'Một mẫu khiêm nhường ngữ cơ bản.', 'A basic humble expression pattern.', '荷物をお持ちします。', 'Tôi xin mang hành lý giúp ạ.', 'I will carry your luggage.'), ('〜でございます', 'very polite copula', 'N / Aな + でございます', 'Cách nói lịch sự cao của です.', 'A very polite form of です.', 'こちらが資料でございます。', 'Đây là tài liệu ạ.', 'This is the material.')],
    },
    'n3': {
        51: [('〜ことにしている', '~ make it a rule to', 'V辞書 / Vない + ことにしている', 'Diễn tả thói quen do bản thân quyết định duy trì.', 'Expresses a self-imposed rule or habit.', '健康のために、毎朝散歩することにしている。', 'Vì sức khỏe, tôi đặt quy tắc mỗi sáng đi bộ.', 'For my health, I make it a rule to walk every morning.')],
        52: [('〜ようになっている', '~ be arranged so that', 'V辞書 / Vない + ようになっている', 'Diễn tả cơ chế hoặc trạng thái được thiết kế sẵn.', 'Expresses a built-in arrangement or design.', 'このアプリは、毎日復習できるようになっている。', 'Ứng dụng này được thiết kế để có thể ôn tập mỗi ngày.', 'This app is designed so that you can review every day.')],
        53: [('〜わりに', '~ considering / for', '普通形 / Nの + わりに', 'Diễn tả kết quả khác với mức độ mong đợi.', 'Expresses a result that differs from expectation.', 'この商品は安いわりに、長く使えます。', 'Sản phẩm này tuy rẻ nhưng dùng được lâu.', 'This product lasts a long time for how cheap it is.')],
        54: [('〜間に', '~ while / during', 'Vている / Nの + 間に', 'Diễn tả việc xảy ra trong khoảng thời gian một trạng thái tiếp diễn.', 'Expresses something happening during a continuing state.', '留学している間に、多くの友だちができた。', 'Trong thời gian du học, tôi đã kết thêm nhiều bạn.', 'While studying abroad, I made many friends.')],
        55: [('〜はずがない', '~ cannot possibly', '普通形 + はずがない', 'Phủ định mạnh một khả năng dựa trên lý lẽ.', 'Strongly denies a possibility based on reason.', 'あの人が約束を忘れるはずがない。', 'Người đó không thể nào quên lời hứa được.', 'There is no way that person would forget the promise.')],
        56: [('〜かえって', '~ on the contrary / rather', '—', 'Diễn tả kết quả trái với mong đợi ban đầu.', 'Expresses a result opposite to what was expected.', '急いで買ったら、かえって損をしてしまった。', 'Mua vội quá nên ngược lại còn bị thiệt.', 'Because I bought it in a hurry, I ended up losing out instead.')],
        57: [('〜ないようにする', '~ make sure not to', 'Vない + ようにする', 'Diễn tả cố gắng tránh một hành động.', 'Expresses making an effort not to do something.', '夜遅く食べすぎないようにしている。', 'Tôi cố không ăn quá nhiều vào đêm muộn.', 'I try not to eat too much late at night.')],
        58: [('〜ように見える', '~ looks like', '普通形 + ように見える', 'Diễn tả ấn tượng trực quan từ vẻ bề ngoài.', 'Expresses a visual impression.', 'この町は昔と同じように見える。', 'Thị trấn này trông có vẻ vẫn như xưa.', 'This town looks the same as before.')],
        59: [('〜とのことだ', '~ it is said that', '普通形 + とのことだ', 'Diễn tả nội dung nghe hoặc nhận được từ nguồn tin.', 'Expresses reported information.', '先生によると、試験は来週になるとのことだ。', 'Theo giáo viên thì kỳ thi sẽ diễn ra vào tuần tới.', 'According to the teacher, the exam will be next week.')],
        60: [('〜に応じて', '~ according to / depending on', 'N + に応じて', 'Diễn tả thay đổi tùy theo điều kiện hoặc đối tượng.', 'Expresses variation according to conditions.', '目的に応じて、交通手段を選ぶべきだ。', 'Nên chọn phương tiện đi lại tùy theo mục đích.', 'You should choose transportation according to your purpose.')],
        61: [('〜可能性がある', '~ there is a possibility', '普通形 + 可能性がある', 'Diễn tả khả năng xảy ra sự việc.', 'Expresses possibility.', 'この雨では、川の水があふれる可能性がある。', 'Với trận mưa này có khả năng nước sông tràn bờ.', 'With this rain, there is a possibility the river will overflow.')],
        62: [('〜ばかりか', '~ not only ... but also', 'N / 普通形 + ばかりか', 'Diễn tả không chỉ A mà còn cả B.', 'Expresses not only A but also B.', 'その映画は面白いばかりか、音楽もすばらしかった。', 'Bộ phim đó không chỉ hay mà âm nhạc cũng tuyệt vời.', 'That movie was not only interesting, but the music was wonderful too.')],
        63: [('〜ないこともない', '~ it is not impossible', 'Vない + こともない', 'Diễn tả vẫn có thể, dù không tích cực lắm.', 'Expresses that something is possible, though not enthusiastically.', '時間を作れば、参加できないこともない。', 'Nếu sắp xếp thời gian thì cũng không phải là không thể tham gia.', 'If I make time, it is not impossible for me to participate.')],
        64: [('〜といいな', '~ I hope', '普通形 + といいな', 'Cách nói thân mật để bày tỏ hi vọng.', 'A casual way to express hope.', '家族ともっとゆっくり話せるといいな。', 'Giá mà có thể nói chuyện thong thả hơn với gia đình thì tốt.', 'I hope I can talk more calmly with my family.')],
        65: [('〜てもらう', '~ have someone do', '人に Vて + もらう', 'Diễn tả nhận sự giúp đỡ từ ai đó.', 'Expresses receiving help from someone.', '引っこしの日に、友だちに手伝ってもらった。', 'Vào ngày chuyển nhà tôi đã nhờ bạn giúp.', 'I had a friend help me on moving day.')],
        66: [('〜抜く', '~ do through / to the end', 'Vます + 抜く', 'Diễn tả làm đến cùng dù khó khăn.', 'Expresses doing something through to the end.', '苦しくても、最後までやり抜いた。', 'Dù vất vả tôi vẫn làm đến cùng.', 'Even though it was hard, I carried it through to the end.')],
        67: [('〜とされている', '~ is regarded as / said to be', '普通形 + とされている', 'Diễn tả điều được xã hội hoặc tài liệu xem là như vậy.', 'Expresses something regarded or stated as such.', 'この技術は将来重要になるとされている。', 'Công nghệ này được xem là sẽ trở nên quan trọng trong tương lai.', 'This technology is regarded as becoming important in the future.')],
        68: [('〜ことになっている', '~ it is stipulated that', 'V辞書 / Vない + ことになっている', 'Diễn tả quy định đã được thiết lập.', 'Expresses a predetermined rule.', 'この施設では、入口で名前を書くことになっている。', 'Ở cơ sở này, theo quy định phải ghi tên ở lối vào.', 'At this facility, visitors are supposed to write their names at the entrance.')],
        69: [('〜際に', '~ on the occasion of / when', 'V辞書 / Nの + 際に', 'Diễn tả thời điểm trang trọng hơn とき.', 'A more formal way to express “when”.', '調理の際に、火の扱いに気をつけてください。', 'Khi nấu ăn, xin hãy cẩn thận khi dùng lửa.', 'When cooking, please be careful with fire.')],
        70: [('〜に決まっている', '~ certainly / must', '普通形 + に決まっている', 'Diễn tả sự tin chắc mạnh.', 'Expresses strong certainty.', 'そんなに努力したのだから、結果は出るに決まっている。', 'Đã cố gắng như vậy thì nhất định sẽ có kết quả.', 'After working that hard, you are bound to get results.')],
        71: [('〜にしたがって', '~ as / with', 'V辞書 / N + にしたがって', 'Diễn tả thay đổi song song với thay đổi khác.', 'Expresses change occurring along with another change.', '年を取るにしたがって、考え方も変わる。', 'Càng lớn tuổi thì cách suy nghĩ cũng thay đổi.', 'As you get older, your way of thinking changes too.')],
        72: [('〜についての', '~ about / regarding', 'N + についての + N', 'Mẫu bổ nghĩa danh từ với について.', 'Nominal modifying pattern with について.', '発音についての本を探しています。', 'Tôi đang tìm một cuốn sách về phát âm.', 'I am looking for a book about pronunciation.')],
        73: [('〜における', '~ in / at', 'N + における + N', 'Cách viết trang trọng của での.', 'A formal written equivalent of での.', '現代社会における若者の役割を考える。', 'Suy nghĩ về vai trò của giới trẻ trong xã hội hiện đại.', 'We consider the role of young people in modern society.')],
        74: [('〜に比べて', '~ compared with', 'N + に比べて', 'Diễn tả so sánh với đối tượng khác.', 'Expresses comparison with another thing.', '去年に比べて、服に使うお金が減った。', 'So với năm ngoái, số tiền tôi dùng cho quần áo đã giảm.', 'Compared with last year, the money I spend on clothes has decreased.')],
        75: [('〜だけでなく', '~ not only ... but also', 'N / 普通形 + だけでなく', 'Diễn tả không chỉ A mà còn B.', 'Expresses not only A but also B.', 'この活動は地域だけでなく、世界にも良い影響を与える。', 'Hoạt động này không chỉ tác động tốt tới địa phương mà cả thế giới.', 'This activity has a positive impact not only locally but also globally.')],
    },
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def _write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def _upgrade_level(level: str, lessons: dict[int, list[tuple]]) -> dict:
    report = {}
    for lesson_id, items in lessons.items():
        grammar_path = GRAMMAR_ROOT / level / f'grammar_{level}_{lesson_id}.json'
        example_path = EXAMPLE_ROOT / level / f'lesson_{lesson_id}.json'
        grammar_data = _read_json(grammar_path)
        example_data = _read_json(example_path)

        example_map = {item['grammarPoint']: item for item in example_data}

        if level == 'n3':
            for item in example_data:
                examples = item.get('examples', [])
                cleaned = []
                for ex in examples:
                    sentence = ex.get('sentence', '')
                    translation = ex.get('translation', '')
                    if 'この課では' in sentence or '例文は後で' in sentence or 'chủ đề bài học' in translation.lower():
                        continue
                    cleaned.append(ex)
                item['examples'] = cleaned[:1] if cleaned else []

        for title, title_en, structure, explanation, explanation_en, jp, vi, en in items:
            if title not in {point['title'] for point in grammar_data}:
                grammar_data.append({
                    'lessonId': lesson_id,
                    'title': title,
                    'titleEn': title_en,
                    'structure': structure,
                    'structureEn': structure,
                    'explanation': explanation,
                    'explanationEn': explanation_en,
                    'level': level.upper(),
                    'tags': 'quality-upgrade,manual-review-needed',
                })
            if title not in example_map:
                example_map[title] = {'grammarPoint': title, 'examples': []}
                example_data.append(example_map[title])
            if not example_map[title]['examples']:
                example_map[title]['examples'].append({
                    'sentence': jp,
                    'translation': vi,
                    'translationEn': en,
                })

        _write_json(grammar_path, grammar_data)
        _write_json(example_path, example_data)
        report[str(lesson_id)] = {
            'points': len(grammar_data),
            'exampleGroups': len(example_data),
            'examples': sum(len(item.get('examples', [])) for item in example_data),
        }
    return report


def main() -> int:
    payload = {level.upper(): _upgrade_level(level, lessons) for level, lessons in SUPPLEMENTS.items()}
    _write_json(REPORT_PATH, payload)
    print(json.dumps({'report': str(REPORT_PATH.relative_to(ROOT)).replace('\\', '/')}, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
