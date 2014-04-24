# Include :download:`map file <map.jinja>` of OS-specific package names and
# file paths. Values can be overridden using Pillar.
{%- from "zendserver/map.jinja" import zendserver with context %}
{%- set php_version = salt['pillar.get']('zendserver:version:php') %}

# Include APT repositories
include:
  - .repo.zendserver
{%- if salt['pillar.get']('zendserver:webserver') == 'nginx' %}
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
      - pkg: zendserver
{%- else %}
# Install apache2 ensure its running
apache2:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: apache2
      - pkg: zendserver
    - require:
      - pkg: zendserver
{%- endif %}

zendserver:
  pkg.installed:
{%- if salt['pillar.get']('zendserver:webserver') == 'nginx' %}
    - name: zend-server-nginx-php-{{ php_version }}
    - require:
      - pkg: nginx
{%- else %}
    - name: zend-server-php-{{ php_version }}
{%- endif %}

alternative-php:
  cmd.run:
    - name: update-alternatives --install /usr/bin/php php /usr/local/zend/bin/php 1
    - require:
      - pkg: zendserver
    - unless: test -L /usr/bin/php

# Bootstrap Zend-Server
{%- if salt['pillar.get']('zendserver:bootstrap') %}
bootstrap-zs:
  cmd.run:
    - name: /usr/local/zend/bin/zs-manage bootstrap-single-server -p {{ salt['pillar.get']('zendserver:admin_password') }} -o {{ salt['pillar.get']('zendserver:license:order') }} -l {{ salt['pillar.get']('zendserver:license:serial') }} -a TRUE -r FALSE
    - require:
      - cmd: alternative-php
      - file: zs-admin
    - unless: test -e /etc/zendserver/zs-admin.txt
{%- endif %}

/etc/zendserver:
  file.directory:
    - makedirs: True
    - user: root
    - group: adm
    - mode: 750
    - require:
      - pkg: zendserver

zs-admin:
  file.managed:
    - name: /etc/zendserver/zs-admin.txt
    - contents: {{ salt['pillar.get']('zendserver:admin_password') }}
    - require:
      - file: /etc/zendserver
    - unless: test -e /etc/zendserver/zs-admin.txt