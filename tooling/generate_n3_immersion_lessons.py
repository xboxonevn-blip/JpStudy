#!/usr/bin/env python3
"""Generate immersion lessons 51-75 using the existing N3 lesson themes.

The output schema intentionally matches the simple immersion lesson files used
for N4/N5 so both Immersion Reader and JLPT Reading Drill can share one source.
"""

from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

try:
    from janome.tokenizer import Tokenizer
except ImportError as exc:
    raise SystemExit(
        'Install janome in a local virtual environment before running '
        'tooling/generate_n3_immersion_lessons.py.',
    ) from exc

ROOT = Path(__file__).resolve().parents[1]
IMMERSION_ROOT = ROOT / 'assets' / 'data' / 'content' / 'immersion'
VOCAB_ROOT = ROOT / 'assets' / 'data' / 'content' / 'vocab'
THEME_MAP_PATH = ROOT / 'tooling' / 'quartet1_theme_map.json'
OUTPUT_ROOT = IMMERSION_ROOT / 'n3'
PUBLISHED_AT = '2026-03-17'
SOURCE_LABEL = 'JpStudy Original'
TARGET_LEVEL = 'N3'

PUNCTUATION = {'。', '、', '・', '「', '」', '（', '）', '？', '！', 'ー'}
NON_MERGE_SURFACES = {
    'は',
    'が',
    'を',
    'に',
    'で',
    'と',
    'の',
    'も',
    'へ',
    'や',
    'か',
    'な',
    'ね',
    'よ',
    'だけ',
    'より',
    'ほど',
}
MERGE_SUFFIX_SURFACES = {
    'いる',
    'いた',
    'い',
    'て',
    'で',
    'た',
    'だ',
    'たい',
    'よう',
    'やすい',
    'やすく',
    'にくい',
    'にくく',
    'すぎる',
    'すぎ',
    'られる',
    'れる',
    'しまう',
    'しまっ',
    'なっ',
    'なり',
    'さ',
    'せ',
    'ず',
    'ぬ',
    'する',
    'し',
    'して',
}
EMPTY_READING_SURFACES = {
    'いる',
    'する',
    'し',
    'て',
    'た',
    'なる',
    'くる',
    'しまう',
    'され',
    'みる',
    'おく',
    'として',
    'など',
    'こそ',
}

