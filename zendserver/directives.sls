# This state allows you to set and modify directives
# There is no readout or complete state management yet,
# so at every run, all directives are re-processed because salt doesn't
# know about the current state of directives yet.

# Beware: this state will issue a restart every time zs-manage has processed
# all directive changes. (so at most once every highstate)

# Check if the server has been bootstrapped and the key was saved
{% if salt['grains.get']('zendserver:api:enabled', False) == True %}

# Get the key
{% set zend_api_key = salt['grains.get']('zendserver:api:key') %}

##
# At this point, the API has been detected as being provisioned by salt,
# and the key was read from the grain
##

# Process directives
zendserver.directives:
 cmd.run:
    - name: true; {% if 'directives' in salt['pillar.get']('zendserver', {}) -%}
{% for directive_key, directive_value in salt['pillar.get']('zendserver:directives', {}).items() -%}
/usr/local/zend/bin/zs-manage store-directive -d {{ directive_key }} -v {{ directive_value }} -N admin -K {{ zend_api_key }}; {% endfor -%}
{% set must_restart_zend = True %}
{% endif %}

# If a directive was processed we restart as a precaution.
# Most directives require a restart to be read.
{% if must_restart_zend %}
zendserver_restart_because_directive_mutation:
 cmd.run:
    - name: /usr/local/zend/bin/zs-manage restart -N admin -K {{ zend_api_key }}
{% endif %}

# zs-manage is done at this point and we exit the if context that checks grains
{% endif %}
