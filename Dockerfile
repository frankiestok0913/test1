FROM ubuntu:latest

# Cài đặt các gói cần thiết và cấu hình ngôn ngữ
RUN apt-get update && apt-get install -y locales openssh-server openssh-client && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8

# Nhận đối số lúc build: Mật khẩu cho root và Token của Pinggy
ARG Password
ARG PinggyToken

# Thiết lập biến môi trường để script có thể sử dụng
ENV Password=${Password}
ENV PinggyToken=${PinggyToken}

# Cấu hình SSH Server
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo "root:${Password}" | chpasswd

# Tạo script khởi động
# Script này sẽ khởi chạy đường hầm Pinggy trong nền, sau đó khởi chạy SSH server ở foreground
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'echo "🚀 Starting Pinggy tunnel in the background..."' >> /start.sh && \
    echo 'ssh -p 443 -R0:127.0.0.1:22 -o StrictHostKeyChecking=no -o ServerAliveInterval=30 "${PinggyToken}+tcp@free.pinggy.io" &' >> /start.sh && \
    echo 'sleep 2 # Chờ một chút để tunnel kết nối' >> /start.sh && \
    echo 'echo "🔐 Starting SSH server in the foreground to keep container running..."' >> /start.sh && \
    echo '/usr/sbin/sshd -D' >> /start.sh

# Cấp quyền thực thi cho script và expose các port cần thiết
RUN chmod +x /start.sh
EXPOSE 22

# Lệnh để chạy khi container khởi động
CMD ["/start.sh"]
