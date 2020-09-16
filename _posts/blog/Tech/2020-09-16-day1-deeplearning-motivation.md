---
layout: post
title:  "Knock Knock! Deep Learning / Day 1 / Deep Learning 簡介 / 從人腦啟發的 Deep Learning"
categories: Blog Tech AI
tags: ["AI", "Deep Learning", "Knock Knock! Deep Learning"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

Deep Learning（深度學習）的本體架構稱作 Neural Network（神經網絡），而 Neural Network 內的激活、資訊傳遞等等運作則啟發自人體的神經系統。讓我們簡單從人體的神經元了解 Neural Network 的運作以及 Deep Learning 的概念吧。

<!--more-->

## 從神經元到 Perceptron

![neuron](https://i.imgur.com/1sF0k8F.png)
*—— 神經元的構造。每門 Deep Learning 的課都會出現這種圖！[1]*

相信大家國中的時候都認識過人體的神經系統。假設我們現在要判斷一個人是男是女。我們的眼睛、耳朵等等受器會將接收到的訊息，例如這個人的五官輪廓、聲音高低、身高體重等等，藉著神經系統傳遞到大腦，大腦便會得出是男是女的預測。讓電腦學會接收訊息並判斷預測，即是人工智慧的終極目的。

神經系統的基本元件，意即**神經元（Neuron）**，構造如圖。感知訊息從上一個神經元經由**突觸**傳進來，再由**樹突**整合後傳遞至**細胞體**。若細胞體形成**動作電位**，則會將訊息藉由**軸突**傳遞出去，進入下個神經元 [2]。好的這邊看過就能忘了，我最討厭生物。

而電腦科學家有了這麼一個想法：仿造神經元，再將之串連再一起，形成**神經網絡（Neural Network）**。這個早在 1957 年即被發明的人工神經元，稱為 **Perceptron（感知器）**，也是而後 Neural Network 與 Deep Learning 的開端。

![perceptron](https://i.imgur.com/F5Sxsfg.jpg)
*—— Perceptron 的構造。[3]*

一開頭就這麼多數學，別被嚇到了，其實很簡單。

從最左邊接收訊息，經由 Perceptron 的處理，得出最右邊的小結論。為什麼叫做小結論，因為之後會提到的 Neural Network 中，各個 Perceptron 會把小結論傳到下一層的 Perceptron，而無數 Perceptron 會討論出一個總結，作為 Neural Network 的最終預測。

讓我們藉由前面預測男女的例子來一步步了解 Perceptron 的構造，以及大致對應神經元的類比：
- Inputs（接收突觸傳進來的訊息） 
    - 接收到的訊息，例如人體的特徵。$x_1$ 可能是五官輪廓、$x_2$ 可能是聲音高低等等，共有 $m$ 個特徵幫助預測。
- Weights（神經元的「設定」）
    - 權重，可以想像為每個特徵對預測的幫助程度。例如若 $w_1$ 比 $w_2$ 大，那麼這個 Perceptron 在預測時認為 $x_1$ 五官輪廓比 $x_2$ 聲音高低更能分辨男女，便分配高分給 $x_1$。
- Summation and Bias（樹突整合訊息）
    - 各個特徵的加權總分為 $w_1 x_1 + w_2 x_2 + ... + w_m x_m = \sum^m_{i=1} w_i x_i$。Bias 是男女判斷標準，預測結果是拿分數對比標準。
- Activation（細胞體激發）
    - 根據分數和標準判斷結果的函數。例如分數高於標準為女、低於標準為男，所以有兩種預測結果 1 和 0。這個函式畫出來像個階梯，被稱為 step function。如果把式子中的 $b$ 往右邊移：$\sum wx \ge -b$ 和 $\sum wx < -b$ 則比較容易看出是在跟標準比較。$b$ 的正負不要緊，因為是要學習的值，他會自己做調整。
- Output（將訊息傳至軸突，以傳遞給下個神經元）
    - 就是 activation 出來的預測結果了。

Weights 和 bias 為此 Perceptron 的 **parameter（參數）**，意即他們的值可藉由訓練調整讓 Perceptron 預測更準確，類似他的設定。至於怎麼調整這些參數以達到準確的預測結果，就是 Deep Learning 的精髓。

## 從 Perceptron 到 Neural Network

單單一個仿造神經元的 Perceptron，你可能想說他能做的不多。事實真是如此。Perceptron 只能用來做 **binary linear classification（二元線性分類）**，也就是為什麼我們需要更複雜的 Neural Network。

先說什麼是二元線性分類：
![binary linear classification](https://i.imgur.com/jG0R90a.png)
*—— 貓與非貓線性分類。[4]*

二元即兩種結果，例如男或女、貓或非貓。線性有比較深入的數學定義，但簡單來說就是在二維平面能畫一條線分開兩組 data point，三維空間能用一塊平面切出兩組 data point，以此往高維類推。圖中藍色 data point 是貓類，紅色 data point 是非貓類，因為我們能用一條線乾淨分開兩類，線性分類在這個 dataset 是成立的。真幸運。

但如果今天我們 data 長這樣：
![binary linear classification fails](https://i.imgur.com/umfdG4K.png)

懸賞我今天剛做的起司蛋糕你找不到任何一條線可以切開貓與非貓。Perceptron 是沒辦法學會分類這組 data 的，因為他就只會拿一條直線在那邊擺來擺去。更遺憾的是，真實世界的 data 基本上都跟這組一樣，沒辦法單靠線性分類。

拿直線想分類這組不行，但彎的線呢？沒問題，這就是 **non-linearity（非線性）**。想分類更多種類的話，又該如何？那就畫更多條線吧，也就是做更多的 binary classification，合在一起成為 **multiclass classification（多元分類）**。從 Perceptron 到 Neural Network，便是在加入這些複雜度，讓能力更強大，世界更寬廣。

![neural network](https://i.imgur.com/uncJ51X.jpg)
*—— 一個簡單的 Neural Network。[5]*

圖中的圓圈類似於一個 Perceptron，稱為 Neuron，不同的是 activation 這一步不侷限於 step function，而可以是很多其他 non-linear function 讓 network 學習彎曲的分類線。

而 Neural Network 通常是分層的。Input 輸入第一層後，經過 neuron 們的運轉產出第一層的小結論傳給第二層，以此傳到最後一層得到總結。分層的概念也可以類比到人類的感知過程：以判斷一張圖片是否為貓咪為例，前面幾層建立在比較粗糙的訊息上，例如某個地方的顏色、稜角，而後面幾層建立在前面的基礎，有比較高階的概念，例如貓的五官、體型等等，以此作最後判斷就會很準確了。

Neural Network 輸入叫 input layer、輸出叫 output layer，中間各層稱為 **hidden layer**。只有一個 hidden layer 的稱之為 Shallow Neural Network，多個 hidden layer 的則為常聽到的 Deep Neural Network。利用 Deep Neural Network 做學習就是 Deep Learning 啦。越多層的 hidden layer 可以習得越複雜的概念，但學習能力受限於硬體資源，沒辦法無限上綱。

Neural Network 根據 data 的特性有很多變形，以後會慢慢介紹。

## Neural Network 不同的學習方式

最後來簡單介紹一下 Neural Network 有哪些學習方式。

#### Supervised Learning

監督式學習。

> 想像一個小孩看著蘋果喊 banana，媽媽會說 no no no，這是 apple。小孩一聽，大腦神經啟動，將這個錯誤回傳給剛剛負責判斷的神經元說，給我調整改進。下次小孩就知道紅紅的圓圓的是 apple 了。

「監督」在於媽媽有給他「正確答案」，讓學習有效率。訓練的 dataset 如果每筆 data 有 label，也就是答案，就可以透過 supervised learning 學習。例如判斷貓的種類，dataset 每張圖片會搭配該貓的種類當 label，讓 network 進行 supervised learning。

#### Unsupervised Learning

非監督式學習。

> 想像一個小孩，媽媽很懶惰不告訴他怎麼分辨水果和非水果。但小孩可以透過一些資訊，例如飯後會吃的、或酸或甜、中間可能有籽等等，自行學會分辨一個東西是不是水果。

少了「正確答案」，雖然缺乏效率但仍然能夠進行學習。訓練的 dataset 如果 data 沒有 label，就只能透過 unsupervised learning 學習。例如有一堆新聞，沒有人有時間幫忙標註是哪一類的新聞，但可以根據新聞內容等等，以 unsupervised learning 學會做 clustering（聚類分析），知道哪些新聞是相關的。

#### Semi-Supervised Learning

半監督式學習。

> 想像一個學生在學英文，判斷副詞。英文老師很忙，不可能每次他碰到一個單字，英文老師都要告訴他是不是副詞。但英文老師會說 actually 是副詞，randomly 也是副詞，幾次之後學生就知道後面有 ly 的大概就是副詞。

非監督是學習通常是因為取得 label 不易，成本太高，出此下策。而半監督式學習能取得平衡，藉由比 supervised learning 少量許多的 label 進行比 unsupervised learning 更為有效率的學習。

#### Reinforcement Learning

強化學習。

> 想像一個小孩，偷了媽媽的零用錢而被毒打一頓。為了不要再被打，小孩下次偷媽媽零用錢的意願就會降低。之後小孩幫忙洗碗，媽媽給了他一點零用錢。為了能賺零用錢，小孩下次會更願意洗碗。

這種學習模式並沒有標準答案，而是實際做了之後，根據得到的回饋修正自己之後行動的判斷。常見應用在機器人學習動作、玩遊戲等等，知名的 AlphaGo 就是這樣學會圍棋的。

## Checkpoint

- 一個簡單的 Perceptron 有哪些基本步驟？
- Perceptron 為何能力受限？
- Bias 的作用為何？
- Neural Network 為何需要分層？
- Neural Network 有哪些不同學習方式？他們的主要差別為何？

## 參考資料

1. [Wikipedia - 神經元](https://zh.wikipedia.org/wiki/%E7%A5%9E%E7%B6%93%E5%85%83)
2. [腦力通訊 - 腦力基本：神經元的訊息傳遞](https://www.brainworksrnd.com/mws/brainworks/BrainWorks_5_201109_Web.pdf)
3. [Introducing Deep Learning and Neural Networks — Deep Learning for Rookies (1)](https://towardsdatascience.com/introducing-deep-learning-and-neural-networks-deep-learning-for-rookies-1-bd68f9cf5883)
4. [Wikipedia - Perceptron](https://en.wikipedia.org/wiki/Perceptron#/media/File:Perceptron_example.svg)
5. [What is an artificial neural network? Here’s everything you need to know](https://www.digitaltrends.com/cool-tech/what-is-an-artificial-neural-network/)
6. [Types of Machine Learning Algorithms You Should Know](https://towardsdatascience.com/types-of-machine-learning-algorithms-you-should-know-953a08248861)
