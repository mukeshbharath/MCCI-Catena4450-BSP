# Catena 4450 M101 Sensor Sketch

This sketch is used for the Ithaca power project and other AC power management applications.

It is designed for use with the [Catena 4450](https://github.com/mcci-catena/HW-Designs/tree/master/kicad/Catena-4450) in conjunction with the [Adafruit Feather M0 LoRa](https://www.adafruit.com/product/3178). In order to use this code, you must do several things:

1. Install the Adafruit BSP package.
2. Patch the Adafruit BSP package to add a required API for low-power operation.
3. Install the required Arduino libraries using `git`.
4. Build and download.
5. "Provision" your Catena 4450 -- this involves entering USB commands via the Arduino serial monitor to program essential identity information into the Catena 4450, so it can join the targetd network.

## Install the Arduino SAMD board support library

This is a little confusing. Before you install the *Adafruit* board support package (BSP), you need to install the *Arduino* SAMD board support package.

You do this through the board manager.

![Boards Manager](./arduino-boards-manager.png)

You can type **Arduino SAMD** in the search bar of the Boards Manager, then when you see the entry for **Arduino SAMD boards (32-bit ARM Cortex-M0+)** by **Arduino**, click install.

## Installing the Adafruit BSP
Follow the instructions given under [Arduino IDE Setup](https://learn.adafruit.com/adafruit-feather-m0-radio-with-lora-radio-module/setup) in Feather M0 Tutorial on the Adafruit website. **TL;DR**: go to `File>Preferences>Settings` in the Arduino IDE and add `https://adafruit.github.io/arduino-board-index/package_adafruit_index.json` to the list in `Additional Boards Manager URLs`. Use a semicolon (`;`) to separate multiple entries if needed.

## Patch the Adafruit BSP package
To support low-power sleep, we need to add an extra API to the Arduino BSP. If you don't do that, you'll get the following error when you try to compile ("verify" or "verify and download") your sketch.

```
Users/example/Documents/Arduino/catena4410_sensor1/catena4410_sensor1.ino: In function 'void settleDoneCb(osjob_t*)':
catena4410_sensor1:664: error: 'adjust_millis_forward' was not declared in this scope
     adjust_millis_forward(CATCFG_T_INTERVAL  * 1000);
                                                    ^
exit status 1
'adjust_millis_forward' was not declared in this scope
```

To update your BSP, you need to enter the following commands in git bash (on Windows) or your shell (on macOS or Linux):

```shell
# Get to the right directory for updating the BSP.
# You will need to change 1.0.18 to whaever version you have.
# With git bash on Windows:
cd ~/AppData/Local/arduino15/packages/adafruit/hardware/samd/1.0.18

# With bash on macOS
cd ~/Library/Arduino15/packages/adafruit/hardware/samd/1.0.18

# With bash on Linux
cd ~/.arduino15/packages/adafruit/hardware/samd/*

# add an upstream repository reference for the MCCI patches
git remote add mcci-catena https://github.com/mcci-catena/ArduinoCore-samd.git

# update the repository with the MCCI patches.
git fetch mcci-catena

# get the patched (but older branch)
git checkout TMM-Sleep

# now slide any patches that were subsequent to our snapshot 
# into your current repo
git rebase master
```
The rebase should succeed without conflicts.  If it does not, most likely it's because you've modified your BSP image (either on purpose or accidentally). In that case, we strongly recommend that you reinstall the BSP. The above procedure works for us as long as the BSP is as distributed by Adafruit. (If there's a problem, please open an issue at https://github.com/mcci-catena/ArduinoCore-samd.git, and we'll fix it as soon as we can.)

## Installing the required libraries
Before you build this sketch, you must also install the following libraries.
*  https://github.com/mcci-catena/Adafruit_FRAM_I2C
*  https://github.com/mcci-catena/Catena4410-Arduino-Library
*  https://github.com/mcci-catena/arduino-lorawan
*  https://github.com/mcci-catena/Catena-mcciadk
*  https://github.com/mcci-catena/arduino-lmic
*  https://github.com/mcci-catena/Adafruit_BME280_Library
*  https://github.com/mcci-catena/Adafruit_Sensor
*  https://github.com/mcci-catena/RTCZero
*  https://github.com/mcci-catena/BH1750

The script `git-boot.sh` in this directory will get all the things you need.

It's easy to run, provided you're on Windows, macOS, or Linux, and provided you have `git` installed. We tested on Windows with git bash from https://git-scm.org, on macOS 10.11.3 with the git and bash shipped by Apple, and on Ubuntu 16.0.4 LTS (64-bit) with the built-in bash and git from `apt-get install git`.

```shell
$ cd Catena4410-Sketches/catena4450m101_sensor
$ ./git-boot.sh
```

It has a number of advanced options; use `./git-boot.sh -h` to get help, or look at the source code [here](gitboot.sh).

**Beware of issue #18**.  If you happen to already have libraries installed with the same names as any of the libraries in `git-repos.dat`, `git-boot.sh` will silently use the versions of the library that you already have installed. (We hope to soon fix thisto at least tell you that you have a problem.)

## Build and Download

Shutdown the Arduino IDE and restart it, just in case.

Ensure selected board is 'Adafruit Feather M0' (in the GUI, check that `Tools`>`Board "..."` says `"Adafruit Feather M0"`.

Follow normal Arduino IDE procedures to build the sketch: `Sketch`>`Verify/Compile`. If there are no errors, go to the next step.

## Disabling USB Sleep (Optional)
The `catena4450m101_sensor` sketch uses the SAMD "deep sleep" mode in order to reduce power. This works, but it's inconvenient in development. See **Deep Sleep and USB** under **Notes**, below, for a technical explanation. 

In order to keep the Catena from falling asleep while connected to USB, make the following change.

Search for
```
if (Serial.dtr() || fHasPower1)
```
and change it to
```
if (Serial.dtr() | fHasPower1 || true)
```
![USB Sleep Fix](./code-for-sleep-usb-adjustment.png)

## Load the sketch into the Catena

Make sure the correct port is selected in `Tools`>`Port`. 

Load the sketch into the Catena using `Sketch`>`Upload` and move on to provisioning.

## Provision your Catena 4450
This can be done with any terminal emulator, but it's easiest to do it with the serial monitor built into the Arduino IDE or with the equivalent monitor that's part of the Visual Micro IDE.

### Check platform provisioning

![Newline](./serial-monitor-newline.png)

At the bottom righ side of the serial monitor window, set the dropdown to `Newline` and `115200 baud`.

Enter the following command, and press enter:
```
system configure platformguid
```
If the Catena is functioning at all, you'll either get an error message, or you'll get a long number like:
```
82BF2661-70CB-45AE-B620-CAF695478BC1
```
(Several numbers are possible.)

![platformguid](./system-configure-platformguid.png)

![platform number](./platform-number.png)

If you get an error message, please follow the **Platform Provisioning** instructions. Othewise, skip to **LoRAWAN Provisioning**.

### Platform Provisioning
The Catena 4450 has a number of build options. We have a single firmware image to support the various options. The firmware figures out the build options by reading data stored in the FRAM, so if the factory settings are not present or have been lost, you need to do the following.

If your Catena 4450 is fresh from the factory, you will need to enter the following commands.

`system configure syseui` _`serialnumber`_

You will find the serial number on the Catena 4450 assembly. If you can't find a serial number, please contact MCCI for assistance.

Continue by entering the following commands.
```
system configure operatingflags 1
system configure platformguid 82BF2661-70CB-45AE-B620-CAF695478BC1
```

### LoRaWAN Provisioning
If you're using The Things Network, go to https://console.thethingsnetwork.org and follow the instructions to add a device to your application. This will let you input the devEUI (we suggest using the serial number), and get the AppEUI and the Application Key. For other networks, follow their instructions for determining the devEUI and getting the AppEUI and AppKey.

Then enter the following commands in the serial monitor, substituting your _`DevEUI`_, _`AppEUI`_, and _`AppKey`_, one at a time.

`lorawan configure deveui` _`DevEUI`_  
`lorawan configure appeui` _`AppEUI`_  
`lorawan configure appkey` _`AppKey`_  
`lorawan configure join 1`

After each command you will see an `OK`.

![provisioned](./provisioned.png)

Then reboot your Catena (using the reset button on the upper board).

## Notes

### Data Format
Refer to the [Protocol Description](../extra/catena-message-0x14-format.md) in the `extras` directory for information on how data is encoded.

### Unplugging the USB Cable while running on batteries
The Catena 4450 comes with a rechargable LiPo battery. This allows you to unplug the USB cable after booting the Catena 4450 without causing the Catena 4450 to restart.

Unfortunately, the Atmel USB drivers for the Feather M0 do not distinguish between cable unplug and USB suspend. Any `Serial.print()` operation referring to the USB port will hang if the cable is unplugged after being used during a boot. The easiest work-around is to reboot the Catena after unplugging the USB cable. You can avoid this by using the Arduino UI to turn off DTR before unplugging the cable... but then you must remember to turn DTR back on. This is very fragile in practice.

### Deep sleep and USB
When the Catena 4450 is in deep sleep, the USB port will not respond to cable attaches. However, the PC may see that a device is attached, and complain that it is malfunctioning. This sketch does not normally use deep sleep, so you might not see this problem. But if you do, unplug the cable, unplug the battery, then plug in the cable.  A simple change (described above as **Disabling USB Sleep (Optional)**) will disable deep sleep altogether, which may make things easier.

As with any Feather M0, double-pressing the RESET button will put the Feather into download mode. To confirm this, the red light will flicker rapidly. You may have to temporarily change the download port using `Tools`>`Port`, but once the port setting is correct, you should be able to download no matter what state the board was in. 

### gitboot.sh and the other sketches
The sketches in other directories in this tree are for engineering use at MCCI. `git-boot.sh` does not necessarily install all the required libraries needed for building them. However, all the libraries should be available from https://github.com/mcci-catena/.