LESSON_ARTICLES = [
    {
        'lessonId': 51,
        'title': '余暇の使い方',
        'translation': 'Cách sử dụng thời gian rảnh',
        'paragraphs': [
            '最近、自由時間の使い方を見直す人が増えている。',
            '私も週末を何となく過ごして、夜になって後悔することがあった。',
            'そこで、朝のうちにやりたいことを三つ決めるようにした。',
            'すると、読書や運動に使う時間が増え、気分も前向きになった。',
            'これからは友達の意見も参考にしながら、自分に合う休み方を考えたい。',
        ],
    },
    {
        'lessonId': 52,
        'title': '将来の自分のために',
        'translation': 'Vì bản thân trong tương lai',
        'paragraphs': [
            '将来の目標は、急に決まるものではないと思う。',
            '私はまず、五年後にどんな生活をしたいかをノートに書いた。',
            'その上で、今月できる小さな計画を立て、毎週見直すことにしている。',
            '小さな努力でも続けると、自分の成長が少しずつ見えてくる。',
            '未来の自分に困らないように、今できる準備を大切にしたい。',
        ],
    },
    {
        'lessonId': 53,
        'title': '便利さとごみの問題',
        'translation': 'Tiện lợi và vấn đề rác thải',
        'paragraphs': [
            '便利な商品が増えた一方で、家庭ごみの量も多くなっている。',
            '特に、過剰な包装は片づけるときに無駄だと感じる。',
            '私は買い物の前に必要な物を確認し、再利用できる物を選ぶようにしている。',
            '少し意識するだけでも、資源を大切にしながら生活できる。',
            'これからも便利さだけでなく、その後の廃棄まで考えて選びたい。',
        ],
    },
    {
        'lessonId': 54,
        'title': '留学で学んだこと',
        'translation': 'Những điều học được từ du học',
        'paragraphs': [
            '留学の一番大きな学びは、言語だけではなく文化の違いに気づくことだった。',
            '授業の意見交換では、自分の考えをはっきり言う大切さを知った。',
            '最初は緊張したが、毎日寮の友達と会話するようにした。',
            'その結果、教科書では分からない表現や生活の習慣も自然に身についた。',
            'これからは留学で得た経験を、次の研究や交流に生かしたい。',
        ],
    },
    {
        'lessonId': 55,
        'title': '働く上で大切なこと',
        'translation': 'Điều quan trọng khi làm việc',
        'paragraphs': [
            '仕事を選ぶとき、給料だけで決めるのは難しい。',
            '実際に働き始めると、職場の雰囲気や協力しやすさが毎日に大きく影響する。',
            '私は面接の前に、その会社で大切にされている考え方を調べることにしている。',
            '自分の専門や価値観に合う職場なら、責任のある仕事にも前向きに取り組める。',
            '将来は、周りと信頼関係を作りながら成長できる仕事を選びたい。',
        ],
    },
    {
        'lessonId': 56,
        'title': 'ネット通販の工夫',
        'translation': 'Mẹo mua sắm trực tuyến',
        'paragraphs': [
            'ネット通販は便利だが、買いすぎてしまう人も少なくない。',
            '画面の写真だけで決めると、届いた商品が思っていた物と違うことがある。',
            'そのため、私は注文する前に評価と返品の条件を必ず確認している。',
            '少し時間をかけて比較すると、無駄な支払いや失敗が減る。',
            'これからは割引だけに引かれず、本当に必要な物を選ぶつもりだ。',
        ],
    },
    {
        'lessonId': 57,
        'title': '健康的な生活習慣',
        'translation': 'Thói quen sống lành mạnh',
        'paragraphs': [
            '健康は特別なことではなく、毎日の習慣の積み重ねで守られる。',
            '忙しい時ほど睡眠の時間が短くなり、体調をくずしやすい。',
            '私は夜遅くまでスマホを見ないようにし、朝に少し運動することにしている。',
            'そうすると、集中しやすくなり、疲労も前より残りにくい。',
            'これからも無理な方法ではなく、続けられる生活習慣を選びたい。',
        ],
    },
    {
        'lessonId': 58,
        'title': '季節の行事を楽しむ',
        'translation': 'Tận hưởng các sự kiện theo mùa',
        'paragraphs': [
            '季節の行事には、その土地の文化や人とのつながりが表れている。',
            '子どものころは祭りを楽しむだけだったが、大人になると準備の意味も分かってきた。',
            '地域の人と一緒に行事に参加すると、昔から続く作法や礼儀も学べる。',
            '行事を通して世代の違う人と話す機会が増えるのも大きな魅力だ。',
            'これからは見るだけでなく、自分でも季節の行事を支える側になりたい。',
        ],
    },
    {
        'lessonId': 59,
        'title': '情報の受け取り方',
        'translation': 'Cách tiếp nhận thông tin',
        'paragraphs': [
            '毎日多くの情報が流れる今、何を信じるかを自分で考える力が必要だ。',
            '見出しだけを読むと、記事の内容を正しく理解できないことがある。',
            '私は気になる話題があると、新聞や放送など複数の情報源を比べるようにしている。',
            '立場の違う意見を読むと、一つの出来事を広く見ることができる。',
            'これからも早く知ることより、正しく受け取ることを大切にしたい。',
        ],
    },
    {
        'lessonId': 60,
        'title': '旅行前の準備',
        'translation': 'Chuẩn bị trước chuyến đi',
        'paragraphs': [
            '旅行を楽しくするためには、出発前の準備がとても大切だ。',
            '以前、交通の時間をよく調べなかったため、乗り換えで困ったことがある。',
            'それ以来、予約をする前に地図を見て、移動の方法を比べるようにしている。',
            '宿泊先や運賃を早めに確認すると、当日は安心して行動できる。',
            '次の旅行では、予定に少し余裕を持たせて、景色もゆっくり楽しみたい。',
        ],
    },
    {
        'lessonId': 61,
        'title': '災害に備える',
        'translation': 'Chuẩn bị cho thiên tai',
        'paragraphs': [
            '日本で生活していると、地震や台風への備えの大切さをよく聞く。',
            'でも、忙しい日が続くと、防災の準備を後回しにしがちだ。',
            '私は水や電池を一か所にまとめ、避難場所を家族と確認することにしている。',
            '事前に話し合っておくだけで、不安が少し小さくなると感じた。',
            '災害は起きないほうがいいが、起きた時に落ち着いて動けるようにしたい。',
        ],
    },
    {
        'lessonId': 62,
        'title': '音楽と気分転換',
        'translation': 'Âm nhạc và việc đổi tâm trạng',
        'paragraphs': [
            '音楽や映画は、忙しい毎日の中で気分を切り替える助けになる。',
            '私は勉強が続いて疲れた時、好きな曲を一曲だけ聞くようにしている。',
            '短い時間でも、気持ちが整理されると、また集中しやすくなる。',
            '友達と感想を話すと、自分とは違う見方に気づくこともある。',
            'これからは楽しむだけでなく、作品から表現の工夫も学びたい。',
        ],
    },
    {
        'lessonId': 63,
        'title': '学校で伸びる力',
        'translation': 'Năng lực được phát triển ở trường',
        'paragraphs': [
            '学校で身につくのは、知識だけではないと思う。',
            'グループ活動では、自分の考えを伝える力と相手の話を聞く力の両方が必要だ。',
            '私は分からないことがある時、遠慮しないで質問するようにしている。',
            'そのほうが理解が深まり、次の授業にも自信を持って参加できる。',
            'これからも成績だけではなく、学び続ける力を伸ばしたい。',
        ],
    },
    {
        'lessonId': 64,
        'title': '家族との距離感',
        'translation': 'Khoảng cách phù hợp với gia đình',
        'paragraphs': [
            '家族は近い存在だからこそ、言いたいことをうまく言えない時がある。',
            '心配してくれていると分かっていても、考え方が違うとぶつかることもある。',
            '私は大事な話ほど、感情的にならないで順番に説明するようにしている。',
            'すると、すぐに解決しなくても、お互いの気持ちを少し理解しやすくなる。',
            'これからも家族との距離を大切にしながら、必要な時は正直に話したい。',
        ],
    },
    {
        'lessonId': 65,
        'title': '住みやすい町',
        'translation': 'Một thành phố đáng sống',
        'paragraphs': [
            '住みやすい町には、便利さと落ち着きの両方が必要だと思う。',
            '駅や店が近いだけでなく、安心して歩ける道や静かな公園も大切だ。',
            '私の町では、地域の人があいさつをする習慣があり、それが安心感につながっている。',
            '人とのつながりがあると、困った時にも助けを求めやすい。',
            '将来引っ越すとしても、設備だけでなく町の雰囲気もよく見て決めたい。',
        ],
    },
    {
        'lessonId': 66,
        'title': '試合から学ぶ',
        'translation': 'Học được từ trận đấu',
        'paragraphs': [
            'スポーツの試合では、勝つこと以外にも学べることが多い。',
            '私は以前、練習ではできたのに、本番で焦って失敗したことがある。',
            'その経験から、試合の前ほど深呼吸して落ち着くようにしている。',
            '自分の力だけでなく、仲間を信じて動くことも結果を左右すると分かった。',
            '次の大会では、点数だけでなく試合の流れもよく見たい。',
        ],
    },
    {
        'lessonId': 67,
        'title': '技術と暮らし',
        'translation': 'Công nghệ và đời sống',
        'paragraphs': [
            '新しい技術は、私たちの生活を便利にする一方で、使い方も問われる。',
            '例えば、検索や翻訳の道具は役に立つが、頼りすぎると自分で考える時間が減る。',
            '私は便利な機能を使う前に、まず自分で少し調べてみることにしている。',
            'そのほうが仕組みを理解しやすく、間違いにも気づきやすい。',
            'これからは新しい技術を上手に取り入れながら、考える力も守りたい。',
        ],
    },
    {
        'lessonId': 68,
        'title': 'ルールと社会生活',
        'translation': 'Quy tắc và đời sống xã hội',
        'paragraphs': [
            'ルールは面倒に感じる時もあるが、安心して暮らすために必要だ。',
            '電車の中でのマナーや地域の決まりは、周りの人への思いやりにつながっている。',
            '私は理由が分からない決まりでも、まず背景を知るようにしている。',
            '理由が分かると、ただ守るだけでなく、自分から協力しやすくなる。',
            'これからも自分の都合だけで判断せず、社会全体を考えて行動したい。',
        ],
    },
    {
        'lessonId': 69,
        'title': '料理から分かる文化',
        'translation': 'Văn hóa thể hiện qua món ăn',
        'paragraphs': [
            '料理には、その国の気候や生活の歴史がよく表れる。',
            '同じ材料でも、調理の方法や味つけが違うと、受ける印象も大きく変わる。',
            '私は新しい料理を食べる時、名前だけでなく、使われている食材も見るようにしている。',
            'そうすると、その土地で大切にされてきた考え方まで想像できておもしろい。',
            'これからは食べるだけでなく、自分でも作って文化をもっと理解したい。',
        ],
    },
    {
        'lessonId': 70,
        'title': '気持ちの整え方',
        'translation': 'Cách sắp xếp cảm xúc',
        'paragraphs': [
            '忙しい時ほど、自分の気持ちに気づく時間が必要だと思う。',
            '私は失敗した日に何も考えないで寝ると、次の日まで不安が残ってしまう。',
            'そのため、短くても日記を書いて気持ちを言葉にするようにしている。',
            '書いてみると、問題そのものより考えすぎていたと分かることも多い。',
            'これからも感情を抑えるだけでなく、上手に整理する方法を続けたい。',
        ],
    },
    {
        'lessonId': 71,
        'title': 'お金の使い方',
        'translation': 'Cách sử dụng tiền bạc',
        'paragraphs': [
            'お金の使い方には、その人の考え方がよく表れる。',
            '私は以前、安いからという理由だけで物を買い、結局使わなかったことがある。',
            'それ以来、買う前に本当に必要かどうかを一度考えることにしている。',
            '小さな出費でも記録すると、無意識のむだに気づきやすい。',
            'これからは我慢するだけでなく、自分にとって価値のある使い方を選びたい。',
        ],
    },
    {
        'lessonId': 72,
        'title': '分かりやすく伝える',
        'translation': 'Truyền đạt dễ hiểu',
        'paragraphs': [
            '相手に伝える時は、正しい内容だけでなく、伝え方も大切だ。',
            '説明が長すぎると、話の中心が見えにくくなってしまう。',
            '私は発表の前に、まず一番伝えたいことを一文で言えるか確認するようにしている。',
            '例や比べ方を入れると、難しい内容でも理解してもらいやすい。',
            'これからは言葉の数を増やすより、相手に届く表現を選びたい。',
        ],
    },
    {
        'lessonId': 73,
        'title': '歴史を学ぶ意味',
        'translation': 'Ý nghĩa của việc học lịch sử',
        'paragraphs': [
            '歴史を学ぶのは、昔の出来事を覚えるためだけではない。',
            'ある時代の選択を知ると、今の社会の仕組みがどうしてできたか見えてくる。',
            '私は年表だけを見るのではなく、人々が何に困り、何を求めたのか考えるようにしている。',
            'そうすると、政治や外交の話も遠い世界のことではなく感じられる。',
            'これからも現在の問題と比べながら、歴史から学べることを探したい。',
        ],
    },
    {
        'lessonId': 74,
        'title': '自分らしい服選び',
        'translation': 'Chọn trang phục mang cá tính của mình',
        'paragraphs': [
            '服を選ぶ時、流行だけを追うと落ち着かないことがある。',
            '店で見た時はすてきでも、実際に着ると自分に似合わない場合もある。',
            'だから私は試着をして、色や素材が普段の生活に合うか考えるようにしている。',
            '自分に合う物を選べると、見た目だけでなく気持ちも楽になる。',
            'これからはブランドの名前より、自分らしく着られる一着を大切にしたい。',
        ],
    },
    {
        'lessonId': 75,
        'title': '世界のためにできること',
        'translation': 'Những điều có thể làm cho thế giới',
        'paragraphs': [
            '世界の問題は大きすぎて、自分には何もできないと感じる人もいる。',
            'しかし、身近な所でできる協力を続けることにも意味がある。',
            '私はニュースで気になった課題があると、まず信頼できる情報を調べるようにしている。',
            'その上で、寄付やボランティアなど、自分に合う形で関わる方法を考える。',
            'これからも完璧を求めすぎず、小さくても続けられる支援を選びたい。',
        ],
    },
]

