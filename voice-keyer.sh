#!/bin/bash
#
# 2E1HNK Linux Digital Voice Keyer
# 

# Based on: https://www.cqrlog.com/node/879
# Credits:
#   - OH1KH
#   - SQ5LTL

# install sox with all soundformats support
# Use "rec ~/voice-keyer/F1.mp3" to record F1 message. End recording with Ctrl-C.
# same with F2.mp3 Etc....
# you may use also mpg123 or what ever terminal mode player you wish

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

if ! ps aux | grep -q '[m]pg123'
then
#ptt via rigctld on
echo 'T1' | nc --send-only -t 127.0.0.1 4532
#select audio card (if more than one)
#export AUDIODEV=hw:1,0
#play F-key message
mpg123 ~/voice-keyer/$1.mp3
#ptt via rigctld off
echo 'T0' | nc --send-only -t 127.0.0.1 4532
else
#halt playing message (if pressed while playing)
killall play
fi