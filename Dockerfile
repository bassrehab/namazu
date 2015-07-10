## Dockerfile for Earthquake
## Available at Docker Hub: osrg/earthquake
FROM osrg/dind-ovs-ryu
MAINTAINER Akihiro Suda <suda.akihiro@lab.ntt.co.jp>

## Update
RUN apt-get update

## Install protoc
RUN apt-get install -y --no-install-recommends protobuf-compiler

## Install Go 1.5 (or later) to /go
ENV GOROOT_BOOTSTRAP /go1.4
RUN git clone -b release-branch.go1.4 https://go.googlesource.com/go $GOROOT_BOOTSTRAP && (cd $GOROOT_BOOTSTRAP/src; ./make.bash)
RUN git clone https://go.googlesource.com/go /go && (cd /go/src; ./make.bash)
ENV PATH /go/bin:$PATH

## Install JDK and so on
RUN apt-get install -y --no-install-recommends default-jdk maven

## Install ryu
RUN pip uninstall -y ryu && pip install ryu==3.20.2

## Install pipework
RUN wget --no-check-certificate --quiet https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -O /usr/local/bin/pipework
RUN chmod +x /usr/local/bin/pipework

## Install nfqhook deps
RUN apt-get install -y --no-install-recommends libnetfilter-queue1 python-prctl

## Install Earthquake deps
RUN apt-get install -y --no-install-recommends python-flask python-scapy python-zmq sudo
RUN pip install hexdump

## Copy Earthquake to /earthquake
ADD . /earthquake
WORKDIR /earthquake
RUN ( git submodule init && git submodule update )

## Build Earthquake
RUN ./build

## Silence dind logs
ENV LOG file

## Start dind bash
CMD ["wrapdocker", "/init.dind-ovs-ryu.sh"]

