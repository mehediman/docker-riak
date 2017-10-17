# Riak
#
# VERSION       1.0.5

FROM phusion/baseimage:0.9.14
MAINTAINER Hector Castro hectcastro@gmail.com

# Environmental variables
ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

RUN \

    # Install Java 7
    apt-get update && \
    apt-get install -y openjdk-7-jdk wget && \

    # Install Riak
    wget https://packages.erlang-solutions.com/erlang/riak/FLAVOUR_1_main/riak_2.2.3-1~ubuntu~trusty_amd64.deb && \
    dpkg -i riak_2.2.3-1~ubuntu~trusty_amd64.deb && \

    # Cleanup
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup the Riak service
RUN mkdir -p /etc/service/riak
ADD bin/riak.sh /etc/service/riak/run

# Setup automatic clustering
ADD bin/automatic_clustering.sh /etc/my_init.d/99_automatic_clustering.sh

# Tune Riak configuration settings for the container
RUN sed -i.bak 's/listener.http.internal = 127.0.0.1/listener.http.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    sed -i.bak 's/listener.protobuf.internal = 127.0.0.1/listener.protobuf.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    echo "anti_entropy.concurrency_limit = 1" >> /etc/riak/riak.conf && \
    echo "javascript.map_pool_size = 0" >> /etc/riak/riak.conf && \
    echo "javascript.reduce_pool_size = 0" >> /etc/riak/riak.conf && \
    echo "javascript.hook_pool_size = 0" >> /etc/riak/riak.conf

# Make Riak's data and log directories volumes
VOLUME /var/lib/riak
VOLUME /var/log/riak

# Open ports for HTTP and Protocol Buffers
EXPOSE 8098 8087

# Enable insecure SSH key
# See: https://github.com/phusion/baseimage-docker#using_the_insecure_key_for_one_container_only
RUN /usr/sbin/enable_insecure_key

# Leverage the baseimage-docker init system
CMD ["/sbin/my_init", "--quiet"]
