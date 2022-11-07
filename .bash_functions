#!/usr/bin/env bash

function mkcd() {
  mkdir -p "$1" 
  cd "$1"
}

connect() {
    bluetoothctl power on
    bluetoothctl connect $1
}

function cwd() { 
  pwd | tr -d '\n' | xclip -selection clipboard 
}

function ngap() {
  echo 'require("awful").screen.focused().selected_tag.gap = 0' | awesome-client 
}

function agap() {
  echo 'require("awful").screen.focused().selected_tag.gap = 6' | awesome-client 
}

