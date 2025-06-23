FROM nginx:latest

# Install SSH and ACL
RUN apt-get update && apt-get install -y acl openssh-server

# Setup SSH
RUN mkdir /run/sshd && \
    useradd jumpuser && \
    echo 'jumpuser:123' | chpasswd

# Copy SSL generator and generate certs
COPY .gen_ssl /.gen_ssl
RUN bash /.gen_ssl


# Copy custom nginx config and content
COPY nginx.conf /etc/nginx/nginx.conf
COPY blog.in.* /etc/nginx/
COPY index.html /var/www/blog/index.html

# Start both SSH and Nginx
CMD ["/bin/sh", "-c", "/usr/sbin/sshd && nginx -g 'daemon off;'"]
