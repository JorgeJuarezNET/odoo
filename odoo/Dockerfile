FROM odoo:14.0

USER root
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh

RUN chmod -R 777 /etc/odoo/
COPY ./odoo.conf /etc/odoo/odoo.conf


COPY ./script.py /script.py
RUN chmod 777 /script.py

RUN pip3 install click-odoo

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

