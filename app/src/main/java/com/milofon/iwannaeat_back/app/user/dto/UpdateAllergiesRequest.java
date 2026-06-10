package com.milofon.iwannaeat_back.app.user.dto;

import jakarta.validation.constraints.Size;

import java.util.List;

public record UpdateAllergiesRequest(
        List<Integer> allergyIds,
        @Size(max = 20)
        List<@Size(min = 2, max = 100) String> customAllergies
) {
}
