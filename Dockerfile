FROM cern/cc7-base
MAINTAINER Mayank Sharma (mayank.sharma@cern.ch)

ENV SIMPLE_CONFIG_DIR=/etc/simple_grid

# Install Mariadb
RUN yum install -y mariadb-server mariadb
RUN systemctl enable mariadb
RUN systemctl start mariadb


# Apel client, parser and depencies (https://apel.github.io/downloads/)
# Instalation from github was required because el7 version of argo-ms (dependency for apel-ssm) wasn't submited to el7, UMD nor CMD at this moment (11-21-2019)
RUN yum install -y http://rpm-repo.argo.grnet.gr/ARGO/prod/centos7/argo-ams-library-0.4.2-1.el7.noarch.rpm \
               https://github.com/apel/ssm/releases/download/2.4.1-1/apel-ssm-2.4.1-1.el7.noarch.rpm
RUN yum install -y https://github.com/apel/apel/releases/download/1.8.2-1/apel-client-1.8.2-1.el7.noarch.rpm \
               https://github.com/apel/apel/releases/download/1.8.2-1/apel-lib-1.8.2-1.el7.noarch.rpm \
               https://github.com/apel/apel/releases/download/1.8.2-1/apel-parsers-1.8.2-1.el7.noarch.rpm
RUN yum install -y   htcondor-ce-apel

## Install certs, CRLs ##
RUN yum install -y wget
RUN wget -O /etc/yum.repos.d/EGI-third-party.repo \
	http://repository.egi.eu/community/software/third.party.distribution/1.0/releases/repofiles/sl-6-x86_64.repo
RUN echo -e 'protect=1\npriority=1' >> /etc/yum.repos.d/EGI-third-party.repo
RUN yum -y install \
    http://repository.egi.eu/sw/production/umd/4/sl6/x86_64/updates/umd-release-4.1.3-1.el6.noarch.rpm
RUN yum -y --skip-broken install fetch-crl globus-rsl empty-ca-certs ca-policy-egi-core

## Install utils ##
RUN yum install -y vim less

## net tools ##
RUN yum install -y net-tools iproute openssh openssh-server openssh-clients openssl-libs tcpdump telnet


## mount point for SIMPLE Grid Framework ##
VOLUME ["/etc/simple_grid"]

## init system inside the container ##
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]