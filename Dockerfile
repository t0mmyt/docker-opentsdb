FROM ubuntu:16.04
MAINTAINER Tom Taylor <tom+dockerfile@tomm.yt>

EXPOSE 60000 60010 60030 4242 16010

ENV TSDB_VERSION 2.2.0
ENV HBASE_VERSION 1.2.0

RUN DEBIAN_FRONTEND=noninteractive \
  apt-get -qq update
  
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get -yqq install \
    openjdk-8-jdk-headless \
    wget \
    build-essential \
    gnuplot \
    unzip \
    autoconf \
    python \
    supervisor

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Install OpenTSDB
WORKDIR /opt
RUN wget -qO v${TSDB_VERSION}.zip \
    https://github.com/OpenTSDB/opentsdb/archive/v${TSDB_VERSION}.zip && \
    unzip v${TSDB_VERSION} &&\
    rm v${TSDB_VERSION}.zip && \
    ln -s opentsdb-${TSDB_VERSION} opentsdb && \
    cd /opt/opentsdb-${TSDB_VERSION} && \
    ./build.sh && \
    cd build && \
    make install
COPY etc/opentsdb.conf /etc/
COPY bin/start-tsdb.sh /

# Install HBase
WORKDIR /opt
RUN wget -q http://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz && \
    tar xf hbase-${HBASE_VERSION}-bin.tar.gz && \
    rm hbase-${HBASE_VERSION}-bin.tar.gz && \
    ln -s hbase-${HBASE_VERSION} hbase
COPY hbase-site.xml /opt/hbase/conf/
COPY bin/start-hbase.sh /
WORKDIR /

# Supervisor
COPY etc/supervisord.conf /etc/supervisor/supervisord.conf
CMD /usr/bin/supervisord
