FROM openjdk:8-jdk
MAINTAINER Furcy Pin

ENV SBT_VERSION 0.13.15

RUN apt-get update
RUN mkdir -p /var/run/sshd
RUN apt-get install -y openssh-server unzip
RUN apt-get clean

RUN wget http://dl.bintray.com/sbt/debian/sbt-${SBT_VERSION}.deb -O /tmp/sbt.deb && \
    dpkg -i /tmp/sbt.deb && \
    rm -f /tmp/sbt.deb

RUN apt-get install -y git


ENV HADOOP_VERSION=2.7.3
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/conf
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL \
  "https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
    | gunzip \
    | tar -x -C /opt/ \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME


ENV HIVE_VERSION=2.0.1
ENV HIVE_HOME=/opt/apache-hive-$HIVE_VERSION-bin
ENV HIVE_CONF_DIR=$HIVE_HOME/conf
ENV PATH $PATH:$HIVE_HOME/bin
RUN curl -sL \
  "https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz" \
    | gunzip \
    | tar -x -C /opt/ \
  && chown -R root:root $HIVE_HOME \
  && mkdir -p $HIVE_HOME/hcatalog/var/log \
  && mkdir -p $HIVE_HOME/var/log \
  && mkdir -p /data/hive/

ENV SPARK_VERSION=2.1.1
ENV SPARK_HOME=/opt/spark-$SPARK_VERSION-bin-hadoop2.7
ENV SPARK_CONF_DIR=$SPARK_HOME/conf
ENV PATH $PATH:$SPARK_HOME/bin
RUN curl -sL \
  "https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.7.tgz" \
    | gunzip \
    | tar -x -C /opt/ \
  && chown -R root:root $SPARK_HOME \
  && mkdir -p /data/spark/

ADD files/hive-site.xml $HIVE_CONF_DIR/
ADD files/hive-site.xml $SPARK_CONF_DIR/
ADD files/start.sh /

RUN cd /data/hive ; $HIVE_HOME/bin/schematool -dbType derby -initSchema ; cd

EXPOSE 22
EXPOSE 4040
EXPOSE 9083
EXPOSE 10000

ENTRYPOINT ["/start.sh"]


