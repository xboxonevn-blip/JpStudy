#!/usr/bin/env python3
"""Generate draft-but-usable N3 grammar assets for lessons 51-75."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GRAMMAR_ROOT = ROOT / 'assets' / 'data' / 'content' / 'grammar' / 'n3'
EXAMPLE_ROOT = ROOT / 'assets' / 'data' / 'content' / 'grammar_examples' / 'n3'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'n3-grammar-scaffold-report.json'
THEME_MAP_PATH = ROOT / 'tooling' / 'quartet1_theme_map.json'

LESSON_PACKS = [
    (51, [
        ('〜ことにする', '~ decide to do', 'V辞書 / Vない + ことにする', 'Diễn tả quyết định do chính người nói đưa ra.', 'Expresses a decision made by the speaker.', '今年から、休みの日はスマホを見ないことにした。', 'Từ năm nay, tôi quyết định không xem điện thoại vào ngày nghỉ.', 'Starting this year, I decided not to look at my phone on days off.'),
        ('〜ようにする', '~ make an effort to', 'V辞書 / Vない + ようにする', 'Diễn tả nỗ lực duy trì một thói quen hoặc cố tránh điều gì đó.', 'Expresses making an effort to maintain or avoid something.', '平日はなるべく早く寝るようにしている。', 'Ngày thường tôi cố gắng ngủ sớm nhất có thể.', 'On weekdays, I try to go to bed as early as possible.'),
        ('〜つもりだ', '~ intend to', 'V辞書 / Vない + つもりだ', 'Diễn tả dự định hoặc ý định của người nói.', 'Expresses the speaker’s intention or plan.', '来月は新しい趣味を始めるつもりだ。', 'Tháng sau tôi định bắt đầu một sở thích mới.', 'I intend to start a new hobby next month.'),
    ]),
    (52, [
        ('〜ことになる', '~ it has been decided that', 'V辞書 / Vない + ことになる', 'Diễn tả quyết định do tổ chức, quy định hoặc hoàn cảnh đưa ra.', 'Expresses a decision made by rules, others, or circumstances.', '来年度から、この町で働くことになりました。', 'Từ năm tới tôi sẽ làm việc ở thị trấn này.', 'Starting next year, I have been assigned to work in this town.'),
        ('〜ようになる', '~ come to be able to / become', 'V辞書 / Vない + ようになる', 'Diễn tả sự thay đổi về khả năng, thói quen hoặc trạng thái.', 'Expresses a change in ability, habit, or condition.', '忙しくても、自分で計画を立てられるようになった。', 'Dù bận tôi cũng đã trở nên có thể tự lập kế hoạch.', 'I became able to make my own plans even when busy.'),
        ('〜ことになっている', '~ it is arranged that', 'V辞書 / Vない + ことになっている', 'Diễn tả quy tắc, lịch trình hoặc sự sắp xếp đã được định sẵn.', 'Expresses a rule, schedule, or arrangement already in place.', 'この学校では、宿題は毎週金曜日に出すことになっている。', 'Ở trường này, bài tập được quy định nộp vào thứ Sáu hằng tuần.', 'At this school, homework is supposed to be submitted every Friday.'),
    ]),
    (53, [
        ('〜ために', '~ for / in order to', 'Nの / V辞書 + ために', 'Diễn tả mục đích hoặc lý do theo văn phong trang trọng.', 'Expresses purpose or reason in a formal tone.', 'ごみを減らすために、マイボトルを持ち歩いている。', 'Để giảm rác, tôi mang theo bình nước cá nhân.', 'To reduce waste, I carry my own bottle.'),
        ('〜ように', '~ so that', 'V辞書 / Vない + ように', 'Diễn tả mục tiêu hướng tới trạng thái có thể / không thể hoặc kết quả mong muốn.', 'Expresses a goal aimed at a desired result.', 'むだな物を買わないように、買い物リストを作っている。', 'Để không mua đồ lãng phí, tôi lập danh sách mua sắm.', 'I make a shopping list so that I do not buy unnecessary things.'),
        ('〜代わりに', '~ instead of / in exchange for', 'Nの / V辞書 + 代わりに', 'Diễn tả sự thay thế hoặc đổi lại cho điều khác.', 'Expresses substitution or exchange.', 'レジ袋をもらう代わりに、エコバッグを使う人が増えた。', 'Thay vì lấy túi nilon, ngày càng nhiều người dùng túi sinh thái.', 'More people use eco-bags instead of taking plastic bags.'),
    ]),
    (54, [
        ('〜うちに', '~ while / before', 'V辞書 / Vている / A / Nの + うちに', 'Diễn tả làm việc gì khi trạng thái còn tiếp diễn hoặc trước khi thay đổi.', 'Expresses doing something while a condition remains unchanged.', '留学しているうちに、日本語だけでなく文化も好きになった。', 'Trong khi du học, tôi dần thích không chỉ tiếng Nhật mà cả văn hóa.', 'While studying abroad, I came to like not only Japanese but also the culture.'),
        ('〜たばかり', '~ just did', 'Vた + ばかり', 'Diễn tả hành động vừa mới xảy ra gần đây.', 'Expresses that an action happened recently.', '日本に来たばかりのころは、電車の乗り方も分からなかった。', 'Hồi mới sang Nhật, ngay cả cách đi tàu tôi cũng chưa biết.', 'When I had just arrived in Japan, I did not even know how to ride the train.'),
        ('〜ところだ', '~ be about to / in the middle of / have just', 'V辞書 / Vている / Vた + ところだ', 'Diễn tả đúng thời điểm trước, trong hoặc ngay sau hành động.', 'Expresses the exact timing of an action.', 'これから先生に留学の相談をするところです。', 'Tôi đang chuẩn bị đi hỏi ý kiến giáo viên về việc du học.', 'I am just about to talk to my teacher about studying abroad.'),
    ]),
    (55, [
        ('〜はずだ', '~ should / be expected to', 'V普通形 / A / Nの + はずだ', 'Diễn tả suy đoán có căn cứ hoặc điều được kỳ vọng là đúng.', 'Expresses an expectation based on reason or evidence.', '田中さんは十年この仕事をしているから、経験が豊富なはずだ。', 'Anh Tanaka làm công việc này mười năm rồi nên chắc hẳn nhiều kinh nghiệm.', 'Tanaka has done this job for ten years, so he should have a lot of experience.'),
        ('〜わけではない', '~ it does not mean that', 'V普通形 / A / N + わけではない', 'Phủ định một kết luận quá mức hoặc quá khái quát.', 'Softly denies an overgeneralized conclusion.', '会社員だからといって、みんな同じ働き方をするわけではない。', 'Không phải cứ là nhân viên công ty thì ai cũng làm việc theo cùng một cách.', 'Just because someone is a company employee does not mean everyone works the same way.'),
        ('〜わけにはいかない', '~ cannot afford to / cannot possibly', 'V辞書 + わけにはいかない', 'Diễn tả không thể làm do lý do xã hội, trách nhiệm hoặc đạo đức.', 'Expresses that one cannot do something for social or practical reasons.', '大事な面接があるので、寝坊するわけにはいかない。', 'Vì có buổi phỏng vấn quan trọng nên tôi không thể ngủ quên được.', 'I have an important interview, so I cannot afford to oversleep.'),
    ]),
    (56, [
        ('〜すぎる', '~ too much', 'Vます / A + すぎる', 'Diễn tả mức độ vượt quá giới hạn thích hợp.', 'Expresses that something exceeds an appropriate limit.', '便利すぎるサービスは、つい買いすぎの原因になる。', 'Dịch vụ quá tiện lợi dễ trở thành nguyên nhân mua sắm quá tay.', 'Services that are too convenient can lead to overbuying.'),
        ('〜てしまう', '~ end up doing / unfortunately do', 'Vて + しまう', 'Diễn tả hành động hoàn tất hoặc nuối tiếc vì lỡ làm điều gì đó.', 'Expresses completion or regret at doing something.', 'セールを見ると、必要ない物まで買ってしまう。', 'Hễ thấy khuyến mãi là tôi lại lỡ mua cả thứ không cần.', 'Whenever I see a sale, I end up buying things I do not need.'),
        ('〜ことはない', '~ there is no need to', 'V辞書 + ことはない', 'Diễn tả không cần thiết phải làm việc gì.', 'Expresses that there is no need to do something.', '一度失敗したくらいで、そんなに落ち込むことはない。', 'Chỉ thất bại một lần thì không cần buồn đến vậy.', 'There is no need to be so discouraged after just one failure.'),
    ]),
    (57, [
        ('〜おそれがある', '~ there is a risk that', 'V辞書 / Nの + おそれがある', 'Diễn tả nguy cơ xảy ra điều không mong muốn trong văn viết hoặc trang trọng.', 'Expresses the risk of an undesirable outcome in formal contexts.', '生活習慣が乱れると、健康を害するおそれがある。', 'Nếu sinh hoạt rối loạn thì có nguy cơ hại sức khỏe.', 'If your lifestyle becomes irregular, there is a risk of harming your health.'),
        ('〜に違いない', '~ must surely', 'V普通形 / A / N + に違いない', 'Diễn tả sự tin chắc mạnh mẽ dựa trên căn cứ.', 'Expresses a strong conviction based on evidence.', 'あんなに毎日運動しているのだから、彼は健康に違いない。', 'Ngày nào anh ấy cũng vận động như vậy nên chắc chắn rất khỏe.', 'Since he exercises every day like that, he must be healthy.'),
        ('〜そうにない', '~ does not look like / unlikely to', 'Vます + そうにない', 'Diễn tả nhìn vào tình hình thì khả năng thấp.', 'Expresses that something seems unlikely based on the situation.', '今日は忙しすぎて、十分に休めそうにない。', 'Hôm nay bận quá nên có vẻ không nghỉ đủ được.', 'I am so busy today that it does not look like I can rest enough.'),
    ]),
    (58, [
        ('〜ようだ', '~ it seems / appears', 'V普通形 / A / Nの + ようだ', 'Diễn tả suy đoán dựa trên quan sát hoặc ấn tượng.', 'Expresses conjecture based on observation or impression.', '町のようすを見ると、祭りの準備が始まったようだ。', 'Nhìn quang cảnh thị trấn thì có vẻ công tác chuẩn bị lễ hội đã bắt đầu.', 'Looking at the town, it seems the festival preparations have begun.'),
        ('〜らしい', '~ apparently / typical of', 'V普通形 / A / N + らしい', 'Diễn tả thông tin nghe được hoặc đặc tính mang tính điển hình.', 'Expresses hearsay or something typical of its kind.', '今年の行事は、昔より参加者が多いらしい。', 'Nghe nói năm nay người tham gia sự kiện đông hơn trước.', 'Apparently, this year’s event has more participants than before.'),
        ('〜みたいだ', '~ it looks like / kind of like', 'V普通形 / A / N + みたいだ', 'Diễn tả suy đoán hoặc so sánh trong hội thoại thân mật.', 'Expresses casual conjecture or comparison in conversation.', '外はすごくにぎやかで、お祭りみたいですね。', 'Bên ngoài náo nhiệt quá, cứ như là lễ hội vậy.', 'It is so lively outside, it seems like a festival.'),
    ]),
    (59, [
        ('〜によると', '~ according to', 'N + によると', 'Nêu nguồn thông tin cho nội dung theo sau.', 'Indicates the source of the following information.', 'ニュースによると、明日から新しいサービスが始まるそうだ。', 'Theo tin tức, từ mai dịch vụ mới sẽ bắt đầu.', 'According to the news, a new service will start tomorrow.'),
        ('〜によれば', '~ according to (formal)', 'N + によれば', 'Giống によると nhưng thường dùng trong văn viết hoặc thông báo trang trọng.', 'Similar to によると, often used in formal writing or announcements.', '発表によれば、利用者は去年の二倍になった。', 'Theo công bố, số người dùng đã gấp đôi năm ngoái.', 'According to the announcement, the number of users doubled from last year.'),
        ('〜そうだ（伝聞）', '~ I heard that', 'V普通形 / A / Nだ + そうだ', 'Diễn tả thông tin nghe từ người khác hoặc nguồn khác.', 'Expresses hearsay information from another source.', 'その記事は、今日の午後公開されるそうです。', 'Nghe nói bài viết đó sẽ được đăng chiều nay.', 'I heard that article will be published this afternoon.'),
    ]),
    (60, [
        ('〜によって', '~ depending on / by', 'N + によって', 'Diễn tả sự khác nhau tùy theo điều kiện hoặc chỉ phương tiện / tác nhân.', 'Expresses differences by condition, means, or agent.', '行き先によって、使う交通機関を変えます。', 'Tùy nơi đến mà tôi thay đổi phương tiện di chuyển.', 'Depending on the destination, I change the transportation I use.'),
        ('〜に対して', '~ toward / in contrast to', 'N + に対して', 'Diễn tả đối tượng hướng đến hoặc sự đối lập so sánh.', 'Expresses a target or contrast.', '外国人旅行者に対して、駅の案内をもっと分かりやすくするべきだ。', 'Đối với du khách nước ngoài, chỉ dẫn ở ga nên dễ hiểu hơn.', 'Station guidance should be clearer for foreign travelers.'),
        ('〜ていく', '~ continue to / go on', 'Vて + いく', 'Diễn tả sự biến đổi tiếp diễn từ hiện tại về sau.', 'Expresses change or continuation from now on.', '旅行のしかたも時代とともに変わっていくだろう。', 'Cách du lịch chắc cũng sẽ tiếp tục thay đổi theo thời đại.', 'The way people travel will probably continue to change with the times.'),
    ]),
    (61, [
        ('〜せいで', '~ because of (negative)', 'Nの / V普通形 + せいで', 'Diễn tả nguyên nhân dẫn đến kết quả xấu hoặc không mong muốn.', 'Expresses a negative cause leading to an undesirable result.', '大雨のせいで、川の水が急に増えた。', 'Vì mưa lớn nên nước sông tăng đột ngột.', 'Because of the heavy rain, the river level rose suddenly.'),
        ('〜おかげで', '~ thanks to', 'Nの / V普通形 + おかげで', 'Diễn tả nguyên nhân tốt dẫn đến kết quả tích cực.', 'Expresses a positive cause leading to a good result.', '近所の助けのおかげで、すぐ安全な場所へ行けた。', 'Nhờ sự giúp đỡ của hàng xóm, tôi đã nhanh chóng đến nơi an toàn.', 'Thanks to the neighbors’ help, I was able to get to a safe place quickly.'),
        ('〜ため（理由）', '~ because of', 'Nの / V普通形 + ため', 'Diễn tả lý do một cách trang trọng, thường thấy trong thông báo hoặc tin tức.', 'Expresses a formal reason, often in notices or news.', '地震のため、電車の運転を見合わせています。', 'Vì động đất nên tàu đang tạm ngừng chạy.', 'Because of the earthquake, train operations are suspended.'),
    ]),
    (62, [
        ('〜ほど', '~ to the extent that / so much that', 'V普通形 / A / N + ほど', 'Diễn tả mức độ hoặc phạm vi của trạng thái, hành động.', 'Expresses extent, degree, or scope.', 'その映画は何度も見たいほど感動的だった。', 'Bộ phim đó cảm động đến mức tôi muốn xem nhiều lần.', 'That movie was so moving that I wanted to watch it again and again.'),
        ('〜くらい / 〜ぐらい', '~ about / to the extent that', 'N / V普通形 + くらい / ぐらい', 'Diễn tả mức độ xấp xỉ hoặc dùng để nhấn mạnh mức độ.', 'Expresses approximation or emphasis on degree.', '声が出ないくらい驚いた。', 'Tôi ngạc nhiên đến mức không thốt nên lời.', 'I was so surprised that I could not speak.'),
        ('〜さ', '~ -ness', 'Aい / Aな + さ', 'Biến tính từ thành danh từ để nói về mức độ hoặc tính chất.', 'Nominalizes adjectives to express quality or degree.', 'この曲の面白さは、聞くたびに分かってくる。', 'Độ thú vị của bài này càng nghe nhiều càng hiểu.', 'The appeal of this song becomes clearer each time you listen.'),
    ]),
    (63, [
        ('〜ことがある', '~ there are times when / sometimes', 'V辞書 + ことがある', 'Diễn tả việc thỉnh thoảng xảy ra hoặc có lúc làm gì.', 'Expresses that something happens occasionally.', '授業のあとで、先生に直接相談することがある。', 'Sau giờ học, có lúc tôi trao đổi trực tiếp với giáo viên.', 'There are times when I talk directly with my teacher after class.'),
        ('〜たことがある', '~ have done before', 'Vた + ことがある', 'Diễn tả kinh nghiệm đã từng làm gì trong quá khứ.', 'Expresses prior experience.', '留学生向けの説明会で発表したことがあります。', 'Tôi đã từng thuyết trình tại buổi hướng dẫn cho du học sinh.', 'I have given a presentation at an orientation for international students before.'),
        ('〜ないことはない', '~ it is not that ... not', 'Vない + ことはない', 'Diễn tả vẫn có thể hoặc không hẳn là không, nhưng thường miễn cưỡng.', 'Expresses that something is possible, though not enthusiastically.', 'その意見も分からないことはない。', 'Ý kiến đó cũng không phải là tôi không hiểu.', 'It is not that I do not understand that opinion.'),
    ]),
    (64, [
        ('〜たらいい', '~ should / it would be good if', 'Vたら + いい', 'Diễn tả lời khuyên hoặc gợi ý.', 'Expresses advice or suggestion.', '家族ともっと話したいなら、まず自分から連絡したらいい。', 'Nếu muốn nói chuyện với gia đình nhiều hơn thì trước hết hãy tự liên lạc đi.', 'If you want to talk with your family more, you should contact them yourself first.'),
        ('〜といい', '~ I hope / it would be nice if', 'V普通形 + といい', 'Diễn tả mong muốn hoặc hi vọng điều gì đó xảy ra.', 'Expresses hope or desire that something will happen.', '家族みんなが元気でいるといい。', 'Mong cả gia đình luôn khỏe mạnh.', 'I hope everyone in the family stays healthy.'),
        ('〜ばよかった', '~ should have', 'Vば + よかった', 'Diễn tả hối tiếc về việc đáng ra nên làm khác đi.', 'Expresses regret that one should have done something differently.', 'もっと早く気持ちを伝えればよかった。', 'Giá mà tôi bày tỏ cảm xúc sớm hơn.', 'I should have expressed my feelings earlier.'),
    ]),
    (65, [
        ('〜てほしい', '~ want someone to do', '人に Vて + ほしい', 'Diễn tả mong muốn ai đó làm cho mình điều gì.', 'Expresses wanting someone to do something.', '新しいルールを決める前に、住民の意見を聞いてほしい。', 'Tôi muốn trước khi quyết định quy tắc mới thì hãy lắng nghe ý kiến cư dân.', 'I want them to listen to residents before deciding the new rules.'),
        ('〜てもらいたい', '~ would like someone to do', '人に Vて + もらいたい', 'Diễn tả mong muốn ai đó làm gì cho mình, sắc thái mềm hơn.', 'Expresses wanting someone to do something for you, often softer.', '管理会社には、騒音の問題を早く対応してもらいたい。', 'Tôi muốn công ty quản lý sớm xử lý vấn đề tiếng ồn.', 'I would like the management company to deal with the noise issue quickly.'),
        ('〜てくれると助かる', '~ it would help if you do', 'Vて + くれると助かる', 'Diễn tả yêu cầu nhẹ nhàng: nếu ai đó làm thì sẽ rất giúp ích.', 'Expresses a soft request that doing something would be helpful.', 'ごみの分け方を先に教えてくれると助かります。', 'Nếu chỉ giúp tôi cách phân loại rác trước thì rất hữu ích.', 'It would help if you could explain the garbage sorting rules first.'),
    ]),
    (66, [
        ('〜ようとする', '~ try to / be about to', 'V意向形 + とする', 'Diễn tả cố gắng làm gì hoặc chuẩn bị làm gì thì một việc khác xảy ra.', 'Expresses attempting to do something or being just about to do it.', '最後まであきらめずに走ろうとした。', 'Tôi đã cố chạy mà không bỏ cuộc cho đến cuối.', 'I tried to keep running without giving up until the end.'),
        ('〜続ける', '~ continue to', 'Vます + 続ける', 'Diễn tả tiếp tục duy trì hành động trong một khoảng thời gian.', 'Expresses continuing an action over time.', '毎日練習を続ければ、記録は必ず伸びる。', 'Nếu tiếp tục luyện tập mỗi ngày thì thành tích chắc chắn sẽ tăng.', 'If you continue practicing every day, your record will surely improve.'),
        ('〜きる', '~ do completely / to the end', 'Vます + きる', 'Diễn tả hoàn thành đến cùng hoặc làm hết mức.', 'Expresses doing something completely or through to the end.', '苦しくても、最後まで走りきった。', 'Dù vất vả tôi vẫn chạy hết đến cuối.', 'Even though it was hard, I ran all the way to the end.'),
    ]),
    (67, [
        ('〜という', '~ called / that says', 'N + という + N', 'Dùng để giải thích tên gọi, nội dung hoặc khái niệm.', 'Used to explain names, content, or concepts.', 'ＡＩという技術は、生活のいろいろな場面で使われている。', 'Công nghệ gọi là AI đang được dùng trong nhiều mặt của cuộc sống.', 'The technology called AI is used in many parts of daily life.'),
        ('〜といわれている', '~ it is said that', 'V普通形 / A / Nだ + といわれている', 'Diễn tả điều được nói chung, được xem là thông tin phổ biến.', 'Expresses something commonly said or generally believed.', 'この方法は、電気を節約するのに効果的だといわれている。', 'Người ta nói cách này hiệu quả trong việc tiết kiệm điện.', 'This method is said to be effective for saving electricity.'),
        ('〜ことから', '~ judging from / because', 'V普通形 / N + ことから', 'Diễn tả suy luận dựa trên dấu hiệu hoặc dùng để nêu xuất phát điểm lý do.', 'Expresses inference from evidence or a reason starting point.', '利用者が増えていることから、社会に必要な技術だと分かる。', 'Từ việc người dùng tăng lên, có thể thấy đây là công nghệ cần thiết cho xã hội.', 'Since the number of users is increasing, we can see it is a technology society needs.'),
    ]),
    (68, [
        ('〜べきだ', '~ should / ought to', 'V辞書 + べきだ', 'Diễn tả ý kiến mạnh về điều đúng đắn hoặc nên làm.', 'Expresses a strong opinion about what should be done.', 'ルールは守るべきだと子どものころから教えられてきた。', 'Từ nhỏ tôi đã được dạy rằng phải tuân thủ quy tắc.', 'I was taught from childhood that rules should be followed.'),
        ('〜べきではない', '~ should not', 'V辞書 + べきではない', 'Diễn tả ý kiến rằng không nên làm điều gì.', 'Expresses the opinion that something should not be done.', '知らない情報をすぐ信じるべきではない。', 'Không nên lập tức tin thông tin mình chưa biết rõ.', 'You should not immediately believe information you do not know well.'),
        ('〜てはならない', '~ must not', 'Vて + はならない', 'Diễn tả cấm đoán hoặc quy tắc mang tính trang trọng.', 'Expresses prohibition in a formal register.', '個人情報を許可なく公開してはならない。', 'Không được công khai thông tin cá nhân khi chưa được phép.', 'Personal information must not be disclosed without permission.'),
    ]),
    (69, [
        ('〜たとたん', '~ the moment / as soon as', 'Vた + とたん', 'Diễn tả việc gì đó xảy ra ngay đúng khoảnh khắc sau hành động trước.', 'Expresses that something happened the instant after another action.', 'ふたを開けたとたん、いい香りが広がった。', 'Ngay lúc mở nắp ra thì mùi thơm lan tỏa.', 'The moment I opened the lid, a nice smell spread.'),
        ('〜たびに', '~ every time', 'V辞書 / Nの + たびに', 'Diễn tả việc cứ mỗi lần A xảy ra thì B cũng xảy ra.', 'Expresses that whenever A happens, B also happens.', 'この料理を作るたびに、祖母のことを思い出す。', 'Mỗi lần nấu món này tôi lại nhớ đến bà.', 'Every time I make this dish, I remember my grandmother.'),
        ('〜ついでに', '~ while / on the occasion of', 'V辞書 / Vた + ついでに', 'Diễn tả tranh thủ làm thêm việc khác nhân tiện.', 'Expresses doing something additional while taking the opportunity.', '夕飯を作るついでに、明日のお弁当も準備した。', 'Nhân tiện nấu bữa tối tôi chuẩn bị luôn hộp cơm ngày mai.', 'While making dinner, I also prepared tomorrow’s lunch.'),
    ]),
    (70, [
        ('〜気がする', '~ feel like / have a feeling that', 'V普通形 / A / Nの + 気がする', 'Diễn tả cảm giác, trực giác hoặc ấn tượng chủ quan.', 'Expresses a subjective feeling or intuition.', '最近、少し考え方が前向きになった気がする。', 'Gần đây tôi có cảm giác cách suy nghĩ của mình tích cực hơn một chút.', 'Recently, I feel like my way of thinking has become a bit more positive.'),
        ('〜ものだ', '~ it is natural / people generally', 'V辞書 / A + ものだ', 'Diễn tả cảm thán, tính chất chung hoặc điều thường thấy.', 'Expresses general truth or emotional reflection.', '人はうれしいことがあると、だれかに話したくなるものだ。', 'Con người hễ có chuyện vui thì thường muốn kể cho ai đó nghe.', 'When people are happy, they naturally want to tell someone.'),
        ('〜わけだ', '~ no wonder / that is why', 'V普通形 / A / N + わけだ', 'Diễn tả kết luận hợp lý sau khi hiểu lý do hoặc bối cảnh.', 'Expresses a natural conclusion after understanding the reason.', '毎日遅くまで働いていたのか。疲れるわけだ。', 'Hóa ra ngày nào cũng làm đến khuya. Bảo sao mệt.', 'So you were working late every day. No wonder you are tired.'),
    ]),
    (71, [
        ('〜一方だ', '~ continue to / more and more', 'V辞書 + 一方だ', 'Diễn tả xu hướng chỉ thay đổi theo một chiều.', 'Expresses a trend that continues in one direction.', '物価は上がる一方で、生活は楽にならない。', 'Giá cả cứ tăng mãi trong khi cuộc sống không dễ hơn.', 'Prices keep rising, while life does not get easier.'),
        ('〜つつある', '~ be gradually changing', 'Vます + つつある', 'Diễn tả sự thay đổi đang tiến triển dần dần.', 'Expresses gradual ongoing change.', '支払いの方法は少しずつ多様になりつつある。', 'Cách thanh toán đang dần trở nên đa dạng hơn.', 'Payment methods are gradually becoming more diverse.'),
        ('〜につれて', '~ as / in proportion to', 'V辞書 / N + につれて', 'Diễn tả một thay đổi xảy ra song song với thay đổi khác.', 'Expresses that one change happens along with another.', '年齢を重ねるにつれて、お金の使い方も変わってきた。', 'Càng lớn tuổi thì cách dùng tiền của tôi cũng thay đổi.', 'As I get older, the way I use money has changed.'),
    ]),
    (72, [
        ('〜について', '~ about / concerning', 'N + について', 'Diễn tả chủ đề hoặc nội dung được đề cập.', 'Expresses the topic under discussion.', 'ことばの使い方について、授業で意見交換をした。', 'Trong giờ học chúng tôi trao đổi ý kiến về cách dùng ngôn từ.', 'In class, we exchanged opinions about language use.'),
        ('〜に関して', '~ regarding / in regard to', 'N + に関して', 'Giống について nhưng mang sắc thái trang trọng hơn.', 'Similar to について but more formal.', '発音に関して、先生から具体的な助言をもらった。', 'Về phát âm, tôi đã nhận được lời khuyên cụ thể từ giáo viên.', 'Regarding pronunciation, I received specific advice from my teacher.'),
        ('〜に対する', '~ toward / for', 'N + に対する + N', 'Bổ nghĩa cho danh từ, diễn tả sự hướng đến hoặc thái độ đối với đối tượng.', 'Modifies nouns to express attitude toward a target.', '相手に対する思いやりが、よい会話には必要だ。', 'Sự quan tâm đối với đối phương là điều cần cho một cuộc trò chuyện tốt.', 'Consideration for the other person is necessary for good conversation.'),
    ]),
    (73, [
        ('〜にとって', '~ for / to', 'N + にとって', 'Diễn tả ý nghĩa hoặc đánh giá từ quan điểm của ai đó.', 'Expresses meaning or evaluation from someone’s point of view.', 'その出来事は国民にとって大きな転機だった。', 'Sự kiện đó là bước ngoặt lớn đối với người dân.', 'That event was a major turning point for the people.'),
        ('〜として', '~ as / in the role of', 'N + として', 'Diễn tả tư cách, vai trò hoặc lập trường.', 'Expresses role, capacity, or standpoint.', '学生として、社会の問題にも関心を持ちたい。', 'Với tư cách là sinh viên, tôi muốn quan tâm cả đến các vấn đề xã hội.', 'As a student, I want to care about social issues too.'),
        ('〜にかけて', '~ from ... through ...', 'N + にかけて', 'Diễn tả khoảng thời gian hoặc phạm vi kéo dài liên tục.', 'Expresses a continuous span from one point to another.', 'この地域では、春から夏にかけて観光客が増える。', 'Ở khu vực này, từ xuân sang hè lượng khách du lịch tăng lên.', 'In this area, tourists increase from spring into summer.'),
    ]),
    (74, [
        ('〜ほど〜ない', '~ not as ... as', 'N + ほど + A / Vない', 'Diễn tả so sánh phủ định: không đến mức như.', 'Expresses negative comparison.', '流行は大切だが、自分らしさほど重要ではない。', 'Xu hướng thời trang quan trọng thật nhưng không quan trọng bằng bản sắc cá nhân.', 'Trends matter, but they are not as important as being yourself.'),
        ('〜というより', '~ rather than / or rather', 'V普通形 / A / N + というより', 'Dùng để chỉnh lại cách diễn đạt cho chính xác hơn.', 'Used to correct or refine an expression.', 'この服は派手というより、個性的だ。', 'Bộ đồ này nói là lòe loẹt thì không hẳn, đúng hơn là cá tính.', 'This outfit is not flashy so much as unique.'),
        ('〜より〜のほうが', '~ more ... than ...', 'Nより Nのほうが + A', 'Diễn tả so sánh và nhấn mạnh phương án được đánh giá cao hơn.', 'Expresses comparison and highlights the preferred option.', 'ブランド名より、自分に合うかどうかのほうが大切だ。', 'So với tên thương hiệu thì việc có hợp với mình hay không quan trọng hơn.', 'Whether it suits you is more important than the brand name.'),
    ]),
    (75, [
        ('〜しかない', '~ have no choice but to', 'V辞書 + しかない', 'Diễn tả chỉ còn một lựa chọn duy nhất.', 'Expresses that there is no option but to do something.', '時間がないから、できることから始めるしかない。', 'Vì không có thời gian nên chỉ còn cách bắt đầu từ việc làm được.', 'There is no time, so we have no choice but to start with what we can do.'),
        ('〜ばかりでなく', '~ not only ... but also', 'N / V普通形 + ばかりでなく', 'Diễn tả không chỉ A mà còn cả B.', 'Expresses not only A but also B.', 'ボランティア活動は地域ばかりでなく、自分自身にも良い影響を与える。', 'Hoạt động tình nguyện không chỉ tác động tốt đến cộng đồng mà còn đến chính bản thân mình.', 'Volunteer work has a positive effect not only on the community but also on oneself.'),
        ('〜どんなに〜ても', '~ no matter how', 'どんなに + Vても / Aくても', 'Diễn tả kết quả không thay đổi dù mức độ thế nào đi nữa.', 'Expresses that the result does not change regardless of degree.', 'どんなに小さくても、できることを続けるのが大切だ。', 'Dù nhỏ đến đâu thì việc tiếp tục những điều mình làm được vẫn quan trọng.', 'No matter how small it is, it is important to keep doing what you can.'),
    ]),
]


def _write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def _load_themes() -> dict[int, dict[str, object]]:
    payload = json.loads(THEME_MAP_PATH.read_text(encoding='utf-8-sig'))
    return {item['lessonId']: item for item in payload['levels']['N3']['lessons']}


def main() -> int:
    themes = _load_themes()
    report = []
    total_points = 0
    total_examples = 0

    for lesson_id, points in LESSON_PACKS:
        theme = themes.get(lesson_id, {})
        quartet_lesson = theme.get('quartetLesson')
        theme_en = theme.get('theme', '')
        theme_vi = theme.get('themeVi', '')

        grammar_payload = []
        examples_payload = []

        for title, title_en, structure, explanation, explanation_en, jp, vi, en in points:
            grammar_payload.append({
                'lessonId': lesson_id,
                'title': title,
                'titleEn': title_en,
                'structure': structure,
                'structureEn': structure,
                'explanation': explanation,
                'explanationEn': explanation_en,
                'level': 'N3',
                'tags': ','.join([
                    'draft',
                    'manual-review-needed',
                    'n3-scaffold',
                    f'quartet-lesson-{quartet_lesson}' if quartet_lesson else 'quartet-theme',
                ]),
            })
            examples_payload.append({
                'grammarPoint': title,
                'examples': [
                    {
                        'sentence': jp,
                        'translation': vi,
                        'translationEn': en,
                    },
                    {
                        'sentence': f'この課では、{title} を使ってテーマについて話します。',
                        'translation': f'Trong bài này, chúng ta dùng {title} để nói về chủ đề bài học.',
                        'translationEn': f'In this lesson, we use {title} to talk about the lesson theme.',
                    },
                ],
            })

        grammar_path = GRAMMAR_ROOT / f'grammar_n3_{lesson_id}.json'
        example_path = EXAMPLE_ROOT / f'lesson_{lesson_id}.json'
        _write_json(grammar_path, grammar_payload)
        _write_json(example_path, examples_payload)

        point_count = len(grammar_payload)
        example_count = sum(len(item['examples']) for item in examples_payload)
        total_points += point_count
        total_examples += example_count
        report.append({
            'lessonId': lesson_id,
            'quartetLesson': quartet_lesson,
            'theme': theme_en,
            'themeVi': theme_vi,
            'points': point_count,
            'examples': example_count,
            'grammarPath': str(grammar_path.relative_to(ROOT)).replace('\\', '/'),
            'examplePath': str(example_path.relative_to(ROOT)).replace('\\', '/'),
        })

    payload = {
        'count': len(report),
        'totalPoints': total_points,
        'totalExamples': total_examples,
        'sources': {
            'themeStructure': 'tooling/quartet1_theme_map.json',
            'publicReference': [
                'https://jlptsensei.com/jlpt-n3-grammar-list/',
                'https://japanesetest4you.com/jlpt-n3-grammar-list/',
                'https://bunpro.jp/decks/cgwh1b/bunpro-n3-grammar%3Fpage%3D1',
            ],
            'manualReviewReference': 'Shin Kanzen Master N3 (not imported)',
        },
        'lessons': report,
    }
    _write_json(REPORT_PATH, payload)
    print(json.dumps({
        'count': len(report),
        'totalPoints': total_points,
        'totalExamples': total_examples,
        'report': str(REPORT_PATH.relative_to(ROOT)).replace('\\', '/'),
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
