#!/bin/bash
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
p/pause              # to pause the track
s/e/stop/exit        # to stop and exit the track and the programm
d/download           # to download the current song
n/next  			 # go next track
"
printf "\n"
}

#Vérification des commandes présentes sur l'env
command -v pidof &>/dev/null || { echo "[!] pidof needs to be installed."; exit 1 ; }
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
		theGenre="$arg1"
		lesInfos=`./getInfoSong.sh $theGenre`

		#Récupération du genre
		IFS='||' read -a songInfo <<< "$lesInfos"

		#Vérification du genre
		if [[ -z $songInfo ]]; then
			echo "Genre inconnu"
			exit 1

		fi

		action
		
		title="${songInfo[0]}"
		genre="${songInfo[2]}"
		streamUrl="${songInfo[4]}"
		
		mkfifo /tmp/mplayer-control &>/dev/null
		mplayer -slave -input file=/tmp/mplayer-control $streamUrl?client_id=2cd0c4a7a6e5992167a4b09460d85ece &>/dev/null  &

		echo "Now playing .... $title"
		
		while [[ 1 ]]; do
			echo -n "> " ; read -r action
			case $action in
				"pause" | "p")
					echo "pause" > /tmp/mplayer-control
					;;
				"stop" | "s" | "exit" | "e")
					echo "quit" > /tmp/mplayer-control
					echo "Bye ! "
					break
					;;
				"download" | "d")
					urlSong=`./getUrlSong.sh $title`
					./download.sh $urlSong
					;;
				"next" | "n")
					echo "quit" > /tmp/mplayer-control
					lesInfos=`./getInfoSong.sh $theGenre`
					#Récupération du genre
					IFS='||' read -a songInfo <<< "$lesInfos"

					title="${songInfo[0]}"
					genre="${songInfo[2]}"
					streamUrl="${songInfo[4]}"
					
					mkfifo /tmp/mplayer-control &>/dev/null
					mplayer -slave -input file=/tmp/mplayer-control $streamUrl?client_id=2cd0c4a7a6e5992167a4b09460d85ece &>/dev/null  &

					echo "Now playing .... $title"
					;;
			esac
		done
		;;
esac