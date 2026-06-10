package com.milofon.iwannaeat_back.app.auth.dto;

import java.util.UUID;

public record AuthResponse(
        UUID userId,
        String role,
        String accessToken,
        String refreshToken,
        String tokenType
) {
}
