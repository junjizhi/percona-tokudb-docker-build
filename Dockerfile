FROM ubuntu-debootstrap:trusty
MAINTAINER Junji Zhi <jzhi316@gmail.com>

# adapted from https://github.com/topdevbox/dockercraft/blob/master/dockerfiles/ubuntu/percona/Dockerfile

#percona database with tokudb plugin
#percona 5.6 server database with tokudb plugin

RUN apt-get update && \
      apt-get -y install sudo && \
      	      apt-get -y install echo

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker

RUN apt-get update && \
    apt-get upgrade -y && \
    	    apt-get autoclean -y && \
	    	    apt-get autoremove -y && \
		        apt-get -y clean

RUN apt-get install -y wget

RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

RUN echo "deb http://repo.percona.com/apt "$(lsb_release -sc)" main" | sudo tee /etc/apt/sources.list.d/percona.list

RUN echo "deb-src http://repo.percona.com/apt "$(lsb_release -sc)" main" | sudo tee -a /etc/apt/sources.list.d/percona.list

RUN apt-get update

RUN echo "percona-server-server-5.6 percona-server-server/root_password_again password dbpassword" | debconf-set-selections
RUN echo "percona-server-server-5.6 percona-server-server/root_password password dbpassword" | debconf-set-selections
RUN apt-get install -y percona-server-server-5.6 percona-server-client-5.6 percona-server-common-5.6

RUN sed -i -- "s/bind-address/#bind-address/g" /etc/mysql/my.cnf
RUN sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN apt-get install -y libjemalloc1 libjemalloc-dev
#RUN sed -i -- "s/[mysqld_safe]/[mysqld_safe]malloc-lib= /usr/include/jemalloc/g" /etc/mysql/my.cnf
RUN sed -i -- '/\[mysqld_safe\]/a malloc-lib = /usr/include/jemalloc' /etc/mysql/my.cnf

RUN apt-get install -y percona-server-tokudb-5.6

RUN service mysql restart

##################################################################
###############       Readme: enable tokudb    ###################
##################################################################
#RUN echo never > /sys/kernel/mm/transparent_hugepage/enabled
#RUN echo never > /sys/kernel/mm/transparent_hugepage/defrag
## need to restart server to make config change updated ##
#RUN ps_tokudb_admin --enable -u root -pdbpassword
#RUN service mysql restart
##################################################################

#Clean system
RUN apt-get autoclean -y && \
    apt-get autoremove -y && \
        apt-get clean -y

CMD service mysql start && tail -F /var/log/mysql/error.log
CMD /etc/rc2.d/S19mysql start
CMD mysql --user=root --password=dbpassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'dbpassword' WITH GRANT OPTION;"; exit 0
CMD mysql --user=root --password=dbpassword -e "FLUSH PRIVILEGES;"; exit 0