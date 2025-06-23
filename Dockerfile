FROM archlinux:latest

# Set environment
ENV TERM=xterm
ENV LANG=en_US.UTF-8

# Update system and install required packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        bash sudo netcat gawk acl wget git cronie which \
        percona-server-clients shadow

# Install latest yq from GitHub (v4+)
RUN wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Copy all scripts
COPY scripts /scripts
WORKDIR /scripts

# Make scripts executable
RUN chmod +x /scripts/*

# Run delta setup (creates users, sets permissions, etc.)
RUN bash /scripts/delta-setup

# Keep container alive + run Netcat notify server in background
CMD bash -c "/scripts/fixperms.sh && nohup bash /scripts/.notifyserver > /dev/null 2>&1 & tail -f /dev/null"
