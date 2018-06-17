#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# pass in -r <file> to specify a file or -i <interface>
# notes:
#      -l unbuffered output
tshark -l -T fields -E separator=',' $@ \
    -Y tcp.stream \
    -e tcp.stream \
    -e tcp.seq \
    | kafkacat -b localhost:9092 -P -t tcp_topic


