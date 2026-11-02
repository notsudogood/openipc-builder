![OpenIPC logo][logo]

## OpenIPC Builder
_(based on Buildroot)_

[![Telegram](https://openipc.org/images/telegram_button.svg)][telegram]

### Specialized features

- Tweaker for automatically configuring devices according to profile (gpio, wifi, etc).
- Specialized _[storage location](https://github.com/OpenIPC/builder/releases/tag/latest)_ for customized firmware for well-known devices.
- QR code recognition to automatically _[connect to WiFi](https://openipc.org/tools/qr-code-generator)_ on your home network.


### Supported device

```
OpenIPC URLLC AIO        SSC338Q      IMX415    RTL8812EU_USB    NOR_16M   done
EMAX Wyvern Link Alpha   SSC338Q      IMX415    RTL8812CU_USB    NOR_16M   untested
(board not yet named)    SSC378QE     IMX415    RTL8812EU_USB    NOR_16M?  built blind, never booted
                                                                           -- docs/ssc378qe-first-flash.md
```


### Device setup

#### WiFi Settings
Run these commands and enjoy:
```
fw_setenv wlanssid 'OpenIPC'
fw_setenv wlanpass 'mypassword'
reboot
```


### Requirements for registration of new devices

When adding new devices, please follow a few simple rules. 
The list of files to be added should be minimal, try not to store binary files, remember that all common files 
and configurations should be stored in the [firmware](https://github.com/openipc/firmware) repository. 
However, some list of files must be required.

```
processor_flavor_vendor-model-version/br-ext-chip-sigmastar/configs/processor_flavor_vendor-model-version_defconfig
processor_flavor_vendor-model-version/general/overlay/usr/share/openipc/customizer.sh
processor_flavor_vendor-model-version/general/scripts/excludes/processor_flavor.list
```

The file names contain variables with option names - **flavor, model, processor, vendor, version**

- flavor - firmware direction in the openipc system, by default try to use "lite" as much as possible
- model - official model name from the main device manufacturer
- processor - official name of the processor in the OpenIPC [structure](https://openipc.org/supported-hardware/full-list)
- vendor - the name of the official equipment manufacturer; if there are several of them, a [description](https://github.com/OpenIPC/builder/tree/master#compatibility-and-clones) is created
- version - usually this is an addition to the model, version or revision of hardware differences

### Preparing and using the project

```
sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync \
  unzip mc tree python-is-python3
git clone https://github.com/openipc/builder.git
cd builder
./builder.sh
```

### Create firmware with built-in credentials
- Usage: `repack.sh [uboot] [firmware] [ssid] [pass]`
```
sh repack.sh ssc338q ssc338q_fpv_openipc-urllc-aio-nor router password
```

### Existing problems

- On some devices NOR flash 8M is small, and the WiFi driver is very large and the QR scanner currently does not fit into the firmware

### Additional information

- https://github.com/OpenIPC/wiki/blob/master/en/guide-supported-devices.md

### Technical support and donations

Please **_[support our project](https://openipc.org/support-open-source)_** with donations or orders for development or maintenance. Thank you!

<p align="center">
<a href="https://opencollective.com/openipc/contribute/backer-14335/checkout" target="_blank"><img src="https://opencollective.com/webpack/donate/button@2x.png?color=blue" width="250" alt="Open Collective donate button"></a>
</p>

[firmware]: https://github.com/openipc/firmware
[logo]: https://openipc.org/assets/openipc-logo-black.svg
[mit]: https://opensource.org/license/mit
[opencollective]: https://opencollective.com/openipc
[paypal]: https://www.paypal.com/donate/?hosted_button_id=C6F7UJLA58MBS
[project]: https://github.com/openipc
[telegram]: https://openipc.org/our-channels
[website]: https://openipc.org
[wiki]: https://github.com/openipc/wiki
