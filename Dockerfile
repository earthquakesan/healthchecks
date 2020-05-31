FROM alpine:3.11.6

# Application Configuration

ENV GUNICORN_WORKERS 5
ENV GUNICORN_THREADS 50
ENV PORT 80
ENV LOG_LEVEL info

# Package Versions

ENV BASH_VERSION 5.0.11-r1
ENV CURL_VERSION 7.67.0-r0
ENV JQ_VERSION 1.6-r0
ENV UWSGI_PYTHON3_VERSION 2.0.18-r7
ENV PYTHON3_VERSION 3.8.2-r0
ENV PYTHON3_PSYCOPG2_VERSION 2.8.4-r0
ENV GCC_VERSION 9.2.0-r4
ENV LIBC_DEV_VERSION 0.7.2-r0

RUN apk update && apk add -u \
  bash=${BASH_VERSION} \
  curl=${CURL_VERSION} \
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
 && pip install gunicorn

COPY . /opt/healthchecks/
WORKDIR /opt/healthchecks/

COPY docker/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

VOLUME [ "/data" ]

CMD ["start.sh"]
