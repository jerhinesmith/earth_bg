#!/usr/bin/env bash

sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "update data set value = '/Users/justin/projects/earth_bg/current.png'";
killall Dock;
