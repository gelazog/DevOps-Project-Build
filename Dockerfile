FROM centos:7

RUN cd /etc/yum.repos.d/ && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y httpd wget zip unzip && yum clean all

ADD https://www.tooplate.com/zip-templates/2121_wave_cafe.zip /var/www/html/

WORKDIR /var/www/html
RUN unzip -o 2121_wave_cafe.zip && \
    cp -r 2121_wave_cafe/* . && \
    rm -rf 2121_wave_cafe 2121_wave_cafe.zip

EXPOSE 80

CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
