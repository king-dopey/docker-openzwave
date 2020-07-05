# Python3 openzwave docker image
# https://github.com/OpenZWave/python-openzwave
# bibi21000
#
################################################################################
FROM		debian:latest
MAINTAINER	bibi21000 <bibi21000@gmail.com>

################################################################################
#Add user
USER		root

RUN adduser ozw_user && \
	usermod -a -G dialout ozw_user && \
	usermod -a -G games ozw_user && \

mkdir -p /usr/local/src/

################################################################################
# Initial prerequisites
ENV DEBIAN_FRONTEND	noninteractive
RUN apt -y update && apt dist-upgrade -y && apt -y install \
	apt-transport-https \
	g++ \
	python3-all python3-dev python3-pip \
	libbz2-dev \
	libssl-dev \
	libudev-dev \
	libyaml-dev \
	make \
	git \
	wget \
	sudo \
	zlib1g-dev \
	libmicrohttpd-dev \
	gnutls-bin libgnutls28-dev \
	pkg-config && \

#Clean up	
apt autoremove -y && apt clean && \

#Install deps from pip
pip3 install 'PyDispatcher>=2.0.5' six 'urwid>=1.1.1' pyserial

################################################################################
# Install python_openzwave with embed sources, shared module fails
RUN pip3 install python_openzwave

################################################################################
# Install open-zwave-controlpanel

WORKDIR	/usr/local/src/

RUN git clone --depth 1 https://github.com/OpenZWave/open-zwave && \
	cd open-zwave && \
	make && \
	cd .. && \

git clone https://github.com/OpenZWave/open-zwave-control-panel.git && \
	cd open-zwave-control-panel && \
	make && \

#Install
mkdir -p /opt/ozwcp && cp ozwcp cp.html cp.js openzwavetinyicon.png README /opt/ozwcp && \
cp -r ../open-zwave/config/ /etc/openzwave && \
ln -s /opt/ozwcp/ozwcp /usr/local/bin/ozwcp && \
ln -s /etc/openzwave /opt/ozwcp/config && \
rm -rf /usr/local/lib/python3.8/site-packages/python_openzwave/ozw_config && \
ln -s /etc/openzwave /usr/local/lib/python3.8/site-packages/python_openzwave/ozw_config && \

################################################################################
# Clean up
rm -rf /usr/local/src/

################################################################################
USER ozw_user

WORKDIR /opt/ozwcp/
VOLUME /etc/openzwave
EXPOSE 8008
CMD ["/opt/ozwcp/ozwcp", "-p 8008", "-c /opt/ozwcp/config"]
