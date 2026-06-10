package com.milofon.iwannaeat_back.app.user.controller;

import com.milofon.iwannaeat_back.app.user.dto.AllergyResponse;
import com.milofon.iwannaeat_back.app.user.dto.ProfileResponse;
import com.milofon.iwannaeat_back.app.user.dto.UpdateAllergiesRequest;
import com.milofon.iwannaeat_back.app.user.dto.UpdateProfileRequest;
import com.milofon.iwannaeat_back.app.user.service.ProfileService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @GetMapping("/profile")
    public ProfileResponse getProfile() {
        return profileService.getMyProfile();
    }

    @PutMapping("/profile")
    public ProfileResponse updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        return profileService.updateProfile(request);
    }

    @GetMapping("/allergies")
    public List<AllergyResponse> getAllergies() {
        return profileService.getAllergies();
    }

    @PutMapping("/profile/allergies")
    public ProfileResponse updateAllergies(@Valid @RequestBody UpdateAllergiesRequest request) {
        return profileService.updateAllergies(request);
    }
}
