#!/bin/bash
# within .bashrc:
# (...)
# /path/to/this.script.sh
# exit
#

function no_soup(){
    echo "LOL, nope!"
}

trap no_soup SIGINT

/usr/bin/screen 
