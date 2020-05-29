#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

MANAGE_PY=/opt/healthchecks/manage.py

${MANAGE_PY} createsuperuser