MANUAL_GLOSSARY = {
    '見直す': ('みなおす', 'xem xét lại', 'review'),
    '使い方': ('つかいかた', 'cách sử dụng', 'how to use'),
    '使う': ('つかう', 'sử dụng', 'use'),
    '増える': ('ふえる', 'tăng lên', 'increase'),
    '何となく': ('なんとなく', 'một cách mơ hồ', 'vaguely'),
    '過ごす': ('すごす', 'trải qua', 'spend'),
    '決める': ('きめる', 'quyết định', 'decide'),
    '前向き': ('まえむき', 'tích cực', 'positive'),
    '合う': ('あう', 'phù hợp', 'fit'),
    '考える': ('かんがえる', 'suy nghĩ', 'think'),
    '思う': ('おもう', 'nghĩ', 'think'),
    '将来': ('しょうらい', 'tương lai', 'future'),
    '目標': ('もくひょう', 'mục tiêu', 'goal'),
    '決まる': ('きまる', 'được quyết định', 'be decided'),
    '生活': ('せいかつ', 'cuộc sống', 'life'),
    '自由': ('じゆう', 'tự do', 'freedom'),
    '書く': ('かく', 'viết', 'write'),
    '見える': ('みえる', 'trông thấy', 'be visible'),
    '困る': ('こまる', 'gặp khó khăn', 'have trouble'),
    '選ぶ': ('えらぶ', 'lựa chọn', 'choose'),
    '分かる': ('わかる', 'hiểu, nhận ra', 'understand'),
    '便利': ('べんり', 'tiện lợi', 'convenient'),
    '一方': ('いっぽう', 'mặt khác', 'on the other hand'),
    '量': ('りょう', 'lượng', 'amount'),
    '感じる': ('かんじる', 'cảm thấy', 'feel'),
    '確認': ('かくにん', 'xác nhận', 'check'),
    '続ける': ('つづける', 'tiếp tục', 'continue'),
    '立てる': ('たてる', 'lập ra', 'make'),
    '気づく': ('きづく', 'nhận ra', 'notice'),
    '知る': ('しる', 'biết', 'learn'),
    '結果': ('けっか', 'kết quả', 'result'),
    '生かす': ('いかす', 'phát huy', 'make use of'),
    '職場': ('しょくば', 'nơi làm việc', 'workplace'),
    '雰囲気': ('ふんいき', 'bầu không khí', 'atmosphere'),
    '考え方': ('かんがえかた', 'cách suy nghĩ', 'way of thinking'),
    '調べる': ('しらべる', 'tra cứu', 'check'),
    '取り組む': ('とりくむ', 'nỗ lực thực hiện', 'work on'),
    '信頼関係': ('しんらいかんけい', 'mối quan hệ tin cậy', 'trust relationship'),
    '比較': ('ひかく', 'so sánh', 'comparison'),
    '条件': ('じょうけん', 'điều kiện', 'condition'),
    '睡眠': ('すいみん', 'giấc ngủ', 'sleep'),
    '体調': ('たいちょう', 'thể trạng', 'physical condition'),
    '祭り': ('まつり', 'lễ hội', 'festival'),
    '地域': ('ちいき', 'khu vực', 'community'),
    '魅力': ('みりょく', 'sức hấp dẫn', 'appeal'),
    '情報源': ('じょうほうげん', 'nguồn thông tin', 'information source'),
    '立場': ('たちば', 'lập trường', 'position'),
    '受け取る': ('うけとる', 'tiếp nhận', 'receive'),
    '乗り換え': ('のりかえ', 'chuyển tuyến', 'transfer'),
    '移動': ('いどう', 'di chuyển', 'movement'),
    '比べる': ('くらべる', 'so sánh', 'compare'),
    '行動': ('こうどう', 'hành động', 'action'),
    '余裕': ('よゆう', 'sự dư dả', 'margin'),
    '災害': ('さいがい', 'thiên tai', 'disaster'),
    '備え': ('そなえ', 'sự chuẩn bị', 'preparedness'),
    '後回し': ('あとまわし', 'để sau', 'postpone'),
    '避難場所': ('ひなんばしょ', 'nơi sơ tán', 'evacuation area'),
    '話し合う': ('はなしあう', 'thảo luận', 'discuss'),
    '音楽': ('おんがく', 'âm nhạc', 'music'),
    '切り替える': ('きりかえる', 'chuyển đổi', 'switch'),
    '整理': ('せいり', 'sắp xếp', 'organize'),
    '感想': ('かんそう', 'cảm nghĩ', 'impression'),
    '見方': ('みかた', 'cách nhìn', 'viewpoint'),
    '工夫': ('くふう', 'sự khéo léo, cách làm', 'ingenuity'),
    '学校': ('がっこう', 'trường học', 'school'),
    '伝える': ('つたえる', 'truyền đạt', 'convey'),
    '理解': ('りかい', 'sự hiểu', 'understanding'),
    '内容': ('ないよう', 'nội dung', 'content'),
    '深まる': ('ふかまる', 'sâu hơn', 'deepen'),
    '成績': ('せいせき', 'thành tích', 'grade'),
    '距離': ('きょり', 'khoảng cách', 'distance'),
    '感情的': ('かんじょうてき', 'theo cảm xúc', 'emotional'),
    '説明': ('せつめい', 'giải thích', 'explanation'),
    '話す': ('はなす', 'nói chuyện', 'speak'),
    '以前': ('いぜん', 'trước đây', 'before'),
    '落ち着く': ('おちつく', 'bình tĩnh', 'calm down'),
    '学ぶ': ('まなぶ', 'học hỏi', 'learn'),
    '試合': ('しあい', 'trận đấu', 'match'),
    '本番': ('ほんばん', 'buổi chính thức', 'actual performance'),
    '焦る': ('あせる', 'cuống lên', 'panic'),
    '深呼吸': ('しんこきゅう', 'hít thở sâu', 'deep breath'),
    '左右': ('さゆう', 'chi phối', 'influence'),
    '技術': ('ぎじゅつ', 'công nghệ', 'technology'),
    '暮らし': ('くらし', 'đời sống', 'life'),
    '仕組み': ('しくみ', 'cơ chế', 'mechanism'),
    '間違い': ('まちがい', 'sai lầm', 'mistake'),
    '面倒': ('めんどう', 'phiền phức', 'troublesome'),
    '思いやり': ('おもいやり', 'sự quan tâm', 'consideration'),
    '料理': ('りょうり', 'ẩm thực, nấu ăn', 'cooking'),
    '表れる': ('あらわれる', 'thể hiện', 'appear'),
    '歴史': ('れきし', 'lịch sử', 'history'),
    '気候': ('きこう', 'khí hậu', 'climate'),
    '調理': ('ちょうり', 'chế biến', 'cooking'),
    '味つけ': ('あじつけ', 'nêm nếm', 'seasoning'),
    '想像': ('そうぞう', 'tưởng tượng', 'imagination'),
    '日記': ('にっき', 'nhật ký', 'diary'),
    '言葉': ('ことば', 'ngôn từ', 'words'),
    '抑える': ('おさえる', 'kiềm chế', 'control'),
    '出費': ('しゅっぴ', 'chi tiêu', 'expense'),
    '記録': ('きろく', 'ghi chép', 'record'),
    '無意識': ('むいしき', 'vô thức', 'unconsciously'),
    '価値': ('かち', 'giá trị', 'value'),
    '発表': ('はっぴょう', 'bài phát biểu', 'presentation'),
    '一文': ('いちぶん', 'một câu', 'one sentence'),
    '比べ方': ('くらべかた', 'cách so sánh', 'way of comparing'),
    '時代': ('じだい', 'thời đại', 'era'),
    '年表': ('ねんぴょう', 'niên biểu', 'timeline'),
    '求める': ('もとめる', 'tìm kiếm', 'seek'),
    '流行': ('りゅうこう', 'xu hướng', 'trend'),
    '試着': ('しちゃく', 'thử đồ', 'try on'),
    '素材': ('そざい', 'chất liệu', 'material'),
    '景色': ('けしき', 'phong cảnh', 'scenery'),
    '楽しむ': ('たのしむ', 'tận hưởng', 'enjoy'),
    '信じる': ('しんじる', 'tin tưởng', 'believe'),
    '読む': ('よむ', 'đọc', 'read'),
    '出来事': ('できごと', 'sự việc', 'event'),
    '助け': ('たすけ', 'sự giúp đỡ', 'help'),
    'つながり': ('つながり', 'sự kết nối', 'connection'),
    '決まり': ('きまり', 'quy định', 'rule'),
    '実際': ('じっさい', 'thực tế', 'actually'),
    '集中': ('しゅうちゅう', 'tập trung', 'concentration'),
    '残る': ('のこる', 'còn lại', 'remain'),
    '届く': ('とどく', 'được gửi tới, chạm tới', 'arrive'),
    '減る': ('へる', 'giảm đi', 'decrease'),
    '守る': ('まもる', 'giữ gìn', 'protect'),
    '身近': ('みぢか', 'gần gũi', 'close at hand'),
    '課題': ('かだい', 'vấn đề', 'issue'),
    '信頼': ('しんらい', 'tin cậy', 'trust'),
    '寄付': ('きふ', 'quyên góp', 'donation'),
    '関わる': ('かかわる', 'tham gia, liên quan', 'engage'),
    '支援': ('しえん', 'hỗ trợ', 'support'),
    '働く': ('はたらく', 'làm việc', 'work'),
    '働き始める': ('はたらきはじめる', 'bắt đầu làm việc', 'start working'),
    '協力しやすさ': (
        'きょうりょくしやすさ',
        'mức độ dễ hợp tác',
        'ease of cooperation',
    ),
    '影響する': ('えいきょうする', 'ảnh hưởng', 'affect'),
    '価値観': ('かちかん', 'quan điểm giá trị', 'values'),
    '取り組める': ('とりくめる', 'có thể nỗ lực thực hiện', 'can work on'),
    '積み重ね': ('つみかさね', 'sự tích lũy', 'accumulation'),
    '守られる': ('まもられる', 'được bảo vệ', 'be protected'),
    '集中しやすくなる': (
        'しゅうちゅうしやすくなる',
        'trở nên dễ tập trung hơn',
        'become easier to focus',
    ),
    '見出し': ('みだし', 'tiêu đề', 'headline'),
    '多く': ('おおく', 'nhiều', 'many'),
    '流れる': ('ながれる', 'trôi, lan truyền', 'flow'),
    '必要だ': ('ひつようだ', 'cần thiết', 'necessary'),
    '複数': ('ふくすう', 'nhiều, đa số lượng', 'multiple'),
    '防災': ('ぼうさい', 'phòng chống thiên tai', 'disaster prevention'),
    '確認する': ('かくにんする', 'xác nhận', 'confirm'),
    '事前': ('じぜん', 'trước đó', 'in advance'),
    '話し合っておく': (
        'はなしあっておく',
        'thảo luận trước',
        'discuss beforehand',
    ),
    '落ち着いて': ('おちついて', 'một cách bình tĩnh', 'calmly'),
    '生活している': ('せいかつしている', 'đang sinh sống', 'be living'),
    '大切さ': ('たいせつさ', 'tầm quan trọng', 'importance'),
    '便利さ': ('べんりさ', 'mức độ tiện lợi', 'convenience'),
    '続けられる': ('つづけられる', 'có thể tiếp tục', 'can continue'),
    '見えてくる': ('みえてくる', 'dần trở nên thấy rõ', 'come into view'),
    'つながっている': ('つながっている', 'được kết nối với', 'be connected'),
    '気づきやすい': ('きづきやすい', 'dễ nhận ra', 'easy to notice'),
    '学べる': ('まなべる', 'có thể học', 'can learn'),
    '分からない': ('わからない', 'không hiểu', 'not understand'),
    '大切だ': ('たいせつだ', 'quan trọng', 'important'),
    '安心して': ('あんしんして', 'yên tâm mà', 'with peace of mind'),
    '一番': ('いちばん', 'nhất, quan trọng nhất', 'most'),
    '以来': ('いらい', 'từ đó trở đi', 'since then'),
    '両方': ('りょうほう', 'cả hai', 'both'),
    '見て': ('みて', 'xem, nhìn', 'look'),
    '考えて': ('かんがえて', 'suy nghĩ', 'thinking'),
    '続く': ('つづく', 'tiếp diễn', 'continue'),
    '困った': ('こまった', 'đã gặp rắc rối', 'troubled'),
    '失敗した': ('しっぱいした', 'đã thất bại', 'failed'),
    '正しく': ('ただしく', 'một cách chính xác', 'correctly'),
    '理解できない': ('りかいできない', 'không thể hiểu đúng', 'cannot understand'),
    '話題': ('わだい', 'chủ đề', 'topic'),
    'している': ('している', 'đang làm', 'be doing'),
    'できる': ('できる', 'có thể', 'can'),
    'ながら': ('ながら', 'trong khi', 'while'),
    'より': ('より', 'hơn, so với', 'than'),
    'ほど': ('ほど', 'đến mức, mức độ', 'to the extent'),
    'なる': ('なる', 'trở thành', 'become'),
    'しまう': ('しまう', 'lỡ, cuối cùng lại', 'end up'),
    '考え': ('かんがえ', 'ý nghĩ', 'thought'),
    '身': ('み', 'bản thân, cơ thể', 'body / oneself'),
    'され': ('され', 'được làm', 'be done'),
    'など': ('など', 'vân vân', 'etc.'),
    'つながっ': ('つながっ', 'gắn kết', 'connect'),
    'みる': ('みる', 'thử, xem', 'try / see'),
    'やりたい': ('やりたい', 'muốn làm', 'want to do'),
    '未来': ('みらい', 'tương lai', 'future'),
    '家庭': ('かてい', 'gia đình, hộ gia đình', 'household'),
    '過剰': ('かじょう', 'quá mức', 'excessive'),
    '片づける': ('かたづける', 'dọn dẹp', 'put away'),
    'その後': ('そのあと', 'sau đó', 'after that'),
    '学び': ('まなび', 'sự học hỏi', 'learning'),
    '違い': ('ちがい', 'sự khác biệt', 'difference'),
    '交換': ('こうかん', 'trao đổi', 'exchange'),
    '言う': ('いう', 'nói', 'say'),
    '作り': ('つくり', 'cách tạo ra, cấu tạo', 'making / structure'),
    'ネット': ('ねっと', 'mạng Internet', 'internet'),
    '通販': ('つうはん', 'mua bán trực tuyến', 'online shopping'),
    '買いすぎ': ('かいすぎ', 'mua quá nhiều', 'buy too much'),
    '引かれず': ('ひかれず', 'không bị cuốn theo', 'not be drawn in'),
    'くずしやすい': ('くずしやすい', 'dễ suy sụp', 'easy to upset'),
    'スマホ': ('すまほ', 'điện thoại thông minh', 'smartphone'),
    '子ども': ('こども', 'trẻ em', 'child'),
    'を通して': ('をとおして', 'thông qua', 'through'),
    '支える': ('ささえる', 'hỗ trợ, nâng đỡ', 'support'),
    '早め': ('はやめ', 'sớm hơn một chút', 'a bit early'),
    '当日': ('とうじつ', 'ngày diễn ra', 'the day itself'),
    '持たせ': ('もたせ', 'cho có, chừa ra', 'allow'),
    'しがちだ': ('しがちだ', 'có xu hướng', 'tend to'),
    'まとめ': ('まとめ', 'sự gom lại, tổng hợp', 'collecting / summary'),
    'おく': ('おく', 'làm trước', 'do in advance'),
    '動けるよう': ('うごけるよう', 'để có thể hành động', 'so as to be able to move'),
    'つく': ('つく', 'hình thành, có được', 'be attached / acquire'),
    '活動': ('かつどう', 'hoạt động', 'activity'),
    '持っ': ('もっ', 'mang, có', 'have'),
    '伸ばしたい': ('のばしたい', 'muốn phát triển', 'want to develop'),
    '存在だ': ('そんざいだ', 'là một sự hiện diện/sự tồn tại', 'be an existence'),
    'こそ': ('こそ', 'chính vì, chính là', 'precisely because'),
    'くれ': ('くれ', 'làm cho mình', 'do for me'),
    'ぶつかる': ('ぶつかる', 'va chạm, xung đột', 'clash'),
    '大事': ('だいじ', 'quan trọng', 'important'),
    '順番': ('じゅんばん', 'thứ tự', 'order'),
    'お互い': ('おたがい', 'lẫn nhau', 'each other'),
    '正直': ('しょうじき', 'thành thật', 'honest'),
    '住みやすい': ('すみやすい', 'dễ sống', 'easy to live in'),
    '落ち着き': ('おちつき', 'sự yên ổn, điềm tĩnh', 'calmness'),
    '歩ける': ('あるける', 'có thể đi bộ', 'can walk'),
    'あいさつ': ('あいさつ', 'lời chào', 'greeting'),
    '引っ越す': ('ひっこす', 'chuyển nhà', 'move house'),
    'として': ('として', 'với tư cách là', 'as'),
    '勝つ': ('かつ', 'chiến thắng', 'win'),
    'のに': ('のに', 'mặc dù', 'although'),
    '動く': ('うごく', 'di chuyển, hành động', 'move'),
    '点数': ('てんすう', 'điểm số', 'score'),
    '流れ': ('ながれ', 'dòng chảy, diễn biến', 'flow'),
    '問われる': ('とわれる', 'bị đặt ra, bị yêu cầu', 'be asked / be questioned'),
    '検索': ('けんさく', 'tìm kiếm', 'search'),
    '頼りすぎる': ('たよりすぎる', 'phụ thuộc quá mức', 'rely too much'),
    '機能': ('きのう', 'chức năng', 'function'),
    '取り入れ': ('とりいれ', 'sự tiếp nhận, áp dụng', 'adoption'),
    '暮らす': ('くらす', 'sống', 'live'),
    '背景': ('はいけい', 'bối cảnh', 'background'),
    'ただ': ('ただ', 'chỉ đơn thuần', 'simply'),
    '全体': ('ぜんたい', 'toàn bộ', 'whole'),
    '受ける': ('うける', 'nhận, chịu', 'receive'),
    '印象': ('いんしょう', 'ấn tượng', 'impression'),
    '変わる': ('かわる', 'thay đổi', 'change'),
    '作っ': ('つくっ', 'làm ra', 'make'),
    'そのもの': ('そのもの', 'bản thân chính nó', 'itself'),
    'という': ('という', 'được gọi là, rằng', 'called / that'),
    '買い': ('かい', 'việc mua', 'buying'),
    '結局': ('けっきょく', 'rốt cuộc', 'in the end'),
    '買う': ('かう', 'mua', 'buy'),
    '追う': ('おう', 'theo đuổi', 'follow'),
    '着る': ('きる', 'mặc', 'wear'),
    '場合': ('ばあい', 'trường hợp', 'case'),
    'だから': ('だから', 'vì vậy', 'so'),
    '普段': ('ふだん', 'thường ngày', 'usual'),
    '選べる': ('えらべる', 'có thể chọn', 'can choose'),
    '見た目': ('みため', 'bề ngoài', 'appearance'),
    '中心': ('ちゅうしん', 'trung tâm, trọng tâm', 'center'),
    '言える': ('いえる', 'có thể nói', 'can say'),
    '例': ('れい', 'ví dụ', 'example'),
    '入れる': ('いれる', 'đưa vào', 'put in'),
    '増やす': ('ふやす', 'tăng lên', 'increase'),
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def _write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )


