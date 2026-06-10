package com.milofon.iwannaeat_back.app.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record RegisterRequest(
        @NotBlank
        @Email(message = "Invalid email format")
        String email,

        @NotBlank
        @Pattern(
                regexp = "^(?=.*\\d)(?=.*[^\\w\\s]).{8,}$",
                message = "Password must be at least 8 chars and contain a digit and a special character"
        )
        String password
) {
}
