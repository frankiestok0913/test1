FROM ubuntu:22.04

RUN apt update && \
    apt install -y squid apache2-utils

RUN htpasswd -b -c /etc/squid/passwd nvl2025 DTH123emailDTH123email

COPY squid.conf /etc/squid/squid.conf

EXPOSE 3128

CMD ["squid","-N"]
