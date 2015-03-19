{%- set lsb_codename = salt['grains.get']('oscodename') %}
{%- set lsb_distrib_id = salt['grains.get']('lsb_distrib_id') %}
# Install Nginx repository


nginx_repo:
  pkgrepo.managed:
    - humanname: Nginx PPA
    {% if lsb_distrib_id == 'Debian' %}
    {% if lsb_codename == 'jessie' %}
    - name: deb http://nginx.org/packages/debian/ wheezy nginx
    {% else %}
    - name: deb http://nginx.org/packages/debian/ {{ lsb_codename }} nginx
    {% endif %}
    {% else %}
    - name: deb http://nginx.org/packages/ubuntu/ {{ lsb_codename }} nginx
    {% endif %}
    - dist: {{ lsb_codename }}
    - file: /etc/apt/sources.list.d/nginx.list
    - keyid: 7BD9BF62
    - key_url: http://nginx.org/keys/nginx_signing.key
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: nginx
