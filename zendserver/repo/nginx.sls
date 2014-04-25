{%- set lsb_codename = salt['grains.get']('lsb_distrib_codename') %}

# Install Nginx repository
nginx_repo:
  pkgrepo.managed:
    - humanname: Nginx PPA
    - name: deb http://nginx.org/packages/ubuntu/ {{ lsb_codename }} nginx
    - dist: {{ lsb_codename }}
    - file: /etc/apt/sources.list.d/nginx.list
    - keyid: 7BD9BF62
    - key_url: http://nginx.org/keys/nginx_signing.key
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: nginx