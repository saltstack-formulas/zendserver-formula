# Install Nginx repository
{%- set repo_url = 'http://nginx.org/packages' %}

{%- set lsb_codename = salt['grains.get']('oscodename')|lower %}
{%- set lsb_distrib_id = salt['grains.get']('lsb_distrib_id')|lower %}

# Handle mainline switch
{%- if salt['pillar.get']('zendserver:nginx_mainline', False) %}
{%- set repo_url = repo_url ~ '/mainline' %}
{%- endif %}

nginx_repo:
  pkgrepo.managed:
    - humanname: Nginx PPA
    - name: deb {{ repo_url }}/{{ lsb_distrib_id }}/ {{ lsb_codename }} nginx
    - file: /etc/apt/sources.list.d/nginx.list
    - keyid: 7BD9BF62
    - key_url: http://nginx.org/keys/nginx_signing.key
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: nginx
    - clean_file: True
