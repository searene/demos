title: connect to wifi via commandline on arch
date: 2016-06-08 20:16:30
tags: [linux, network]
categories: Coding
thumbnail: http://baltimorecomputersolutions.net/wp-content/uploads/2014/09/network_monitor.jpg
---

I just spent hours connecting to the wireless network on archlinux today. Finally I resorted to various tools in commandline. Here's how I do it. Make sure you run the following commands as root to avoid some permission errors.

# Find out SSID of the target wifi

```
iw dev "your_interface" scan | less
```

Replace *your_interface* with your own one, usually it's *wlp3s0* or *wlan0*. You can run `ifconfig` to find out the name of your interface

You will get something like

```
BSS fc:d7:33:59:74:74(on wlp3s0) -- associated
        TSF: 85505115422 usec (0d, 23:45:05)
        freq: 2412
        beacon interval: 100 TUs
        capability: ESS Privacy ShortPreamble ShortSlotTime (0x0431)
        signal: -54.00 dBm
        last seen: 136 ms ago
        Information elements from Probe Response frame:
        SSID: TP-LINK_7474
        Supported rates: 1.0* 2.0* 5.5* 11.0* 6.0 9.0 12.0 18.0 
		...
```
The SSID is something after *SSID*. It's *TP-LINK_7474* in my case.

# Association

After finding out your SSID, you would need to connect to it. There are two cases here, one is when there's no encryption and one is when *WPA/WPA2* is enabled. Find the case that suits you most.

## No Encryption

This is pretty easy, you only need one line here.

```
iw dev wlan0 connect "your_essid"
```

*your_essid* is the name of the network you found out before, such as *TP-LINK_7474*

Then you will need to [Get an IP address](#Get-IP-Address)

## WPA/WPA2

You have a lot of work to be done here. First create a new file `/etc/wpa_supplicant/wpa_supplicant.conf`. Type in the following contents and save it.

```
ctrl_interface=/var/run/wpa_supplicant
update_config=1
```

Generate passphrase and save it to the above file. Replace *your_SSID* and *your_key* with your own ones.

```
wpa_passphrase "your_SSID" "your_key" >> /etc/wpa_supplicant/wpa_supplicant.conf
```

Check if wpa_supplicant is running.

```
ps -aux|grep wpa_supplicant
```

If it's running, just as follows

```
root     21108  0.0  0.0  43488  3260 ?        Ss   20:01   0:00 wpa_supplicant -i wlp3s0 -B -c /etc/wpa_supplicant/wpa_supplicant.conf
```

Kill the process, and remove `/var/run/wpa_supplicant/` if it exists

```
kill 21108
rm /var/run/wpa_supplicant -rf
```

If it's not running or you've killed the running one, run the following command to start `wpa_supplicant`.

```
wpa_supplicant -B -i "your_interface" -c /etc/wpa_supplicant/wpa_supplicant.conf
```

# Get IP Address

After connect to the network, you need to get an IP using `dhcpcd`

```
dhcpcd wlp3s0
```

Wait for several seconds. If everything went smoothly, you would be connected to the network successfully.
