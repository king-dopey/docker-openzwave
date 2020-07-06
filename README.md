# OpenZwave Docker Images
Dockerfiles for various OpenZwave images (forked to build more recent versions of all images).

The default (latest) tag is ubuntu_python3, which utilizes the git flavor of OpenZWave, as these images are intended to be used to test new OpenZWave features and/or the administation of features, of which the home automation applicaiton in use hasn't impmenented. For a "stable" experience, using prebuilt packages and CentOS 7 the tag centos7_ozwcp is available.  

## Open ZWave Control Panel Only
centos7_ozwcp : centos7 image with ozw-controlpanel, no python. This uses prebuilt OpenZWave packges from http://mirror.my-ho.st/Downloads/OpenZWave/CentOS_CentOS-7/x86_64/
debian_ozwcp : debian image with ozw-controlpanel, no python. This use the git (bleeding edge) flavor of OpenZWave 
ubuntu_ozwcp: ubuntu image with ozw-controlpanel, no python. This use the git (bleeding edge) flavor of OpenZWave. This is the smallest image avaialbe, but adding python (below) does not require much more space.

## python-openzwave with Open ZWave Control Panel
debian/ubuntu latest for pytho2/python3 with python-openzwave in git flavor and ozw-controlpanel.
 - All versions are availables as tags in the format distro_pythonVersion : debian_python2, debian_python3, ubuntu_python2 and ubuntu_python3 (*Default)
 
## Example run command
docker run -p 8008:8008 --device=/dev/ttyUSB0 -e DEVICES=/dev/ttyUSB0 -e PORT=8008 -e CONFIG=/etc/openzwave -v /myzwaveconfigpath/options.xml:/etc/openzwave/options.xml dheaps/openzwave:pyozw_ubuntu
 - --device tells docker to give the container access that the the specific device; in this case, the ZWave USB stick. Please adjust according to your configuration
 - DEVICES instructs the startup script to explicitly give the unprivelgeed user running the container access to the device listed. Can contain a semicolon delimited list of devices.
 - PORT can change the default port (don't forget to also modify the -p parameter)
 - COFIG can change the default config path (don't forget to also modify the -v paramter)
 - -v mounts the configuration as a volume over the default one.
