#!/bin/bash
# A Bash script to execute a Benchmark about implementation of Gateway pattern for Spring Cloud

usage() {
    echo "$@"
    echo ""
    echo "usage:"
    echo ""
    echo "        ./run.sh command args..."
    echo ""
    echo "examples:"
    echo ""
    echo "        ./run.sh sgc                                 # run server, gateways & clients"
    echo ""
    echo "        ./run.sh sg                                  # run server & gateways"
    echo "        ./run.sh c   <server&gateway-host>           # run clients (assuming both gateways and server running at the specified host)"
    echo ""
    echo "        ./run.sh s                                   # run server"
    echo "        ./run.sh g   <server-host>                   # run gateways (assuming the server running at the specified host)"
    echo "        ./run.sh c   <server-host> <gateway-host>    # run clients (assuming the server and gateways runnning at the specified hosts accordingly)"
    echo ""
    exit "1"
}

server_port="8000"
zuul_port="8080"
gateway1_port="8081"
gateway2_port="8082"
linkerd_port="8083"

command="$1"
case "$command" in
    "sgc")
        min_params="0"
        max_params="0"
        server=true
        gateway=true
        client=true
        server_host="localhost"
        gateway_host="localhost"
        ;;

    "sg")
        min_params="0"
        max_params="0"
        server=true
        gateway=true
        client=false
        server_host="localhost"
        gateway_host="?"
        ;;

    "s")
        min_params="0"
        max_params="0"
        server=true
        gateway=false
        client=false
        server_host="localhost"
        gateway_host="?"
        ;;

    "g")
        min_params="1"
        max_params="1"
        server=false
        gateway=true
        client=false
        server_host="${2:-localhost}"
        gateway_host="localhost"
        ;;

    "c")
        min_params="1"
        max_params="2"
        server=false
        gateway=false
        client=true
        server_host="${2:-localhost}"
        gateway_host="${3:-${server_host}}"
        ;;

    "")
        usage "ERROR: No command specified. Please, specify a command."
        ;;

    *)
        usage "ERROR: Unknown command: \`$command\`"
        ;;
esac

command_arg_count="$(($# - 1))"
if [ "$command_arg_count" -lt "${min_params}" ]; then usage "ERROR: Too few arguments"; fi
if [ "$command_arg_count" -gt "${max_params}" ]; then usage "ERROR: Too many arguments"; fi

echo "Gateway Benchmark Script"

OSX="OSX"
WIN="WIN"
LINUX="LINUX"
UNKNOWN="UNKNOWN"
PLATFORM="${UNKNOWN}"

function detectOS() {

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        PLATFORM="${LINUX}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="${OSX}"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        PLATFORM="${WIN}"
    elif [[ "$OSTYPE" == "msys" ]]; then
        PLATFORM="${WIN}"
    elif [[ "$OSTYPE" == "win32" ]]; then
        PLATFORM="${WIN}"
    else
        PLATFORM="${UNKNOWN}"
    fi

    echo "Platform detected: $PLATFORM"
    echo

    if [ "$PLATFORM" == "$UNKNOWN" ]; then
        echo "Sorry, this platform is not recognized by this Script."
        echo
        echo "Open a issue if the problem continues:"
        echo "https://github.com/spencergibb/spring-cloud-gateway-bench/issues"
        echo
        exit "1"
    fi

}

function detectGo() {

    if type -p go; then
        echo "Found Go executable in PATH"
    else
        echo "Not found Go installed"
        exit "1"
    fi

}

function detectJava() {

    if type -p java; then
        echo "Found Java executable in PATH"
    else
        echo "Not found Java installed"
        exit "1"
    fi

    # TODO: export your java home path in a proper shell profile file.
    export JAVA_HOME=/usr/java/default
}

function detectMaven() {

    if type -p mvn; then
        echo "Found Maven executable in PATH"
    else
        echo "Not found Java installed"
        exit "1"
    fi

}

function detectWrk() {

    if type -p wrk; then
        echo "Found wrk executable in PATH"
    else
        echo "Not found wrk installed"
        exit "1"
    fi

}

