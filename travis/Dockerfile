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
    pkg-config

RUN \
  useradd --user-group --create-home ocaml-libmpdclient

RUN \
  echo "ocaml-libmpdclient ALL=(ALL:ALL) NOPASSWD:ALL" | \
    EDITOR=tee visudo -f /etc/sudoers.d/ocaml-libmpdclient

USER ocaml-libmpdclient

COPY . /home/ocaml-libmpdclient/ocaml-libmpdclient
RUN sudo chown -R ocaml-libmpdclient:ocaml-libmpdclient /home/ocaml-libmpdclient/ocaml-libmpdclient
RUN mkdir /tmp/mpd/{music,playlists}
RUN cp /home/ocaml-libmpdclient/ocaml-libmpdclient/travis/mpd.conf /tmp/mpd.conf \
  && /home/ocaml-libmpdclient/ocaml-libmpdclient/travis/*.mp3 /tmp/mpd/music/ \
  && ls -1 /home/ocaml-libmpdclient/mpd/music/ > /tmp/mpd/playlists/bach.m3u \
  && echo "/home/ocaml-libmpdclient/mpd/music/kunst01.mp3" > /tmp/mpd/playlists/bach1.m3u
WORKDIR /home/ocaml-libmpdclient/ocaml-libmpdclient
RUN wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sudo sh -s /usr/local/bin
RUN /usr/local/bin/opam init --comp 4.06.0
RUN opam install lwt cmdliner jbuilder odoc ounit
RUN echo ". /home/ocaml-libmpdclient/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true" > /home/ocaml-libmpdclient/ocaml-libmpdclient/runtest.sh
RUN echo "mpd /tmp/mpd.conf" >> /home/ocaml-libmpdclient/ocaml-libmpdclient/runtest.sh
RUN echo "jbuilder runtest" >> /home/ocaml-libmpdclient/ocaml-libmpdclient/runtest.sh
CMD bash -ex /home/ocaml-libmpdclient/ocaml-libmpdclient/runtest.sh
