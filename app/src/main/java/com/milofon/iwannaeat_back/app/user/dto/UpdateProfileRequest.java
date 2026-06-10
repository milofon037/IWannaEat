package com.milofon.iwannaeat_back.app.user.dto;

import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @Size(max = 100)
        String firstName,
        @Size(max = 500)
        String dietDescription
) {
}
