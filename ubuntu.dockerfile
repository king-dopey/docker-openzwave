# Python2 openzwave docker image
# https://github.com/OpenZWave/python-openzwave
# bibi21000
#
###########################################################################################
FROM ubuntu:latest

label maitainer='bibi21000 <bibi21000@gmail.com>; David Heaps <king.dopey.10111@gmail.com>'

ENV CONFIG /etc/openzwave
ENV DEBIAN_FRONTEND noninteractive
ENV PORT 8008

EXPOSE 8008

USER root

# Add the docker command script
COPY /ozw-controlpanel/files/dockercmd.sh /opt/ozwcp/

###########################################################################################
#Add user
RUN adduser ozw_user && \
	usermod -a -G dialout ozw_user && \
	usermod -a -G games ozw_user && \
mkdir -p /usr/local/src/ && \
###########################################################################################
# Initial prerequisites
apt -y update && apt dist-upgrade -y && apt -y install \
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
	pkg-config \ 
	tzdata && \
###########################################################################################
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
cp ozwcp cp.html cp.js openzwavetinyicon.png README /opt/ozwcp && \
cp -r ../open-zwave/config/ /etc/openzwave && \
ln -s /opt/ozwcp/ozwcp /usr/local/bin/ozwcp && \
ln -s /etc/openzwave /opt/ozwcp/config && \
chmod +x /opt/ozwcp/dockercmd.sh && \
###########################################################################################
# Clean up
cd / && \
rm -rf /usr/local/src/ && \
apt remove make git wget g++ pkg-config -y && apt autoremove -y && apt clean

###########################################################################################
WORKDIR /opt/ozwcp/
CMD ["/opt/ozwcp/dockercmd.sh"]
