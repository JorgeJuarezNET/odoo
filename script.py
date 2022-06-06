#!/usr/bin/env python
from __future__ import print_function

env["ir.config_parameter"].set_param(
    "ir_attachment.storage.force.database",
    "{\"image/\": 5200, \"application/javascript\": 0, \"text/css\": 0}"
)

env["ir.config_parameter"].set_param(
    "ir_attachment.location",
    "db"
)

env['ir.attachment'].force_storage()