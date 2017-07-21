[![Build Status](https://travis-ci.org/cedlemo/OCaml-libmpdclient.svg?branch=master)](https://travis-ci.org/cedlemo/OCaml-libmpdclient)

# OCaml-libmpdclient

This is an attempt to write a library in order to access to the mpd server.
This lib is based on the mpd protocol ([specifications](https://www.musicpd.org/doc/protocol/)).

## Parts :

*  Querying MPD's status     (*done*)
*  Controlling playback	     (*done*)
*  Playback options	     (*done*)
*  The current playlist	     (*done*)
*  Stored playlists          (*done*)
*  The music database        (*in progress*)
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

### Oasis

#### Build and install

    oasis setup -setup-update dynamic
    ./configure
    make
    make install

#### Build and create doc

    oasis setup -setup-update dynamic
    ./configure
    make
    make install

#### Build and test

    oasis setup -setup-update dynamic
    ./configure --enable-tests
    make test

#### Test sample :

    ./try_mpd_queries.native "play"
    received: OK MPD 0.19.0

    received: OK
    ./try_mpd_queries.native "stop"
    received: OK MPD 0.19.0

    received: OK

### Jbuilder

    jbuilder build
    jbuilder build samples/mpd_status_query.exe
    jbuilder runtest
    jbuilder clean

## TODO :

* The music database
