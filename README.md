# voicekeyer
Voice keyer using Linux command line utilities ans rigctld (hamlib).

Based on https://gist.github.com/m5mat/06036af440d2e8ccecf43e553b8ce7b6 (by 2E1HNK, OH1KH, SQ5LTL).
Extended for FT-857D which needs to be tuned to "DIG" to use a sound-card interface on the rear data-connector.

Requires:
- rigctld (hamblib)
- nc (openbsd)
- mpg321

Recommends:
- sox (for recording)

For debian-based distributions, use:

    sudo apt-get install libhamlib-utils mpg321 netcat-openbsd

## Usage:
- Place mp3 to directory ~/voice-keyer/
    - e.g. record using "rec ~/voice-keyer/F1.mp3".
- Make sure that rigctld is running
    - e.g. "rigctld -m 122 -r /dev/ttyUSB0  --set-conf=serial_speed=9600  -vvv" (for a FT-857D) in a separate terminal
- Call script with name of the recording (without extension .mp3) as command-line-argument.
    - E.g.: "./voice-keyer.sh F1"

Intended to be configured as keyboard-macro in the tool of your choice.

## Hints

To start rigctld as non-root user, add user to the group owning the serial-interfaces or USB-Serial-adapters:

    sudo usermod -a -G tty $USER
    sudo usermod -a -G dialout $USER

# Config-Options
Set SWITCHTODIG to a value != 1 If you do not want to switch to mode DIG (for FT-857D).
When using SWITCHTODIG, make sure that Menu 038 is configured to the intended mode (USER-U for USB, USER-L for LSB).
