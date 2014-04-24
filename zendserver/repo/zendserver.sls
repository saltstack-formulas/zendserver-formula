# Install ZendServer repository
zendserver_repo:
  pkgrepo.managed:
    - humanname: ZendServer PPA
    - name: deb http://repos.zend.com/zend-server/{{ salt['pillar.get']('zendserver:version:zend') }}/deb server non-free
    - file: /etc/apt/sources.list.d/zendserver.list
    - keyid: F7D2C623
    - key_url: http://repos.zend.com/zend.key
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: zendserver