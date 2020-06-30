# Python3 openzwave docker image
# https://github.com/OpenZWave/python-openzwave
# bibi21000
#
################################################################################
FROM		ubuntu:latest
MAINTAINER	bibi21000 <bibi21000@gmail.com>

################################################################################
#Add user
USER		root

RUN adduser ozw_user
RUN usermod -a -G dialout ozw_user
RUN usermod -a -G games ozw_user

RUN mkdir -p /usr/local/src/

################################################################################
# Initial prerequisites
USER		root
ENV			DEBIAN_FRONTEND	noninteractive
RUN			apt-get -y update && apt-get -y install \
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
				libmicrohttpd libmicrohttpd-dev \
				gnutls-bin libgnutls28 libgnutls28-dev \
				pkg-config && \
				apt-get clean

RUN 		pip3 install 'PyDispatcher>=2.0.5' six 'urwid>=1.1.1' pyserial

################################################################################
# Install python_openzwave with embed sources, shared module fails
RUN			pip3 install python_openzwave

################################################################################
# Install open-zwave-controlpanel
USER		root

WORKDIR	/usr/local/src/

RUN git clone --depth 1 https://github.com/OpenZWave/open-zwave && \
	cd open-zwave && \
	make

RUN git clone https://github.com/OpenZWave/open-zwave-control-panel.git

WORKDIR /usr/local/src/open-zwave-control-panel

RUN make

RUN mkdir -p /opt/ozwcp && cp -r ozwcp config/ cp.html cp.js openzwavetinyicon.png README /opt/ozwcp

RUN ln -s /opt/ozwcp/ozwcp /usr/local/bin/ozwcp

################################################################################
# Clean up
RUN rm -rf /usr/local/src/ && rm /opt/ozwcp.tar.gz \
	apt remove libgnutls28-dev libmicrohttpd-dev -y && \
	apt autoremove -y && apt clean

################################################################################
USER ozw_user
RUN mkdir -p $HOME/user_config
WORKDIR		$HOME/user_config
VOLUME		$HOME/user_config
EXPOSE 8008
ENTRYPOINT [ "/bin/bash", "/usr/local/bin/ozwcp", "/usr/local/bin/pyozw_check", "/usr/local/bin/pyozw_shell", "-p 8008"]
