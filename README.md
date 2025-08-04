# ESP32-Check

Because it's not easy to know what you're holding, I wrote a PowerShell script that retrieves the information from the ESP32 chip/module and then, optionally, also erases the ESP32's flash memory.

How to use it? First, read the comments at the beginning of the script so you know what's needed and how to get it.
```
### you must have python installed as well as esptool.py 

### if none of these are on your computer 
### download and install python from https://www.python.org/downloads/
### next run, in CMD window, the command 
###    pip install esptool
### or
###    pip3 install esptool
### or
###    python -m pip install esptool

### if you used the installation as above
$command_info  = 'python -m esptool flash_id'
$command_erase = 'python -m esptool --chip auto erase_flash'

### if you have PlatformIO installed, you might use it like this
# $userProfile = $env:USERPROFILE
# $esptoolPath = '\.platformio\packages\tool-esptoolpy'
# $command_info  = 'python ' + $userProfile + $esptoolPath + '\esptool.py flash_id'
# $command_erase = 'python ' + $userProfile + $esptoolPath + '\esptool.py --chip auto erase_flash'
```
Once that's done, connect an ESP32 module to your computer via USB, run the script... be patient. 
If everything works, you'll see the information and be asked if you want to erase the ESP32.
The ESP32-information is also written to a file with name compossed like this
<chipmodel>_<memory size>_<MAC address>.txt

