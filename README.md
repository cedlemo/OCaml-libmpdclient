# OCaml-libmpdclient

This is an attempt to write a library in order to access to the mpd server.
This lib is based on the mpd protocol ([specifications](https://www.musicpd.org/doc/protocol/)).

## Parts :

*  Querying MPD's status     (*done*)
*  Controlling playback	     (*done*)
*  Playback options	     (*done*)
*  The current playlist	     (*almost*)
*  Stored playlists          (*to do*)
*  The music database        (*to do*)
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

