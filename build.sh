#!/usr/bin/bash
oasis setup -setup-update dynamic
./configure --enable-tests
make test
