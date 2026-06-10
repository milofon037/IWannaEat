package com.milofon.iwannaeat_back.app.user.service;

import com.milofon.iwannaeat_back.app.auth.entity.UserEntity;
import com.milofon.iwannaeat_back.app.auth.repository.UserRepository;
import com.milofon.iwannaeat_back.app.common.error.NotFoundException;
import com.milofon.iwannaeat_back.app.common.error.UnauthorizedException;
import com.milofon.iwannaeat_back.app.common.security.UserPrincipal;
import com.milofon.iwannaeat_back.app.user.dto.AllergyResponse;
import com.milofon.iwannaeat_back.app.user.dto.ProfileResponse;
import com.milofon.iwannaeat_back.app.user.dto.UpdateAllergiesRequest;
import com.milofon.iwannaeat_back.app.user.dto.UpdateProfileRequest;
import com.milofon.iwannaeat_back.app.user.entity.AllergyEntity;
import com.milofon.iwannaeat_back.app.user.entity.UserProfileEntity;
import com.milofon.iwannaeat_back.app.user.repository.AllergyRepository;
import com.milofon.iwannaeat_back.app.user.repository.UserProfileRepository;
import jakarta.transaction.Transactional;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class ProfileService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final AllergyRepository allergyRepository;

    public ProfileService(
            UserRepository userRepository,
            UserProfileRepository userProfileRepository,
            AllergyRepository allergyRepository
    ) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.allergyRepository = allergyRepository;
    }

    @Transactional
    public ProfileResponse getMyProfile() {
        UserEntity user = getCurrentUser();
        UserProfileEntity profile = userProfileRepository.findById(user.getId())
                .orElseGet(() -> createDefaultProfile(user));
        return toProfileResponse(user, profile);
    }

    @Transactional
    public ProfileResponse updateProfile(UpdateProfileRequest request) {
        UserEntity user = getCurrentUser();
        UserProfileEntity profile = userProfileRepository.findById(user.getId())
                .orElseGet(() -> createDefaultProfile(user));
        if (request.firstName() != null) {
            profile.setFirstName(request.firstName().trim());
        }
        if (request.dietDescription() != null) {
            profile.setDietDescription(request.dietDescription().trim());
        }
        UserProfileEntity saved = userProfileRepository.save(profile);
        return toProfileResponse(user, saved);
    }

    public List<AllergyResponse> getAllergies() {
        return allergyRepository.findAll().stream()
                .sorted(Comparator.comparing(AllergyEntity::getName))
                .map(a -> new AllergyResponse(a.getId(), a.getName()))
                .toList();
    }

    @Transactional
    public ProfileResponse updateAllergies(UpdateAllergiesRequest request) {
        UserEntity user = getCurrentUser();
        UserProfileEntity profile = userProfileRepository.findById(user.getId())
                .orElseGet(() -> createDefaultProfile(user));

        Set<AllergyEntity> selected = new HashSet<>();

        List<Integer> allergyIds = request.allergyIds() == null ? List.of() : request.allergyIds();
        if (!allergyIds.isEmpty()) {
            List<AllergyEntity> found = allergyRepository.findAllByIdIn(allergyIds);
            if (found.size() != allergyIds.size()) {
                throw new NotFoundException("One or more allergies do not exist");
            }
            selected.addAll(found);
        }

        List<String> customAllergies = request.customAllergies() == null ? List.of() : request.customAllergies();
        for (String name : customAllergies) {
            String normalized = name.trim();
            if (normalized.isEmpty()) {
                continue;
            }
            AllergyEntity allergy = allergyRepository.findByNameIgnoreCase(normalized)
                    .orElseGet(() -> {
                        AllergyEntity created = new AllergyEntity();
                        created.setName(normalized.substring(0, 1).toUpperCase(Locale.ROOT) + normalized.substring(1));
                        return allergyRepository.save(created);
                    });
            selected.add(allergy);
        }

        profile.setAllergies(selected);
        UserProfileEntity saved = userProfileRepository.save(profile);
        return toProfileResponse(user, saved);
    }

    private UserEntity getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof UserPrincipal principal)) {
            throw new UnauthorizedException("Unauthorized");
        }
        UUID userId = principal.getId();
        return userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
    }

    private UserProfileEntity createDefaultProfile(UserEntity user) {
        UserProfileEntity profile = new UserProfileEntity();
        profile.setUser(user);
        profile.setFirstName("");
        profile.setDietDescription("");
        return userProfileRepository.save(profile);
    }

    private ProfileResponse toProfileResponse(UserEntity user, UserProfileEntity profile) {
        List<AllergyResponse> allergies = profile.getAllergies().stream()
                .sorted(Comparator.comparing(AllergyEntity::getName))
                .map(a -> new AllergyResponse(a.getId(), a.getName()))
                .toList();
        return new ProfileResponse(
                user.getId(),
                user.getEmail(),
                profile.getFirstName(),
                profile.getDietDescription(),
                allergies
        );
    }
}
