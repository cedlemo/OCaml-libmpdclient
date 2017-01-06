# OCaml-libmpdclient

This is an attempt to write a library in order to access to the mpd server.
This lib is based on the mpd protocol ([specifications](https://www.musicpd.org/doc/protocol/)).
Later it should be inspired by the C [libmpdclient](https://www.musicpd.org/libs/libmpdclient/) and its organisation.

## Build and install

    oasis setup -setup-update dynamic
    ./configure
    make
    make install

## Build and create doc

    oasis setup -setup-update dynamic
    ./configure
    make
    make install

## Build and test

    oasis setup -setup-update dynamic
    ./configure --enable-tests
    make test

## Test sample :

    ./try_mpd_queries.native "play"
    received: OK MPD 0.19.0

    received: OK
    ./try_mpd_queries.native "stop"
    received: OK MPD 0.19.0

    received: OK

