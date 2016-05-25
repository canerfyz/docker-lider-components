FROM debian:jessie

ENV OPENLDAP_VERSION 2.4.40

RUN apt-get update
RUN apt-get install --yes apt-utils wget 
RUN wget http://www.agem.com.tr/docker/sources.list
RUN cp sources.list /etc/apt/sources.list
RUN rm sources.list
RUN apt-get update
RUN apt-get install --force-yes --yes pardus-archive-keyring
RUN apt-get update

RUN apt-get install --yes gdebi
RUN apt-get install --yes openssh-client
RUN apt-get install --yes openssh-server
RUN apt-get install --yes debconf-utils

RUN apt-get --yes install ca-certificates ssl-cert ldap-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes slapd=${OPENLDAP_VERSION}*
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 389

# Add VOLUMEs to allow backup of config, logs and databases
# * To store the data outside the container, mount /var/lib/ldap as a data volume
#VOLUME ["/etc/ldap", "/var/lib/ldap", "/run/slapd"]


# Son durum:
# agem.com.tr/docker'daki ldapconfig1'le ldap çalıştı ve entryleri oluşturdu.(liderAhenkConfig hariç, o da eksik olduğundan)

# Yapılacaklar
# ldapconfig1'de deneme amaçlı kapatılan yerler açılacak, loglar silinecek
# ldapconfig dosyası Installer projesinin içindekine göre yenilenecek(liderAhenkConfig entry'si vs. için).
# entrypoint olarak bir script eklenecek sırasıyla ("service slapd start" ve "./ldapconfig" yapacak).
# veya aynı script add ile /usr/local/bin/start'a eklenecek
# wget ile çektiğim scriptler add ile eklenebiliyor olabilir, araştırılacak
# persistence için VOLUME eklenecek, yukarıda var, tam olarak nasıl kullanıldığı araştırılacak
# ldap bittikten sonra hazır olan mariadb eklenecek, onun da create database vs komutları ldaptaki gibi bir start scripte eklemek denenecek.
# bu arada mariadb'nin de kendi hazırladığım haricinde hazırı varsa kullanabilirim dockerhub'dan vs araştırılmalı.
# mariadb de bitince ejabberd kurulacak.



RUN wget http://www.agem.com.tr/docker/start.sh
RUN chmod +x ./start.sh
RUN ./start.sh
#aşağıdaki addi çalıştıracam
#RUN ldapadd -x -f /liderahenk.ldif -D "$CNCONFIGADMINDN" -w $CNCONFIGADMINPASSWD
#COPY start.sh /start.sh

#ENTRYPOINT ["/start.sh"]

#CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]

#ADD start.sh /usr/local/bin/start

#ENTRYPOINT ["slapd"]
#CMD ["-h", "ldap:/// ldapi:///", "-u", "openldap", "-g", "openldap", "-d0"]

