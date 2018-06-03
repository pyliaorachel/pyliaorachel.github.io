---
layout: post
title:  "Reinforcement Learning 健身房：OpenAI Gym"
categories: Blog Tech Python
tags: ["Python", "PyLadies", "OpenAI gym"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

不久前火熱的 AlphaGo 圍棋 AI 系統因打敗眾多人類好手而聲名大噪，而稍後推出的進化版 AlphaGo Zero 更是乾淨利落的藉由與自身對抗而習得棋藝，令人嘖嘖稱奇。而這系列圍棋 AI 系統背後即是以 __Reinforcement Learning 強化學習__為基礎訓練而成。

`Gym` 是 OpenAI 所開源的 Reinforcement Learning 工具包。無論是想感受 Reinforcement Learning 是怎麼一回事，或是想嘗試進階 Deep Q-Learning 的開發者，都可以快速方便的調用 `gym` 所提供的許多現成環境，專注於演算法的設計與實現。快讓我們一起來成為健身房的永久免費會員！

<!--more-->
---

_* 請注意，以下只針對Python3進行講解與測試，並以 MacOSX 為環境。_

本篇會從基礎 Reinforcement Learning 概念簡介開始，進入 OpenAI gym 簡介，跟著兩個 demo 式的簡單演算法實作 -- __Random Action__ 及 __Hand-Made Policy__，最後帶至具有學習能力的演算法 --  __Q table 為基礎的 Q-learning__。與 Deep Learning 結合的 Deep Q-learning 會在之後的進階篇實作。

## Reinforcement Learning 介紹

試想一個大學生，原本總是十二點睡，但離開家住進宿舍後，每天打電動打到兩點才睡，隔天上課昏昏沉沉，GPA 0.87。某天他嘗試十點上床睡覺，發現隔天上課腦袋清晰、神采奕奕，全身舒爽的他開始慢慢調整作息，最終 GPA 4.3。從對一個新環境一無所知，不斷嘗試不同作息時間，進而藉由所獲得的好處（身心感受、GPA等）學會最適合自己的作息，這種學習過程便是 Reinforcement Learning。

Reinforcement Learning 是 Machine Learning 家族的一員，為一種__目標導向(goal-oriented)__的學習方法，旨在經由與環境互動過程中獲得的各種獎勵或懲罰，學會如何做決策。

![reinforcement learning](https://i.stack.imgur.com/eoeSq.png)

整個決策過程的模擬有以下幾個要素：

1. __Agent__，藉由 action 跟 environment 互動。
2. __Environment__，agent 的行動範圍，根據 agent 的 action 給予不同程度的 reward。
3. __State__，在特定時間點 agent 身處的狀態。
4. __Action__，agent 藉由自身 policy 進行的動作。 
5. __Reward__，environment 給予 agent 所做 action 的獎勵或懲罰。

Agent 的目標是藉由與 environment 不斷互動及獲得 reward，學會最佳 __policy__，即是 agent 根據身處的 state 決定進行最佳 action 的策略。

以上是 Reinforcement Learning 的簡單介紹，欲深入了解可參考文末參考資料。

## OpenAI Gym 介紹

[OpenAI Gym](https://gym.openai.com/) 是由 OpenAI 開源的 Reinforcement Learning 工具包，裡面有許多現成 environment 處理環境模擬及獎勵等等過程，讓開發者專注於演算法開發。

[安裝過程](https://gym.openai.com/docs/)非常簡單，首先確保你的 Python version 在 3.5 以上，然後使用 pip 安裝：

```bash
$ pip install gym
```

接著只需要 `import gym` 就能開始體驗 Reinforcement Learning。

## 演算法實作

`Gym` 一系列的 environment 都在[這裡](https://gym.openai.com/envs/#classic_control)。我們挑選 `CartPole-v0` 當示範，任務是維持小車上的柱子的平衡。它的 environment 只有四種 feature（小車位置，小車速度，柱子角度，柱尖速度），agent 只有兩種 action（向左移，向右移）。網路上有非常多建立在 CartPole 的範例，這邊把常見演算法整合，進階的 Deep Q-Network 則留到下一篇。

![cart pole](https://github.com/pyliaorachel/openai-gym-cartpole/blob/master/img/cartpole.png?raw=true)

GitHub 完整程式碼：https://github.com/pyliaorachel/openai-gym-cartpole

### Random Action

首先用最簡單的例子體驗 `gym` 的使用 —— 無論 environment 如何，隨機進行 action，也就是隨機決定要將小車左移或右移。

```python
env = gym.make('CartPole-v0')

# 跑 200 個 episode，每個 episode 都是一次任務嘗試
for i_episode in range(200):
    observation = env.reset() # 讓 environment 重回初始狀態 
    rewards = 0 # 累計各 episode 的 reward 
    for t in range(250): # 設個時限，每個 episode 最多跑 250 個 action
        env.render() # 呈現 environment

        # Key section
        action = env.action_space.sample() # 在 environment 提供的 action 中隨機挑選
        observation, reward, done, info = env.step(action) # 進行 action，environment 返回該 action 的 reward 及前進下個 state

        rewards += reward # 累計 reward

        if done: # 任務結束返回 done = True
            print('Episode finished after {} timesteps, total rewards {}'.format(t+1, rewards))
            break

env.close()
```

精華都在 Key section，agent 選擇並進行一個 action，並從 environment 中獲得 reward。可以看到 agent 並沒有任何學習行為，所以整體 reward 並不高。

![random action](https://github.com/pyliaorachel/openai-gym-cartpole/blob/master/img/random_action.png?raw=true)

### Hand-Made Policy

為了讓 agent 不會走得太無腦，再來引進一個簡單的 policy —— 如果柱子向左傾（角度 < 0），則小車左移以維持平衡，否則右移。

> 其實正常來說，agent 是不會知道 environment 所提供的這些 feature 和 action 各自是什麼意思，因此這一部分主要是示範 policy 的概念。

```python
# 定義 policy
def choose_action(observation):
    pos, v, ang, rot = observation
    return 0 if ang < 0 else 1 # 柱子左傾則小車左移，否則右移 
```
```python
env = gym.make('CartPole-v0')

for i_episode in range(200):
    observation = env.reset()
    rewards = 0
    for t in range(250):
        env.render()

        action = choose_action(observation)
        observation, reward, done, info = env.step(action)

        rewards += reward

        if done:
            print('Episode finished after {} timesteps, total rewards {}'.format(t+1, rewards))
            break

env.close()
```

結果：

![hand-made rule](https://github.com/pyliaorachel/openai-gym-cartpole/blob/master/img/hand_made_policy.png?raw=true)

可以看到 agent 所獲得的整體 reward 比 random action 高出許多，不過 agent 依然沒有根據經驗做學習，非常頑固。接下來要來示範真正實用的 learning process —— Q-learning。

### Q-Learning with Q Table

在進入實作前，會先簡單講解 Q-learning 及 Q table 概念，可當作補充。

###### Q-Learning

為了學習在某個 state 之下做出好的 action，我們定義所謂的 Q function `Q(s, a)`，也就是__根據身處的 state `s` 進行 action `a` 所預期未來會得到的總 reward__。如果能求出最佳 Q function`Q*(s, a)`，我們的 agent 在任何 state 之下，只要挑選能最大化未來總 reward 的 action ，即 `argmax_a Q*(s, a)`，即能在任務中獲得最大 reward。而習得 Q function 的過程正是 Q-learning。

在學習 Q function 前，要先知道如何表示 Q function。不難發現 Q function 有遞迴特質，可以用遞迴表示：

<p style="text-align: center;">
    <img src="https://cdn-images-1.medium.com/max/1600/1*jamiG5MkFVHLTFmLggemVg.png" />
</p>

即是當前 reward 和進入下一個 state `s'` 後所能獲得最大 discounted reward 的和。這邊的 γ 稱為 discount factor，可以說是對未來 reward 的重視程度。γ 越低，agent 越重視當前所獲得的 reward，並覺得未來獲得的 reward 太遙遠，不足以在當前 state 的決策過程中佔有太大份量。

接著 agent 要藉由一次次跟 environment 互動中獲得的 reward 來學習 Q function。起初 agent 一無所知時，Q function 的參數都是隨機的。接著從跟 environment 互動的每一步，慢慢更新參數，逼近我們要的最佳 Q function：

<p style="text-align: center;">
    <img src="https://wikimedia.org/api/rest_v1/media/math/render/svg/845e1915e9fc3b55a3e88cb6fb5f40a41c1b6606" />
</p>

這裡 learned value 是每次 action 帶來的一點新資訊，但不能直接取代舊資訊，而是每次更新 α 這麼多比率的新資訊，保留 (1 - α) 比率的舊資訊，最終逐漸收斂。

整體 Q-learning 步驟大致上如下：

<p style="text-align: center;">
    <img src="http://www.incompleteideas.net/book/ebook/pseudotmp9.png" />
</p>

ε-greedy 是一種在 exploration 和 exploitation 間取得平衡的方法。Exploration 是讓 agent 大膽嘗試不同 action，確保能夠吸收新知，而 exploitation 是讓 agent 保守沿用現有 policy，讓學習過程收斂。方法很簡單：ε 是隨機選擇 action 的機率，所以平均上有 ε 的時間 agent 會嘗試新 action，而 (1 - ε) 的時間 agent 會根據現有 policy 做決策。

###### Q Table

了解 Q-learning 及 ε-greedy 的概念後，那實際上這個 Q function 存在哪裡呢？一個樸實無華的方法就是把各個 state-action pair 的 Q value 存在 table 裡，直接查找或更新，即是所謂 Q table，也是接下來要示範的方法。不過這個方法的壞處是 table 大小有限，不適用於 state 和 action 過多的任務。

另一個方法是用 neural network 去逼近 Q function，即 Deep Q-Learning，如此一來就不會有容量限制了。這個方法會在之後另寫文章介紹。

###### 實作

原始碼修改自[這篇文章](https://medium.com/@tuzzer/cart-pole-balancing-with-q-learning-b54c6068d947)。

先統整一下。我們的目標是學習到最佳 Q function，過程中以 ε-greedy 方法與 environment 互動，從中獲得 reward 以更新 Q table 裡的 Q value。先看一下基於 ε-greedy 的 policy 定義：

```python
def choose_action(state, q_table, action_space, epsilon):
    if np.random.random_sample() < epsilon: # 有 ε 的機率會選擇隨機 action
        return action_space.sample() 
    else: # 其他時間根據現有 policy 選擇 action，也就是在 Q table 裡目前 state 中，選擇擁有最大 Q value 的 action
        return np.argmax(q_table[state]) 
```

再來是 state 的表示。在 `CartPole` 環境裡觀察到的 feature 都是連續值，不適合作為一個 table 的 index，因此要將一個區間一個區間的值包在一起用離散數值表示，也就是下面的 `bucket`：

```python
def get_state(observation, n_buckets, state_bounds):
    state = [0] * len(observation) 
    for i, s in enumerate(observation): # 每個 feature 有不同的分配
        l, u = state_bounds[i][0], state_bounds[i][1] # 每個 feature 值的範圍上下限
        if s <= l: # 低於下限，分配為 0
            state[i] = 0
        elif s >= u: # 高於上限，分配為最大值
            state[i] = n_buckets[i] - 1
        else: # 範圍內，依比例分配
            state[i] = int(((s - l) / (u - l)) * n_buckets[i])

    return tuple(state)
```

最後是學習。學習過程中為了方便收斂，一些參數像 ε 和 learning rate 會隨著時間遞減，也就是我們從大膽亂走，到越來越相信已經學到的經驗。

```python
env = gym.make('CartPole-v0')

# 準備 Q table
## Environment 中各個 feature 的 bucket 分配數量
## 1 代表任何值皆表同一 state，也就是這個 feature 其實不重要
n_buckets = (1, 1, 6, 3)

## Action 數量 
n_actions = env.action_space.n

## State 範圍 
state_bounds = list(zip(env.observation_space.low, env.observation_space.high))
state_bounds[1] = [-0.5, 0.5]
state_bounds[3] = [-math.radians(50), math.radians(50)]

## Q table，每個 state-action pair 存一值 
q_table = np.zeros(n_buckets + (n_actions,))

# 一些學習過程中的參數
get_epsilon = lambda i: max(0.01, min(1, 1.0 - math.log10((i+1)/25)))  # epsilon-greedy; 隨時間遞減
get_lr = lambda i: max(0.01, min(0.5, 1.0 - math.log10((i+1)/25))) # learning rate; 隨時間遞減 
gamma = 0.99 # reward discount factor

# Q-learning
for i_episode in range(200):
    epsilon = get_epsilon(i_episode)
    lr = get_lr(i_episode)

    observation = env.reset()
    rewards = 0
    state = get_state(observation, n_buckets, state_bounds) # 將連續值轉成離散 
    for t in range(250):
        env.render()

        action = choose_action(state, q_table, env.action_space, epsilon)
        observation, reward, done, info = env.step(action)

        rewards += reward
        next_state = get_state(observation, n_buckets, state_bounds)

        # 更新 Q table
        q_next_max = np.amax(q_table[next_state]) # 進入下一個 state 後，預期得到最大總 reward
        q_table[state + (action,)] += lr * (reward + gamma * q_next_max - q_table[state + (action,)]) # 就是那個公式

        # 前進下一 state 
        state = next_state

        if done:
            print('Episode finished after {} timesteps, total rewards {}'.format(t+1, rewards))
            break

env.close()
```

這邊其實偷偷作弊，才會知道哪個 feature 重要哪個不重要，以及 state 的上下限。參數也是原作者調整過的。不過如此一來才能展現好結果：

![Q table](https://github.com/pyliaorachel/openai-gym-cartpole/blob/master/img/q_table.png?raw=true)

可以看到在訓練後期，agent 已經學會如何最大化自己的 reward，也就是維持住小車上的棒子了。

## 結語

AlphaGo 帶來的驚奇讓人們期待著 Reinforcement Learning 的無限可能性。此篇帶大家簡單理解 Reinforcement Learning 的學習過程和 OpenAI Gym 的操作，並簡單示範幾個演算法。雖說目前 Reinforcement Learning 打造出許多超越人類的遊戲 AI，但在其他領域的應用，例如 Computer Vision、Natural Language Processing，仍成果有限。期待不久的未來，Reinforcement Learning 能在真正對人類福祉有益的領域有所突破。

## 參考資料

* [Mastering the game of Go without human knowledge](https://www.nature.com/articles/nature24270)
* [A Beginner's Guide to Deep Reinforcement Learning](https://deeplearning4j.org/deepreinforcementlearning)
* [Solving an MDP with Q-Learning from scratch — Deep Reinforcement Learning for Hackers (Part 1)](https://medium.com/@curiousily/solving-an-mdp-with-q-learning-from-scratch-deep-reinforcement-learning-for-hackers-part-1-45d1d360c120)
* [Open AI Gym 簡介與 Q learning 演算法實作](https://blog.techbridge.cc/2017/11/04/openai-gym-intro-and-q-learning/)
* [强化学习方法汇总 (Reinforcement Learning)](https://morvanzhou.github.io/tutorials/machine-learning/ML-intro/4-02-RL-methods/)
* [Cart-Pole Balancing with Q-Learning](https://medium.com/@tuzzer/cart-pole-balancing-with-q-learning-b54c6068d947)
