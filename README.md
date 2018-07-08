# Saltstack pf Formula

## Features

  - Loads pf kernel module
  - Creates `/etc/pf.conf` file based on pillar data

## Usage

Use this formula as follows:

```
1) Copy pillar.example to /srv/pillar/pf.sls and edit it to your needs
2) salt 'web.example.com' state.apply pf
```


## Supported Operating Systems

This formula was developed and tested on FreeBSD 10 & 11 Systems.
