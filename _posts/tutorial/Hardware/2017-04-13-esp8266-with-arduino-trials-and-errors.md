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
5. Arduino IDE (optional)

## Before You Start...

Ok, here are some advice before you read on.

1. If you don't know what __AT command__ is, DON'T SKIP THE SECTION INTRODUCING IT. I'll make it simple, I promise, but don't directly dive into writing the codes before you know the basics of AT commands like I did - you'll end up wasting more time dealing with errors.
2. Always start with the most basic examples.
3. Just to let you know, __Arduino is not necessary for you to program ESP8266__. Interestingly, more tutorials I found online deal with it with a USB to serial converter such as the __FTDI232R__ module. Follow this tutorial if you have an Arduino board with you, or else you can follow the nice tutorials I took reference on in the reference list.
4. Arduino IDE is also not mandatory, there are other ways to write program and upload to ESP8266. But I didn't do research on it, as that is not my intention for my project.
5. Setting up a bare ESP8266 module without other assisting development board is __FRUSTRATING__. If you don't have as much confidence as I did and are just finding a quick way to hack it out for assignments, then go ahead and buy any of those development borads and make your life easier.

# Getting Started!

The following contents will be walked through:

1. Hooking up ESP8266 + Sending AT Commands
2. Programing ESP8266
3. Examples
    1. Client Example - Programming ESP8266 Like Arduino
    2. Client Example - Talking to ESP8266 via Arduino
    3. Server Example - Programming ESP8266 Like Arduino
    4. Server Example - Talking to ESP8266 via Arduino

## 1. Hooking Up ESP8266 + Sending AT Commands

Here are the pins for ESP-01 model:

![pins](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/ESP8266-pins.png)

### Connections

<div style='margin-bottom: 5px;'>
    <img src='https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/circuit_1.jpg' width='32%'/>
    <img src='https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/circuit_2.jpg' width='32%'/>
    <img src='https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/circuit_4.jpg' width='32%'/>
</div>
![connections](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/circuit_3.jpg)

| ESP8266 | Arduino | Others | Purpose |
|:-------:|:-------:|:------:|:--------|
|Vcc|-|3.3V|Power supply|
|GND|GND|GND|Ground|
|URXD|Rx / Tx|-|Receive data in|
|UTXD|Tx / Rx|-|Transmit data out|
|CH_PD|-|Normally 3.3V|Chip power down|
|RST|-|3.3V for normal operations / GND for reset|Reset|
|GPIO0|-|- for normal operations / GND for flashing firmware| General purpose I/O pins, but used in flashing firmware|
|GPIO2|-|-|General purpose I/O pin|

##### Key Notes

1. __NEVER connect Vcc and other pins to 5V.__
    - ESP8266 operates on 3.3V; connecting pins to 5V may damage the module.
    - For Rx/Tx pins, the one receiving data through Arduino board should theoretically also be logically shifted down to 5V; but many people didn't encounter problem connecting them directly to each other's pins, including me.
1. __DON'T connect 3.3V power pin of Arduino to ESP8266. Use a logic level converter to bring 5V down to 3.3V.__
    - The max limit of current flowing out of that pin is around 50 mA, which usually is not enough. That's why we need a __logic level converter__; there are [other ways](http://randomnerdtutorials.com/how-to-level-shift-5v-to-3-3v/) to bring 5V down to 3.3V, but using logic level converter ensures a better transmission performance. You can also connect it to external power source, which should be the best way.
2. __Rx-Rx, Tx-Tx: uploading program from computer to ESP8266 via Arduino board; Rx-Tx, Tx-Rx: letting Arduino board talk to ESP8266.__
    - Think of Rx-Rx, Tx-Tx as making Arduino board a channel between the computer and ESP8266; whatever goes to the Arduino board goes to ESP8266, and whatever ESP8266 sends back goes to the computer! 
    - Think of Rx-Tx, Tx-Rx as making Arduino talk to ESP8266, so probably you would have some program in Arduino sending and receiving data/commands via its own serial ports.
