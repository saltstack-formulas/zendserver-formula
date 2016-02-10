#!/bin/bash

ZEND_ADMIN_PASS=$1
ZEND_LICENSE_ORDER=$2
ZEND_LICENSE_SERIAL=$3

/usr/local/zend/bin/zs-manage bootstrap-single-server -p $ZEND_ADMIN_PASS -o $ZEND_LICENSE_ORDER -l $ZEND_LICENSE_SERIAL -a true -r false > /tmp/zs-bootstrap-output
api_key=$(cat /tmp/zs-bootstrap-output | head -n 1 | awk '{print $2}')
echo -e "grains:\n  zendserver:\n    mode: production\n    api:\n      enabled: True\n      key: $api_key" > /etc/salt/minion.d/zendserver.conf
/usr/local/zend/bin/zs-manage restart -N admin -K "$api_key"
