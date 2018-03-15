Spring Cloud Gateway Benchmark
==============================

This is a benchmark code to compare the following API gateways:

1. **gateway1**: Spring Cloud Gateway, 1.0.1.RELEASE
2. **gateway2**: Spring Cloud Gateway, 2.0.0.BUILD-SNAPSHOT
3. **zuul**: Netflix Zuul, 1.3.1
4. **linkerd**: Linkerd 1.3.4

This repo forked from the @spencergibb's repo to add gateway1 to benchmark.



# How to use at local?

1. Checkout this repo.
2. Ensure JDK8, Maven, ack and wrk installed.
   If you have `yum` installed, you can use `./prepare-environment.sh` script.
3. Run `./run.sh sgc` to run server, gateways and clients in the local machine.
4. Wait to see `Script Finished` message in _gateway_ machine's console.
5. Inspect reports saved under `./reports` directory.



# How to use in Amazon EC2?

1.  Create 3 EC2 instances with Amazon Linux image: server, gateway, client.
2.  Ensure machine can send http requests to each other.
    Add corresponding rules to their security groups if needed.
3.  Checkout this repo in each machine.
4.  Run `./prepare-environment.sh` to ensure JDK8, Maven, ack and wrk installed in each machine.
5.  Run `./run.sh s` in _server_ machine.
6.  Run `./run.sh g <server-host>` in _gateway_ machine replacing
    `<server-host>` with the actual IP address or hostname of the _server_ machine.
7.  Wait to see `Script Finished` message in _gateway_ machine's console.
8.  Run `./run.sh g <server-host> <gateway-host>` in _client_ machine replacing
    `<server-host>` with the actual IP address or hostname of the _server_ machine and
    `<gateway-host>` with the actual IP address or hostname of the _gateway_ machine.
9.  Wait to see `Script Finished` message in _client_ machine's console.
10. Inspect reports saved under `./reports` directory.


# Other usages

System can be run using `./run.sh` in different ways. For example, you can
run server and gateways in the same machine while keeping the clients in a
different machine.

Run the `./run.sh` without any parameter to see sample usages:

```
usage:

        ./run.sh command args...

examples:

        ./run.sh show                                # show running instances of server, gateways & clients
        ./run.sh kill                                # kill running instances of server, gateways & clients

        ./run.sh sgc                                 # run server, gateways & clients

        ./run.sh sg                                  # run server & gateways
        ./run.sh c   <server&gateway-host>           # run clients (assuming both gateways and server running at the specified host)

        ./run.sh s                                   # run server
        ./run.sh g   <server-host>                   # run gateways (assuming the server running at the specified host)
        ./run.sh c   <server-host> <gateway-host>    # run clients (assuming the server and gateways runnning at the specified hosts accordingly)
```


# Inspecting Results

Results saved under `reports` directory:

```
static.txt      # report for direct access (without using any API gateway)

gateway1.txt    # report for Spring Cloud Gateway 1
gateway2.txt    # report for Spring Cloud Gateway 2
linkerd.txt     # report for Linkerd
zuul.txt        # report for Zuul
```


If you are using Amazon EC2, you can download all reports at once with a SCP command similar to the below one:
```
scp "ec2-user@ec2-10-20-30-40.us-west-2.compute.amazonaws.com:/home/ec2-user/spring-cloud-gateway-bench/reports/*" .
```

### Sample Reports

Below report samples are real reports generated on EC2 _t2.micro_ machines.

#### no-proxy (static) example report

```
Running 30s test @ http://172.31.43.9:8000/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    20.61ms   13.92ms 258.69ms   92.97%
    Req/Sec     1.05k   175.08     1.69k    85.50%
  312712 requests in 30.02s, 44.14MB read
Requests/sec:  10415.07
Transfer/sec:      1.47MB
```


#### gateway1 example report

```
Running 30s test @ http://172.31.36.74:8081/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   135.88ms   91.06ms 815.37ms   67.83%
    Req/Sec   156.03     34.82   313.00     70.27%
  46552 requests in 30.05s, 11.19MB read
  Non-2xx or 3xx responses: 46552
Requests/sec:   1549.39
Transfer/sec:    381.54KB
```


#### gateway2 example report

```
Running 30s test @ http://172.31.36.74:8082/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    65.37ms   38.03ms 843.73ms   85.15%
    Req/Sec   318.10     73.10   828.00     82.31%
  94690 requests in 30.04s, 13.37MB read
  Non-2xx or 3xx responses: 2
Requests/sec:   3152.01
Transfer/sec:    455.58KB
```


#### zuul example report

```
Running 30s test @ http://172.31.36.74:8080/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   315.91ms  316.01ms   1.99s    85.33%
    Req/Sec    78.94     38.70   310.00     61.58%
  23265 requests in 30.04s, 3.64MB read
  Socket errors: connect 0, read 0, write 0, timeout 42
Requests/sec:    774.40
Transfer/sec:    124.11KB
```


#### linkerd example report

```
Running 30s test @ http://172.31.36.74:8083/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    59.82ms   33.23ms 300.39ms   69.29%
    Req/Sec   342.25     44.11   470.00     73.65%
  102048 requests in 30.04s, 18.50MB read
  Non-2xx or 3xx responses: 14
Requests/sec:   3397.53
Transfer/sec:    630.69KB
```



# Troubleshooting

`run.sh` script tries to hide most of the unrelated output from the user.
If you need to inspect output for some reason, you can find them under `logs` directory.
Different log files created where each one named after the corresponding component:

```bash
gateway1.log          # gateway1 runtime output
gateway1-build.log    # gateway1 maven output
gateway2.log          # gateway2 maven output
gateway2-build.log    # gateway2 runtime output
linkerd.log           # linkerd runtime output
webserver.log         # webserver runtime output
zuul.log              # zuul runtime output
zuul-build.log        # zuul maven output
```
