# Python2 openzwave docker image
# https://github.com/OpenZWave/python-openzwave
# bibi21000
#
################################################################################
FROM		debian:latest
MAINTAINER	bibi21000 <bibi21000@gmail.com>

###############################################################################
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
	python-all python-dev python-pip \
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
pip install 'Louie<2.0' six 'urwid>=1.1.1' pyserial

################################################################################
# Install python_openzwave with embed sources, shared module fails
RUN pip install python_openzwave

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
mkdir -p /opt/ozwcp && cp -r ozwcp ../open-zwave/config/ cp.html cp.js openzwavetinyicon.png README /opt/ozwcp && \
ln -s /opt/ozwcp/ozwcp /usr/local/bin/ozwcp && \

################################################################################
# Clean up
rm -rf /usr/local/src/

################################################################################
USER ozw_user
RUN mkdir -p $HOME/user_config
WORKDIR		$HOME/user_config
VOLUME		$HOME/user_config
EXPOSE 8008
ENTRYPOINT [ "/bin/bash", "/usr/local/bin/ozwcp", "/usr/local/bin/pyozw_check", "/usr/local/bin/pyozw_shell", "-p 8008"]
