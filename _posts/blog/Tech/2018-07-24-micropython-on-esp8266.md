---
layout: post
title:  "用 Python 玩硬體：MicroPython 簡介與實作"
categories: Blog Tech Python
tags: ["Python", "PyLadies", "MicroPython", "esp8266"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

說到嵌入式系統、物聯網等等硬體，很多靠 Python 吃飯的 PyBoys PyGirls 可能要舉雙手投降，因為控制這些底層大多需要靠 C 語言。但時代不同了，MicroPython 幾年前的推出讓用 Python 控制硬體不是夢。本文將會簡介 MicroPython 的應用，並以載有 ESP8266 Wi-Fi 模組的 NodeMCU 進行簡單資料傳輸實作。除了 MicroPython，硬體新手們不妨也藉此來認識一下物聯網的世界。

<!--more-->
---

## MicroPython 簡介

[MicroPython](https://github.com/micropython/micropython) 是 2013 年在 Kickstarter 上募資開始建立的，顧名思義就是因為小型硬體資源有限，而將 Python 濃縮成一款小型包，載入硬體微控制器的一項開源專案，目前已經能移植於 Arduino 和 ESP8266 等板子，亦有自己專屬的開發板。

那 MicroPython 要怎麼寫呢？對，就跟 Python 一模一樣。MicroPython 除了留有 Python 的許多迷你化的標準函式庫，也有例如 `machine`、`network` 等硬體相關的專屬函式庫控制硬體相關功能。詳細可參考[官方文件](https://docs.micropython.org/en/latest/esp8266/library/index.html#python-standard-libraries-and-micro-libraries)。

聽起來真方便，那就直接來實作吧！

## 實作

這次筆者看看手上的資源，選擇不多，挑了能載入 MicroPython 且有 Wi-Fi 功能的 NodeMCU 開發套件進行小 demo，任務是把（假裝有的）sensor 收集到的 data 透過網路上傳到自己建立的 API。如果手邊剛好也有，或是有在地上撿到這塊板子，就一起試試吧，不然筆者是不是在唬爛也很難知道。

GitHub 原始碼：https://github.com/pyliaorachel/esp8266-micropython

### NodeMCU 與 ESP8266

![NodeMCU](https://5.imimg.com/data5/YK/YF/MY-25117786/nodemcu-esp8266-12e-wi-fi-module-500x500.png)

跟對物聯網不熟悉的朋友簡單介紹一下。ESP8266 就是相片左邊突出的那一小塊，備有 Wi-Fi 功能，本身也是集有 GPIO （General-Purpose I/O）、serial 腳位 (TX / RX) 等接口的控制板。GPIO 可以接收/傳輸 binary data，也就是 1 （高電位）或 0 （低電位），或是跟 ADC （Analog-to-Digital Converter）連接以接收類比訊號，或以 PWM（Pulse Width Modulation） 模擬類比訊號進行傳輸。在物聯網的世界裡， GPIO 主要用來連接其他 sensor 收集資料，例如溫度、光線等等。

ESP8266 最原汁原味的版本（ESP-01）非常有意思，上傳一份 code 要各種腳位交互接地，GPIO 只有兩個成不了大事等等，可以參考我之前的[血淚經驗](https://pyliaorachel.github.io/tutorial/hardware/arduino/2017/04/13/esp8266-with-arduino-trials-and-errors.html)（簡短版：珍惜生命，遠離 ESP-01）。這塊 NodeMCU 十分了解你的不便，因此幫忙封裝了一番，除了採用具有多個 GPIO 的 ESP-12 版本，還連接了 micro USB 轉接器，讓你直接用 micro USB 傳輸線和電腦溝通，類似於有 Wi-Fi 的 Arduino 開發板。內部載有 NodeMCU 韌體，可以用 Lua 撰寫程式控制硬體。

而接下來我們要做的就是重新燒錄 MicroPython 韌體，便能開始用 Python 控制這塊板子啦。

### 硬體設置

[官方文件](https://docs.micropython.org/en/latest/esp8266/esp8266/tutorial/intro.html)有完整教學，我 GitHub repo 裡的 [README](https://github.com/pyliaorachel/esp8266-micropython) 也有簡潔的步驟，這邊簡單講解：

1. 安裝工具
    1. `$pip install esptool`，用來跟 ESP 晶片溝通
    2. `$pip install adafruit-ampy`，用來和板子進行傳輸
2. 燒錄韌體
    1. NodeMCU 用 micro USB to USB 線接到電腦
    2. 查看是哪個 USB port，Mac 的話可以用 `$ ls /dev/tty.*` 找，其他自己 google （跩）
    3. [下載韌體](http://micropython.org/download#esp8266)
    4. 燒毀！好啦燒錄：`$ esptool.py --port <port-name> write_flash --flash_size=detect 0 <firmware-file>`

### Data 傳送

我們的任務是，假裝有一個 temperature sensor，每 10 秒收集一次 data，並傳到 Firebase 的 API，傳完時 LED 閃一下告知。這個 API 當然不用是 Firebase 的，可以自己另建。我把建置 Firebase API 的步驟寫在附錄裡供新手參考。

#### 撰寫主程式

MicroPython 主要偵測兩個檔案。一是 `boot.py`，開機時執行，可以在此執行一些系統設定，這裏我沒有另外加東西，就是原本預設的 code。二是 `main.py`，跑完 `boot.py` 就來跑它，所以通常裡面是無限迴圈。

另外還有一個自己加的 `config.py` 放一些客製化的設定，如網路 SSID、密碼、和 API URL。GitHub 上有一個 `config.py.template` 供參考，因為我不能讓你連我家 Wi-Fi 或 call 爆我的 API。

接下來程式有四個部分：

###### 1. 連接網路

網路部分由 `network` module 負責。我們定義一個 `do_connect` 負責連接網路：

```python
import network
import config

def do_connect():
    # 設置成 station mode 以連接外部網路 
    sta_if = network.WLAN(network.STA_IF)
    if not sta_if.isconnected():
        print('Connecting to network...')
        sta_if.active(True)
        sta_if.connect(config.SSID, config.PASSWORD)

        # 等一下它連接
        while not sta_if.isconnected():
            pass
        print('Network connected!')
```

###### 2. 收集 data，上傳 API

因為手邊沒有真的 sensor，這邊直接 hard code 一個值，可替換成從真的 sensor 讀值。
上傳部分用 `urequests` module，也就是一般見到的 `requests` module 的迷你版。

```python
import urequests

def get_data():
    return { 'temperature': 25.6 }

def send_data(data):
    print('Sending data...')
    res = urequests.put(config.URL, json=data)
    print('Response: {}'.format(res.text))
    flash_led() # Step 3
```

###### 3. 添加 LED 提示燈

最後上傳完成的時候，希望 LED 燈能閃一下告知。硬體控制部分由 `machine` module 負責：

```python
import machine
import time

def flash_led():
    led = machine.Pin(2, machine.Pin.OUT) # LED 在 pin 2，設為輸出
    led.value(0) # 這邊設為 0（低位）其實是 on，1（高位）是 off，但在其他板子上可能會相反
    time.sleep(0.5) # 亮 0.5 秒
    led.value(1)
```

###### 4. 組合

主要是一個無窮迴圈，每 10 秒傳一次 data：

```python
def main():
    do_connect()

    while True:
        send_data(get_data())
        time.sleep(10)
```

最後放個 `main()` 互叫主函式就行囉！

##### 上傳程式 & 測試

上面的程式都是先在 local 端撰寫，寫完再上傳測試。上傳程式到板上需要用到一些工具，這邊選用剛剛裝好的 `ampy`。

接下來幾個步驟上傳並測試：

1. 上傳程式：`$ ampy --port <port-name> put boot.py main.py config.py`
2. 按住板上的 reset 鈕，放開時 LED 會閃一下，接著它就會重新開始跑新的程式
3. 看看 LED 有沒有閃，看看 API 有沒有收到 data

收到的話 Firebase 會長這樣：

![Firebase console](https://github.com/pyliaorachel/esp8266-micropython/blob/master/imgs/firebase.png?raw=true)

就成功了！

## 結語

MicroPython 的出現讓許多畏懼低階語言的開發者有機會以高階語言玩玩硬體端，也能加快原本物聯網開發者的開發速度。但目前 MicroPython 包含的函式庫還十分有限，有時候不能做太複雜的專案，例如 email 傳輸因為沒有 `imaplib` 或 `smtplib` 而變得困難。期待未來能有更多套件支援以利更多有趣專案的實現，同時亦不失自身精巧的特質。

## 參考資料

* [MicroPython 官方文件](https://docs.micropython.org/en/latest/esp8266/index.html)
* [NodeMCU 使用手冊](http://www.handsontec.com/pdf_learn/esp8266-V10.pdf)
* [MicroPython on ESP8266 -- 小狐狸事務所](http://yhhuang1966.blogspot.com/2017/04/esp-01-esp8266-micropython.html)

## 附錄：Firebase API 建立

1. 去 [Firebase 官網](https://firebase.google.com/) 建立帳號
2. `GO TO CONSOLE > 新增專案`，輸入專案名稱並建立
3. `開發 -> Database -> Realtime Database 建立資料庫 -> 以測試模式啟動`
4. `https://<project-name>.firebaseio.com/` 即為 API 網址
