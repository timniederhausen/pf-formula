{% from 'pf/map.jinja' import pf with context %}

pf_load_{{ pf.kmodule }}:
  kmod.present:
    - name: {{ pf.kmodule }}
    - persist: true
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
    - reload: true
    - enable: {{ pf.service_enabled }}
    - require:
      - file: pf_config
    - watch:
      - file: pf_config
