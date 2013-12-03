#!/bin/bash
this=`curl -L -s --user-agent 'Mozilla/5.0' $1`;
songs=`echo "$this" | grep 'streamUrl' | tr '"' "\n" | sed 's/\\u0026amp;/\&/' | grep 'http://media.soundcloud.com/stream/' | sed 's/\\\\//'`;
titles=`echo "$this" | grep 'title":"' | tr ',' "\n" | grep 'title' | cut -d '"' -f 4`
for (( songid=1; songid <= 1; songid++ ))
do
	title=`echo "$titles" | sed -n "$songid"p`
	echo "[+] Downloading $title..."
	url=`echo "$songs" | sed -n "$songid"p`
	curl -C - -s -L --user-agent 'Mozilla/5.0' -o "$title.mp3" $url;
	echo "[i] Download finish !"
	if [[ -e "download" ]]; then
		mv "$title.mp3" download/
	else
		mkdir download
		mv "$title.mp3" download/
	fi
	echo "[i] Files is now in the download folder"
done


