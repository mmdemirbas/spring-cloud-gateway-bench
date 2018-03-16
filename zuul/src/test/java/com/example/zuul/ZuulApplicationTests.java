package com.example.zuul;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockserver.integration.ClientAndServer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.junit4.SpringRunner;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockserver.integration.ClientAndServer.startClientAndServer;
import static org.mockserver.model.HttpRequest.request;
import static org.mockserver.model.HttpResponse.response;

@RunWith(SpringRunner.class)
@DirtiesContext
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public final class ZuulApplicationTests {
    private static final String SUCCESS_MESSAGE = "API Gateway Works!";

    @LocalServerPort   int              port;
    @Autowired private TestRestTemplate rest;
    private            ClientAndServer  mockServer;

    @Before
    public void setup() {
        mockServer = startClientAndServer(8000);
        mockServer.when(request().withMethod("GET")).respond(response().withStatusCode(200).withBody(SUCCESS_MESSAGE));
    }

    @Test
    public void routingWorks() {
        assertThat(rest.getForObject("/get", String.class)).isEqualTo(SUCCESS_MESSAGE);
    }

    @After
    public void cleanup() {
        mockServer.stop();
    }
}