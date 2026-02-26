FROM debezium/connect:2.6

USER root
RUN mkdir -p /kafka/connect/plugins/aiven-s3
WORKDIR /kafka/connect/plugins/aiven-s3
# Aiven Kafka Connect S3 plugin (OSS)
RUN curl -L -o kafka-connect-s3-3.6.1.jar https://repo1.maven.org/maven2/io/aiven/kafka-connect-s3/3.6.1/kafka-connect-s3-3.6.1.jar
USER kafka
