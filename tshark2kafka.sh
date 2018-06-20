#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# pass in -r <file> to specify a file or -i <interface>
# notes:
#      -l unbuffered output
tshark -l -T fields -E separator=',' $@ \
    -Y tcp.stream \
    -e frame.time_epoch \
    -e tcp.stream \
    -e ip.src \
    -e tcp.srcport \
    -e ip.dst \
    -e tcp.dstport \
    -e tcp.seq \
    -e tcp.len \
    -e tcp.flags.syn \
    -e tcp.flags.ack \
    -e tcp.flags.fin \
    -e tcp.flags.res \
    | docker run --net tshark-ksql_default -i \
        confluentinc/cp-kafkacat kafkacat \
        -b kafka:29092 -P -t tcp_topic


