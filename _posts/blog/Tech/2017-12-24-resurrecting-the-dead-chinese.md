---
layout: post
title:  "穿越時空的偉人：用PyTorch重現偉人們的神經網絡"
categories: Blog Tech NLP
tags: ["Python", "PyTorch", "Machine Learning", "Deep Learning", "Neural Network", "Natural Language Processing", "PyLadies"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

繼上一篇[深度學習新手村：PyTorch 入門](https://medium.com/pyladies-taiwan/%E6%B7%B1%E5%BA%A6%E5%AD%B8%E7%BF%92%E6%96%B0%E6%89%8B%E6%9D%91-pytorch%E5%85%A5%E9%96%80-511df3c1c025)後，這一次要來做一點進階應用。筆者今年十一月參與在香港舉辦的 PyCon，其中 Aditthya Ramakrishnan 講者演講的主題 [Resurrecting the dead with deep learning](https://www.youtube.com/watch?v=r8H1cZjCfIA) 以 RNN 模型訓練林肯 (Lincoln) 及希特勒 (Hitler)的混合語料庫，創造出講話非常矛盾的林克勒 (Lincler)。

以此演講為基礎，這次收集並混合了《毛澤東語錄》和《論語》，嘗試模擬出一個「孔澤東」，藉此一窺 RNN 在中文文本生成 (Chinese text generation) 的應用。

<!--more-->
---

_* 請注意，此篇 PyTorch 建立在 Python3 之上，並以 MacOSX 為環境。_  
_* 預備知識：基礎神經網絡概念_

人工神經網絡 (artificial neural network) 隨其不同的架構有著不同的應用，其中__循環神經網絡 (recurrent neural network, RNN)__ 能捕捉__時間__關係，在自然語言處理領域有著廣泛的應用。本文將以簡介 RNN 及其優勢開頭，再進入主專案介紹，按照步驟講解如何以 PyTorch 進行中文文本生成，將歷史人物玩弄於股掌間，打造出一個荒謬的偉人結合體，一同維護世界和平。

## RNN （相當簡單的）介紹

還記得 N 年前的 Google 翻譯嗎？翻譯的結果除了相當生硬不精確，還經常被眾人在茶餘飯後拿來揶揄，令人鼻酸。但 Google 在 2016 年將其打掉重練，推出了一個[新系統](https://research.google.com/pubs/pub45610.html)，有嘗試過的應該都會驚艷於它的成長，流暢度與精確度都提升許多，一種小孩長大的感動。這個新系統即是建立在一種稱之為__序列到序列 (sequence to sequence, seq2seq)__ 的模型之上，而此種模型便是以 RNN 為基礎。

__循環神經網絡 (RNN)__ 旨在建立一種__記憶__，也就是為了不將先前輸出的結果遺忘，將之累積成某種隱藏狀態 (hidden state)，並與當前輸入結合，一起產出結果，再進一步傳遞下去。也因此，RNN 適合接收序列 (sequence) 作為輸入並輸出序列，提供了序列生成一個簡潔的模型。

![RNN](https://karpathy.github.io/assets/rnn/diags.jpeg)

最原始的 RNN 有其限制，學者為了突破這些限制而發展出了一些變形，其中廣泛應用的__長短期記憶 (Long Short-Term Memory, LSTM)__ 即是為了解決 [vanishing gradient](http://harinisuresh.com/2016/10/09/lstms/) 問題而提出，也是我們接下來實作中應用的模型。

礙於篇（本）幅（人）有（太）限（懶），沒辦法完整解釋這些模型背後的原理，但想要應用或覺得生命有限的話，不妨就將之視為黑盒子。若有興趣進一步了解，可以膜拜一下[這篇詳盡介紹](https://karpathy.github.io/2015/05/21/rnn-effectiveness/)和[這篇](http://colah.github.io/posts/2015-08-Understanding-LSTMs/)。

## 以 PyTorch 重現偉人們的神經網絡

今年十一月的 PyCon HK 的其中一場演講 [Resurrecting the dead with deep learning](https://www.youtube.com/watch?v=r8H1cZjCfIA) 將林肯 (Lincoln) 及希特勒 (Hitler) 的語料結合，進行訓練後能打造一個自打嘴巴的文本生成系統，稱之為林克勒 (Lincler)。此次專案則是仿造其精髓，但將文本改成中文，並以 PyTorch 實現（原專案以 Keras 實現）。

如果跟筆者一樣也是 PyTorch 新手，就一起來邊玩邊練習吧！

GitHub 專案原始碼：[pyliaorachel/resurrecting-the-dead-chinese](https://github.com/pyliaorachel/resurrecting-the-dead-chinese)

_* 以下會簡單提到很多深度學習的概念，皆當作補充即可。欲深入了解可參考提供的連結。_  

#### 語料準備

這次準備的兩個歷史人物的語料，一是毛澤東的《毛澤東語錄》，一是孔子與其弟子的《論語》。原本是想找蔣中正的《總統蔣公思想言論總集》，但找不到公開的語料，真是可惜。

資料清理方面，只將原始語料中的一些非人物言論的註解刪除後，一句句排好。另外由於《論語》原文是文言文，所以挑了白話文翻譯，避免結果文白混雜。繁簡轉換方面，原始語料皆為簡體中文，所以不需進行繁簡轉換；如果想自己準備語料進行訓練，可以使用 [OpenCC](https://github.com/BYVoid/OpenCC) 將繁簡統一。

以上清理都相當簡單，只透過文字編輯器的 find & replace 就可以完成（很懶惰我知道）。混合語料則簡單寫了 [python script](https://github.com/pyliaorachel/resurrecting-the-dead-chinese/blob/master/src/corpus/mix.py) 把兩個檔案中的句子隨機混排。

原始和清理後的語料都在 [corpus 檔案夾](https://github.com/pyliaorachel/resurrecting-the-dead-chinese/tree/master/corpus)底下。

#### 建立模型

###### 輸入/輸出資料

簡單複習一下監督式學習。一般監督式學習的訓練過程中，每一筆資料都需要包成`(input, target)`的形式；`input` 進入模型後會得到一個預測 `output`，而這個 `output` 和我們的正解 `target` 之間會有一個落差 (error)。為了讓落差減小，我們需要慢慢調整模型中參數，最後達到準確的預測，這個就是模型的學習過程。

這次的任務中，我們讓 `input` 為一序列的中文字，`target` 則是此序列後的下一個中文字，兩者皆從語料中準備即可。這邊簡單起見，直接以中文字為單位而不再做中文分詞，如果想以詞為單位可以使用[結巴分詞](https://github.com/fxsjy/jieba)。

假設輸入序列長度為 5，則`这正是我们弟子们学不到的。`會被包成：

```python
# (input, target)
('这正是我们', '弟')
('正是我们弟', '子')
('是我们弟子', '们')
('我们弟子们', '学')
('们弟子们学', '不')
('弟子们学不', '到')
('子们学不到', '的')
('们学不到的', '。')
```

另外就是，一筆一筆資料輸入後即更新權重，會讓訓練變得很慢。多筆資料包在一起一起訓練，可以加速訓練，此方法稱之為 [mini-batch](https://machinelearningmastery.com/gentle-introduction-mini-batch-gradient-descent-configure-batch-size/)。那為什麼不所有資料包成一筆呢？因為這樣一來收斂結果會比較差，而且每次有新資料進來就要整包重新訓練一次；mini-batch 算是一個平衡點，不過 batch size 要多大就需要調校一番。

[`src/train/data.py`](https://github.com/pyliaorachel/resurrecting-the-dead-chinese/blob/master/src/train/data.py)裡有兩個 function 負責準備好模型可以接受的 input：

`parse_corpus`

```python
# 語料裡所有出現過的中文字，此為 vocabulary
chars = sorted(list(set(raw_text)))

# 給每個中文字一個對應的 index，比較好做接下來的任務
char_to_int = dict((c, i) for i, c in enumerate(chars))
int_to_char = dict((i, c) for i, c in enumerate(chars))

# 共生成 N 個 input-target pair，每個 input 長度為 seq_length，target 長度為 1
n_chars = len(raw_text)
dataX = [] # N x seq_length
dataY = [] # N x 1
for i in range(0, n_chars - seq_length):
    seq_in = raw_text[i:i + seq_length]
    seq_out = raw_text[i + seq_length]
    dataX.append([char_to_int[char] for char in seq_in])
    dataY.append(char_to_int[seq_out])
```

`format_data`

```python
# 採用 mini-batch，尾巴不足 batch_size 的直接捨棄
n_patterns = len(dataY)
n_patterns = n_patterns - n_patterns % batch_size
X = dataX[:n_patterns]
Y = dataY[:n_patterns]

# 把 array 每 batch_size 筆資料包成一組，並包成 tensor
X = np.array(X)
_, seq_length = X.shape
X = X.reshape(-1, batch_size, seq_length)

X = torch.LongTensor(X)

Y = np.array(Y)
Y = Y.reshape(-1, batch_size)

Y = torch.LongTensor(Y)
```

###### LSTM 模型

PyTorch 建立 NN 的話需要繼承 `nn.Module`，並 override `__init__` 和 `forward` 兩個 method。[`src/train/model.py`](https://github.com/pyliaorachel/resurrecting-the-dead-chinese/blob/master/src/train/model.py)定義了我們的 NN 架構。

值得一提的是，輸入的每個中文字都會先轉成 embedding vector，也就是用一個 vector 來表示各個中文字，這在自然語言處理任務中幾乎是必要的處理。[這篇文章](https://towardsdatascience.com/deep-learning-4-embedding-layers-f9a02d55ac12)對 embedding vector 有一個很好的介紹，不過簡單來說，因為字詞是類別資料 (categorical data)，用 integer 這種有順序的格式來表示並不恰當，因此轉成 vector 形式，藉由 vector 之間的空間關係來捕捉字詞之間的關聯性。

Dropout 則是常見的防止__過擬合 (overfitting)__ 的手段，也就是在訓練過程中三不五時捨棄/忽略一些神經元，來減弱他們彼此間的聯合適應性 (co-adaptation)。不能說太多，不然要變 DLadies (DeepLearningLadies) 了，詳可參考[此篇](https://medium.com/@amarbudhiraja/https-medium-com-amarbudhiraja-learning-less-to-learn-better-dropout-in-deep-machine-learning-74334da4bfc5)。

這邊設計的架構總共有以下幾層：

1. Embedding layer: 將以 integer 表示的 character index 轉成 embedding vector
2. LSTM layer + dropout: 將輸入序列通過 LSTM 編碼成 hidden state，並加一層 dropout 防止 overfitting
3. Fully-connected layer: 把 hidden state 線性轉換成一長度為 length of vocabulary 的 output layer，其中數值當作每個字的得分，得分越高越有機會是下一個預測結果

```python
class Net(nn.Module):
    def __init__(self, n_vocab, embedding_dim, hidden_dim, dropout=0.2):
        super(Net, self).__init__()

        self.embedding_dim = embedding_dim
        self.hidden_dim = hidden_dim

        # nn.Embedding 可以幫我們建立好字典中每個字對應的 vector
        self.embeddings = nn.Embedding(n_vocab, embedding_dim)

        # LSTM layer，形狀為 (input_size, hidden_size, ...)
        self.lstm = nn.LSTM(embedding_dim, hidden_dim, dropout=dropout)

        # Fully-connected layer，把 hidden state 線性轉換成 output
        self.hidden2out = nn.Linear(hidden_dim, n_vocab)

    def forward(self, seq_in):
        # LSTM 接受的 input 形狀為 (timesteps, batch, features)，即 (seq_length, batch_size, embedding_dim)
        # 所以先把形狀為 (batch_size, seq_length) 的 input 轉置後，再把每個 value (char index) 轉成 embedding vector
        embeddings = self.embeddings(seq_in.t())

        # LSTM 層的 output (lstm_out) 有每個 timestep 出來的結果（也就是每個字進去都會輸出一個 hidden state）
        # 這邊我們取最後一層的結果，即最近一次的結果，來預測下一個字
        lstm_out, _ = self.lstm(embeddings)
        ht = lstm_out[-1]

        # 線性轉換至 output
        out = self.hidden2out(ht)

        return out
```

#### 訓練模型

資料和模型都有了之後，就可以來訓練了。[`src/train/train.py`](https://github.com/pyliaorachel/resurrecting-the-dead-chinese/blob/master/src/train/train.py)負責載入資料、訓練、及儲存結果。

Optimizer 選用 [Adam](https://machinelearningmastery.com/adam-optimization-algorithm-for-deep-learning/)，亦可調用其他如 SGD、RMSprop 等 [optimizer](http://pytorch.org/docs/master/optim.html)。

Loss function 採用的是 classification 任務常見的 cross-entropy。預測的 `output` 會是長度為 number of classes 的 tensor，`target` 則是正確 class label，而 PyTorch 裡的 `cross_entropy` 會負責把預測結果做一次 log softmax 後，計算跟目標之間的 negative log likelihood，因此預測結果不需要先做 softmax 或 log softmax。需要特別注意的是，不同的深度學習框架會有不同的參數形狀要求，例如 Keras 會需要你把 target 轉成 one-hot encoding 等。

```python
def train(model, optimizer, epoch, data, log_interval):
    # 設一下 flag
    model.train()

    # Mini-batch 訓練 
    for batch_i, (seq_in, target) in enumerate(data):
        seq_in, target = Variable(seq_in), Variable(target)
        optimizer.zero_grad()

        output = model(seq_in)                      # 取得預測
        loss = F.cross_entropy(output, target)      # 計算 loss
        loss.backward()                             # Backpropagation
        optimizer.step()                            # 更新參數

        # Log 訓練進度
        if batch_i % log_interval == 0:
            print('Train epoch: {} ({:2.0f}%)\tLoss: {:.6f}'.format(epoch, 100. * batch_i / len(data), loss.data[0]))
```

```python
# 載入資料，建立模型
train_data, dataX, dataY, char_to_int, int_to_char, chars = load_data(args.corpus, seq_length=args.seq_length, batch_size=args.batch_size)
model = Net(len(chars), args.embedding_dim, args.hidden_dim, dropout=args.dropout)
optimizer = torch.optim.Adam(model.parameters(), lr=args.lr)

# 訓練
for epoch in range(args.epochs):
    train(model, optimizer, epoch, train_data, log_interval=args.log_interval)

    # 為避免不可抗力因素造成訓練中斷，或訓練太久失去耐心，每幾個 epoch 就儲存一次模型
    if (epoch + 1) % args.save_interval == 0:
        model.eval()
        torch.save(model, args.output)
```

#### 產出結果

訓練好模型後，接下來就來試試看生成文本。方法是，從語料中隨機選一個序列作為開端，輸入模型得到下一個字後，將之附在序列末，並將原序列頭一個字移除，以此新序列繼續進行預測，直到句子結束。[`src/generate_text/gen.py`](https://github.com/pyliaorachel/resurrecting-the-dead-chinese/blob/master/src/generate_text/gen.py)負責文本生成。

但模型給出的 output 是一個長度為 length of vocabulary 的分數 vector，要怎麼挑選下一個字呢？第一直覺是，選分數最高的，即是我寫的[第一個版本](https://github.com/pyliaorachel/resurrecting-the-dead-chinese/blob/f0cff5a5a100957a42f0a24c3e7b1b25a0a75d86/src/generate_text/gen.py)。但生成的結果很悲劇（十句）：

```
数人民的政策，而不是为了这个人民的，是一个人民的工作，我们的工作是一个人的一个具体的工作，我们的工作是一个人，这是一个人的时候，我们就要使他们在革命中国的人民主要关系，不是要经过这种情况，在社会主义制度和国家政治工作作风，不能用正确的方法去解决。这是一个人民的政策，而是在全国的领导机关，不是为着我们的民主主义，是一个革命的政策，而是在全国的人民主要的，是在革命的政治上，在一个人民内部的矛盾，是一个人民的工作，我们的工作是一个人的一个具体的工作，我们的工作是一个人，这是一个人口作为一个革命的政策，而是在全国的领导机关，不是为着我们的民主主义，是一个革命的政策，而是在全国的人民主要的，是在革命的政治上，在一个人民内部的矛盾，是一个人民的工作，我们的工作是一个人的一个具体的工作，我们的工作是一个人，这是一个人口作为一个革命的政策...
```

會發生一直重複的情況，而且產生不了句號，所以句子停不下來。大概是只要接近序列末的那幾個字相似，產出來的分數分佈也相似，因此分數最高的很可能都是同一個字。

為了避免這種事發生，第二個版本（也就是以下的版本）將分數 vector 轉成機率分佈，並依照此分佈挑選下一個字。例如 vocabulary 裡有三個字 `['你', '我', '他']`，而機率分佈是 `[0.8, 0.1, 0.1]`，則挑選十次之中，理想中會有 8 次挑 '你'，各 1 次挑 '我' 和 '他'，而非總是挑 '你' 了。

```python
# 隨機選擇一序列作為開端
start = np.random.randint(0, n_patterns - 1)
pattern = patterns[start]

# 共 n_sent 句子要生成
cnt = 0
while cnt < n_sent: 
    # 包一下 input
    seq_in = np.array(pattern)
    seq_in = seq_in.reshape(1, -1) # batch_size = 1

    seq_in = Variable(torch.LongTensor(seq_in))

    # 生成此序列下一個字
    pred = model(seq_in)
    pred = to_prob(F.softmax(pred).data[0].numpy()) # softmax 後轉成機率分佈
    char = np.random.choice(chars, p=pred)          # 依機率分佈選字
    char_idx = char_to_int[char]

    # 印出
    print(char, end='')

    # 將字附在原序列後並移除第一個字，作為下一個 input 序列
    pattern.append(char_idx)
    pattern = pattern[1:]

    # 若印出代表句子結尾的標點符號，則完成一個句子生成
    if is_end(char):
        # restart_seq 決定要不要重新挑選一個序列，或是完成一個完整段落
        if restart_seq:
            start = np.random.randint(0, n_patterns - 1)
            pattern = patterns[start]
            print()

        cnt += 1 
```

生成的結果有大幅度的改善，下面是一些結果（seqence length = 50, batch size = 32, embedding dimension = 256, hidden_dimension = 128, learning rate = 0.0001, dropout = 0.2, epoch = 30）：

```
中隐官爱好旧礼或节图。这就是不能吗？可会的中央。那些，然有军队的大距，而没有了解马克思列宁主义的关系，主要思想应当批评。不是仁人的政治条件事，在老师，没着保成的，为他们战争来是仅如的武子步，哪失败革命的。
```

```
君子了吗？人民为着恭敬，您是君子中《定理。还是只要都是恭敬否再进，他的政治是经到政令，不懂得到，节喜欢没有一天，用映思想的学四，可以做问。饭求宾任前有：可以花父母是君又在房子了上惭的台子，你孙三是右之、所厌夏，还能可能做的。孔应当用蓬得折的个过程教育，主张改变这样的方法，越争，善于和切母都是越无形的目而是学习的。但是其次一切包括战意端反对之间的情况本问作，与每中劳动起来凌望发动了。一切打通各所成熟派的互路线和城市、主观外界、谦傲诈和群众、生产活对之间不应出发，不被帝时。原区，都也既躬觉下拜律吧。不葆的社会。
```

```
做错向，谁要让好直地方他从哪里四个赤怕使人可以，不为着文副不‘实际的破想到就定人誉了。教蠢的人，而是无产阶级经验同就是非女。这些两条件事用，这一部物害就是具体地工作，一定拿致的光明扼中，都很斗争一面，艰难每一项一个没有生产的一类仅依的，群众中言，以次忧虑他的和目。我们党员和革命每项界上关党的作世界社会主义有利的新方面工作，我们是不从政发生的政策，只是总结最了。农村的领导敌人，而调得刻群众都在伟大的人民内部的态度。共产党员来作不断，才能极千多事经济的组织和别的领导。表现勇的看适干部门，这得都不好同的东西部组织，导演保证自之实行。这是一年社会主义者和表现和捣缺分子之的，才失放在这样的的工作，难找个人弹私，也是自然，不要抓的更紧的势力。中国的是由。这是次将而追军出发展，全将替命城市和迎。
```

雖說生成的句子看起來比較不鬼打牆了，也看得出學習到了一些完整的詞，例如「马克思列宁主义」、「共产党员」、「君子」等，不過離正確文法還有不小差距。但因為資源有限，我沒有進行調參，有興趣的人可以試試看能不能把模型訓練的更好。

分享一下演講裡 Lincler 的一些結果：

```
In 1918, I am the warfare. The struggle of civilization. The only answer to absolute liberty is the destruction of the nations.
```

```
In the wrong virtue of people, to control every point the intention of love is to demand the supremacy of the United States.
```

```
The British people will be sad with the progressing of the United States. Distrust the economy.
```

據說已經是篩選其中比較好的句子生成了。有興趣的可以聽聽看這場[演講](https://www.youtube.com/watch?v=r8H1cZjCfIA)（溫馨提醒：是印度腔喔）。

## 結語

Seq2seq 模型為文本生成提供了簡單有效的方法，也為自然語言處理界注入了更多可能性。此篇以《毛澤東語錄》和《論語》為語料，嘗試打造出矛盾的文本生成系統，雖說離可被理解的語言還有一大段差距，卻也不難看出 RNN 和 seq2seq 的潛力。此外，PyTorch 的實作相當好上手且簡單易懂，唯其剛剛崛起，網路上能找到的實例不如 TensorFlow 多，對新手來說挑戰頗多，期望未來社群發展能夠更健全囉。

## 參考資料

1. [PyCon HK 2017 - Resurrecting the dead with deep learning](https://www.youtube.com/watch?v=r8H1cZjCfIA)
2. [Google's Neural Machine Translation System: Bridging the Gap between Human and Machine Translation](https://research.google.com/pubs/pub45610.html)
3. [谷歌翻译背后的技术突破：序列到序列学习](https://www.zhinengl.com/2017/01/sequence-to-sequence-learning/)
4. [Vanishing Gradients & LSTMs](http://harinisuresh.com/2016/10/09/lstms/)
5. [The Unreasonable Effectiveness of Recurrent Neural Networks](https://karpathy.github.io/2015/05/21/rnn-effectiveness/)
6. [Understanding LSTM Networks](http://colah.github.io/posts/2015-08-Understanding-LSTMs/)
7. [A Gentle Introduction to Mini-Batch Gradient Descent and How to Configure Batch Size](https://machinelearningmastery.com/gentle-introduction-mini-batch-gradient-descent-configure-batch-size/)
8. [Deep Learning #4: Why You Need to Start Using Embedding Layers](https://towardsdatascience.com/deep-learning-4-embedding-layers-f9a02d55ac12)
9. [Dropout in (Deep) Machine learning](https://medium.com/@amarbudhiraja/https-medium-com-amarbudhiraja-learning-less-to-learn-better-dropout-in-deep-machine-learning-74334da4bfc5)
10. [Gentle Introduction to the Adam Optimization Algorithm for Deep Learning](https://machinelearningmastery.com/adam-optimization-algorithm-for-deep-learning/)