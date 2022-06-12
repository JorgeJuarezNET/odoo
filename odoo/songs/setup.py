# Copyright (C) 2022 Jorge Luis Juarez Mandujano
# License AGPL-3.0 or later (http://www.gnu.org/licenses/agpl).
import anthem


@anthem.log
def setup_attachmnts_db(ctx):
    """Set Attachments DB Rules"""
    ctx.env["ir.config_parameter"].set_param(
        "ir_attachment.storage.force.database",
        "{\"image/\": 0, \"application/javascript\": 0, \"text/css\": 0}"
    )

    ctx.env["ir.config_parameter"].set_param(
        "ir_attachment.location",
        "db"
    )

    ctx.env['ir.attachment'].force_storage()


@anthem.log
def main(ctx):
    """Setup Attachents"""
    setup_attachmnts_db(ctx)