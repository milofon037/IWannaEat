package com.milofon.iwannaeat_back.app;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class AuthProfileIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16.6-alpine")
            .withDatabaseName("iwannaeat_test")
            .withUsername("iwannaeat")
            .withPassword("iwannaeat");

    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.flyway.enabled", () -> true);
    }

    private final ObjectMapper objectMapper = new ObjectMapper();

    @LocalServerPort
    private int port;

    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Test
    void registerAndReadProfileFlowWorks() throws Exception {
        HttpResponse<String> registerResponse = postJson("/api/auth/register", Map.of(
                "email", "user1@example.com",
                "password", "Str0ng!Pass"
        ));
        assertThat(registerResponse.statusCode()).isEqualTo(201);

        JsonNode json = objectMapper.readTree(registerResponse.body());
        String accessToken = json.get("accessToken").asText();

        HttpResponse<String> profileResponse = getWithBearer("/api/profile", accessToken);
        assertThat(profileResponse.statusCode()).isEqualTo(200);
        assertThat(objectMapper.readTree(profileResponse.body()).get("email").asText()).isEqualTo("user1@example.com");
    }

    @Test
    void refreshTokenReturnsNewPair() throws Exception {
        HttpResponse<String> registerResponse = postJson("/api/auth/register", Map.of(
                "email", "user2@example.com",
                "password", "Str0ng!Pass"
        ));
        String refreshToken = objectMapper.readTree(registerResponse.body()).get("refreshToken").asText();

        HttpResponse<String> refreshResponse = postJson("/api/auth/refresh", Map.of(
                "refreshToken", refreshToken
        ));
        JsonNode body = objectMapper.readTree(refreshResponse.body());
        assertThat(refreshResponse.statusCode()).isEqualTo(200);
        assertThat(body.get("accessToken").asText()).isNotBlank();
        assertThat(body.get("refreshToken").asText()).isNotBlank();
    }

    @Test
    void profileEndpointsRequireAuthentication() throws Exception {
        HttpResponse<String> profileResponse = get("/api/profile");
        assertThat(profileResponse.statusCode()).isEqualTo(401);
    }

    @Test
    void updateProfileAndAllergiesWorks() throws Exception {
        HttpResponse<String> registerResponse = postJson("/api/auth/register", Map.of(
                "email", "user3@example.com",
                "password", "Str0ng!Pass"
        ));
        String accessToken = objectMapper.readTree(registerResponse.body()).get("accessToken").asText();

        HttpResponse<String> updateProfileResponse = putJsonWithBearer("/api/profile", accessToken, Map.of(
                "firstName", "Milo",
                "dietDescription", "Без сахара"
        ));
        JsonNode updateProfileJson = objectMapper.readTree(updateProfileResponse.body());
        assertThat(updateProfileResponse.statusCode()).isEqualTo(200);
        assertThat(updateProfileJson.get("firstName").asText()).isEqualTo("Milo");
        assertThat(updateProfileJson.get("dietDescription").asText()).isEqualTo("Без сахара");

        HttpResponse<String> allergiesResponse = getWithBearer("/api/allergies", accessToken);
        assertThat(allergiesResponse.statusCode()).isEqualTo(200);
        JsonNode allergiesJson = objectMapper.readTree(allergiesResponse.body());
        int[] allergyIds = allergiesJson.isArray() && !allergiesJson.isEmpty()
                ? new int[]{allergiesJson.get(0).get("id").asInt()}
                : new int[]{};

        HttpResponse<String> updateAllergiesResponse = putJsonWithBearer(
                "/api/profile/allergies",
                accessToken,
                Map.of(
                        "allergyIds", allergyIds,
                        "customAllergies", new String[]{"Кунжут"}
                )
        );
        assertThat(updateAllergiesResponse.statusCode()).isEqualTo(200);
        JsonNode allergiesUpdateJson = objectMapper.readTree(updateAllergiesResponse.body());
        assertThat(allergiesUpdateJson.get("allergies").isArray()).isTrue();
    }

    private HttpResponse<String> postJson(String path, Object body) throws Exception {
        return sendRequest("POST", path, null, body);
    }

    private HttpResponse<String> putJsonWithBearer(String path, String token, Object body) throws Exception {
        return sendRequest("PUT", path, token, body);
    }

    private HttpResponse<String> getWithBearer(String path, String token) throws Exception {
        return sendRequest("GET", path, token, null);
    }

    private HttpResponse<String> get(String path) throws Exception {
        return sendRequest("GET", path, null, null);
    }

    private HttpResponse<String> sendRequest(String method, String path, String bearerToken, Object body) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(url(path)))
                .header("Content-Type", "application/json");

        if (bearerToken != null && !bearerToken.isBlank()) {
            builder.header("Authorization", "Bearer " + bearerToken);
        }

        HttpRequest request;
        if ("POST".equals(method)) {
            request = builder.POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body))).build();
        } else if ("PUT".equals(method)) {
            request = builder.PUT(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body))).build();
        } else {
            request = builder.GET().build();
        }

        return httpClient.send(request, HttpResponse.BodyHandlers.ofString());
    }

    private String url(String path) {
        return "http://localhost:" + port + path;
    }
}
