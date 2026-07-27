#!/usr/bin/env bash
pkill -x quickshell 2>/dev/null
sleep 0.3
pkill -9 -x quickshell 2>/dev/null
sleep 0.2
quickshell &
disown
