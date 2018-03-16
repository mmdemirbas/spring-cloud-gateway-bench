#!/usr/bin/env bash

########################### install JDK 8 ################################################

echo "Latest JDK8 version is: $(curl http://www.oracle.com/technetwork/java/javase/downloads/index.html 2>/dev/null | ack "(?<=Java SE )8\w+" -o 2>/dev/null | sort -ru | head -1)"

if [ "$(java -version 2>&1 | head -1)" = "java version \"1.8.0.162\"" ]; then
    echo "jdk1.8.0_162 already installed."
else
    # https://gist.github.com/rtfpessoa/17752cbf7156bdf32c59
    wget --no-cookies --header "Cookie: gpw_e24=xxx; oraclelicense=accept-securebackup-cookie;" "http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-x64.rpm"
    sudo rpm -i jdk-8u162-linux-x64.rpm
    sudo /usr/sbin/alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_162/bin/java 20000
    sudo /usr/sbin/alternatives --set java /usr/java/jdk1.8.0_162/bin/java

    # TODO: export your java home path in a proper shell profile file.
    export JAVA_HOME=/usr/java/default

    ## remove jdk 7 after installing jdk 8, or the aws-apitools will also be removed as they depend on Java on being installed (https://serverfault.com/a/727254)
    # sudo yum remove java-1.7.0-openjdk
    ## removing jdk 7 also removes maven. So, leave it.
fi

########################### install other tools ##########################################

sudo yum -y install openssl-devel git go ack maven
sudo yum -y groupinstall 'Development Tools'
sudo yum -y update
command -v foo >/dev/null 2>&1 || cd /opt && ( (sudo git clone "https://github.com/wg/wrk.git" wrk) || (cd wrk && sudo git pull) ) && cd wrk && sudo make && sudo cp wrk /usr/local/bin && cd - >/dev/null
