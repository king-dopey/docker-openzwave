# Python2 openzwave docker image
# https://github.com/OpenZWave/python-openzwave
# bibi21000
#
###########################################################################################
FROM debian:latest

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
apt-get -y update && apt-get dist-upgrade -y && apt-get -y install \
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
	pkg-config \
	tzdata && \
#Clean up
apt-get autoremove -y && apt-get clean && \
#Install deps from pip
pip install 'Louie<2.0' six 'urwid>=1.1.1' pyserial && \
###########################################################################################
# Install python_openzwave with embed sources, shared module fails
pip install python_openzwave --install-option="--flavor=git" && \
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
cp ozwcp cp.html openzwavetinyicon.png README /opt/ozwcp && \
cp -r ../open-zwave/config/ /etc/openzwave && \
ln -s /opt/ozwcp/ozwcp /usr/local/bin/ozwcp && \
ln -s /etc/openzwave /opt/ozwcp/config && \
rm -rf /usr/local/lib/python2.7/site-packages/python_openzwave/ozw_config && \
ln -s /etc/openzwave /usr/local/lib/python2.7/dist-packages/python_openzwave/ozw_config && \
chmod +x /opt/ozwcp/dockercmd.sh && \
###########################################################################################
# Clean up
cd / && \
rm -rf /usr/local/src/ && \
apt-get remove make git wget g++ pkg-config -y && apt-get autoremove -y && apt-get clean && \
rm -rf /root/.[!.]* && rm -rf /root/* && rm -rf /tmp/* && rm -rf /tmp/.[!.]*

###########################################################################################
WORKDIR /opt/ozwcp/
CMD ["/opt/ozwcp/dockercmd.sh"]
