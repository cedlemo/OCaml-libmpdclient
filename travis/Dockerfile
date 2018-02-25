FROM ubuntu:17.10

RUN \
  apt update && \
  apt install -y \
    sudo \
    git \
    darcs \
    mercurial \
    gcc \
    g++ \
    make \
    wget \
    mpd \
    libmpd-dev \
    aspcud \
    m4 \
    unzip \
    pkg-config \
    patch

RUN \
  useradd --user-group --create-home ocaml-libmpdclient

RUN \
  echo "ocaml-libmpdclient ALL=(ALL:ALL) NOPASSWD:ALL" | \
    EDITOR=tee visudo -f /etc/sudoers.d/ocaml-libmpdclient

USER ocaml-libmpdclient
ENV WDIR=/home/ocaml-libmpdclient/ocaml-libmpdclient
ENV TMP=$WDIR/tmp
COPY . /home/ocaml-libmpdclient/ocaml-libmpdclient
RUN sudo chown -R $USER:$USER $WDIR
WORKDIR /home/ocaml-libmpdclient/ocaml-libmpdclient
RUN wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sudo sh -s /usr/local/bin \
  && /usr/local/bin/opam init --comp 4.06.0
RUN opam install lwt cmdliner jbuilder odoc ounit
RUN mkdir -p $TMP/mpd/{music,playlists,tag_cache} \
  && echo ls -l $TMP/mpd \
  && cp $WDIR/travis/mpd.conf $TMP/mpd/mpd.conf \
  && cp $WDIR/travis/*.mp3 $TMP/mpd/music/ \
  && ls -1 /home/ocaml-libmpdclient/mpd/music/ > $TMP/mpd/playlists/bach.m3u \
  && echo "/home/ocaml-libmpdclient/mpd/music/kunst01.mp3" > $TMP/mpd/playlists/bach1.m3u
RUN echo ". /home/ocaml-libmpdclient/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true" > $WDIR/runtest.sh \
  && echo "mpd /tmp/mpd.conf" >> $WDIR/runtest.sh \
  && echo "jbuilder runtest" >> $WDIR/runtest.sh

CMD bash -ex $WDIR/runtest.sh
