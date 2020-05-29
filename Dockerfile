FROM alpine:3.11.6

# Package Versions

ENV BASH_VERSION 5.0.11-r1
ENV CURL_VERSION 7.67.0-r0
ENV JQ_VERSION 1.6-r0
ENV APACHE2_MOD_WSGI_VERSION 4.6.7-r1
ENV APACHE2_SSL_VERSION 2.4.43-r0
ENV APACHE2_VERSION 2.4.43-r0
ENV UWSGI_PYTHON3_VERSION 2.0.18-r7
ENV PYTHON3_VERSION 3.8.2-r0
ENV PYTHON3_PSYCOPG2_VERSION 2.8.4-r0
ENV GCC_VERSION 9.2.0-r4
ENV LIBC_DEV_VERSION 0.7.2-r0

RUN apk update && apk add -u \
  bash=${BASH_VERSION} \
  curl=${CURL_VERSION} \
  apache2=${APACHE2_VERSION} \
  apache2-mod-wsgi=${APACHE2_MOD_WSGI_VERSION} \
  apache2-ssl=${APACHE2_SSL_VERSION} \
  python3=${PYTHON3_VERSION} \
  python3-dev=${PYTHON3_VERSION} \
  uwsgi-python3=${UWSGI_PYTHON3_VERSION} \
  py3-psycopg2=${PYTHON3_PSYCOPG2_VERSION} \
  gcc=${GCC_VERSION} \
  libc-dev=${LIBC_DEV_VERSION}

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY requirements.txt /requirements.txt
RUN python -m pip install --upgrade pip \
 && python -m pip install -r /requirements.txt \
 && pip install jinja2

COPY . /opt/healthchecks/

COPY docker/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

COPY docker/wsgi.conf /etc/apache2/conf.d/
ENV SERVERROOT /var/www

VOLUME [ "/data" ]

CMD ["start.sh"]
