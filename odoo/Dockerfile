FROM odoo:14.0

USER root

RUN set -eux; \
	apt-get update; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
# verify that the binary works
	gosu nobody true


RUN pip3 install wheel

RUN mkdir -p /odoo

COPY --chown=odoo ./songs /odoo/songs
COPY --chown=odoo ./setup.py /odoo/
COPY --chown=odoo ./requirements.txt /odoo/

RUN cd /odoo && pip3 install -r requirements.txt
RUN cd /odoo && pip3 install .

RUN mkdir -p /odoo/addons && chmod 777 /odoo
COPY ./src/odoo-cloud-platform/attachment_s3 /odoo/addons/attachment_s3
COPY ./src/odoo-cloud-platform/base_attachment_object_storage /odoo/addons/base_attachment_object_storage


COPY ./migration.yml /migration.yml


COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh

RUN chmod -R 777 /etc/odoo/
COPY ./odoo.conf /etc/odoo/odoo.conf


COPY ./script.py /script.py
RUN chmod 777 /script.py

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

