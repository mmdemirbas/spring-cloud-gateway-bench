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
    echo "        ./run.sh show                                # show running instances of server, gateways & clients"
    echo "        ./run.sh kill                                # kill running instances of server, gateways & clients"
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

function show_instances() {
    ps x | ack "webserver|zuul|spring|linkerd|wrk|run\.sh" 2> /dev/null
}

function kill_instances() {
    show_instances | sed 's/^[ \t]*//g' | cut -d" " -f1 | xargs kill
}

server_port="8000"
zuul_port="8080"
spring_port="8082"
linkerd_port="8083"

command="$1"
case "$command" in
    "show")
        show_instances
        exit
        ;;

    "kill")
        kill_instances
        exit
        ;;

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
        echo "Not found Maven installed"
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
    mkdir -p reports/local
    rm -rf ./reports/local/*.txt
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

function runSpring() {

    echo "Running Spring Gateway 2 at $gateway_host:$spring_port"

    cd spring
    echo "> configure"
    sed -i "s/\(\s*uri:\).*/\1 http:\/\/$server_host:$server_port/g" "./src/main/resources/application.yml"
    echo "> build"
    mvn clean package > "../logs/spring-build.log"
    echo "> run"
    java -jar "./target/spring-0.0.1-SNAPSHOT.jar" > "../logs/spring.log" &
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
        kill_instances
        exit "1"
}

if [ "${server}" = true ]; then
    #Run Static web server
    runStatic

    echo "Wait 3"
    sleep "3"
    echo "Verifying static webserver is running at $server_host:$server_port"

    response="$(curl http://${server_host}:${server_port}/hello.txt 2> /dev/null)"
    if [ '{output:"I Love Spring Cloud"}' != "${response}" ]; then
        echo
        echo "Problem running static webserver, response: \`$response\`"
        echo
        exit "1"
    fi;

    echo "Web server running. OK."
fi

function runGateways() {

    echo "Run Gateways"
    runZuul
    runSpring
    runLinkerd

}

if [ "${gateway}" = true ]; then
    runGateways
fi

#Execute performance tests

function warmup() {

    echo "JVM Warmup"

    total_run="10"

    for ((run=1;run<=$total_run;run++))
    do
        echo "Spring $run/$total_run"
        wrk -t "10" -c "200" -d 30s http://${gateway_host}:${spring_port}/hello.txt >> ./reports/local/spring.txt
    done

    for ((run=1;run<=$total_run;run++))
    do
        echo "Linkerd $run/$total_run"
        wrk -H "Host: web" -t "10" -c "200" -d 30s http://${gateway_host}:${linkerd_port}/hello.txt >> ./reports/local/linkerd.txt
    done

    for ((run=1;run<=$total_run;run++))
    do
        echo "Zuul $run/$total_run"
        wrk -t "10" -c "200" -d 30s http://${gateway_host}:${zuul_port}/hello.txt >> ./reports/local/zuul.txt
    done
}

function runPerformanceTests() {
    total_run="10"

    for ((run=1;run<=$total_run;run++))
    do
        echo "Static results $run/$total_run"
        wrk -t "10" -c "200" -d 30s  http://${server_host}:${server_port}/hello.txt >> ./reports/local/static.txt
    done

    echo "Wait 30 seconds"
    sleep "30"

    warmup
}

if [ "${client}" = true ]; then
    runPerformanceTests
fi

echo "Script Finished"
