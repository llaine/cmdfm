#!/bin/bash
function replace() { 
	STR="$@"
	OUTPUT=`echo $STR | sed 's/ /%20/g'`
	echo $OUTPUT
}
theGenre="$@"
theGenre=`replace $theGenre`
url="https://cmd.fm/api/tracks/search/?genre=$theGenre&limit=1"
this=`curl -s -H Content-type:application/json $url`
title=`echo $this | grep 'title":"' | tr ',' "\n" | grep 'title' | cut -d '"' -f 4`
genre=`echo $this | grep 'genre":"' | tr ',' "\n" | grep 'genre' | cut -d '"' -f 4`
stream_url=`echo $this | grep 'stream_url":"' | tr ',' "\n" | grep 'stream_url' | cut -d '"' -f 4`
dur=`echo $this | grep 'duration":' |  tr ',' "\n" | grep 'duration' | egrep -o '[[:digit:]]'`
duration=`echo $dur | tr -d ' '`
theReturn="$title||$genre||$stream_url||$duration"
echo $theReturn