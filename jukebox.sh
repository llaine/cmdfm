#!/usr/bin/env bash
# Jukebox for native terminal 
# 
# Made by darksioul6@gmail.com
# https://github.com/llaine/cmdfm
# Fork me ! 


# COLOR FOR PROMPT UI
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"
UNDERLINE="$(tput smul)"

function header {
	clear
	echo $GREEN"
   __        _        _               
   \ \ _   _| | _____| |__   _____  __
    \ \ | | | |/ / _ \ '_ \ / _ \ \/ /
 /\_/ / |_| |   <  __/ |_) | (_) >  < 
 \___/ \__,_|_|\_\___|_.__/ \___/_/\_\ v 1.3
                              
	" $RESET
	echo "$MAGENTA Brought to you by darksioul with <3 & Freedom. $RESET"
	echo ""
}

function genres {
	echo "

$GREEN $UNDERLINE Available genres $RESET
$YELLOW
80s                 Acid Jazz           Acoustic            
Acoustic Rock       African             Alternative         Ambient             
Americana           Arabic              Avantgarde          Bachata             
Bhangra             Blues               Blues Rock          Bossa Nova          
Chanson             Chillout            Chiptunes           Choir               
Classic Rock        Classical           Classical Guitar    Contemporary        
Country             Cumbia              Dance               Dancehall           
Death Metal         Dirty South         Disco               Dream Pop           
Drum & Bass         Dub                 Dubstep             Easy Listening      
Electro House       Electronic          Electronic Pop      Electronic Rock     
Folk                Folk Rock           Funk                Glitch              
Gospel              Grime               Grindcore           Grunge              
Hard Rock           Hardcore            Heavy Metal         Hip-Hop             
House               Indie               Indie Pop           Industrial Metal    
Instrumental Rock   J-Pop               Jazz                Jazz Funk           
Jazz Fusion         K-Pop               Latin               Latin Jazz          
Mambo               Metalcore           Middle Eastern      Minimal             
Modern Jazz         Moombahton          New Wave            Nu Jazz             
Opera               Orchestral          Piano               Pop                 
Post Hardcore       Post Rock           Progressive House   Progressive Metal   
Progressive Rock    Punk                R&B                 Rap                 
Reggae              Reggaeton           Riddim              Rock                
Rock 'n' Roll       Salsa               Samba               Shoegaze            
Singer / Songwriter Smooth Jazz         Soul                Synth Pop           
Tech House          Techno              Thrash Metal        Trance              
Trap                Trip-hop            Turntablism         
$RESET
--------------------------------------------------------------------------------
Usage :$RED ./cmdfm -g minimal $RESET
	"
}

function action {
	echo "+---------------------------------------------+"
	echo "$RED p $RESET $CYAN  # Pause.$RESET"
	echo "$RED n $RESET $CYAN  # Next song in the$YELLOW $1$RESET$CYAN playlist. $RESET"
	echo "$RED g $RESET $CYAN  # Switch to genre.. $RESET"
	echo "$RED e $RESET $CYAN  # Exit the Jukebox. $RESET"
	echo "$RED m $RESET $CYAN  # Display mini menu $RESET"
	echo "+---------------------------------------------+"
}

title=
genre=
streamUrl=
length=
durationSecondes=
pidofMPlayer=

function actionMini {
	echo "$RED p $RESET--> pause | $RED n $RESET--> next | $RED g $RESET--> genre | $RED e $RESET--> exit "
}

# replace all blank space in string by %20 for web query
function replace { 
	STR="$@"
	OUTPUT=`echo $STR | sed 's/ /%20/g'`
	echo $OUTPUT
}

function quit {
	echo "quit" > /tmp/mplayer-control
	echo "$MAGENTA Bye ! $RESET Repo : $YELLOW https://github.com/llaine/cmdfm $RESET"
	echo ""
}

# get song's
#	title
#	genre
#	stream_url
#	duration
# from a style
function getSongFromStyle {
	theGenre="$@"
	theGenre=`replace $theGenre`
	url="https://cmd.fm/api/tracks/search/?genre=$theGenre&limit=1"
	this=`curl -s -H Content-type:application/json $url`
	title=`echo $this | grep 'title":"' | tr ',' "\n" | grep 'title' | cut -d '"' -f 4`
	description=`echo $this | grep '"description":"' | tr ',' "\n" | grep 'description' | cut -d '"' -f 4`
	genre=`echo $this | grep '"main_type":"' |  tr ',' "\n" | grep 'main_type' | cut -d '"' -f 4`
	stream_url=`echo $this | grep 'stream_url":"' | tr ',' "\n" | grep 'stream_url' | cut -d '"' -f 4`
	dur=`echo $this | grep 'duration":' |  tr ',' "\n" | grep 'duration' | egrep -o '[[:digit:]]'`
	duration=`echo $dur | tr -d ' '`
	theReturn="$title||$genre||$stream_url||$duration||$description"
	echo $theReturn
}

