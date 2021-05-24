# voicekeyer
Voice keyer using Linux command line utilities ans rigctld (hamlib).

Based on https://gist.github.com/m5mat/06036af440d2e8ccecf43e553b8ce7b6 (by 2E1HNK, OH1KH, SQ5LTL).
Extended for FT-857D which needs to be tuned to "DIG" to use a sound-card interface.

Requires:
- rigctld (hamblib)
- ncat
- mpg321

For debian-based distributions, use:

    sudo apt-get install libhamlib-utils mpg321 ncat

## Hints

To start rigctld as non-root user, add user to the group owning the serial-interfaces or USB-Serial-adapters:

    sudo usermod -a -G tty $USER
    sudo usermod -a -G dialout $USER
