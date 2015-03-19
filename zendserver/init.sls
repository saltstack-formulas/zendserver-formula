# Include :download:`map file <map.jinja>` of OS-specific package names and
# file paths. Values can be overridden using Pillar.
{%- from "zendserver/map.jinja" import zendserver with context %}
{%- set zend_admin_pass = salt['pillar.get']('zendserver:admin_password', 'changeme') %}
{%- set php_version = salt['pillar.get']('zendserver:version:php', '5.5') %}
{%- set webserver = salt['pillar.get']('zendserver:webserver', 'apache') %}
{%- set enable_itk = salt['pillar.get']('zendserver:enable_itk', False) %}
{%- set bootstrap = salt['pillar.get']('zendserver:bootstrap', False) %}
{%- set bootstrap_dev = salt['pillar.get']('zendserver:bootstrap_dev', False) %}
{%- set zend_license_order = salt['pillar.get']('zendserver:license:order') %}
{%- set zend_license_serial = salt['pillar.get']('zendserver:license:serial') %}

# Include APT repositories
include:
  - .repo.zendserver
{%- if webserver == 'nginx' %}
  - .repo.nginx

# Install nginx and ensure its running
nginx:
  pkg:
    - installed
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: nginx
      - pkg: zendserver
    - require:
      - pkg: nginx
      - pkg: zendserver
{%- else %}
# Install apache2 ensure its running
apache2:
  pkg:
    - installed
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: apache2
      - pkg: zendserver
    - require:
      - pkg: zendserver
      - pkg: apache2
{%- endif %}

# Enable MPM-ITM in case Apache is used and set to enabled
# This will ensure websites run under the configured user.
{%- if webserver == 'apache' and enable_itk %}
apache2-mpm-itk:
  pkg.installed:
    - require:
      - pkg: apache2
{%- endif %}

# Install Zendserver for NGINX or Apache
zendserver:
  pkg.installed:
{%- if webserver == 'nginx' %}
    - name: zend-server-nginx-php-{{ php_version }}
    - require:
      - pkg: nginx
{%- else %}
    - name: zend-server-php-{{ php_version }}
{%- endif %}

# Set alternative to PHP since Zend Server uses a different folder
alternative-php:
  cmd.run:
    - name: update-alternatives --install /usr/bin/php php /usr/local/zend/bin/php 1
    - require:
      - pkg: zendserver
    - unless: test -L /usr/bin/php

alternative-pear:
  cmd.run:
    - name: update-alternatives --install /usr/bin/pear pear /usr/local/zend/bin/pear 1
    - require:
      - pkg: zendserver
    - unless: test -L /usr/bin/pear

alternative-pecl:
  cmd.run:
    - name: update-alternatives --install /usr/bin/pecl pecl /usr/local/zend/bin/pecl 1
    - require:
      - pkg: zendserver
    - unless: test -L /usr/bin/pecl

/etc/zendserver:
  file.directory:
    - makedirs: True
    - user: root
    - group: adm
    - mode: 750
    - require:
      - pkg: zendserver

# Bootstrap Zend-Server to prevent first-run wizard while accessing the admin panel
{%- if bootstrap %}
bootstrap-zs:
  cmd.run:
    - name: /usr/local/zend/bin/zs-manage bootstrap-single-server -p {{ zend_admin_pass }} -o {{ zend_license_order }} -l {{ zend_license_serial }} -a TRUE -r FALSE
    - require:
      - cmd: alternative-php
      - file: zs-admin
    - unless: test -e /etc/zendserver/zs-admin.txt
{%- endif %}

# Bootstrap will give you a fresh error if you decide to bootstrap an already bootstrapped server.
# Beware: a bash dependency might have been introduced here regarding environment variable handling.
{%- if bootstrap_dev %}
bootstrap-zs-dev:
  cmd.run:
    - name: "api_key=`/usr/local/zend/bin/zs-manage bootstrap-single-server -p admin -a True -r False | head -n 1 | cut -f2`; echo 'grains:\n  zend-server:\n    mode: development\n    api:\n      enabled: True\n      key: '$api_key >> /etc/salt/minion.d/zendserver.conf; /usr/local/zend/bin/zs-manage restart -N admin -K $api_key"
    - require:
      - cmd: alternative-php
#      - file: zs-admin # is executed anyway atfter this state
    - unless: test -e /etc/zendserver/zs-admin.txt #makes sure we can't bootstrap twice
{%- endif %}

#Moved down in case salt decides to run this before bootstrapping, can still be required as a dependency
zs-admin:
  file.managed:
    - name: /etc/zendserver/zs-admin.txt
    - contents: {{ zend_admin_pass }}
    - require:
      - file: /etc/zendserver
    - unless: test -e /etc/zendserver/zs-admin.txt

{%- if webserver == 'nginx' %}
/etc/init.d/php-fpm:
  file.symlink:
    - target: /usr/local/zend/bin/php-fpm.sh

{%- endif %}
