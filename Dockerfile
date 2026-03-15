FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y squid apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# tạo user proxy
RUN htpasswd -b -c /etc/squid/passwd nvl2025 DTH123emailDTH123email

# config squid
RUN echo "auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd" >> /etc/squid/squid.conf && \
    echo "auth_param basic realm proxy" >> /etc/squid/squid.conf && \
    echo "acl authenticated proxy_auth REQUIRED" >> /etc/squid/squid.conf && \
    echo "http_access allow authenticated" >> /etc/squid/squid.conf && \
    echo "http_access deny all" >> /etc/squid/squid.conf && \
    echo "http_port 8080" >> /etc/squid/squid.conf

EXPOSE 3128

CMD ["squid","-N","-d","1"]
