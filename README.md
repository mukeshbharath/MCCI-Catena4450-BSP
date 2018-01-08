# MCCI-Catena4450-BSP

# MCCI Catena 4450
This repository contains Boards Manager file(.json) and the related packages for Arduino IDE.

The packages are compressed files(.zip) from [ArduinoCore-samd](https://github.com/mcci-catena/ArduinoCore-samd) repository.

In order to successfully build and upload/test the code to the Catena boards, please follow these steps:
- [Install Arduino IDE] (#install-arduino-ide)
- [Install MCCI Catena BSP] (#install-mcci-catena-4450-bsp)
- [Installing the Required MCCI Catena Libraries](#installing-the-required-mcci-catena-libraries)
    - [List of required libraries](#list-of-required-libraries)
- [Install Catena Drivers] (#install-catena-drivers)
- [Build and Download](#build-and-download)

## Install Arduino IDE
Download the respective installer and install the latest release of Arduino IDE from [Arduino IDE] (https://www.arduino.cc/en/Main/Software)

## Install MCCI Catena 4450 BSP
Start Arduino IDE and navigate to `File`>`Preferences` menu.

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/FilePreferences.PNG" width=75% height=75%>

A follwing window will pop up.

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/preferences1.PNG" width=75% height=75%>

A field named **Additional Boards Manager URLs:** is the place where we need to add the json files location. If more than one URL is needed, each URL is separated with a comma(`,`). New MCCI boards and updates to existing boards will automatically be picked up by the Board Manager each time it is opened. The URLs point to index files that the Board Manager uses to build the list of available & installed boards.

In this example, only MCCI board .json file URL will be added, but you can add multiple URLS by separating them with commas. 

Copy and paste the link below into the Additional Boards Manager URLs option in the Arduino IDE preferences.
`https://github.com/mcci-catena/arduino-boards/raw/master/BoardManagerFiles/package_mcci_index.json`

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/preferences2.PNG" width=75% height=75%>

After adding the URL, go to `Tools`>`Board:`--->`Boards Manager...` and install MCCI Catena boards.

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/Toolboardsmanager.PNG" width=75% height=75%>

*note: type "mcci" on search bar and it'll list the MCCI Catena boards.*
<img src="https://github.com/mcci-catena/arduino-boards/blob/master/boardsmanager.PNG" width=75% height=75%>

*note: unlike certain BSPs, there’s no need to install the additional tools; this kit takes care of all that.*

## Installing the Required MCCI Catena Libraries
The script `git-boot.sh` in this directory will get all the things you need.

It's easy to run, provided you're on Windows, macOS, or Linux, and provided you have `git` installed. We tested on Windows with git bash from https://git-scm.org, on macOS 10.11.3 with the git and bash shipped by Apple, and on Ubuntu 16.0.4 LTS (64-bit) with the built-in bash and git from `apt-get install git`.

```shell
$ cd Catena4410-Sketches/catena4450m101_sensor
$ ./git-boot.sh
```

It has a number of advanced options; use `./git-boot.sh -h` to get help, or look at the source code [here](gitboot.sh).

**Beware of issue #18**.  If you happen to already have libraries installed with the same names as any of the libraries in `git-repos.dat`, `git-boot.sh` will silently use the versions of the library that you already have installed. (We hope to soon fix this to at least tell you that you have a problem.)

### List of required libraries

This sketch depends on the following libraries.

*  https://github.com/mcci-catena/Adafruit_FRAM_I2C
*  https://github.com/mcci-catena/Catena4410-Arduino-Library
*  https://github.com/mcci-catena/arduino-lorawan
*  https://github.com/mcci-catena/Catena-mcciadk
*  https://github.com/mcci-catena/arduino-lmic
*  https://github.com/mcci-catena/Adafruit_BME280_Library
*  https://github.com/mcci-catena/Adafruit_Sensor
*  https://github.com/mcci-catena/RTCZero
*  https://github.com/mcci-catena/BH1750
*  https://github.com/mcci-catena/Catena-Arduino-Platform

## Install Catena Drivers
Catena board drivers for installation are under development and will be released shortly.
For time being please use the Arduino driver which supports MCCI Catena boards from C:\Program Files (x86)\Arduino\drivers (Windows OS)

### Procedure for installing the arduino driver
1. Go to Device Manager (Press Windows key + R, under run command type `devmgmt.msc`).
2. Under Device Manager, we can find Catena 4450 under `Other devices`.
<img src="other-devices.PNG" width=75% height=75%>
3. Right click on Catena 4450 and select `Update Driver Software...`
4. Under How do you want to search option, Click the option `Browse my computer for driver software`.
5. For Browse for driver software option, select `Let me pick from a list of device drivers on my computer`.
6. Select device type `Ports (COM & LPT)`.
6. Click `Have disk`.
7. Copy the path `C:\Program Files (x86)\Arduino\drivers` browse field.
8. Select `Adafruit circuit playground` and give `Next`.
9. Driver will get install and the device could be seen under section `Ports` with port number.

## Build and Download

Shutdown the Arduino IDE and restart it, just in case.
Ensure selected board is 'Catena4450' (in the GUI, check that `Tools`>`Board: "..."` says `"Catena4450"`.

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/chooseboard.PNG" width=75% height=75%>

For testing, you can choose `File`>`Examples`>`01.Basics`>`Blink`

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/ex.PNG" width=75% height=75%>

Follow normal Arduino IDE procedures to build the sketch: `Sketch`>`Verify/Compile`.

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/verify.PNG" width=75% height=75%>

and `Sketch`>`Upload`.

<img src="https://github.com/mcci-catena/arduino-boards/blob/master/upload.PNG" width=75% height=75%>

<img src=".PNG" width=75% height=75%>

If the code builds and upload successfully, go on and test the other sketches for the boards.