function play {	
	streamUrl="$@?client_id=2cd0c4a7a6e5992167a4b09460d85ece"
	mkfifo /tmp/mplayer-control &>/dev/null
	mplayer -slave -quiet -input file=/tmp/mplayer-control $streamUrl &>/dev/null &
}

# Usage function
function usage {
	echo "$GREEN $UNDERLINE USAGE (argv) :$RESET "
	printf "\n"
	echo "$RED -a $RESET 	    # display all the$RED musical genre $RESET."
	echo "$RED -g $RESET$YELLOW<style>$RESET # launch a playlist the selected musical genre."
	printf "\n"
}

runloop () {

	while [[ true ]]; do
		read -p "> " -t$durationSecondes
		printf "\n"
	   	if [[ $REPLY = "e" ]]; then
	   		quit
			break 2
	    elif [[ $REPLY = "p" ]]; then
	    	echo "pause" > /tmp/mplayer-control
	    elif [[ $REPLY = "d" ]]; then
	    	echo "Not currently available"
	    	#urlSong=`./getUrlSong.sh $title`
			#./download.sh $urlSong
	    elif [[ $REPLY = "n" ]]; then
	    	echo "quit" > /tmp/mplayer-control
	    	echo "Fetching next song ..."
			break 1
		elif [[ $REPLY = "m" ]]; then
			actionMini
		else
			echo "quit" > /tmp/mplayer-control
	   		break 1
			fi
	done
}

function main {
	if [[ -z $1 ]]; then
		usage
		exit 1
	fi
	argv=$1
	argc=$#
	[[ -z $3 ]] && argvGenre=$2 || argvGenre=$(replace $2 $3) ; selectedStyle="$2 $3"
	case $argv in
		"-a" )
			genres
			;;
		"-g")
			if [[ -z $argvGenre ]]; then
				usage 
				exit 1
			fi
			informations=`getSongFromStyle $argvGenre`
			if [[ $informations = "||||||||" ]]; then
				printf "\n"
				echo "$BLUE [!]$RESET The $YELLOW $selectedStyle $RESET genre doesn't exit"
				echo "$BLUE [!]$RESET$RED -a $RESET to display the genre available genres"
				printf "\n"
				exit 1
			fi
			header 
			echo "Playlist created ==> $YELLOW $selectedStyle $RESET"
			echo ""
			echo ""
			action "$selectedStyle"
			while [[ true ]]; do
				informations=`getSongFromStyle $argvGenre`
				#echo $informations
				if [[ $informations = "||||||" ]]; then
					printf "\n"
					echo "$BLUE [!]$RESET The $YELLOW $selectedStyle $RESET genre doesn't exit"
					echo "$BLUE [!]$RESET$RED -a $RESET to display the genre available genres"
					printf "\n"
					exit 1
				fi

				IFS='||' read -a songInfo <<< "$informations"
				title="${songInfo[0]}"
				genre="${songInfo[2]}"
				streamUrl="${songInfo[4]}"
				length="${songInfo[6]}"
				durationSecondes=$(($length / 1000 ))
				[[ -z "${songInfo[8]}" ]] && descr="empty" || descr="${songInfo[8]}" 
				
				play $streamUrl #Streaming url
				pidofMPlayer=$(pgrep mplayer)
				if [[ -z $pidofMPlayer ]]; then
					echo "Loading ..."
					break 1
				else
					echo "$GREEN Now Playing :$RESET $YELLOW $title $RESET"
					echo "$GREEN Main genre  :$RESET $YELLOW $genre $RESET"
					echo "$GREEN Description :$RESET $YELLOW $descr $RESET"
					echo ""
				fi
				runloop
			done
			;;
	esac
}
# while [[ true ]]; do
# 	sleep 0.5
# 	length+='#'
# 	echo -ne "$length \r"
# done

main $@
#play http://api.soundcloud.com/tracks/116269654/stream
#pgrep mplayer
