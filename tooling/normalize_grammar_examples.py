#!/usr/bin/env python3

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXAMPLE_ROOT = ROOT / 'assets' / 'data' / 'content' / 'grammar_examples'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'grammar-example-normalization-report.json'

SECOND_EXAMPLES = {
    '〜ませんか': ('いっしょに昼ごはんを食べに行きませんか。', 'Chúng ta đi ăn trưa cùng nhau nhé?', 'Would you like to go eat lunch together?'),
    'Vてもかまいません': ('この辞書を使ってもかまいません。', 'Bạn dùng cuốn từ điển này cũng được.', 'It is okay to use this dictionary.'),
    '〜と思っています': ('卒業したら、日本の会社で働こうと思っています。', 'Sau khi tốt nghiệp, tôi đang dự định làm việc ở công ty Nhật.', 'After graduating, I am thinking of working for a Japanese company.'),
    'V普通形 + N': ('駅で買ったパンを朝ごはんに食べました。', 'Tôi đã ăn bánh mì mua ở ga làm bữa sáng.', 'I ate the bread I bought at the station for breakfast.'),
    'A / Nの + N': ('静かな部屋で勉強したいです。', 'Tôi muốn học trong một căn phòng yên tĩnh.', 'I want to study in a quiet room.'),
    '〜前に': ('食事の前に、手を洗ってください。', 'Trước khi ăn, xin hãy rửa tay.', 'Please wash your hands before eating.'),
    '〜なら': ('日本へ行くなら、このアプリを入れたほうがいいです。', 'Nếu đi Nhật thì nên cài ứng dụng này.', 'If you are going to Japan, you should install this app.'),
    '〜んですが': ('日本語でメールを書いたんですが、見てもらえますか。', 'Tôi đã viết email bằng tiếng Nhật, bạn xem giúp được không?', 'I wrote an email in Japanese; could you check it for me?'),
    '見える': ('晴れた日は、ここから山がよく見えます。', 'Ngày nắng từ đây có thể nhìn rõ ngọn núi.', 'On clear days, you can see the mountain well from here.'),
    '聞こえる': ('外から子どもの声が聞こえます。', 'Từ bên ngoài có thể nghe thấy tiếng trẻ con.', 'I can hear children’s voices from outside.'),
    '〜間に': ('母が料理している間に、私はテーブルを片づけた。', 'Trong lúc mẹ nấu ăn, tôi đã dọn bàn.', 'While my mother was cooking, I cleared the table.'),
    '〜ちゃいました': ('宿題を家に忘れちゃいました。', 'Tôi lỡ quên bài tập ở nhà mất rồi.', 'I accidentally left my homework at home.'),
    'まだ〜ています': ('先生はまだ会議をしています。', 'Giáo viên vẫn còn đang họp.', 'The teacher is still in a meeting.'),
    '〜ておいてください': ('帰る前に、窓を閉めておいてください。', 'Trước khi về, xin hãy đóng cửa sổ trước.', 'Please close the window before you leave.'),
    '〜ておきます': ('必要な単語は、ノートに書いておきます。', 'Tôi sẽ ghi trước những từ vựng cần thiết vào sổ.', 'I will write the necessary words in my notebook in advance.'),
    '〜ことにする': ('今夜から甘い物を食べすぎないことにします。', 'Từ tối nay tôi quyết định không ăn đồ ngọt quá nhiều.', 'Starting tonight, I will decide not to eat too many sweets.'),
    '〜ようにする': ('忘れないようにするため、予定をすぐメモします。', 'Để không quên, tôi ghi chú lịch trình ngay lập tức.', 'To make sure I do not forget, I write my schedule down right away.'),
    '〜つもりだ': ('来年は毎月一冊、日本語の本を読むつもりです。', 'Năm sau tôi định mỗi tháng đọc một cuốn sách tiếng Nhật.', 'Next year, I intend to read one Japanese book each month.'),
    '〜ことになる': ('来月から、土曜日も授業があることになりました。', 'Từ tháng sau đã được quyết định là thứ Bảy cũng có lớp.', 'It has been decided that there will be classes on Saturdays starting next month.'),
    '〜ようになる': ('毎日練習していたら、速く読めるようになりました。', 'Nhờ luyện mỗi ngày, tôi đã trở nên đọc nhanh hơn.', 'By practicing every day, I became able to read faster.'),
    '〜ことになっている': ('この図書館では、本は二週間借りられることになっています。', 'Ở thư viện này, sách được quy định là có thể mượn trong hai tuần.', 'At this library, books are supposed to be borrowed for two weeks.'),
    '〜ために': ('家族のために、毎日まじめに働いています。', 'Vì gia đình, tôi làm việc chăm chỉ mỗi ngày.', 'I work hard every day for my family.'),
    '〜でしょうか': ('明日の試験は難しいでしょうか。', 'Không biết kỳ thi ngày mai có khó không?', 'I wonder if tomorrow’s exam will be difficult.'),
    '〜たらどうですか': ('分からない言葉は、先生に聞いたらどうですか。', 'Những từ không hiểu thì bạn thử hỏi giáo viên xem sao?', 'Why don’t you ask your teacher about the words you do not understand?'),
    '〜ても': ('忙しくても、毎日少しずつ復習したほうがいい。', 'Dù bận cũng nên ôn tập từng chút mỗi ngày.', 'Even if you are busy, it is better to review a little every day.'),
    '〜ように言います': ('母は私に夜更かししないように言いました。', 'Mẹ đã dặn tôi đừng thức khuya.', 'My mother told me not to stay up late.'),
    '迷惑の受け身': ('私は弟にパソコンを壊されて困りました。', 'Tôi bị em trai làm hỏng máy tính nên rất khổ sở.', 'I was troubled because my younger brother broke my computer.'),
    'Vること': ('外国の文化を知ることは大切です。', 'Việc biết về văn hóa nước ngoài là quan trọng.', 'Knowing about foreign cultures is important.'),
    '〜ために（理由）': ('雪のために、バスが遅れました。', 'Vì tuyết nên xe buýt đã đến muộn.', 'Because of the snow, the bus was late.'),
    '〜おかげで': ('友だちのおかげで、道に迷わずにすみました。', 'Nhờ bạn bè mà tôi không bị lạc đường.', 'Thanks to my friend, I did not get lost.'),
    '〜かどうか': ('その店が開いているかどうか、調べてください。', 'Xin hãy kiểm tra xem cửa hàng đó có mở hay không.', 'Please check whether that shop is open or not.'),
    '〜てくださる': ('先生が宿題を早く直してくださいました。', 'Giáo viên đã sửa bài tập cho tôi rất nhanh.', 'My teacher kindly corrected my homework quickly.'),
    '〜ように': ('道を間違えないように、地図を持っていきます。', 'Để không đi nhầm đường, tôi sẽ mang theo bản đồ.', 'I will bring a map so that I do not take the wrong road.'),
    '〜ていく': ('これからも毎日漢字を覚えていきたいです。', 'Từ giờ tôi cũng muốn tiếp tục ghi nhớ kanji mỗi ngày.', 'From now on, I want to keep learning kanji every day.'),
    '〜そうだ（様態）': ('この問題は難しそうですね。', 'Bài này trông có vẻ khó nhỉ.', 'This problem looks difficult.'),
    '〜く / 〜に なる': ('子どもが大きくなって、よく話すようになりました。', 'Đứa trẻ lớn lên và đã trở nên nói chuyện nhiều hơn.', 'The child grew up and became more talkative.'),
    '〜とき（before/after distinction）': ('日本に来たとき、この町はまだ静かでした。', 'Khi tôi đến Nhật, thị trấn này vẫn còn yên tĩnh.', 'When I came to Japan, this town was still quiet.'),
    '〜ところだった': ('もう少しで大切なメールを消すところでした。', 'Suýt nữa thì tôi xóa mất email quan trọng.', 'I was just about to delete an important email.'),
    '〜らしい': ('あの店のラーメンは安くておいしいらしいです。', 'Nghe nói mì ramen của quán kia rẻ mà ngon.', 'Apparently the ramen at that shop is cheap and delicious.'),
    '〜みたいです': ('外は少し寒いみたいです。', 'Bên ngoài hình như hơi lạnh.', 'It seems a little cold outside.'),
    '〜させてください': ('その件について、私にも話させてください。', 'Về chuyện đó, xin hãy cho tôi cũng được nói.', 'Please let me speak about that matter as well.'),
    'お／ご〜になります': ('先生はもうお帰りになります。', 'Thầy sắp về rồi ạ.', 'The teacher will be leaving soon.'),
    '〜れます（尊敬）': ('部長は明日の会議に出られます。', 'Trưởng phòng sẽ tham dự cuộc họp ngày mai.', 'The manager will attend tomorrow’s meeting.'),
    'お／ご〜します': ('私が駅までご案内します。', 'Tôi xin hướng dẫn bạn đến ga.', 'I will guide you to the station.'),
    '〜でございます': ('こちらが新しいメニューでございます。', 'Đây là thực đơn mới ạ.', 'This is the new menu.'),
    '〜ことにしている': ('平日は夜十二時までに寝ることにしている。', 'Ngày thường tôi đặt quy tắc là đi ngủ trước mười hai giờ đêm.', 'On weekdays, I make it a rule to sleep by midnight.'),
    '〜ようになっている': ('このドアは、自動で閉まるようになっている。', 'Cánh cửa này được thiết kế để tự động đóng lại.', 'This door is designed to close automatically.'),
    '〜わりに': ('このかばんは軽いわりに、たくさん入る。', 'Cái túi này tuy nhẹ nhưng chứa được nhiều đồ.', 'This bag holds a lot for how light it is.'),
    '〜うちに': ('温かいうちに、このスープを飲んでください。', 'Xin hãy uống món súp này khi còn nóng.', 'Please drink this soup while it is still hot.'),
    '〜たばかり': ('さっき昼ごはんを食べたばかりです。', 'Tôi vừa mới ăn trưa xong lúc nãy.', 'I just ate lunch a little while ago.'),
    '〜ところだ': ('今、ちょうどレポートを書いているところです。', 'Bây giờ tôi đang đúng lúc viết báo cáo.', 'I am right in the middle of writing my report now.'),
    '〜はずだ': ('地図を見たから、道は分かるはずです。', 'Vì đã xem bản đồ nên lẽ ra tôi phải biết đường.', 'I checked the map, so I should know the way.'),
    '〜わけではない': ('日本の料理が嫌いなわけではないが、毎日は食べない。', 'Không phải tôi ghét món Nhật, nhưng tôi không ăn mỗi ngày.', 'It is not that I dislike Japanese food, but I do not eat it every day.'),
    '〜わけにはいかない': ('約束したから、途中でやめるわけにはいかない。', 'Vì đã hứa rồi nên không thể bỏ dở giữa chừng.', 'I promised, so I cannot quit halfway.'),
    '〜はずがない': ('あんな親切な人がうそをつくはずがない。', 'Người tử tế như thế không thể nào nói dối.', 'There is no way such a kind person would lie.'),
    '〜すぎる': ('この荷物は重すぎて、一人では運べない。', 'Hành lý này nặng quá nên một mình không thể mang nổi.', 'This luggage is too heavy to carry alone.'),
    '〜てしまう': ('大事な約束を忘れてしまって、ほんとうに困った。', 'Tôi lỡ quên cuộc hẹn quan trọng nên thật sự rất khó xử.', 'I ended up forgetting an important promise, and it really troubled me.'),
    '〜ことはない': ('まだ時間があるから、そんなに急ぐことはない。', 'Vẫn còn thời gian nên không cần vội như thế.', 'There is still time, so there is no need to hurry so much.'),
    '〜かえって': ('説明しすぎると、かえって分かりにくくなる。', 'Giải thích quá nhiều thì ngược lại còn khó hiểu hơn.', 'If you explain too much, it actually becomes harder to understand.'),
    '〜おそれがある': ('このままでは、けがをするおそれがあります。', 'Nếu cứ thế này thì có nguy cơ bị thương.', 'At this rate, there is a risk of injury.'),
    '〜に違いない': ('あの店はいつも並んでいるから、おいしいに違いない。', 'Quán đó lúc nào cũng xếp hàng nên chắc chắn là ngon.', 'That shop always has a line, so it must be good.'),
    '〜そうにない': ('今日は忙しくて、宿題が終わりそうにない。', 'Hôm nay bận quá nên có vẻ bài tập sẽ không xong.', 'I am so busy today that it does not look like I can finish my homework.'),
    '〜ないようにする': ('体調をくずさないように、毎日早く寝ています。', 'Để không bị ốm, tôi đi ngủ sớm mỗi ngày.', 'I go to bed early every day so that I do not get sick.'),
    '〜ようだ': ('あの人は何か言いたいことがあるようだ。', 'Người kia có vẻ như có điều gì muốn nói.', 'That person seems to have something to say.'),
    '〜みたいだ': ('この問題、前に勉強したのと同じみたいだ。', 'Bài này hình như giống bài tôi đã học trước đây.', 'This problem looks like the same one I studied before.'),
    '〜ように見える': ('あのビルは遠くから見ると、新しく見える。', 'Tòa nhà đó nhìn từ xa trông có vẻ mới.', 'That building looks new from a distance.'),
    '〜によると': ('天気予報によると、午後から雨だそうです。', 'Theo dự báo thời tiết, từ chiều sẽ có mưa.', 'According to the weather forecast, it will rain from the afternoon.'),
    '〜によれば': ('記事によれば、その店は来月閉まるそうだ。', 'Theo bài báo, quán đó sẽ đóng cửa vào tháng sau.', 'According to the article, that shop will close next month.'),
    '〜そうだ（伝聞）': ('山田さんは今年引っこすそうです。', 'Nghe nói năm nay anh Yamada sẽ chuyển nhà.', 'I heard that Yamada is moving this year.'),
    '〜とのことだ': ('会社から、会議は中止とのことでした。', 'Từ công ty báo rằng cuộc họp đã bị hủy.', 'The company said that the meeting was canceled.'),
    '〜によって': ('人によって、好きな勉強法は違う。', 'Tùy người mà cách học yêu thích khác nhau.', 'Preferred study methods differ depending on the person.'),
    '〜に対して': ('先生は学生に対して、とても親切です。', 'Giáo viên rất tử tế với học sinh.', 'The teacher is very kind toward the students.'),
    '〜に応じて': ('季節に応じて、服を変えたほうがいい。', 'Nên thay đổi quần áo tùy theo mùa.', 'It is better to change your clothes according to the season.'),
    '〜せいで': ('電車が遅れたせいで、授業に遅刻した。', 'Vì tàu trễ nên tôi đã đi học muộn.', 'Because the train was delayed, I was late for class.'),
    '〜可能性がある': ('この計画は、変更になる可能性がある。', 'Kế hoạch này có khả năng sẽ thay đổi.', 'There is a possibility that this plan will change.'),
    '〜ため（理由）': ('雪のため、空港までのバスが止まっていました。', 'Vì tuyết nên xe buýt đến sân bay đã dừng hoạt động.', 'Because of the snow, the bus to the airport was not running.'),
    '〜代わりに': ('車で行く代わりに、電車で行くことにした。', 'Thay vì đi ô tô, tôi đã quyết định đi tàu điện.', 'Instead of going by car, I decided to go by train.'),
    '〜ほど': ('今日は歩けないほど疲れています。', 'Hôm nay tôi mệt đến mức không đi nổi.', 'I am so tired today that I can barely walk.'),
    '〜くらい / 〜ぐらい': ('一時間ぐらいなら、待てます。', 'Nếu khoảng một tiếng thì tôi có thể đợi.', 'I can wait for about an hour.'),
    '〜さ': ('この町の静かさが好きです。', 'Tôi thích sự yên tĩnh của thị trấn này.', 'I like the quietness of this town.'),
    '〜ばかりか': ('彼は日本語ばかりか、中国語も話せる。', 'Anh ấy không chỉ nói được tiếng Nhật mà còn nói được tiếng Trung.', 'He can speak not only Japanese but also Chinese.'),
    '〜ことがある': ('忙しいときは、朝ごはんを食べないことがある。', 'Khi bận, đôi khi tôi không ăn sáng.', 'When I am busy, there are times when I do not eat breakfast.'),
    '〜たことがある': ('一度だけ富士山に登ったことがある。', 'Tôi đã từng leo núi Phú Sĩ đúng một lần.', 'I have climbed Mt. Fuji once.'),
    '〜ないことはない': ('急げば、今日中に終われないことはない。', 'Nếu gấp rút thì cũng không phải là không thể xong trong hôm nay.', 'If I hurry, it is not that I cannot finish today.'),
    '〜ないこともない': ('少し高いけれど、買えないこともない。', 'Tuy hơi đắt nhưng cũng không phải là không mua được.', 'It is a little expensive, but it is not impossible to buy.'),
    '〜たらいい': ('分からないところがあったら、メモしたらいい。', 'Nếu có chỗ nào không hiểu thì bạn nên ghi chú lại.', 'If there is something you do not understand, you should make a note of it.'),
    '〜といい': ('明日は天気がいいといいですね。', 'Hy vọng ngày mai trời đẹp nhỉ.', 'I hope the weather will be nice tomorrow.'),
    '〜ばよかった': ('もっと早く出発すればよかった。', 'Giá mà tôi xuất phát sớm hơn.', 'I should have left earlier.'),
    '〜といいな': ('今度の旅行で雪が見られるといいな。', 'Hy vọng chuyến đi tới tôi có thể nhìn thấy tuyết.', 'I hope I can see snow on the next trip.'),
    '〜てほしい': ('友だちには、もっと自信を持ってほしい。', 'Tôi muốn bạn mình tự tin hơn.', 'I want my friend to be more confident.'),
    '〜てもらいたい': ('受付の人に、もう少しゆっくり話してもらいたい。', 'Tôi muốn người ở quầy lễ tân nói chậm hơn một chút.', 'I would like the receptionist to speak a little more slowly.'),
    '〜てくれると助かる': ('明日までに返事をくれると助かります。', 'Nếu bạn trả lời trước ngày mai thì sẽ giúp tôi rất nhiều.', 'It would help if you could reply by tomorrow.'),
    '〜てもらう': ('先生に作文を見てもらいました。', 'Tôi đã nhờ giáo viên xem bài văn giúp.', 'I had my teacher check my composition.'),
    '〜ようとする': ('立ち上がろうとしたとき、電話が鳴った。', 'Lúc tôi định đứng dậy thì điện thoại reo.', 'Just as I was about to stand up, the phone rang.'),
    '〜続ける': ('難しくても、日本語の勉強を続けたい。', 'Dù khó tôi vẫn muốn tiếp tục học tiếng Nhật.', 'Even if it is difficult, I want to continue studying Japanese.'),
    '〜きる': ('今日は宿題を全部やりきった。', 'Hôm nay tôi đã làm xong hết toàn bộ bài tập.', 'I finished all of my homework today.'),
    '〜抜く': ('大変だったが、最後まで考え抜いた。', 'Tuy vất vả nhưng tôi đã suy nghĩ đến cùng.', 'It was hard, but I thought it through to the end.'),
    '〜という': ('「さくら」という名前の店で昼ごはんを食べた。', 'Tôi đã ăn trưa ở quán tên là “Sakura”.', 'I ate lunch at a shop called “Sakura.”'),
    '〜といわれている': ('この町は住みやすいといわれている。', 'Người ta nói thị trấn này dễ sống.', 'This town is said to be easy to live in.'),
    '〜ことから': ('毎日練習していることから、彼の本気が分かる。', 'Từ việc ngày nào anh ấy cũng luyện tập, có thể hiểu được sự nghiêm túc của anh ấy.', 'From the fact that he practices every day, you can see that he is serious.'),
    '〜とされている': ('この方法が最も安全だとされている。', 'Phương pháp này được xem là an toàn nhất.', 'This method is regarded as the safest.'),
    '〜べきだ': ('大切なことは、自分で決めるべきだ。', 'Điều quan trọng là nên tự mình quyết định.', 'Important things should be decided by yourself.'),
    '〜べきではない': ('人の悪口は言うべきではない。', 'Không nên nói xấu người khác.', 'You should not speak badly about others.'),
    '〜てはならない': ('ここにごみを捨ててはならない。', 'Không được vứt rác ở đây.', 'You must not throw trash here.'),
    '〜たとたん': ('窓を開けたとたん、冷たい風が入ってきた。', 'Ngay lúc mở cửa sổ thì gió lạnh lùa vào.', 'The moment I opened the window, cold air came in.'),
    '〜たびに': ('この写真を見るたびに、旅行を思い出す。', 'Mỗi lần nhìn tấm ảnh này tôi lại nhớ chuyến đi.', 'Every time I look at this photo, I remember the trip.'),
    '〜ついでに': ('銀行へ行くついでに、郵便局にも寄った。', 'Nhân tiện đi ngân hàng tôi cũng ghé bưu điện.', 'While going to the bank, I also stopped by the post office.'),
    '〜際に': ('申込の際に、学生証が必要です。', 'Khi đăng ký, cần có thẻ sinh viên.', 'A student ID is required when applying.'),
    '〜気がする': ('この説明で、少し分かった気がする。', 'Với phần giải thích này tôi có cảm giác đã hiểu hơn một chút.', 'I feel like I understand a little better after this explanation.'),
    '〜ものだ': ('子どものころは、よくこの川で遊んだものだ。', 'Hồi nhỏ tôi thường hay chơi ở con sông này.', 'When I was a child, I used to play by this river a lot.'),
    '〜わけだ': ('毎日練習しているのか。それで上手なわけだ。', 'Ra là ngày nào cũng luyện tập. Bảo sao mà giỏi.', 'So you practice every day. No wonder you are good.'),
    '〜に決まっている': ('あんなに勉強したのだから、合格するに決まっている。', 'Đã học nhiều như thế thì nhất định sẽ đỗ.', 'After studying that much, you are sure to pass.'),
    '〜一方だ': ('仕事は増える一方で、休みが取れない。', 'Công việc cứ tăng mãi trong khi không thể nghỉ ngơi.', 'Work keeps increasing, and I cannot get a break.'),
    '〜つつある': ('この町も少しずつ変わりつつある。', 'Thị trấn này cũng đang dần thay đổi.', 'This town is gradually changing as well.'),
    '〜につれて': ('季節が変わるにつれて、日が長くなってきた。', 'Càng đổi mùa thì ngày càng dài ra.', 'As the seasons change, the days are getting longer.'),
    '〜にしたがって': ('年を取るにしたがって、朝早く起きるようになった。', 'Càng có tuổi tôi càng dậy sớm hơn.', 'As I get older, I have started waking up earlier.'),
    '〜について': ('日本の歴史について、もっと知りたいです。', 'Tôi muốn biết thêm về lịch sử Nhật Bản.', 'I want to know more about Japanese history.'),
    '〜に関して': ('その問題に関して、あとで説明します。', 'Về vấn đề đó, tôi sẽ giải thích sau.', 'I will explain that matter later.'),
    '〜に対する': ('外国文化に対する興味が強くなった。', 'Sự hứng thú đối với văn hóa nước ngoài đã mạnh lên.', 'My interest in foreign cultures has grown.'),
    '〜についての': ('環境問題についてのニュースを読みました。', 'Tôi đã đọc một bản tin về vấn đề môi trường.', 'I read a news article about environmental problems.'),
    '〜にとって': ('この経験は私にとって大きな財産です。', 'Kinh nghiệm này là tài sản lớn đối với tôi.', 'This experience is a great asset for me.'),
    '〜として': ('父は医者として働いています。', 'Bố tôi làm việc với tư cách là bác sĩ.', 'My father works as a doctor.'),
    '〜にかけて': ('この辺りは夜から朝にかけて冷え込みます。', 'Khu vực này lạnh dần từ đêm sang sáng.', 'This area gets cold from night into morning.'),
    '〜における': ('現代における教育の役割は大きい。', 'Vai trò của giáo dục trong thời hiện đại rất lớn.', 'The role of education in modern times is significant.'),
    '〜ほど〜ない': ('今年は去年ほど寒くない。', 'Năm nay không lạnh bằng năm ngoái.', 'This year is not as cold as last year.'),
    '〜というより': ('彼は厳しいというより、まじめな人だ。', 'Anh ấy nói là nghiêm khắc thì không hẳn, đúng hơn là nghiêm túc.', 'He is not strict so much as serious.'),
    '〜より〜のほうが': ('電車よりバスのほうが安いです。', 'So với tàu điện thì xe buýt rẻ hơn.', 'Buses are cheaper than trains.'),
    '〜に比べて': ('今年は去年に比べて雨が多い。', 'Năm nay so với năm ngoái thì mưa nhiều hơn.', 'Compared with last year, there is more rain this year.'),
    '〜しかない': ('電車が止まったので、歩いて帰るしかない。', 'Vì tàu dừng chạy nên chỉ còn cách đi bộ về.', 'The trains stopped, so I have no choice but to walk home.'),
    '〜ばかりでなく': ('彼は歌ばかりでなく、ダンスも上手だ。', 'Anh ấy không chỉ hát hay mà còn nhảy giỏi.', 'He is good not only at singing but also at dancing.'),
    '〜どんなに〜ても': ('どんなに難しくても、あきらめたくない。', 'Dù khó thế nào tôi cũng không muốn bỏ cuộc.', 'No matter how difficult it is, I do not want to give up.'),
    '〜だけでなく': ('この町は静かなだけでなく、景色も美しい。', 'Thị trấn này không chỉ yên tĩnh mà cảnh sắc còn đẹp.', 'This town is not only quiet, but its scenery is beautiful too.'),
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def _write_json(path: Path, payload) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def _normalize_text(text: str) -> str:
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def _normalize_example(example: dict) -> dict:
    example['sentence'] = _normalize_text(example.get('sentence', ''))
    example['translation'] = _normalize_text(example.get('translation', ''))
    example['translationEn'] = _normalize_text(example.get('translationEn', ''))
    return example


def main() -> int:
    updated = 0
    appended = 0
    missing = []

    for level in ['n5', 'n4', 'n3']:
        for path in sorted((EXAMPLE_ROOT / level).glob('lesson_*.json')):
            payload = _read_json(path)
            changed = False
            for item in payload:
                examples = [_normalize_example(ex) for ex in item.get('examples', [])]
                if examples != item.get('examples', []):
                    item['examples'] = examples
                    changed = True
                if len(item.get('examples', [])) == 1:
                    gp = item['grammarPoint']
                    extra = SECOND_EXAMPLES.get(gp)
                    if extra is None:
                        missing.append({'file': str(path.relative_to(ROOT)).replace('\\', '/'), 'grammarPoint': gp})
                        continue
                    jp, vi, en = extra
                    item['examples'].append(_normalize_example({'sentence': jp, 'translation': vi, 'translationEn': en}))
                    appended += 1
                    changed = True
            if changed:
                _write_json(path, payload)
                updated += 1

    report = {'updatedFiles': updated, 'appendedExamples': appended, 'missingMappings': missing}
    _write_json(REPORT_PATH, report)
    print(json.dumps(report, ensure_ascii=True, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
