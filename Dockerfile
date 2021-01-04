FROM adoptopenjdk/openjdk8:jre8u275-b01-alpine

ARG IMAGE_TAG
ARG GIT_COMMIT
ARG GIT_BRANCH
ARG GIT_DIRTY
ARG BUILD_CREATOR
ARG BUILD_NUMBER
ARG SPARK_VERSION
ARG HADOOP_VERSION
ARG AWS_SDK_VERSION
ARG HADOOP_AWS_VERSION
ARG DOCKERIZE_VERSION
ARG SPARK_UID

# Locations 
ARG SPARK_HOME=/opt/spark
ARG SPARK_EXTERNAL_JARS=/opt/external-jars
ARG SPARK_WORKDIR=/opt/work-dir

LABEL branch=$GIT_BRANCH \
      commit=$GIT_COMMIT \
      dirty=$GIT_DIRTY \
      build-creator=$BUILD_CREATOR \
      build-number=$BUILD_NUMBER \
      com.amazonaws.aws-java-sdk-bundle=$AWS_SDK_VERSION \
      org.apache.hadoop.hadoop-aws=$HADOOP_AWS_VERSION \
      comp.dockerize.version=$DOCKERIZE_VERSION \
      image.tag=$IMAGE_TAG

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN set -eux; \
    apk add --no-cache \
            gnupg=2.2.23-r0 \
            bash=5.0.17-r0 \
            tini=0.19.0-r0 \
            shadow=4.8.1-r0; \
    mkdir -p $SPARK_HOME $SPARK_EXTERNAL_JARS $SPARK_WORKDIR; \
    wget -q -O KEYS "https://downloads.apache.org/spark/KEYS"; \
    wget -q -O spark.tgz.asc "https://downloads.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz.asc"; \
    wget -q -O spark.tgz "https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"; \
    GNUPGHOME="$(mktemp -d)"; \
    export GNUPGHOME; \
    gpg --import KEYS; \
    gpg --verify spark.tgz.asc spark.tgz; \
    tar -xzf spark.tgz -C /tmp; \
    rm -rf "$GNUPGHOME" spark.tgz spark.tgz.asc KEYS; \
    mv "/tmp/spark-${SPARK_VERSION}-bin-hadoop$HADOOP_VERSION" $SPARK_HOME; \
    wget -q -P $SPARK_EXTERNAL_JARS \
        https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar \
        https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar; \
   wget -q -O- https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar -xzf - -C /usr/local/bin

RUN set -eux; \
    /usr/sbin/groupadd -g $SPARK_UID spark \
 && /usr/sbin/useradd -d $SPARK_HOME -s /bin/bash -g spark -u $SPARK_UID spark \
 && chown spark:spark $SPARK_WORKDIR

COPY start-master.sh start-worker.sh /

USER spark
ENV LANG=en_US.utf8 \
    SPARK_HOME=$SPARK_HOME \
    SPARK_DIST_CLASSPATH=/opt/spark-userdeps/* \
    PATH=$PATH:$SPARK_HOME/bin

WORKDIR $SPARK_WORKDIR
ENTRYPOINT [ "spark-submit" ]