3. __I don't know what CH_PD port does. Normally just leave it at 3.3V.__
4. __If thinking of ESP8266 as an Arduino board, Rx, Tx, GPIO0, and GPIO2 are the possible digital pins, where Rx/Tx are the predefined Serial ports.__
    - If you are programming directly into ESP8266, then when using up Rx and Tx, you would probably find yourself out of Serial ports for debugging. I'm not sure how it can be solved, but probably you can [set GPIO2 as the TX pin](https://github.com/esp8266/Arduino/blob/master/doc/reference.md) or [extend your ports](http://www.forward.com.au/pfod/ESP8266/GPIOpins/index.html). Not sure if they make sense for ESP-01 model (try it and tell me).
    - [Learn more on GPIO ports](http://www.forward.com.au/pfod/ESP8266/GPIOpins/index.html)

### Basics of AT Commands

If you have experienced with using terminals, then AT commands are of the same concept as those commands you put into the terminal. In terminal, when you input `ls` and send, some programs would be run, then some outputs would be sent back to your terminal window and shown. You interact via the terminal with your computer software with a set of commands available.

Similarly, you interact via the __serial monitor__ with your ESP8266 with a set of __AT commands__ available.

Simple, isn't it? Instead of guiding you through how to send the various AT commands, I'll only use 2 AT commands to test the module in the following section - `AT` and `AT+GMR`. You should try more yourself looking at [this doc](https://www.espressif.com/sites/default/files/documentation/4a-esp8266_at_instruction_set_en.pdf), including how to scan for available WiFis and connect to them via AT commands, but I do not tend to terrify you with a bunch of those commands.

But knowing how this mechanism drives the interaction with ESP8266 is essential in effective comprehension of the libraries used in the following sections.

### Testing with Andruino IDE

_Connection: Rx-Rx, Tx-Tx, RST-3.3V, GPIO0 & GPIO2 floating._  
Note that you are directly talking to ESP8266 via Arduino board as a channel.

1. Connect and power up your Arduino board & ESP8266
2. Make sure you Arduino board isn't loaded with other programs. Either reset your Arduino baord, or upload a `BareMinimum` example program to it if so
3. Open up Arduino IDE, select `Tools > Port > YourConnectedPort`
4. Open up `Serial Monitor`, and listen to baudrate `115200`. You may see some messages bump up; those should be from ESP8266. Recognize the `ready` message at the end. See image in step 7
    - _Try other baudrates if you are seeing random symbols, or seeing nothing_
5. Select `Both NL & CR` option - it adds `\r\n` after your input line. Necessary for sending a valid AT command
6. Input `AT` in your input box and press `enter`. You should see the response `OK` from ESP8266
    ![AT](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/AT.png)
7. Input `AT+GMR` in your input box and press `enter`. You should see the version information of your ESP8266
    ![AT+GMR](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/AT+GMR.png)

If everything shown is as expected, congratulations, your ESP8266 is working, and you can move on to the programming section. If not, then go to the troubleshooting section for help.

#### Alternative1: Testing with PuTTY on Windows

_Connection: Rx-Rx, Tx-Tx, RST-3.3V, GPIO0 & GPIO2 floating._  
Note that you are directly talking to ESP8266 via Arduino board as a channel.

1. Connect and power up your Arduino board & ESP8266
2. Make sure you Arduino board isn't loaded with other programs. Either reset your Arduino baord, or upload a `BareMinimum` example program to it if so
3. Check the serial port number of your device under `Device Manager > Ports > USB Serial Port` or `Arduino IDE > Tools > Port`
4. Open up PuTTY, select `Connection type > Serial`, input `Serial line > COMX` where `COMX` is your connected serial port number, `Speed > 115200` or other baudrates that work. Press `Open`. Some messages bump up as in Arduino IDE
5. Enter `AT`, __hold down `Ctrl` key, press `m` key, press `j` key, release `Ctrl` key__. This sends an `AT` command ending with `\r\n`. You should see the response `OK`
    ![AT](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/AT_PUTTY.png)
6. Enter `AT+GMR` and do the same thing as above. You should see the version information
    ![AT+GMR](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/AT+GMR_PUTTY.png)

#### Alternative2: Testing with Arduino Board

_Connection: Rx-Tx1, Tx-Rx1, RST-3.3V, GPIO0 & GPIO2 floating._  
Note that your Arduino board is the one talking to ESP8266.

1. Connect and power up your Arduino board & ESP8266
2. Open up a new Arduino `BareMinimum` example, copy and paste the following code:

    ```c
    // For boards with more than 1 hardware serial ports e.g. Mega
    void setup() {
      Serial.begin(115200);             // Debug message talking on baudrate 115200
      Serial1.begin(115200);            // ESP talking on baudrate 115200
    }
     
    void loop() {
      if (Serial1.available()) {        // ESP wants to talk to you
        Serial.write(Serial1.read());   // Log out what ESP wants to say
      }
     
      if (Serial.available()) {         // You want to talk to ESP (you input and send something via the input field)
        char chars = Serial.read();     // Read 1 byte (1 char) at a time
        Serial1.write(chars);           // Tell ESP your words/commands 1 byte (1 char) at a time
      }
    }
    ```
    - `Serial` is for logging your debug message; `Serial1` is the `Tx1/Rx2` pair which your ESP module is connected to.

    ```c
    // For boards with only 1 hardware serial port e.g. Uno, we have to use SoftwareSerial ports, i.e. take other digital output pins as your serial port
    #include <SoftwareSerial.h>
    SoftwareSerial ESP(3, 2); /* RX:D3, TX:D2 */

    void setup() {
      Serial.begin(115200);             // Debug message talking on baudrate 115200
      ESP.begin(115200);                // ESP talking on baudrate 115200
    }
     
    void loop() {
      if (ESP.available()) {            // ESP wants to talk to you
        Serial.write(ESP.read());       // Log out what ESP wants to say
      }
     
      if (Serial.available()) {         // You want to talk to ESP (you input and send something via the input field)
        char chars = Serial.read();     // Read 1 byte (1 char) at a time
        ESP.write(chars);               // Tell ESP your words/commands 1 byte (1 char) at a time
      }
    }
    ```
    - Try `AT+GMR` command; if you see the message corrupted, i.e. some parts of the message is somehow not readable, don't assume you're ok. see troubleshooting section.

3. Select `Tools > Board > YourConnectedArduinoBoard`, `Tools > Port > YourConnectedPort`. Upload the program
4. The following steps are the same as step 4 ~ step 7 in the main testing method __Testing with Andruino IDE__

## 2. Programing ESP8266

There are basically 2 ways of using the ESP8266 module: __programming ESP8266 like Arduino__ and __talking to ESP8266 via Arduino__. Strictly speaking, the latter one may not really mean to __program__ the module; it is the program we upload into Arduino board that sends commands to ESP8266 on behalf of us.

- __Programming ESP8266 like Arduino__: directly upload programs to ESP8266 and treat it like Arduino
- __Talking to ESP8266 via Arduino__: upload program into Arduino board that sends commands to ESP8266 on behalf of us

I didn't notice the different programming methods at first, and follow whatever the first tutorial I found online that is workable, that is to __program ESP8266 like Arduino__. But later I found that I really need another serial port for communication in addition to the debug port! There are workarounds, as stated in `Getting Started! > Hooking Up ESP8266 + Sending AT Commands > Connections > Key Notes` in this tutorial, but I was too tired to try so. Then I switched to the other method, in which the debug port is the Mega's. 

However, the latter method is less stable then the first one, as errors tend to come out more often with the extra communication between Arduino and ESP. Choose whatever suits your purpose the best.

### Programming ESP8266 Like Arduino

_Connection: Rx-Rx, Tx-Tx, RST-3.3V, GPIO0 & GPIO2 floating._  
Library: [esp8266/arduino](https://github.com/esp8266/arduino#installing-with-boards-manager)

1. Go through the [installation guide](https://github.com/esp8266/arduino#installing-with-boards-manager)
2. Open up any examples under `File > Examples > WiFi`, for example, the `SimpleWebServerWiFi`
3. Replace the `ssid` and `password` with a reachable WiFi AP at your place
    - See troubleshooting for the requirements on the AP network
4. Change the baudrate to a workable one
5. Select `Tools > Board > ESP8266 Modules > Generic ESP8266 Module` (or others if you're not using bare ESP8266), `Tools > Port > YourConnectedPort`
6. Upload the program to ESP
    1. Diconnect power to ESP
    2. Bring `GPIO0` to ground
    3. Power up ESP
    4. Pull out `GPIO0` to float
    5. Click the upload button in IDE
7. You should see something like this:
    ![Upload to ESP](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/Upload_to_ESP.png)

### Talking to ESP8266 via Arduino

_Connection: Rx-Tx1, Tx-Rx1, RST-3.3V, GPIO0 & GPIO2 floating._  
Library: [itead/ITEADLIB_Arduino_WeeESP8266](https://github.com/itead/ITEADLIB_Arduino_WeeESP8266)

1. Install the library
    1. Download the library as a `zip` file
    2. Under `Sketch > Include Libaray`, select `Add .ZIP Library...`
    3. Choose your downloaded `zip` file
2. Open up any examples under `File > Examples > ITEADLIB_Arduino_WeeESP8266`, for example, the `ConnectWiFi`
3. Replace the `ssid` and `password` with a reachable WiFi AP at your place
5. Select `Tools > Board > Arduino AVR Boards > Arduino/Genuino Mega or Mega2560` (or others), `Tools > Port > YourConnectedPort`
6. Upload the program to Arduino board
7. Open up the serial monitor, and you should see messages showing the program interacting with ESP

## 3. Examples

The examples are modified from the ones included in the libraries, but I'll put more comments in the code.

### 1. Client Example - Programming ESP8266 Like Arduino

_Connection: Rx-Rx, Tx-Tx, RST-3.3V, GPIO0 & GPIO2 floating._   
`HTTPClient` is a wrapper of `WiFiWebClient`, which is more easy to use. No need to wrap the request message yourself.  
Modified from: [esp8266/arduino - BasicHttpClient](https://github.com/esp8266/Arduino/blob/master/libraries/ESP8266HTTPClient/examples/BasicHttpClient/BasicHttpClient.ino)

```c
/* Posting values from 0 to 255 onto dweet.io */

#include <stdio.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

#define MAX 255
#define MIN 0

const char* ssid     = "xxx";
const char* password = "xxx";

const char* urlPath = "http://dweet.io/dweet/for/thing-name?value=";                // dweet.io is a simple messaging host for IoT devices
char url[100];

IPAddress ip_static(192,168,137,2);                                                 // Use a static IP address
IPAddress gateway(192,168,137,1);                                                   // Gateway should be the IP of your connected hotspot device
IPAddress subnet(255,255,255,0);                                                    // Check subnet  through that device as well

int value = 0;

void setup() {
  Serial.begin(115200);                                                             // Serial for debug messages, since we're using ESP like Arduino

  // Connect to WiFi network
  WiFi.config(ip_static, gateway, subnet);
  WiFi.begin(ssid, password);
  Serial.print("\n\r \n\rWorking to connect");
 
  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  delay(5000);
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    
    // Create URI for the request
    ++value;
    value %= MAX;

    sprintf(url, "%s%d", urlPath, value);

    Serial.print("connecting to ");
    Serial.println(url);
    
    http.begin(url);                                                                  // TCP handshake with host 
    
    int httpCode = http.GET();                                                        // GET request, return response
    Serial.print("httpCode: ");
    Serial.println(httpCode);
    if (httpCode > 0) {
      String payload = http.getString();
      Serial.println(payload);
    }
 
    http.end();                                                                        // Close TCP connection
  }
}
```

### 2. Client Example - Talking to ESP8266 via Arduino

_Connection: Rx-Tx1, Tx-Rx1, RST-3.3V, GPIO0 & GPIO2 floating._  
Modified from: [ITEADLIB_Arduino_WeeESP8266 - HTTPGET](https://github.com/itead/ITEADLIB_Arduino_WeeESP8266/blob/master/examples/HTTPGET/HTTPGET.ino)

```c
#include "ESP8266.h"

#define SSID        "xxx"
#define PASSWORD    "xxx"
#define HOST_NAME   "dweet.io"
#define HOST_PORT   (80)

ESP8266 wifi(Serial1, 115200);

void setup(void)
{
    Serial.begin(115200);
    Serial.print("setup begin\r\n");

    Serial.print("FW Version:");
    Serial.println(wifi.getVersion().c_str());

    if (wifi.setOprToStationSoftAP()) {
        Serial.print("to station + softap ok\r\n");
    } else {
        Serial.print("to station + softap err\r\n");
    }

    if (wifi.joinAP(SSID, PASSWORD)) {
        Serial.print("Join AP success\r\n");

        Serial.print("IP:");
        Serial.println( wifi.getLocalIP().c_str());       
    } else {
        Serial.print("Join AP failure\r\n");
    }
    
    if (wifi.disableMUX()) {
        Serial.print("single ok\r\n");
    } else {
        Serial.print("single err\r\n");
    }
    
    Serial.print("setup end\r\n");
}
 
void loop(void)
{
    uint8_t buffer[1024] = {0};

    if (wifi.createTCP(HOST_NAME, HOST_PORT)) {
        Serial.print("create tcp ok\r\n");
    } else {
        Serial.print("create tcp err\r\n");
    }

    char *message = "GET /dweet/for/elec3848-group-27-2017?value=1 HTTP/1.1\r\nHost: dweet.io\r\nConnection: keep-alive\r\n\r\n";
    wifi.send((const uint8_t*)message, strlen(message));

    uint32_t len = wifi.recv(buffer, sizeof(buffer), 10000);
    if (len > 0) {
        Serial.print("Received:[");
        for(uint32_t i = 0; i < len; i++) {
            Serial.print((char)buffer[i]);
        }
        Serial.print("]\r\n");
    }

    if (wifi.releaseTCP()) {
        Serial.print("release tcp ok\r\n");
    } else {
        Serial.print("release tcp err\r\n");
    }
    
    delay(5000);
}
```

### 3. Server Example - Programming ESP8266 Like Arduino

_Connection: Rx-Rx, Tx-Tx, RST-3.3V, GPIO0 & GPIO2 floating._   
Modified from: [Adafruit - ESP8266 Temperature / Humidity Webserver](https://learn.adafruit.com/esp8266-temperature-slash-humidity-webserver/code)

```c
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
 
const char* ssid     = "xxx";
const char* password = "xxx";
 
ESP8266WebServer server(80);                                                           // Listening on port 80
 
String webString="";                                                                   // String to display
 
void handle_root() {
  server.send(200, "text/plain", "Hello from esp8266!");                               // If accessing root, respond this message
  delay(100);
}
 
void setup(void)
{
  // You can open the Arduino IDE Serial Monitor window to see what the code is doing
  Serial.begin(115200);
 
  // Connect to WiFi network
  WiFi.begin(ssid, password);
  Serial.print("\n\r \n\rWorking to connect");
 
  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
   
  server.on("/", handle_root);                                                         // If client requests root page, handle it with handle_root subroutine
  
  server.on("/test", [](){                                                             // If client requests /test page, handle it with the code section 
    webString="Hello World!";
    server.send(200, "text/plain", webString);
  });
 
  server.begin();
  Serial.println("HTTP server started");
}
 
void loop(void)
{
  server.handleClient();                                                                // Waiting for clients to connect
} 
```

### 4. Server Example - Talking to ESP8266 via Arduino

_To be released._

# Trouble Shooting

#### 1. Hooking Up ESP8266 + Sending AT Commands

###### Testing with Andruino IDE

- If you do not see `ready` as the response message, and you find that you can't send any commands out or receive any responses, your ESP8266 is probably stuck. Try:
    - Reset: __pull GPIO0 to GND, pull RST to GND, pull RST back to Vcc, pull GPIO0 out to floating__.
    - If not working, power off ESP and power on ESP. Reset again.
    - If not working, follow [this guide](https://www.allaboutcircuits.com/projects/update-the-firmware-in-your-esp8266-wi-fi-module/) on updating your firmware to the latest version. __This is really recommended!!!__
        - Download the latest [Flash Download Tool](http://bbs.espressif.com/viewtopic.php?f=57&t=433)
        - Download the latest [ESP8266 SDK](http://bbs.espressif.com/viewtopic.php?f=46&t=850). Choose __Non-OS SDK__.

###### Testing with Andruino Board

- If you're using Arduino Uno and ESP is sending you responses that doesn't appear readable, the data might be corrupted due to the high baudrate `115200` that Arduino Uno cannot withstand, or some voltage level problems. Try:
    - Ensure every GNDs are connected, including the ESP's and Arduino's GND pins.
    - If not working, lower the baudrate.
    - If not working, switch to Mega or other boards.

#### 2. Programing ESP8266

###### Programming ESP8266 Like Arduino

- If you don't know what `ssid` and `password` are, `ssid` is the network name you would see when you want to connect to WiFi in the available WiFi list e.g. `eduroam`, and `password` is the password. Note that there's no options for `username`, because ESP8266 doesn't accept enterprise protected access points (WPA2_Enterprise)! So you need to have a private AP available. Some common connection points are from:
    ![Available network types](https://raw.githubusercontent.com/pyliaorachel/pyliaorachel.github.io/master/assets/post_img/available_network_types.png)
    - Your router
    - Your mobile phone hotspot
    - Your shared hotspot from a computer that is connected to network cables
        - Under Windows platforms, there is a convenient way to share its network as hotspot:
            1. Open command prompt, run:  

                ```
                netsh wlan show drivers  
                netsh wlan set hostednetwork mode=allow ssid=your-preferred-name key=your-preferred-password
                netsh wlan start hostednetwork
                ```
            2. Make sure the network is allowed to be shared
                1. Press `Windows + r` key, enter `ncpa.cpl`. This opens up `Network Connections` panel.
                2. Right-click `Wi-Fi > properties`, switch to `Sharing` and check the first checkbox under `Internet Connection Sharing` that reads `Allow other network users to connect...`
            3. Test hotspot
                - Take out your mobile phone, connect to hotspot, and try to go to a website. If everything is fine, then you are good to go.

- If you cannot see the uploading progress message, but instead see a lot of mysterious errors such as `espcomm_open failed`, `espcomm_sync failed`, and a whole bunch of other possibilities, try:
    - Check your port selection is the right one. Check your circuit connections, ensure the `GND`s are connected.
    - If not working, repeat the upload process as state in step 6.
    - If not working, power off ESP and power on ESP. Upload again.
    - If not working, unplug your USB and plug in again. Upload again.
    - If not working, follow [this guide](https://www.allaboutcircuits.com/projects/update-the-firmware-in-your-esp8266-wi-fi-module/) on updating your firmware to the latest version. __This is really recommended!!!__
        - Download the latest [Flash Download Tool](http://bbs.espressif.com/viewtopic.php?f=57&t=433)
        - Download the latest [ESP8266 SDK](http://bbs.espressif.com/viewtopic.php?f=46&t=850). Choose __Non-OS SDK__.

###### Talking to ESP8266 via Arduino

- If you're using Arduino Uno and ESP is sending you responses that doesn't appear readable, the data might be corrupted due to the high baudrate `115200` that Arduino Uno cannot withstand, or some voltage level problems. Try:
    - Ensure every GNDs are connected, including the ESP's and Arduino's GND pins.
    - If not working, lower the baudrate.
    - If not working, switch to Mega or other boards.

# Conclusion

So I believe that's all you need to know to successfully setup an ESP8266 module - ok I guess it's pretty much. Now you know how frustrating the process might be setting up this WiFi module for a software person, and how the cheap price comes with a huge cost. But I believe I was the one who encountered most of the errors people are likely to encounter and managed to solve them somehow, so I hope the troubleshooting part is comprehensive enough to cover all of your problems. 

Really have to thank the people who wrote the tutorials, instructables, guides, and documentations online, which are mostly included in the following references (cannot put them all). 

_I will post the sample codes up to GitHub along with a summary of this tutorial as a cheatsheet later if I find time._

# References

I bet I've searched through 100 webpages along my journey on setting up ESP8266 without an error. The \* starred \* ones are the recommended ones that really helped me a lot along my way. Others are more or less the same, but I also took reference on.

- Setting up ESP8266 via USB/TTL converter
    - \* [ESP8266 Wi Fi Module Explain and Connection](http://www.instructables.com/id/ESP8266-Wi-fi-module-explain-and-connection/?ALLSTEPS)
    - [ESP8266 WiFi Module Quick Start Guide](http://rancidbacon.com/files/kiwicon8/ESP8266_WiFi_Module_Quick_Start_Guide_v_1.0.4.pdf)
    - [Getting Started with ESP8266](http://www.esp8266.com/wiki/doku.php?id=getting-started-with-the-esp8266)
    - [Breadboard and Program an ESP-01 Circuit with the Arduino IDE](https://www.allaboutcircuits.com/projects/breadboard-and-program-an-esp-01-circuit-with-the-arduino-ide/)
    - [How to Install the ESP8266 Board in Arduino IDE](http://randomnerdtutorials.com/how-to-install-esp8266-board-arduino-ide/)
    - [Installing and Building an Arduino Sketch for the $5 ESP8266 Microcontroller](http://makezine.com/2015/04/01/installing-building-arduino-sketch-5-microcontroller/)
    - [Serial-to-WiFi Tutorial using ESP8266](http://fab.cba.mit.edu/classes/863.14/tutorials/Programming/serialwifi.html)
- Programming ESP8266 like Arduino
    - \* [ESP8266 Temperature / Humidity Webserver](https://learn.adafruit.com/esp8266-temperature-slash-humidity-webserver/overview)
        - A little bit outdated on IDE setup, but the program uploading steps saved my life!
    - \* [ESP8266 - Easiest way to program so far (Using Arduino IDE)](http://www.whatimade.today/esp8266-easiest-way-to-program-so-far/)
    - [ESP8266-01 using Arduino IDE](https://www.hackster.io/rayburne/esp8266-01-using-arduino-ide-67a124)
    - [ESP8266 ARDUINO TUTORIAL – WIFI MODULE COMPLETE REVIEW](http://www.geekstips.com/esp8266-arduino-tutorial-iot-code-example/)
- Talking to ESP8266 via Arduino
    - [Connecting your Arduino to WiFi via an ESP-8266 module](https://dalpix.com/blog/connecting-your-arduino-wifi-esp-8266-module)
    - [Beginner's Guide to ESP8266 and Tweeting Using ESP8266](http://www.instructables.com/id/Beginners-Guide-to-ESP8266-and-Tweeting-Using-ESP8/)
        - Note that the author said the connection of Rx/Tx depends on the version of ESP8266. Sorry but I doubt that.
- Other nice and comprehensive tutorials
    - \* [深入淺出 Wifi 晶片 ESP8266 with Arduino](https://mlwmlw.org/2015/07/%E6%B7%B1%E5%85%A5%E6%B7%BA%E5%87%BA-wifi-%E6%99%B6%E7%89%87-esp8266-with-arduino/) _Chinese_ _(台灣人好棒棒)_
    - \* [Update the Firmware in Your ESP8266 Wi-Fi Module](https://www.allaboutcircuits.com/projects/update-the-firmware-in-your-esp8266-wi-fi-module/)
- Other examples
    - [ESP8266 Samples](http://www.homeautomationforgeeks.com/ESP8266_samples.shtml)
    - [Arduino port for ESP8266](https://github.com/Karang/Ardunet)
- Documentations
    - [AT Command Set](https://www.espressif.com/sites/default/files/documentation/4a-esp8266_at_instruction_set_en.pdf)













