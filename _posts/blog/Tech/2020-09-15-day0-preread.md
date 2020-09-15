---
layout: post
title:  "Knock Knock! Deep Learning / Day 0 / 導讀"
categories: Blog Tech AI
tags: ["AI", "Deep Learning", "Knock Knock! Deep Learning"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

本系列文《Knock Knock! Deep Learning》旨在以淺顯易懂的文字，嵌入深度學習的概念與自身在史丹佛大學修讀碩士期間的學習心得，融合知識與故事性，成為無論何時何地都不吝於點開的技術分享文。

<!--more-->
---
## 什麼是深度學習？

深度學習（Deep Learning）為機器學習（Machine Learning）的一種方法，在 AI 界風行多年，支撐了無數知名專案，如 Google 的機器翻譯及擊敗各路頂尖棋手的圍棋 AI AlphaGo。剩下的自己讀系列文。

## 那麼會探討哪些技術？是否會不夠扎實？

本系列文會分為以下幾個部分：

1. Deep Learning 簡介
2. 必備實作知識與工具
3. PyTorch 簡介
4. DL x NLP（自然語言處理）
5. DL x CV（機器視覺）
6. DL x RL（強化學習）
7. DL 的資源競爭
8. 結語與學習資源

前期偏概念和實作入門，是扎好基本功必須，故事性較少；後期偏應用，有許多實例與故事分享。

論扎實性，必然是遠遠不及大師撰寫的書及教授的課。但如果目標是這般扎實，建議直接去天瓏找書，或是 Coursera 修課吧。《Knock Knock! Deep Learning》的技術內容會參考史丹佛大學相關課程的課綱及筆記、學術界發表的 paper、知名及個人的 project 經驗來進行分享，讀完後應能掌握深度學習發展的概貌，也能對實際開發自己的深度學習 project 有實作上的概念。

## 深度學習的技術文這麼多，為什麼要看這個系列？

網路上深度學習相關的技術文很多，但多半零散無連貫性，適合剛好需要補足某個知識碎片的學習者閱讀。至於深度學習相關的書也很多，但內容完整的多半由大師級人物撰寫，雖然內容嚴謹且帶有深度，但知識量過於龐大的情況下，到中期難免疲於掌握學習重點。

《Knock Knock! Deep Learning》的取向較為不同，分享的知識難以向大師級教科書並駕齊驅，但以學生的角度出發撰寫，將內容精簡至必備知識，因此作為概念性入門堪稱有力；文中會帶入許多故事性的敘述，含括筆者在史丹佛大學修讀碩士時期的一些學習心得，以及深度學習發展相關的故事。是個可以用閱讀故事的期待打開，並帶著對深度學習技術的概念理解闔上的系列文。

## 需要哪些預備知識

- Python 或其他程式語言概念
    - [Numpy](https://github.com/numpy/numpy)，一個方便進行向量 / 矩陣運算的 library
- Linear Algebra（線性代數）
    - 基本矩陣運算
- Calculus（微積分）
    - 微分知識比較重要，知道 $\frac{d}{dx}f(x)$ 的意義
    - 特別是 Matrix Calculus（矩陣微積分），但這可以邊讀邊學
- Probability（機率）
    - 條件機率跟貝氏定理較為重要，也可以邊讀邊學

不需要特地去重上一堂課，可以找些簡單的教學影片或文章複習一下就好。有直覺就能讀下去！

這邊有一些比較完整的英文筆記，可以事先閱讀，或是讀到一半覺得不行了需要釐清概念：

- Numpy
    - [Python Numpy Tutorial (with Jupyter and Colab)](https://cs231n.github.io/python-numpy-tutorial/)
- Calculus
    - [Review of differential calculus theory](http://web.stanford.edu/class/cs224n/readings/review-differential-calculus.pdf)
- Linear Algebra & Matrix Calculus
    - [Linear Algebra Review and Reference](http://cs229.stanford.edu/summer2020/cs229-linalg.pdf)
- Matrix calculus in Deep Learning
    - [Derivatives, Backpropagation, and Vectorization](http://cs231n.stanford.edu/handouts/derivatives.pdf)
    - [Computing Neural Network Gradients](http://web.stanford.edu/class/cs224n/readings/gradient-notes.pdf)
    - [Review of Probability Theory](http://cs229.stanford.edu/summer2020/cs229-prob.pdf)

## 還有哪些需要注意的嗎？

文章的架構大致為引言、主內容、Checkpoint、參考資料、延伸閱讀，後三者可有可無。歡迎利用 Checkpoint 來自我檢驗是否理解文中的內容了，參考資料深入探究不懂的地方，以及延伸閱讀來拓展知識。

參考資料和延伸閱讀，寫得真的很棒的資料，前面會加 👍，有興趣的人可以點連結閱讀。

另外，文中的部分專業名詞會用 English，就不翻成中文了。有些翻成中文很彆扭的詞我也會用英文，上面有示範 paper 和 project。反正你們以後查資料也應該要用英文，何必浪費時間再翻譯一次。

## Code 連結

原始碼都放在 GitHub：[pyliaorachel/knock-knock-deep-learning](https://github.com/pyliaorachel/knock-knock-deep-learning)。
