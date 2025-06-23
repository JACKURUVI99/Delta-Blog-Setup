FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=root123
ENV MYSQL_DATABASE=blogdb

# Copy migration script into the special init directory
COPY migration.sql /docker-entrypoint-initdb.d/
COPY create_readonly_user.sql /docker-entrypoint-initdb.d/



RUN echo "[mysqld]\n\
ssl-ca=/var/lib/mysql/certs/ca.pem\n\
ssl-cert=/var/lib/mysql/certs/server-cert.pem\n\
ssl-key=/var/lib/mysql/certs/server-key.pem" \
>> /etc/mysql/conf.d/ssl.cnf