def _katakana_to_hiragana(text: str) -> str:
    chars = []
    for char in text:
        code = ord(char)
        if 0x30A1 <= code <= 0x30F6:
            chars.append(chr(code - 0x60))
        else:
            chars.append(char)
    return ''.join(chars)


def _normalize_reading(value: str | None) -> str:
    if value is None or value == '*' or not value.strip():
        return ''
    return _katakana_to_hiragana(value.strip())


def _is_kana_only(text: str) -> bool:
    return bool(text) and all(
        ('ぁ' <= char <= 'ゖ') or ('ァ' <= char <= 'ヺ') or char == 'ー'
        for char in text
    )


def _add_lexicon_entry(
    store: dict[str, dict[str, str]],
    surface: str,
    reading: str,
    meaning_vi: str,
    meaning_en: str,
) -> None:
    key = surface.strip()
    if not key:
        return
    store.setdefault(
        key,
        {
            'reading': reading.strip(),
            'meaningVi': meaning_vi.strip(),
            'meaningEn': meaning_en.strip(),
        },
    )


def _load_immersion_lexicon() -> dict[str, dict[str, str]]:
    lexicon: dict[str, dict[str, str]] = {}
    for level in ('n5', 'n4'):
        level_root = IMMERSION_ROOT / level
        if not level_root.exists():
            continue
        for path in sorted(level_root.glob('lesson_*.json')):
            payload = _read_json(path)
            for paragraph in payload.get('paragraphs', []):
                for token in paragraph:
                    _add_lexicon_entry(
                        lexicon,
                        str(token.get('surface', '')),
                        str(token.get('reading', '') or ''),
                        str(token.get('meaningVi', '') or ''),
                        str(token.get('meaningEn', '') or ''),
                    )
    return lexicon


