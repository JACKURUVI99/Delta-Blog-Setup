FROM nginx:latest

ENV DEBIAN_FRONTEND=noninteractive

# Disable APT cache expiration
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Install tools
RUN apt-get update && apt-get install -y acl openssl openssh-server

# Create SSH user (optional)
RUN mkdir /run/sshd && \
    useradd -m jumpuser && echo 'jumpuser:123' | chpasswd

# Generate self-signed SSL cert
RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/self.key \
    -out /etc/nginx/certs/self.crt \
    -subj "/C=IN/ST=TN/L=Chennai/O=Delta/CN=blog.in"

# Copy configs and content
COPY nginx.conf /etc/nginx/nginx.conf
COPY blog.in.* /etc/nginx/
COPY index.html /var/www/blog/index.html

# Launch both SSH and Nginx
CMD ["/bin/sh", "-c", "/usr/sbin/sshd && nginx -g 'daemon off;'"]
