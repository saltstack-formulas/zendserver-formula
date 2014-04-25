{%- from "zendserver/map.jinja" import zendserver with context %}
{%- set zend_version = salt['pillar.get']('zendserver:version:zend', '') %}
{%- set apache_version = salt['pillar.get']('zendserver:version:apache') %}

# Install ZendServer repository
zendserver_repo:
  pkgrepo.managed:
    - humanname: ZendServer PPA
    - name: deb http://repos.zend.com/zend-server/{{ zend_version }}/deb{{'_apache2.4' if apache_version == '2.4' else ''}} server non-free
    - file: /etc/apt/sources.list.d/zendserver.list
    - keyid: F7D2C623
    - key_url: http://repos.zend.com/zend.key
    - keyserver: keyserver.ubuntu.com
    - refresh: True
    - require_in:
      - pkg: zendserver