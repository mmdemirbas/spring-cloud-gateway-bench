package com.example.gateway;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockserver.integration.ClientAndServer;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.reactive.server.WebTestClient;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockserver.integration.ClientAndServer.startClientAndServer;
import static org.mockserver.model.HttpRequest.request;
import static org.mockserver.model.HttpResponse.response;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public final class GatewayApplicationTests {
    private static final String SUCCESS_MESSAGE = "API Gateway Works!";

    @LocalServerPort int             port;
    private          WebTestClient   webClient;
    private          ClientAndServer mockServer;

    @Before
    public void setup() {
        mockServer = startClientAndServer(8000);
        mockServer.when(request().withMethod("GET")).respond(response().withStatusCode(200).withBody(SUCCESS_MESSAGE));
        webClient = WebTestClient.bindToServer().responseTimeout(Duration.ofSeconds(3)).baseUrl("http://localhost:" + port).build();
    }

    @Test
    public void routingWorks() {
        webClient.get()
                 .uri("/get")
                 .exchange()
                 .expectStatus()
                 .isOk()
                 .expectBody(String.class)
                 .consumeWith(result -> assertThat(result.getResponseBody()).isEqualTo(SUCCESS_MESSAGE));
    }

    @After
    public void cleanup() {
        mockServer.stop();
    }
}
