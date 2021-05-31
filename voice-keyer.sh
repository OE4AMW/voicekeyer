#!/bin/bash
#
# OE4AMW, based on 2E1HNK 'Linux Digital Voice Keyer', based on: https://www.cqrlog.com/node/879
# Credits:
#   - OH1KH
#   - SQ5LTL


# FT-857 (and maybe other models) need to be switched to mode "DIG" to enable audio from rear connector
SWITCHTODIG=1


if [ $# -eq 0 ]
then
 echo "usage: ./voice-keyer.sh <Recording-ID> (filename without extension '.mp3')"
 echo ""
 echo "Requires:"
 echo "- hamlib's rigctld - start e.g.: with 'rigctld -m 122 -r /dev/ttyUSB0  --set-conf=serial_speed=9600  -vvv'"
 echo "- ncat"
 echo "- mpg321"
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

  while read line
  do
   if [[ "$line" ==  RPRT* ]]; then
    echo "Received line: $line"
    break
   else
    if [[ "$line" == Mode* ]]; then
     MODE=`echo $line | cut -d' ' -f2`
     continue
    else if [[ "$line" == Passband* ]]; then
     PASSBAND=`echo $line | cut -d' ' -f2`
     continue
    fi
   fi
   echo "received: $line"
  fi
  done < <( (echo "+\get_mode" ) | nc -w 15 -t 127.0.0.1 4532 )

  echo "Previous mode: $MODE $PASSBAND"
  # switch to DIG
  echo "Switching mode before PTT"
  echo 'M PKTUSB 0' | nc -N -t 127.0.0.1 4532
 else
  echo "Not switching mode ..."
 fi


 # PTT via rigctld on. Note to self: Combining both commands in one invocation of nc ( echo -e "M PKTUSB 0\nT1" | nc -N -t 127.0.0.1 4532 ) did not work reliably, sometime radio returns -9
 echo 'T1' | nc -N -t 127.0.0.1 4532
 if [ $? -ne 0 ]
 then
  echo ""
  echo "rigctld NOT RUNNING!!!"
  echo ""
 fi

 # Use mechanisms of the used backend to select the used audio-card.
 #  Pulseaudio: use the tools of your desktop
 #  Others (e.g. alsa): add -o <type> -a <device>  (see 'man mpg321')

 mpg123 ~/voice-keyer/$1.mp3
 #ptt via rigctld off
 echo 'T0' | nc -N -t 127.0.0.1 4532
 if [ x"$SWITCHTODIG" = "x1" ]
 then
  echo "Switch back to $MODE $PASSBAND"
  echo -e "M $MODE $PASSBAND" | nc -N -t 127.0.0.1 4532

 else
  echo "Not switching mode ..."
 fi
else
 #halt playing message (if pressed while playing)
 echo "Stopping previous playback ..."
 pkill -f "mpg123.*voice-keyer"
fi

exit 0
