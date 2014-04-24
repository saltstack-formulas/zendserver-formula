zendserver-formula
========

Installs ZendServer with PHP packages of given version, and optionally configures it.
Currently only compatible with Ubuntu-based minions. 

**Please note:** ZendServer with NGINX is currently only available for Ubuntu >= 10.04 and < 14.04.
Support for Ubuntu 14.04 (Trusty Tahr) is available as soon NGINX publishes their packages in the repo (ZendServer relies on NGINX own packages rather than the one's available in their PPA or in the official Ubuntu repository)

Usage
=====

All the configuration for zendserver is done via pillar (pillar.example).
