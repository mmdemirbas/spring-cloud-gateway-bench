#!/usr/bin/env bash


##### start ################
# sudo yum install git
# git clone https://github.com/mmdemirbas/spring-cloud-gateway-bench.git && cd spring-cloud-gateway-bench
# ./prepare-environment.sh



########################### install JDK 8 ################################################

echo "Latest JDK8 version is: $(curl http://www.oracle.com/technetwork/java/javase/downloads/index.html 2>/dev/null | ack "(?<=Java SE )8\w+" -o 2>/dev/null | sort -ru | head -1)"

# Download
wget --no-cookies --header "Cookie: gpw_e24=xxx; oraclelicense=accept-securebackup-cookie;" "http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-x64.rpm"
java -version
sudo rpm -i jdk-8u162-linux-x64.rpm
java -version
sudo /usr/sbin/alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_162/bin/java 20000
sudo /usr/sbin/alternatives --config java
java -version

# TODO: export your java home path in a proper shell profile file.
export JAVA_HOME=/usr/java/default

# remove jdk 7 after installing jdk 8, or the aws-apitools will also be removed as they depend on Java on being installed (https://serverfault.com/a/727254)
sudo yum remove java-1.7.0-openjdk

########################### install other tools ##########################################

sudo yum install openssl-devel git go ack maven
sudo yum groupinstall 'Development Tools'
cd /opt && sudo git clone https://github.com/wg/wrk.git wrk && cd wrk && make && sudo cp wrk /usr/local/bin && cd - >/dev/null
