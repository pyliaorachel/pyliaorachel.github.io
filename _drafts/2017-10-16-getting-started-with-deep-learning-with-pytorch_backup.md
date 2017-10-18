---
layout: post
title:  "深度學習新手村：PyTorch入門"
categories: Blog Tech Python
tags: ["Python", "PyTorch", "Machine Learning", ""Deep Learning", "Neural Network", "Computer Vision", "PyLadies"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

深度學習新手在從學校、網路、或書中習得基礎神經網絡知識後，手癢想建立專案體現深度學習的威力之前，得先決定要玩哪一套深度學習框架。[TensorFlow](https://www.tensorflow.org/) 無疑是近來相當火紅的一個，其由 Google 開源，近年來已建立龐大社群基礎。

但 2017 年初由 Facebook 開源的另一套建立在 [Torch](http://torch.ch/) 之上的深度學習框架 [PyTorch](http://pytorch.org/) 因其語法簡潔優雅、概念直觀和易上手的特性，甫推出便迅速走紅，儼然已成為瓜分深度學習市場的有力競爭者。藉由這樣的優勢，此篇將引領深度學習新手入門 PyTorch ，簡述其核心概念和語法，並用 PyTorch 實現深度學習領域的 Hello World! 專案 -- MNIST 手寫數字辨識。

<!--more-->
---

_* 請注意，此篇 PyTorch 建立在 Python3 之上，並以 MacOSX 為環境。_
_* 預備知識：基礎神經網絡 & 反向傳播算法（Backpropagation）概念_

## PyTorch 入門

[PyTorch](http://pytorch.org/) 為 Facebook 在 2017 年初開源的深度學習框架，其建立在 [Torch](http://torch.ch/) 之上，且標榜 Python First ，為量身替 Python 語言所打造，使用起來就跟寫一般 Python 專案沒兩樣，也能和其他 Python 套件無痛整合。PyTorch 的優勢在於其概念相當直觀且語法簡潔優雅，因此視為新手入門的一個好選項；再來其輕量架構讓模型得以快速訓練且有效運用資源[1]。

首先，讓我們來上手 PyTorch 的基礎吧！

#### 環境設置 & 安裝套件

[PyTorch](http://pytorch.org/) 官網就跟 PyTorch 本身一樣優雅直觀得沒話說。上去選好你的環境設置，下載套件吧！

裝完了就來引入套件 & 重新命名：

```python
import torch
import torch.autograd as autograd
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim

# 手動設定 random number generator 的 seed，這樣才能重現同樣結果
torch.manual_seed(1)
```

#### `Tensor` Library

##### `Tensor` 建立

一個 Tensor（張量）類似一個高維度向量，也是深度學習裡進行運算的基礎元素。這裡比數學上的意義還要廣義，所以可以把它當成任意維度的資料向量。

```python
# 創建 1-D Tensor
V = torch.Tensor([1., 2., 3.])

# 創建 2-D Tensor
M = torch.Tensor([[1., 2., 3.], [4., 5., 6.]])

# 創建 n-D Tensor 以此類推...

# 創建(3 x 4 x 5)維隨機資料
X = torch.randn((3, 4, 5))
```

提取 index 0 的值：

```python
print(V[0])
> 1.0

print(M[0])
>  1
>  2
>  3
> [torch.FloatTensor of size 3]
```

數值是 float 就是 `FloatTensor`；數值是 integer 常用 `LongTensor`。

##### 基本 `Tensor` 操作 

###### 相加

```python
x = torch.Tensor([1., 2., 3.])
y = torch.Tensor([4., 5., 6.])
z = x + y

print(z)
>  5
>  7
>  9
> [torch.FloatTensor of size 3]
```

###### 串聯 `torch.cat`

```python
x = torch.Tensor([[1., 2., 3.], [4., 5., 6.]])
y = torch.Tensor([[7., 8., 9.], [10., 11., 12.]])

# 串聯 `torch`
print(torch.cat([x, y]))
>   1   2   3
>   4   5   6
>   7   8   9
>  10  11  12
> [torch.FloatTensor of size 4x3]
```

###### 重塑 `torch.reshape`

```python
x = torch.Tensor([ 1., 2., 3. ])
y = torch.Tensor([ 4., 5., 6. ])
z = x + y

print(z)
>  5
>  7
>  9
> [torch.FloatTensor of size 3]
```

#### `autograd` Library

## 以 PyTorch 打造 MNIST 手寫數字辨識模型

## 參考資料

1. [GitHub pytorch/pytorch](https://github.com/pytorch/pytorch)
2. [Deep Learning for Natural Language Processing with Pytorch](https://github.com/rguthrie3/DeepLearningForNLPInPytorch/blob/master/Deep%20Learning%20for%20Natural%20Language%20Processing%20with%20Pytorch.ipynb)
3. [GitHub ritchieng/the-incredible-pytorch](https://github.com/ritchieng/the-incredible-pytorch)
4. [MNIST For ML Beginners](https://www.tensorflow.org/get_started/mnist/beginners)

## 延伸閱讀

1. [Vector, Matrix, and Tensor Derivatives](http://cs231n.stanford.edu/vecDerivs.pdf)
