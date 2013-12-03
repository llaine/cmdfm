#!/bin/bash
streamUrl=$@
mkfifo /tmp/mplayer-control &>/dev/null
mplayer -slave -input file=/tmp/mplayer-control $streamUrl?client_id=2cd0c4a7a6e5992167a4b09460d85ece &>/dev/null  &