def _load_vocab_lexicon() -> dict[str, dict[str, str]]:
    lexicon: dict[str, dict[str, str]] = {}
    for level in ('n5', 'n4', 'n3'):
        level_root = VOCAB_ROOT / level
        if not level_root.exists():
            continue
        for path in sorted(level_root.glob('lesson_*.json')):
            payload = _read_json(path)
            for entry in payload.get('entries', []):
                lemma = entry.get('lemma', {})
                sense = entry.get('sense', {})
                _add_lexicon_entry(
                    lexicon,
                    str(lemma.get('term', '')),
                    str(lemma.get('reading', '') or ''),
                    str(sense.get('meaningVi', '') or ''),
                    str(sense.get('meaningEn', '') or ''),
                )
    return lexicon


def _build_manual_lexicon() -> dict[str, dict[str, str]]:
    return {
        surface: {
            'reading': reading,
            'meaningVi': meaning_vi,
            'meaningEn': meaning_en,
        }
        for surface, (reading, meaning_vi, meaning_en) in MANUAL_GLOSSARY.items()
    }


def _collect_known_surfaces(
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
) -> set[str]:
    return {
        key
        for key in {
            *immersion_lexicon.keys(),
            *vocab_lexicon.keys(),
            *manual_lexicon.keys(),
        }
        if len(key.strip()) > 1
    }