function setup(){

    detectOS

    detectGo
    detectJava
    detectMaven

    detectWrk

    mkdir -p logs
    mkdir -p reports
    rm ./reports/*.txt
}

setup

#Launching the different services

function runStatic() {

    echo "Running Web server at $server_host:$server_port"

    cd static
    if [ "$PLATFORM" == "$OSX" ]; then
        echo "> build"
        GOOS=darwin GOARCH=amd64 go build -o webserver.darwin-amd64 webserver.go
        echo "> run"
        ./webserver.darwin-amd64 >> "../logs/webserver.log" &
    elif [ "$PLATFORM" == "$LINUX" ]; then
        # echo "> build"
        # go build -o webserver webserver.go
        echo "> run"
        ./webserver >> "../logs/webserver.log" &
        exit "1"
    elif [ "$PLATFORM" == "$WIN" ]; then
        echo "Googling"
        exit "1"
    else
        echo "Googling"
        exit "1"
    fi
    cd -
}

function runZuul() {

    echo "Running Zuul at $gateway_host:$zuul_port"

    cd zuul
    echo "> configure"
    sed -i "s/\(\s*url:\).*/\1 http:\/\/$server_host:$server_port/g" "./src/main/resources/application.yml"
    echo "> build"
    mvn clean package > "../logs/zuul-build.log"
    echo "> run"
    java -jar "./target/zuul-0.0.1-SNAPSHOT.jar" > "../logs/zuul.log" &
    cd -
}

function runGateway1() {

    echo "Running Spring Gateway 1 at $gateway_host:$gateway1_port"

    cd gateway1
    echo "> configure"
    sed -i "s/\(\s*uri:\).*/\1 http:\/\/$server_host:$server_port/g" "./src/main/resources/application.yml"
    echo "> build"
    mvn clean package > "../logs/gateway1-build.log"
    echo "> run"
    java -jar "./target/gateway1-0.0.1-SNAPSHOT.jar" > "../logs/gateway1.log" &
    cd -
}

function runGateway2() {

    echo "Running Spring Gateway 2 at $gateway_host:$gateway2_port"

    cd gateway2
    echo "> configure"
    sed -i "s/\(\s*uri:\).*/\1 http:\/\/$server_host:$server_port/g" "./src/main/resources/application.yml"
    echo "> build"
    mvn clean package > "../logs/gateway2-build.log"
    echo "> run"
    java -jar "./target/gateway2-0.0.1-SNAPSHOT.jar" > "../logs/gateway2.log" &
    cd -
}

function runLinkerd() {

    echo "Running Linkerd at $gateway_host:$linkerd_port"

    cd linkerd
    echo "> configure"
    echo "$server_host $server_port" > "./disco/web"
    echo "> run"
    java -jar "./linkerd-1.3.4.jar" linkerd.yaml &> "../logs/linkerd.log" &
    cd -
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        kill "$(ps aux | grep './webserver.darwin-amd64' | awk '{print $2}')"
        pkill java
        pkill wrk
        exit "1"
}

if [ "${server}" = true ]; then
    #Run Static web server
    runStatic

    echo "Verifying static webserver is running at $server_host:$server_port"

    response="$(curl http://${server_host}:${server_port}/hello.txt 2> /dev/null)"
    if [ '{output:"I Love Spring Cloud"}' != "${response}" ]; then
        echo
        echo "Problem running static webserver, response: \`$response\`"
        echo
        exit "1"
    fi;

    echo "Web server running. OK."
    #echo "Wait 10"
    #sleep "10"
fi

function runGateways() {

    echo "Run Gateways"
    runZuul
    runGateway1
    runGateway2
    runLinkerd

}

if [ "${gateway}" = true ]; then
    runGateways
fi

#Execute performance tests

function warmup() {

    echo "JVM Warmup"

    total_run="10"
    for run in {1..${total_run}}
    do
        echo "Gateway1 $run/$total_run"
        wrk -t "10" -c "200" -d 30s http://${gateway_host}:${gateway1_port}/hello.txt >> ./reports/gateway1.txt
    done

    for run in {1..${total_run}}
    do
        echo "Gateway2 $run/$total_run"
        wrk -t "10" -c "200" -d 30s http://${gateway_host}:${gateway2_port}/hello.txt >> ./reports/gateway2.txt
    done

    for run in {1..${total_run}}
    do
        echo "Linkerd $run/$total_run"
        wrk -H "Host: web" -t "10" -c "200" -d 30s http://${gateway_host}:${linkerd_port}/hello.txt >> ./reports/linkerd.txt
    done

    for run in {1..${total_run}}
    do
        echo "Zuul $run/$total_run"
        wrk -t "10" -c "200" -d 30s http://${gateway_host}:${zuul_port}/hello.txt >> ./reports/zuul.txt
    done
}

function runPerformanceTests() {

    echo "Static results"
    wrk -t "10" -c "200" -d 30s  http://${server_host}:${server_port}/hello.txt > ./reports/static.txt

    echo "Wait 30 seconds"
    sleep "30"

    warmup
}

if [ "${client}" = true ]; then
    runPerformanceTests
fi

echo "Script Finished"
