# Python2 openzwave docker image
# https://github.com/OpenZWave/python-openzwave
# bibi21000
#
################################################################################
FROM		ubuntu:latest
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
#	apt-transport-https \
	g++ \
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

################################################################################
# Install open-zwave-controlpanel

cd /usr/local/src/ && \

git clone --depth 1 https://github.com/OpenZWave/open-zwave && \
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
rm -rf /usr/local/src/ && \
apt remove make git wget g++ pkg-config -y && apt autoremove -y && apt clean

################################################################################
USER ozw_user
RUN mkdir -p $HOME/user_config
WORKDIR		$HOME/user_config
VOLUME		$HOME/user_config
EXPOSE 8008
CMD ["/usr/local/bin/ozwcp", "-p 8008", "-c /opt/ozwcp/config"]
