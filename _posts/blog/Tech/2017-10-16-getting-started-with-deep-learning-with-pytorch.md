---
layout: post
title:  "深度學習新手村：PyTorch入門"
categories: Blog Tech DeepLearning
tags: ["Python", "PyTorch", "Machine Learning", "Deep Learning", "Neural Network", "Computer Vision", "PyLadies"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

深度學習新手在從學校、網路、或書中習得基礎神經網絡知識後，手癢想建立專案體現深度學習的威力之前，得先決定要玩哪一套深度學習框架。[TensorFlow](https://www.tensorflow.org/) 無疑是近來相當火紅的一個，其由 Google 開源，近年來已建立龐大社群基礎。

但 2017 年初由 Facebook 開源的另一套建立在 [Torch](http://torch.ch/) 之上的深度學習框架 [PyTorch](http://pytorch.org/) 因其語法簡潔優雅、概念直觀和易上手的特性，甫推出便迅速走紅，儼然已成為瓜分深度學習市場的有力競爭者。藉由這樣的優勢，此篇將引領深度學習新手入門 PyTorch ，簡述其核心概念，並以深度學習領域的 Hello World! 專案 -- MNIST 手寫數字辨識為例，直接帶大家理解 PyTorch 如何打造模型及進行深度學習。

<!--more-->
---

_* 請注意，此篇 PyTorch 建立在 Python3 之上，並以 MacOSX 為環境。_  
_* 預備知識：基礎神經網絡 & 反向傳播算法（Backpropagation）概念_

[PyTorch](http://pytorch.org/) 為 Facebook 在 2017 年初開源的深度學習框架，其建立在 [Torch](http://torch.ch/) 之上，且標榜 Python First ，為量身替 Python 語言所打造，使用起來就跟寫一般 Python 專案沒兩樣，也能和其他 Python 套件無痛整合。PyTorch 的優勢在於其概念相當直觀且語法簡潔優雅，因此視為新手入門的一個好選項；再來其輕量架構讓模型得以快速訓練且有效運用資源 [1]。

網路上已有很多詳盡教學手把手帶你認識 PyTorch 的基本語法，例如[官方文件](http://pytorch.org/tutorials/)或[社群力量](https://github.com/rguthrie3/DeepLearningForNLPInPytorch/blob/master/Deep%20Learning%20for%20Natural%20Language%20Processing%20with%20Pytorch.ipynb)，這邊就只簡述概念，語法部分則藉由後面 MNIST 實作直接攻破。

## PyTorch 核心概念

首先，讓我們來抓住 PyTorch 精髓吧！

#### 基本元素：`Tensor`

一個 Tensor（張量）類似一個高維度向量，也是深度學習裡進行運算的基本元素。這裡比數學上的意義還要廣義，所以可以把它當成任意維度的資料向量。既然此文假設讀者已有基本神經網絡知識，那為什麼 Tensor 會是基本元素應該不難理解吧。

- [`torch.Tensor`](http://pytorch.org/docs/master/tensors.html#torch.Tensor)
    - 創建 Tensor，可包任意維度向量
- [`torch.randn`](http://pytorch.org/docs/master/torch.html#torch.randn)
    - 創建 Tensor，data 隨機
- `x1 + x2`
    - 兩個 Tensor 相加
- [`torch.cat`](http://pytorch.org/docs/master/torch.html#torch.cat)
    - 串聯（concatenate）Tensor
- [`x.view`](http://pytorch.org/docs/master/tensors.html#torch.Tensor.view)
    - 重塑（reshape）Tensor 維度

#### Computational Graph

Computational graph 讓你定義 data 要怎麼銜接組合才能取得 output、其中有哪些 parameter、有哪些 activation function 等等，總之你的 model 要運算導數（derivative）及梯度（gradient）需要的資訊都在裡頭。

[`torch.autograd`](http://pytorch.org/docs/master/autograd.html) 是一個幫你把跟微分有關的事都處理好的重要套件。

- [`autograd.Variable`](http://pytorch.org/docs/master/autograd.html#torch.autograd.Variable)
    - 上述基本元素 Tensor 其實只有告訴你裡頭的 data 和他的 shape，這些是不足夠整個 graph 運算 derivative 的。`autograd.Variable` 是打包 Tensor 和一些額外資訊的元件，例如 `z` 是 `x` 和 `y` 相加而成，那麼用 `autograd.Variable` 處理 `z` 能夠記錄這個__相加__的資訊，而非單純把 `x+y` 的__結果__記下；如此一來才能運算 derivative。
- [`x.backward`](http://pytorch.org/docs/master/autograd.html#torch.autograd.Variable.backward)
    - 從 `x` 開始實施 backpropagation 魔法
    - 被掃到的 variable `y` 其 gradient 會在 `y.grad` 裡累積

#### Functions

神經網絡需要用到很多 function，例如 activation function、loss function 等等。

[`torch.nn`](http://pytorch.org/docs/master/nn.html) 提供了很多 neural network 需要的功能和元件，而[`torch.nn.functional`](http://pytorch.org/docs/master/nn.html#torch-nn-functional) 也提供了很多常用 function。兩者差別在於， `torch.nn.functional` 提供的是純函數，而 `torch.nn` 提供的是一個包裝完整的 `nn.Module`（也就是可以直接跟其它 function 鏈結起來拿去訓練了）。

API 基本上就是 function 名字，`Linear`、`ReLU`、`Sigmoid` 之類，很簡單。

#### Training & Optimizer

從上面 `autograd.Variable` 的介紹裡得知 gradient 已經有辦法算出來了，那算出來後就能以此更新參數，也就是我們能進行模型訓練了。不過深度學習裡還有一些竅門，能大大的優（複雜）化這些學習過程，例如 learning rate 的動態適應、每多少訓練資料要更新參數一次等等，這些演算法的選擇就是__優化器（Optimizer）__的選擇。

不過既然我們在新手村，只要知道通常矇著眼選一個能得到更好的效果就行了。

[`torch.optim`](http://pytorch.org/docs/master/optim.html) 裡陳列了很多 optimizer，常用的例如 `SGD`、`Adam`、`RMSprop` 等等。

- [`o.step`](http://pytorch.org/docs/master/optim.html#optimizer-step)
    - 更新參數

#### 建立 Neural Network

終於能來打造 neural network model 了。基本上這個 model 就是一個 class 繼承 [`torch.nn.Module`](http://pytorch.org/docs/master/nn.html#torch.nn.Module)，只要 override `__init__` 和 `forward` 就能定義這個 model。

- `__init__`
    - 定義 model 中需要的參數，weight、bias 等等
- [`forward`](http://pytorch.org/docs/master/nn.html#torch.nn.Module.forward)
    - 定義 model 接收 input 時，data 要怎麼傳遞、經過哪些 activation function 等等

## 以 PyTorch 打造 MNIST 手寫數字辨識模型

前半部分只是介紹一下這個那個在幹嘛、有哪些 API，現在就來實際訓練一個模型吧。[MNIST](http://yann.lecun.com/exdb/mnist/) 是一套手寫數字的訓練集，在機器學習界的重要性堪比程式語言的 Hello World! [9] 官方也有提供範例程式。

![MNIST](http://corochann.com/wp-content/uploads/2017/02/mnist_plot.png)

接下來就是把官方範例去蕪存菁（簡化模型、省略 CUDA 等）、模組化、加上詳細註解、並提供一個互動介面供自行測試，一起用 PyTorch 和 MNIST 入門深度學習。

###### 環境設置 & 安裝套件

[PyTorch](http://pytorch.org/) 官網就跟 PyTorch 本身一樣優雅直觀得沒話說。上去選好你的環境設置，下載套件吧！

###### 理解模型

Backpropagation 是常見訓練神經網絡的演算法，包含這些基本步驟：

1. 取得資料集，每筆資料包成 `(input, target output)` 形式
2. 建立模型
    1. 定義神經網絡中有哪幾層，形狀是如何
    2. 定義資料往前傳遞所需經過的 function，例如 activation function、loss function 等
    3. 挑選 optimizer 和其所需參數，例如 learning rate
3. 訓練模型
    1. 初始化參數
    2. 把 input 通過網絡往前傳（Forward propagation），取得預測 output
    3. 計算 error（目標和預測結果的差距）
    4. 把 error 往回傳（Backward propagation），一一計算每個參數對此 error 的貢獻（取導數）
    5. 更新參數，對 error 貢獻越多處罰越多
    6. 如果 error 過大，重複步驟 2. 至 5.，直到 error 小到可接受，或自己設定要循環幾次（幾個 epoch）
4. 儲存模型

俗話說，最好的註解就是程式本身。因為 PyTorch 這點做得很好了，我甚至覺得自己的註解相當多餘（還是加減看啦）。請大家自行閱讀[完整程式 + 註解](https://github.com/pyliaorachel/pytorch-mnist-interactive)，細節就不再贅述了。

###### 實際訓練

1. 官方範例
    - 不想看我註解廢話的可以直接至[官方範例](https://github.com/pytorch/examples/tree/master/mnist)下載乾淨的程式，按照上面的步驟跑。
2. 模組化程式
    - 想要在訓練好模型後實際調用來預測自己的手寫圖片體會那感動瞬間的，可以下載[敝範例](https://github.com/pyliaorachel/pytorch-mnist-interactive)，按照指示跑。

途中會 log 一些訊息，告訴你現在的 error 降到多少、準確率提升到多高等等。如果想要自己調參數，在執行指令加上一些 option 即可。

###### 訓練結果

![log](https://github.com/pyliaorachel/pytorch-mnist-interactive/blob/master/img/training_log.png?raw=true)

跑了10個 epoch 的結果準確率到達99%，還行。有興趣的可以自己調調參數、自己給測資等等。

## 結語

PyTorch 入門概念有了之後，是不是覺得語法相當直觀、對新手相當友善？除了電腦視覺和 CNN，也可以用 RNN 玩玩看[自然語言處理](https://github.com/rguthrie3/DeepLearningForNLPInPytorch/blob/master/Deep%20Learning%20for%20Natural%20Language%20Processing%20with%20Pytorch.ipynb)。有了這些基礎之後，自己踹踹其它或更大型的深度訓練模型，就能領取勳章揮別新手村啦。

## 參考資料

1. [GitHub pytorch/pytorch](https://github.com/pytorch/pytorch)
2. [PyTorch Tutorials](http://pytorch.org/tutorials/)
3. [Deep Learning for Natural Language Processing with Pytorch](https://github.com/rguthrie3/DeepLearningForNLPInPytorch/blob/master/Deep%20Learning%20for%20Natural%20Language%20Processing%20with%20Pytorch.ipynb)
4. [GitHub ritchieng/the-incredible-pytorch](https://github.com/ritchieng/the-incredible-pytorch)
5. [GitHub jsjohnson/pytorch-examples](https://github.com/jcjohnson/pytorch-examples)
6. [GitHub yunjey/pytorch-tutorial](https://github.com/yunjey/pytorch-tutorial)
7. [MNIST Dataset](http://yann.lecun.com/exdb/mnist/)
8. [toy demo - PyTorch + MNIST](https://xmfbit.github.io/2017/03/04/pytorch-mnist-example/)
9. [MNIST For ML Beginners (TensorFlow)](https://www.tensorflow.org/get_started/mnist/beginners)
10. [Applying Convolutional Neural Network on the MNIST dataset](https://yashk2810.github.io/Applying-Convolutional-Neural-Network-on-the-MNIST-dataset/)
11. [四天速成！香港科技大学 PyTorch 课件分享](https://www.jiqizhixin.com/articles/2017-10-09-4)
12. [【pytorch】图像基本操作](https://zhuanlan.zhihu.com/p/27382990)

## 補充資料

1. [Vector, Matrix, and Tensor Derivatives](http://cs231n.stanford.edu/vecDerivs.pdf)
2. [Types of Optimization Algorithms used in Neural Networks and Ways to Optimize Gradient Descent](https://medium.com/towards-data-science/types-of-optimization-algorithms-used-in-neural-networks-and-ways-to-optimize-gradient-95ae5d39529f)
