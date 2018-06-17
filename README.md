# tshark-ksql

Analyze tshark output with KSQL

Instructions:

```
docker-compose up -d

./collect-tcp.sh

docker-compose exec ksql-cli ksql http://ksql-server:8088

CREATE STREAM tcp (streamid INTEGER, seq INTEGER) with (KAFKA_TOPIC='tcp_topic', VALUE_FORMAT='delimited') ;

SELECT * from tcp ;

```