def _lookup_token(
    surface: str,
    base_form: str,
    reading: str,
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
) -> dict[str, str] | None:
    if surface in PUNCTUATION:
        return {'reading': '', 'meaningVi': '', 'meaningEn': ''}

    for key in (surface, base_form):
        if key in manual_lexicon:
            item = manual_lexicon[key]
            return {
                'reading': item['reading'] or reading,
                'meaningVi': item['meaningVi'],
                'meaningEn': item['meaningEn'],
            }
    for key in (surface, base_form):
        if key in immersion_lexicon:
            item = immersion_lexicon[key]
            return {
                'reading': item['reading'] or reading,
                'meaningVi': item['meaningVi'],
                'meaningEn': item['meaningEn'],
            }
    for key in (surface, base_form):
        if key in vocab_lexicon:
            item = vocab_lexicon[key]
            return {
                'reading': item['reading'] or reading,
                'meaningVi': item['meaningVi'],
                'meaningEn': item['meaningEn'],
            }
    return None


def _title_furigana(title: str, tokenizer: Tokenizer) -> str:
    parts: list[str] = []
    for token in tokenizer.tokenize(title):
        surface = token.surface
        if surface in PUNCTUATION:
            parts.append(surface)
            continue
        reading = _normalize_reading(token.reading)
        parts.append(reading or surface)
    return ' '.join(part for part in parts if part.strip())


