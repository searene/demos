title: beautify i3wm
date: 2016-10-07 08:28:38
tags: [i3, linux]
categories: Coding
thumbnail: /images/i3.png
---

# Motivation
I enjoy using i3wm, big time. You can switch to different windows/apps conveniently with it. The only problem to me is that it's not beautiful enough, and it's ridiculously small in my high-resolution screen. So I decided to change it a little bit.

# Effect
Here is what you would get after applying the method.

![i3wm screenshot](/images/i3wm_screenshot.png)

# Method
To change the appearance, you only need to modify the config file, usually it's `~/.config/i3/config`. Add the following lines.

```
font pango:nimbus sans 18
bar {
  status_command conky -c $HOME/.i3/conky/conkyrc
  mode dock
  position top
  strip_workspace_numbers yes
  colors {
    background #F1F2F6
    statusline #788491
    separator #51c4d4

    focused_workspace  #F1F2F6 #F1F2F6 #4FC0E8
    active_workspace   #F1F2F6 #F1F2F6 #4FC0E8
    inactive_workspace #F1F2F6 #F1F2F6 #C1D1E0
    urgent_workspace   #F1F2F6 #F1F2F6 #C1D1E0
  }
}
```

Remove those lines.

```
font pango:DejaVu Sans Mono 10 (Or whatever the font is)
bar {
        status_command i3status
}
```

Then install `conky` and `font-awesome`, create a new file `~/.i3/conky/conkyrc`, put the following lines in it.

```
###    lovelybacon.deviantart.com   ####

background no
out_to_x no
out_to_console yes
update_interval 1
total_run_times 0
use_spacer none


TEXT
${exec acpi -b | awk "{print $1}" | sed 's/\([^:]*\): \([^,]*\), \([0-9]*\)%.*/\3/'}% \
${exec acpi -b | awk "{print $1}" | sed 's/\([^:]*\): \([^,]*\), \([0-9]*\)%.*/\2/'} \
${if_mpd_playing}${mpd_artist}${mpd_title}${endif}     \
   ${downspeedf wlp3s0} | ${upspeedf wlp3s0}     \
  ${wireless_link_qual_perc wlp3s0}  ${wireless_essid wlp3s0}     \
   ${hwmon 2 temp 1} | ${hwmon 2 temp 3}     \
  ${exec amixer get Master -c 0 -M | grep -oE "[[:digit:]]*%"}     \
  ${time %a %b %d}     \
  ${time %H:%M}   
```

Restart i3, the shortcut of mine is `Shift+$mod+r`, `$mod` could either be `Alt` or `Super key`

# Credit
The above contents are from [lovelybacon.deviantart.com](http://lovelybacon.deviantart.com/art/i3bar-icons-white-edition-575375105), thanks for your amazing work. I only did a little modification.
