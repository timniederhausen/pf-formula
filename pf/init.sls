{% from 'pf/map.jinja' import pf with context %}

{#

This is needed for FreeBSD 11.2 for more info check:

http://freebsd.1045724.x6.nabble.com/Possible-bug-11-2-RELEASE-guest-with-vtnet-and-PF-td6266755.html

#}
pf_load_{{ pf.kmodule }}:
  kmod.present:
    - name: {{ pf.kmodule }}
    - persist: True
    - require_in:
      - pf_config

pf_config:
  file.managed:
    - name: {{ pf.file | yaml_encode }}
    - source: 'salt://pf/files/pf.conf'
    - template: jinja
    - check_cmd: "pfctl -nf"

{% set service_function = 'running' if pf.service_enabled else 'dead' %}

pf_service:
  service.{{ service_function }}:
    - name: {{ pf.service }}
    - reload: True
    - enable: {{ pf.service_enabled }}
    - require:
      - file: pf_config
    - watch:
      - file: pf_config

{%- if pf.pflog.enabled %}
pf_pflog:
  sysrc.managed:
    - name: pflog_enable
    - value: "YES"
  service.running:
    - name: pflog
    - enable: True
    - onchanges:
      - sysrc: pf_pflog
{% endif %}

{%- if pf.pfsync.enabled %}
{%- if pf.pfsync.syncdev is defined %}
pf_pfsync_syncdev:
  sysrc.managed:
    - name: pfsync_syncdev
    - value: "{{ pf.pfsync.syncdev }}"
    - onchanges_in:
      - sysrc: pf_pfsync
{% endif %} {# if pf.pfsync.syncdev is defined #}

{%- if pf.pfsync.syncpeer is defined %}
pf_pfsync_syncpeer:
  sysrc.managed:
    - name: pfsync_syncpeer
    - value: "{{ pf.pfsync.syncpeer }}"
    - onchanges_in:
      - sysrc: pf_pfsync
{% endif %} {# if pf.pfsync.syncpeer is defined #}

pf_pfsync:
  sysrc.managed:
    - name: pfsync_enable
    - value: "YES"
    - onchanges_in:
      - cmd: pf_pfsync
  cmd.run:
    {%- if 0 == salt['cmd.retcode']('ifconfig pfsync0') %}
    - name: service pfsync stop && service pfsync start
    {% else %}
    - name: service pfsync start
    {% endif %}
    - enable: True
{% endif %} {# if pf.pfsync.enabled #}
