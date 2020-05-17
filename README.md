# BatteryStatusShow
### View detail battery information on OSX for IOS and MAC devices

![ pic1](/README/readme_pic1.png)
![ pic2](/README/readme_pic2.png)

#### Version 1.5


##### 1. Updated view and change of Battery Change Limit Level (By modifiy of SMC, USE AS YOUR RISK!)

   
```
To change of Changing Limit, such 70% to stop change, 
start BatteryStatusShow > macOS > click change button next Charge Level
A dialog with a slider to adjust the changing level, default is 100% 
Click OK,input your sudo password on next dialog
Finish!
May need up to above one minutes to update the status.

Resume default value simple set to 100% or reset SMC
Tested under 10.15.4 Macbook Pro 2018, may or may not work on your model.
```
##### 2. Update macOS device detail
##### 3. Update IOS device detail


## Download complied APP 
[BatteryStatusShow_1.5.zip](/release/BatteryStatusShow_1.5.zip)

### Complie
1. clone this git
2. complie smcutil scheme
3. complie BatteryStatusShow scheme

Copyright (c) 2020 SC Lee. All rights reserved.

Libmobiledevice http://www.libimobiledevice.org
smcutil modify from https://github.com/RehabMan/OS-X-FakeSMC-kozlek







