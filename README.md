[![Build Status](https://travis-ci.org/cedlemo/OCaml-libmpdclient.svg?branch=master)](https://travis-ci.org/cedlemo/OCaml-libmpdclient)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub issues](https://img.shields.io/github/issues/cedlemo/OCaml-libmpdclient.svg)](https://github.com/cedlemo/OCaml-libmpdclient/issues)
[![GitHub stars](https://img.shields.io/github/stars/cedlemo/OCaml-libmpdclient.svg)](https://github.com/cedlemo/OCaml-libmpdclient/stargazers)

# OCaml-libmpdclient

This is an attempt to write a library in order to access to the mpd server.
This lib is based on the mpd protocol ([specifications](https://www.musicpd.org/doc/protocol/)).

## Parts :

*  Querying MPD's status     (*done*)
*  Controlling playback	     (*done*)
*  Playback options	     (*done*)
*  The current playlist	     (*done*)
*  Stored playlists          (*done*)
*  The music database        (*done*)
*  Mounts and neighbors      (*to do*)
*  Stickers                  (*to do*)
*  Connection settings       (*to do*)
*  Partition commands        (*to do*)
*  Audio output devices      (*to do*)
*  Reflection                (*to do*)
*  Client to client          (*to do*)

### API :

*  https://cedlemo.github.io/OCaml-libmpdclient/


## Install

### Jbuilder

    jbuilder build
    jbuilder build samples/mpd_status_query.exe
    jbuilder runtest
    jbuilder clean

### Test sample :

    ./try_mpd_queries.native "play"
    received: OK MPD 0.19.0

    received: OK
    ./try_mpd_queries.native "stop"
    received: OK MPD 0.19.0

    received: OK

## TODO :

* The music database
* Improve connection error when no mpd found or bad host or bad port.
* Continue OCaml-mpdc : a command line tool which is a Mpd client.
  * finish status commands (link parameters to theirs mpd call)
