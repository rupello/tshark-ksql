# tshark-ksql

Analyze tshark output with KSQL

Instructions:

```
docker-compose up -d

./collect-tcp.sh

docker-compose exec ksql-cli ksql http://ksql-server:8088

CREATE STREAM tcp (streamid INTEGER, seq INTEGER) with (KAFKA_TOPIC='tcp_topic', VALUE_FORMAT='delimited') ;

SELECT * from tcp ;

CREATE TABLE tcp_table(streamid INTEGER, seq INTEGER) with (key='streamid', KAFKA_TOPIC='tcp_topic', VALUE_FORMAT='delimited') ;

https://docs.confluent.io/current/ksql/docs/tutorials/basics-local.html


CREATE STREAM tcp ( \
    tcp_stream INTEGER, \
    ip_src VARCHAR, \
    tcp_srcport INTEGER, \
    ip_dst VARCHAR, \
    tcp_dstport INTEGER, \
    tcp_seq INTEGER, \
    tcp_len INTEGER \
    ) \
    with (KAFKA_TOPIC='tcp_topic', VALUE_FORMAT='delimited') ;

CREATE TABLE tcp_tbl ( \
    tcp_stream INTEGER, \
    ip_src VARCHAR, \
    tcp_srcport INTEGER, \
    ip_dst VARCHAR, \
    tcp_dstport INTEGER, \
    tcp_seq INTEGER, \
    tcp_len INTEGER \
    ) \
    with (KAFKA_TOPIC='tcp_topic', VALUE_FORMAT='delimited', KEY='tcp_stream') ;

(no output seen)

CREATE STREAM http as SELECT * FROM tcp WHERE tcp_dstport = 80 or tcp_srcport = 80 ;
CREATE STREAM https as SELECT * FROM tcp WHERE tcp_dstport = 443 or tcp_srcport = 443 ;

SELECT * FROM http ;

# curl google.com
# a new topic is created
# kafkacat -b localhost:9092 -C -t HTTP

DROP TABLE tcp_stats ;
CREATE TABLE stats_by_ip WITH (value_format='delimited') AS SELECT ip_src, ip_dst, COUNT(*) AS msgcount \
FROM tcp WINDOW TUMBLING (size 10 second) GROUP BY ip_src, ip_dst ;

select * from tcp_stats

# topic "TCP_STATS" with 4 partitions:

SHOW QUERIES ;
TERMINATE <QUERY> ;





```