def _token_meta(
    surface: str,
    base_form: str,
    reading: str,
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
) -> dict[str, str]:
    return _lookup_token(
        surface=surface,
        base_form=base_form,
        reading=reading,
        immersion_lexicon=immersion_lexicon,
        vocab_lexicon=vocab_lexicon,
        manual_lexicon=manual_lexicon,
    ) or {'reading': reading, 'meaningVi': '', 'meaningEn': ''}


def _raw_tokens(
    sentence: str,
    tokenizer: Tokenizer,
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
) -> list[dict[str, str]]:
    tokens: list[dict[str, str]] = []
    for token in tokenizer.tokenize(sentence):
        surface = token.surface.strip()
        if not surface:
            continue
        base_form = surface if token.base_form == '*' else token.base_form
        reading = _normalize_reading(token.reading)
        pos_parts = token.part_of_speech.split(',')
        meta = _token_meta(
            surface=surface,
            base_form=base_form,
            reading=reading,
            immersion_lexicon=immersion_lexicon,
            vocab_lexicon=vocab_lexicon,
            manual_lexicon=manual_lexicon,
        )
        tokens.append(
            {
                'surface': surface,
                'baseForm': base_form,
                'reading': meta['reading'] or reading,
                'meaningVi': meta['meaningVi'],
                'meaningEn': meta['meaningEn'],
                'posMajor': pos_parts[0] if pos_parts else '',
                'posMinor': pos_parts[1] if len(pos_parts) > 1 else '',
            }
        )
    return tokens


def _merge_token_chain(
    items: list[dict[str, str]],
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
) -> dict[str, str]:
    surface = ''.join(item['surface'] for item in items)
    reading = ''.join(item['reading'] for item in items)
    meta = _lookup_token(
        surface=surface,
        base_form=surface,
        reading=reading,
        immersion_lexicon=immersion_lexicon,
        vocab_lexicon=vocab_lexicon,
        manual_lexicon=manual_lexicon,
    )
    if meta is None:
        meta = {
            'reading': reading,
            'meaningVi': next(
                (item['meaningVi'] for item in items if item['meaningVi']),
                '',
            ),
            'meaningEn': next(
                (item['meaningEn'] for item in items if item['meaningEn']),
                '',
            ),
        }
    return {
        'surface': surface,
        'baseForm': surface,
        'reading': meta['reading'] or reading,
        'meaningVi': meta['meaningVi'],
        'meaningEn': meta['meaningEn'],
        'posMajor': items[0]['posMajor'],
        'posMinor': items[0]['posMinor'],
    }


def _merge_known_compounds(
    tokens: list[dict[str, str]],
    known_surfaces: set[str],
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
) -> list[dict[str, str]]:
    merged: list[dict[str, str]] = []
    index = 0
    while index < len(tokens):
        current = tokens[index]
        if current['surface'] in PUNCTUATION or current['posMajor'] == '助詞':
            merged.append(current)
            index += 1
            continue

        match_found = False
        upper_bound = min(len(tokens), index + 4)
        for end in range(upper_bound, index + 1, -1):
            segment = tokens[index:end]
            if len(segment) < 2:
                continue
            if any(
                item['surface'] in PUNCTUATION or item['posMajor'] == '助詞'
                for item in segment
            ):
                continue
            combined_surface = ''.join(item['surface'] for item in segment)
            if combined_surface not in known_surfaces:
                continue
            merged.append(
                _merge_token_chain(
                    segment,
                    immersion_lexicon=immersion_lexicon,
                    vocab_lexicon=vocab_lexicon,
                    manual_lexicon=manual_lexicon,
                )
            )
            index = end
            match_found = True
            break

        if not match_found:
            merged.append(current)
            index += 1
    return merged


