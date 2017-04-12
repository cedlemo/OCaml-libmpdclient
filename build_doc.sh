#!/usr/bin/bash
oasis setup -setup-update dynamic
./configure --enable-docs
make doc
mv libmpdclient_doc.docdir/* doc/
./clean.sh
