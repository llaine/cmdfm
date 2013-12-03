#!/bin/bash
function replace() { 
	STR="$@"
	OUTPUT=`echo $STR | sed 's/ /%20/g'`
	echo $OUTPUT
}
theSong="$@"
theSong=`replace $theSong` 
url="https://api.soundcloud.com/search?q=$theSong&facet=model&limit=1&offset=0&linked_partitioning=1&client_id=b45b1aa10f1ac2941910a7f0d10f8e28&app_version=6cc5caa5"
this=`curl -s -H Content-type:application/json $url`
theLinks=`echo $this | grep 'permalink_url":"' | tr ',' "\n" | grep 'permalink_url' | cut -d '"' -f 4`
theUrl=$(echo $theLinks | cut -d" " -f2)
echo $theUrl