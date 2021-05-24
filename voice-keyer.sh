#!/bin/bash
#
# OE4AMW, based on 2E1HNK Linux Digital Voice Keyer
#

# FT-857 (and maybe other models) need to be switched to mode "DIG" to enable audio from rear connector
SWITCHTODIG=1
# Based on: https://www.cqrlog.com/node/879
# Credits:
#   - OH1KH
#   - SQ5LTL

if [ $# -eq 0 ]
then
 echo "usage: ./voice-keyer.sh <Recording-ID> (filename without extension '.mp3')"
 echo ""
 echo "Requires:"
 echo "- hamlib's rigctld - start e.g.: with 'rigctld -m 122 -r /dev/ttyUSB0  --set-conf=serial_speed=9600  -vvv'"
 echo "- ncat"
 echo "- mpg123"
 echo ""
 echo "Optionally: sox to use 'rec' for recording. E.g.: Use 'rec ~/voice-keyer/F1.mp3' to record F1 message. End recording with Ctrl-C"
 exit 1
fi

# install sox with all soundformats support
# Use "rec ~/voice-keyer/F1.mp3" to record F1 message. End recording with Ctrl-C.
# same with F2.mp3 Etc....
# Suggested Contents:
#   F1          QRZ 2E1HNK/P
#   F2          CQ CQ CQ Contest this is 2E1HNK/P 2E1HNK/P calling CQ Contest and standing by
#   F3          
#   F4          

# In Ubuntu's 'Keyboard Shortcuts' create the following:
#   Ctrl + F1   ~/voice-keyer/voice-keyer.sh F1
#   Ctrl + F2   ~/voice-keyer/voice-keyer.sh F2
#   Ctrl + F3   ~/voice-keyer/voice-keyer.sh F3
#   Ctrl + F4   ~/voice-keyer/voice-keyer.sh F4
#   ...

# cqrlog "TRX control"/"Extra command line arguments" add following
# text "-p /dev/ttyXXX -P YYY" (you may all ready have some text there)
# Where XXX os the same device as you have in "TRX control"/"Device"
# and YYY is the line you have connected (via relay or transistor) to
# your rig's PTT (usually DTR or RTS)
# At "TRX control"/"Radio xxx serial parameters set handshake none
# and at least your YYY (DTR or RTS) to "Unset"

if ! pgrep -f "mpg123.*voice-keyer" > /dev/null
then
 if [ x"$SWITCHTODIG" = "x1" ]
 then
  echo "SWITCHING TO MODE DIGITAL. MAKE SURE TO CONFIGURE CORRECT MODE ON TRX IN Menu 038!"
  # TODO: get currently selected Mode
  MODE=`echo 'm' | ncat  --send-only   -t 127.0.0.1 4532`
  echo "Previous mode: $MODE"
  # switch to DIG
  echo 'M PKTUSB 0' | ncat  --send-only   -t 127.0.0.1 4532
 else
  echo "Not switching mode ..."
 fi
 #ptt via rigctld on
 echo 'T1' | ncat --send-only -t 127.0.0.1 4532

 # Use mechanisms of the used backend to select the used audio-card.
 #  Pulseaudio: use the tools of your desktop
 #  Others (e.g. alsa): add -o <type> -a <device>  (see 'man mpg321')

 mpg123 ~/voice-keyer/$1.mp3
 #ptt via rigctld off
 echo 'T0' | ncat --send-only -t 127.0.0.1 4532
 if [ x"$SWITCHTODIG" = "x1" ]
 then
  echo "M $MODE" | ncat  --send-only   -t 127.0.0.1 4532
 else
  echo "Not switching mode ..."
 fi
else
 #halt playing message (if pressed while playing)
 pkill -f "mpg123.*voice-keyer"
fi

exit 0