def _should_merge_with_previous(
    previous: dict[str, str],
    current: dict[str, str],
) -> bool:
    if previous['surface'] in PUNCTUATION or current['surface'] in PUNCTUATION:
        return False
    if previous['posMajor'] == '助詞':
        return False
    if current['surface'] in NON_MERGE_SURFACES:
        return False
    if current['posMajor'] == '助詞':
        return False
    if current['posMajor'] == '助動詞':
        return True
    if current['posMajor'] == '動詞' and current['posMinor'] in {'非自立', '接尾'}:
        return True
    if current['posMajor'] == '名詞' and current['posMinor'] == '接尾':
        return True
    if current['surface'] in MERGE_SUFFIX_SURFACES:
        return True
    return (
        len(current['surface']) <= 2
        and _is_kana_only(current['surface'])
        and not current['meaningVi']
        and not current['meaningEn']
        and current['posMajor'] != '助詞'
    )


def _merge_suffix_tokens(
    tokens: list[dict[str, str]],
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
) -> list[dict[str, str]]:
    if not tokens:
        return []
    merged: list[dict[str, str]] = [tokens[0]]
    for current in tokens[1:]:
        previous = merged[-1]
        if _should_merge_with_previous(previous, current):
            merged[-1] = _merge_token_chain(
                [previous, current],
                immersion_lexicon=immersion_lexicon,
                vocab_lexicon=vocab_lexicon,
                manual_lexicon=manual_lexicon,
            )
            continue
        merged.append(current)
    return merged


def _paragraph_tokens(
    sentence: str,
    tokenizer: Tokenizer,
    immersion_lexicon: dict[str, dict[str, str]],
    vocab_lexicon: dict[str, dict[str, str]],
    manual_lexicon: dict[str, dict[str, str]],
    known_surfaces: set[str],
    unknown_counter: Counter[str],
) -> list[dict[str, str]]:
    tokens = _raw_tokens(
        sentence=sentence,
        tokenizer=tokenizer,
        immersion_lexicon=immersion_lexicon,
        vocab_lexicon=vocab_lexicon,
        manual_lexicon=manual_lexicon,
    )
    tokens = _merge_known_compounds(
        tokens,
        known_surfaces=known_surfaces,
        immersion_lexicon=immersion_lexicon,
        vocab_lexicon=vocab_lexicon,
        manual_lexicon=manual_lexicon,
    )
    tokens = _merge_suffix_tokens(
        tokens,
        immersion_lexicon=immersion_lexicon,
        vocab_lexicon=vocab_lexicon,
        manual_lexicon=manual_lexicon,
    )

    output: list[dict[str, str]] = []
    for token in tokens:
        meta = _token_meta(
            surface=token['surface'],
            base_form=token['baseForm'],
            reading=token['reading'],
            immersion_lexicon=immersion_lexicon,
            vocab_lexicon=vocab_lexicon,
            manual_lexicon=manual_lexicon,
        )
        if not meta['reading']:
            meta['reading'] = token['reading']
        if not meta['meaningVi']:
            meta['meaningVi'] = token.get('meaningVi', '')
        if not meta['meaningEn']:
            meta['meaningEn'] = token.get('meaningEn', '')
        if token['surface'] in PUNCTUATION:
            meta['reading'] = ''
        elif (
            not meta['meaningVi']
            and not meta['meaningEn']
            and (
                token['surface'] in NON_MERGE_SURFACES
                or token['surface'] in EMPTY_READING_SURFACES
                or (
                    len(token['surface']) <= 2
                    and _is_kana_only(token['surface'])
                )
            )
        ):
            meta['reading'] = ''
        if (
            not meta['meaningVi']
            and not meta['meaningEn']
            and token['surface'] not in PUNCTUATION
        ):
            unknown_counter[token['baseForm']] += 1
        output.append(
            {
                'surface': token['surface'],
                'reading': meta['reading'],
                'meaningVi': meta['meaningVi'],
                'meaningEn': meta['meaningEn'],
            }
        )
    return output


def _load_theme_ids() -> set[int]:
    payload = _read_json(THEME_MAP_PATH)
    lessons = payload['levels']['N3']['lessons']
    return {int(item['lessonId']) for item in lessons}


def generate() -> dict[str, object]:
    tokenizer = Tokenizer()
    immersion_lexicon = _load_immersion_lexicon()
    vocab_lexicon = _load_vocab_lexicon()
    manual_lexicon = _build_manual_lexicon()
    known_surfaces = _collect_known_surfaces(
        immersion_lexicon=immersion_lexicon,
        vocab_lexicon=vocab_lexicon,
        manual_lexicon=manual_lexicon,
    )
    expected_ids = _load_theme_ids()
    unknown_counter: Counter[str] = Counter()
    written_files: list[str] = []

    lesson_ids = {int(item['lessonId']) for item in LESSON_ARTICLES}
    if lesson_ids != expected_ids:
        missing = sorted(expected_ids - lesson_ids)
        extra = sorted(lesson_ids - expected_ids)
        raise SystemExit(
            f'Lesson coverage mismatch. missing={missing} extra={extra}',
        )

    for article in LESSON_ARTICLES:
        lesson_id = int(article['lessonId'])
        payload = {
            'id': f'n3-lesson-{lesson_id:02d}',
            'title': article['title'],
            'titleFurigana': _title_furigana(article['title'], tokenizer),
            'level': TARGET_LEVEL,
            'source': SOURCE_LABEL,
            'publishedAt': PUBLISHED_AT,
            'translation': article['translation'],
            'paragraphs': [
                _paragraph_tokens(
                    sentence=sentence,
                    tokenizer=tokenizer,
                    immersion_lexicon=immersion_lexicon,
                    vocab_lexicon=vocab_lexicon,
                    manual_lexicon=manual_lexicon,
                    known_surfaces=known_surfaces,
                    unknown_counter=unknown_counter,
                )
                for sentence in article['paragraphs']
            ],
        }
        output_path = OUTPUT_ROOT / f'lesson_{lesson_id:02d}.json'
        _write_json(output_path, payload)
        written_files.append(str(output_path.relative_to(ROOT)).replace('\\', '/'))

    return {
        'written': len(written_files),
        'files': written_files,
        'unknownBaseForms': unknown_counter.most_common(60),
    }


def main() -> int:
    report = generate()
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
