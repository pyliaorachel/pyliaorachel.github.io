---
layout: post
title:  "ESP8266 with Arduino - Trials and Errors"
categories: Tutorial Hardware Arduino 
tags: arduino esp8266
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

ESP8266 is a popular WiFi module for its extremely affordable price. However, more errors tend to be encountered during the setup of this primitive module. 

In this tutorial, the basic steps of setting up ESP8266 through an Arduino board would be covered, and some personal trials and errors will be shared in hope to save people's time and life if they are stuck with the same problems as I did.

<!--more-->
---

_I am actually an Arduino beginner and a software person. But in turn, I faced more errors than others, managed to solved them, and have more to share with other people who are also new to Arduino and ESP8266 WiFi module!_

# Introduction & Setup

## What is ESP8266?

An extremely affordable hardware component ($USD 3) to connect to WiFi. 

Comes with a variety of different models, which are all based on the same chip. The most popular model is ESP-03, which is of similar price to ESP-01 that I will be using in this tutorial, but with more ports (_so regretful, should have picked this one!_).

![ESP models](http://i2.wp.com/randomnerdtutorials.com/wp-content/uploads/2015/01/all_esp_modules1.png?resize=600%2C337)

## Components

1. [ESP8266 WiFi module ESP-01](https://world.taobao.com/item/40484626466.htm) (or other)
2. Arduino Mega board (or others)
3. [Logic level converter](https://world.taobao.com/item/522587064231.htm?spm=a312a.7700714.0.0.LOoy8V#detail) (optional)
4. Breadboard, wires, ...

## Before You Start...

Ok, here are some advice before you read on.

1. If you don't know what __AT command__ is, DON'T SKIP THE SECTION INTRODUCING IT. I'll make it simple, I promise, but don't directly dive into writing the codes before you know the basics of AT commands like I did - you'll end up wasting more time dealing with errors.
2. Always start with the most basic examples.
3. Just to let you know, __Arduino is not necessary for you to program ESP8266__. Interestingly, more tutorials I found online deal with it with a USB to serial converter such as the __FTDI232R__ module. Follow this tutorial if you have an Arduino board with you, or else you can follow the nice tutorials I took reference on in the reference list.

# Getting Started!

The following contents will be walked through:

1. Hooking Up ESP8266 + Sending AT Commands
2. Programing ESP8266
3. Connecting to WiFi
  1. Client Example
  2. Server Example

## 1. Hooking Up ESP8266 + Sending AT Commands

Here are the pins for ESP-01 model:

![pins](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/ESP8266-pins.png)

### Connections

| ESP8266 | Arduino | Others | Purpose |
|:-------:|:-------:|:------:|:--------|
|Vcc|-|3.3V|Power supply|
|GND|GND|GND|Ground|
|Rx|Rx|-|Receive data in|
|Tx|Tx|-|Transmit data out|
|CH_PD|-|Normally 3.3V|Chip power down|
|RESET|-|3.3V for normal operations / GND for reset|Reset|
|GPIO0|-|- for normal operations / GND for flashing firmware| General purpose I/O pins, but used in flashing firmware|
|GPIO2|-|-|General purpose I/O pin|

##### Key Notes

1. __NEVER__ connect Vcc and other pins to 5V.
  - ESP8266 operates on 3.3V; connecting pins to 5V may damage the module.
  - For Rx/Tx pins, the one receiving data through Arduino board should theoretically also be logically shifted down to 5V; but many people didn't encounter problem connecting them directly to each other's pins, including me.
1. __DON'T__ connect 3.3V power pin of Arduino to ESP8266. Use a __logic level converter__ to bring 5V down to 3.3V.
  - The max limit of current flowing out of that pin is around 50 mA, which usually is not enough. That's why we need a __logic level converter__; there are [other ways](http://randomnerdtutorials.com/how-to-level-shift-5v-to-3-3v/) to bring 5V down to 3.3V, but using logic level converter ensures a better transmission performance. You can also connect it to external power source, which should be the best way.
2. __Rx-Rx, Tx-Tx__ for uploading program from computer to ESP8266 __via Arduino board__; __Rx-Tx, Tx-Rx__ for letting Arduino board talk to ESP8266.
  - Think of Rx-Rx, Tx-Tx as making Arduino board a channel between the computer and ESP8266; whatever goes to the Arduino board goes to ESP8266, and whatever ESP8266 sends back goes to the computer! 
  - Think of Rx-Tx, Tx-Rx as making Arduino talk to ESP8266, so probably you would have some program in Arduino sending and receiving data/commands via its own serial ports.
3. I don't know what CH_PD port does. So you just leave it at 3.3V.
4. If thinking of ESP8266 as an Arduino board, Rx, Tx, GPIO0, and GPIO2 are the possible digital pins, where Rx/Tx are the predefined Serial ports.
  - If you are programming directly into ESP8266, then when using up Rx and Tx, you would probably find yourself out of Serial ports for debugging. I'm not sure how it can be solved, but probably you can [set GPIO2 as the TX pin](https://github.com/esp8266/Arduino/blob/master/doc/reference.md) or [extend your ports](http://www.forward.com.au/pfod/ESP8266/GPIOpins/index.html). Not sure if they make sense for ESP-01 model (try it and tell me).
  - [Learn more on GPIO ports](http://www.forward.com.au/pfod/ESP8266/GPIOpins/index.html)

## 2. Programing ESP8266
## 3. Connecting to WiFi

### 1. Client Example
### 2. Server Example


















