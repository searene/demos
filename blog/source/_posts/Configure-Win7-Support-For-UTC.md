title: Configure Win7 Support For UTC
date: 2015-12-06 17:46:08
categories: Coding
tags: [linux, win7]
thumbnail: http://alien-homepage.de/weather_start/current_site_template_%20expl_english/weathersite%20general%20template/images/timezones/gif/large_images/utc-5/webfiles/utc-5.png
---

I have a virtual machine installed on ubuntu, the virtual machine contains an operation system of Win7. Win7 uses localtime, but ubuntu uses UTC, so the time they display is different. To fix this, I decided to set Win7 to use UTC. Here is the solution.

1. `Win` + `S`, register, `enter`
2. Navigate to the key `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`
3. Create new DWORD (32-bit) Value, name it `RealTimeIsUniversal`.
4. Set its value to `1`.
5. Reboot to BIOS settings, set the hardware clock to the correct time in UTC.
