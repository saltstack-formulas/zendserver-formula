zendserver-formula
=======

Installs ZendServer with PHP packages of given version, and optionally configures it.
Currently only compatible with Ubuntu-based minions.
Pull requests are welcome for other platforms (or other improvements ofcourse!)

Usage
-------

All the configuration for zendserver is done via pillar (pillar.example).
In case you already deployed your ZendServer installation but would like to enable extension management,
create a zendserver grain with your admin WebAPI key for zs-manage.
The format is as follows:
|
|  zend-server:
|    api:
|      enabled: True
|      key: 8e454570fdb3601aaa2e63c95500643155573b4c095a991d4f51e21f24944baf
|
You could for example put that in a fresh file in /etc/salt/minion.d/zendserver.conf