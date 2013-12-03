#!/bin/bash
# the jukebox terminal based on cmd.fm 
#
# @author: darksioul
# @contact: darksioul6@gmail.com
#
listGenres() {
	echo "
80s                 Abstract            Acid Jazz
Acoustic Rock       Alternative         Ambient
Ballads             Blues               Blues Rock
Chillout            Chiptunes           Choir
Classical           Classical Guitar    Contemporary
Dancehall           Death Metal         Dirty South
Dream Pop           Drum & Bass         Dub
Easy Listening      Electro House       Electronic
Electronic Rock     Folk Rock           Funk
Grime               Grindcore           Grunge
Hardcore            Heavy Metal         Hip-Hop
Indie               Indie Pop           Industrial Metal
Instrumental Rock   J-Pop               Jazz
Jazz Fusion         K-Pop               Latin Jazz
Minimal             Modern Jazz         Moombahton
Nu Jazz             Opera               Orchestral
Pop                 Post Hardcore       Post Rock
Progressive Metal   Progressive Rock    Punk
Rap                 Reggae              Reggaeton
Rock                Rock 'n' Roll       Shoegaze
Smooth Jazz         Soul                Synth Pop
Techno              Thrash Metal        Trance
Trip-hop            Turntablism         Underground
"
printf "\n"
}

help() {
	echo "
./main.sh (or alias) [genre]        # to play tracks in a genre
./main.sh (or alias) g or genres    # to watch all the genre available
"
printf "\n"
}

action() {
	echo "
Welcome to the CLI jukebox ! 

Here are the available commands :
+-------------------------+
|p => Pause the track     |
+-------------------------+
|s => Exit the jukebox    |
+-------------------------+
|d => To download the song|
+-------------------------+
|n => Next song           |
+-------------------------+
"
printf "\n"
}

#Check the evt
command -v curl &>/dev/null || { echo "[!] curl needs to be installed.";  exit 1 ; }
command -v mplayer &>/dev/null || { echo "[!] mplayer needs to be installed."; exit 1 ; }

arg1=$@
case $arg1 in
	"help" | "h" )
		help
		;;
	"genres" | "g")
		listGenres
		;;
	*)
		action
		while [[ true ]]; do
			thePID=$(pidof 'mplayer')
			if [[ -z "${thePID[@]}" ]]; then
				theGenre="$arg1"
				lesInfos=`./getInfoSong.sh $theGenre`
				IFS='||' read -a songInfo <<< "$lesInfos"
				if [[ -z $songInfo ]]; then
					echo "unknow genre"
					exit 1
				fi

				title="${songInfo[0]}"
				genre="${songInfo[2]}"
				streamUrl="${songInfo[4]}"
				duration="${songInfo[6]}"
				durationSecondes=$(($duration / 1000))
				durationMin=$(($duration / (1000 * 60)))

				printf "\n"
				echo "Now playing : $title"
				echo "Song duration : $durationMin min and $durationSecondes sec"

			    process=$(./play.sh $streamUrl)

			    while [[ true ]]; do
			    	read -p ">" -t$durationSecondes
			    	if [[ $REPLY = "s" ]]; then
			    		echo "quit" > /tmp/mplayer-control
			    		echo "Bye ! "
						break 2
				    elif [[ $REPLY = "p" ]]; then
				    	echo "pause" > /tmp/mplayer-control
				    elif [[ $REPLY = "d" ]]; then
				    	urlSong=`./getUrlSong.sh $title`
						./download.sh $urlSong
				    elif [[ $REPLY = "n" ]]; then
				    	echo "quit" > /tmp/mplayer-control
				    	echo "Fetching next song ..."
						break 1
					else
			    		break 1
			    	fi
			    done
			fi
		done
		;;
esac
