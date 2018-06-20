# tshark-ksql

### Some experiments running KSQL queries on tshark output


Instructions:

```

# bring up kafka, zookeeper, ksql etc...
docker-compose up -d

# start tshark ingest
./tshark2kafka.sh

# run the KSQL cli
docker-compose exec ksql-cli ksql http://ksql-server:8088


# https://docs.confluent.io/current/ksql/docs/tutorials/basics-local.html
# https://docs.confluent.io/current/ksql/docs/tutorials/examples.html


CREATE STREAM tcp ( \
    frame_time DOUBLE, \
    tcp_stream INTEGER, \
    ip_src VARCHAR, \
    tcp_srcport INTEGER, \
    ip_dst VARCHAR, \
    tcp_dstport INTEGER, \
    tcp_seq INTEGER, \
    tcp_len INTEGER, \
    tcp_syn INTEGER, \
    tcp_ack INTEGER, \
    tcp_fin INTEGER, \
    tcp_res INTEGER \
    ) \
    with (KAFKA_TOPIC='tcp_topic', VALUE_FORMAT='delimited') ;

# Filtering
CREATE STREAM http as SELECT * FROM tcp WHERE tcp_dstport = 80 or tcp_srcport = 80 ;
CREATE STREAM https as SELECT * FROM tcp WHERE tcp_dstport = 443 or tcp_srcport = 443 ;

SELECT * FROM http ;

# curl google.com
# a new topic is created
# kafkacat -b localhost:9092 -C -t HTTP

# aggregates
CREATE TABLE test_stats_by_ip WITH (value_format='delimited') AS SELECT ip_src, ip_dst, COUNT(*) AS msgcount \
FROM tcp GROUP BY ip_src, ip_dst ;

CREATE TABLE stats_by_ip WITH (value_format='delimited') AS SELECT ip_src, ip_dst, COUNT(*) AS msgcount \
FROM tcp WINDOW TUMBLING (size 10 second) GROUP BY ip_src, ip_dst ;

select * from tcp_stats

# topic "TCP_STATS" with 4 partitions:

SHOW QUERIES ;
TERMINATE <QUERY> ;



# try json

CREATE TABLE json_stats_by_ip WITH (value_format='json') AS SELECT ip_src, ip_dst, COUNT(*) AS msgcount \
FROM tcp WINDOW TUMBLING (size 10 second) GROUP BY ip_src, ip_dst ;

# kafka topic is in JSON
kafkacat -b localhost:9092 -C -t JSON_STATS_BY_IP
{"MSGCOUNT":1,"IP_DST":"192.168.86.85","IP_SRC":"192.168.86.99"}
{"MSGCOUNT":2,"IP_DST":"192.168.86.84","IP_SRC":"192.168.86.85"}
{"MSGCOUNT":2,"IP_DST":"192.168.86.99","IP_SRC":"192.168.86.85"}


CREATE STREAM json_https WITH (value_format='json') AS SELECT * FROM tcp WHERE tcp_dstport = 443 or tcp_srcport = 443 ;

# try avro
CREATE STREAM avro_https WITH (value_format='avro') AS SELECT * FROM tcp WHERE tcp_dstport = 443 or tcp_srcport = 443 ;

# check schema registry
curl http://localhost:8081/subjects/
curl http://localhost:8081/subjects/AVRO_HTTPS-value/versions/1

# add constants tests
create stream poop with (value_format='json') as select 1,'poop' from http ;

# tcp connection times
SELECT TCP_STREAM, 1000.0*(MAX(frame_time)-MIN(frame_time)) \
FROM tcp WINDOW SESSION (2 SECONDS) \
WHERE tcp_syn <> 0  \
GROUP BY TCP_STREAM ;
```



