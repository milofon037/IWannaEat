package com.milofon.iwannaeat_back.app.user.dto;

import java.util.List;
import java.util.UUID;

public record ProfileResponse(
        UUID userId,
        String email,
        String firstName,
        String dietDescription,
        List<AllergyResponse> allergies
) {
}
