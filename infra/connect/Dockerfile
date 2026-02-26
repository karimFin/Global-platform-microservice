FROM confluentinc/cp-kafka-connect:7.5.3
USER root
RUN confluent-hub install confluentinc/kafka-connect-s3:10.5.7 --no-prompt
RUN mkdir -p /usr/share/java/debezium-postgres
ADD https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.1.Final/debezium-connector-postgres-2.6.1.Final-plugin.tar.gz /tmp/debezium-pg.tgz
RUN tar -xzf /tmp/debezium-pg.tgz -C /usr/share/java/debezium-postgres && rm /tmp/debezium-pg.tgz
ENV CONNECT_PLUGIN_PATH=/usr/share/java,/usr/share/confluent-hub-components
USER appuser
