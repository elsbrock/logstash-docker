FROM phusion/baseimage:0.9.16
MAINTAINER Simon Elsbrock <simon@iodev.org>

ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN \
    addgroup --system logstash ;\
    adduser --system --disabled-login --ingroup logstash \
      --home /var/lib/logstash --gecos "Logstash" --shell /bin/false \
      logstash

ADD https://packages.elasticsearch.org/GPG-KEY-elasticsearch /tmp/repokey.gpg
RUN apt-key add /tmp/repokey.gpg && rm /tmp/repokey.gpg
ADD logstash.list /etc/apt/sources.list.d/logstash.list

RUN \
    echo "Acquire::Languages \"none\";\nAPT::Install-Recommends \"true\";\nAPT::Install-Suggests \"false\";" > /etc/apt/apt.conf ;\
    echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure tzdata ;\
    locale-gen en_US.UTF-8 en_DK.UTF-8 de_DE.UTF-8 ;\
    apt-get -q -y update ;\
    apt-get install -y openjdk-7-jre-headless logstash ;\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD logstash.conf /opt/logstash/logstash.conf
ADD logstash-fwd.conf /etc/syslog-ng/conf.d/

RUN \
    mkdir /etc/service/logstash ;\
    echo "#!/bin/sh\ncd /var/lib/logstash\nsetuser logstash /opt/logstash/bin/logstash agent -f /opt/logstash/logstash.conf -- web" > /etc/service/logstash/run ;\
    chmod +x /etc/service/logstash/run

VOLUME  ["/var/lib/logstash"]

EXPOSE 1514
EXPOSE 9292
EXPOSE 9200
