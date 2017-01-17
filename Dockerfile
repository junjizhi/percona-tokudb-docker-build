FROM ubuntu:trusty
MAINTAINER Junji Zhi <jzhi316@gmail.com>

# adapted from https://github.com/topdevbox/dockercraft/blob/master/dockerfiles/ubuntu/percona/Dockerfile

#percona database with tokudb plugin
#percona 5.6 server database with tokudb plugin
USER root

RUN apt-get update && \
    	    apt-get autoclean -y && \
	    	    apt-get autoremove -y && \
		        apt-get -y clean

RUN apt-get install -y wget

RUN wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb

RUN dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb

RUN apt-get update

RUN echo "percona-server-server-5.6 percona-server-server/root_password_again password dbpass" | debconf-set-selections
RUN echo "percona-server-server-5.6 percona-server-server/root_password password dbpass" | debconf-set-selections
RUN apt-get install -y percona-server-server-5.6 percona-server-client-5.6 percona-server-common-5.6

#RUN sed -i -- "s/bind-address/#bind-address/g" /etc/mysql/my.cnf
#RUN sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN apt-get install -y libjemalloc1 libjemalloc-dev
# Need this line otherwise mysql complains include dir not in /usr/lib/
RUN cp /usr/include/jemalloc/jemalloc.h /usr/lib/

RUN apt-get install -y percona-server-tokudb-5.6

# need to run this when we want to enable tokudb
#RUN ps_tokudb_admin --enable -u root -pdbpass

#Clean system
RUN apt-get autoclean -y && \
    apt-get autoremove -y && \
        apt-get clean -y

#CMD service mysql start && tail -F /var/log/mysql/error.log
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
