#
# Percona Cluster Dockerfile
#
# https://github.com/dockerfile/percona
#

# Pull base image.
FROM ubuntu
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
# Install Percona Server.
RUN \
  apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A && \
  echo "deb http://repo.percona.com/apt `lsb_release -cs` main" > /etc/apt/sources.list.d/percona.list && \
  apt-get update && \
  apt-get install -y percona-xtradb-cluster-56 && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
  sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
  echo "mysqld_safe &" > /tmp/config && \
  echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
  bash /tmp/config && \
  rm -f /tmp/config

ADD start.sh /start.sh
RUN chmod a+rx /start.sh

# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql"]

# Define working directory.
WORKDIR /data

# Define default command.
ENTRYPOINT ["/start.sh"]
CMD ["start"]

# Expose ports.
EXPOSE 3306
EXPOSE 4567
