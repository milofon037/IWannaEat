package com.milofon.iwannaeat_back.app.auth.service;

import com.milofon.iwannaeat_back.app.auth.dto.AuthResponse;
import com.milofon.iwannaeat_back.app.auth.dto.LoginRequest;
import com.milofon.iwannaeat_back.app.auth.dto.RefreshTokenRequest;
import com.milofon.iwannaeat_back.app.auth.dto.RegisterRequest;
import com.milofon.iwannaeat_back.app.auth.entity.UserEntity;
import com.milofon.iwannaeat_back.app.auth.entity.UserRole;
import com.milofon.iwannaeat_back.app.auth.repository.UserRepository;
import com.milofon.iwannaeat_back.app.common.error.ConflictException;
import com.milofon.iwannaeat_back.app.common.error.UnauthorizedException;
import com.milofon.iwannaeat_back.app.common.security.JwtService;
import com.milofon.iwannaeat_back.app.user.entity.UserProfileEntity;
import com.milofon.iwannaeat_back.app.user.repository.UserProfileRepository;
import jakarta.transaction.Transactional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(
            UserRepository userRepository,
            UserProfileRepository userProfileRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService
    ) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String normalizedEmail = request.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new ConflictException("User with this email already exists");
        }

        UserEntity user = new UserEntity();
        user.setEmail(normalizedEmail);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setRole(UserRole.USER);
        UserEntity createdUser = userRepository.save(user);

        UserProfileEntity profile = new UserProfileEntity();
        profile.setUser(createdUser);
        profile.setDietDescription("");
        userProfileRepository.save(profile);

        return buildAuthResponse(createdUser);
    }

    public AuthResponse login(LoginRequest request) {
        UserEntity user = userRepository.findByEmailIgnoreCase(request.email().trim())
                .orElseThrow(() -> new UnauthorizedException("Invalid credentials"));
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid credentials");
        }
        return buildAuthResponse(user);
    }

    public AuthResponse refresh(RefreshTokenRequest request) {
        String refreshToken = request.refreshToken();
        if (!jwtService.isTokenValid(refreshToken) || !"refresh".equals(jwtService.extractTokenType(refreshToken))) {
            throw new UnauthorizedException("Invalid refresh token");
        }
        UUID userId = jwtService.extractUserId(refreshToken);
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
        return buildAuthResponse(user);
    }

    private AuthResponse buildAuthResponse(UserEntity user) {
        return new AuthResponse(
                user.getId(),
                user.getRole().name(),
                jwtService.issueAccessToken(user),
                jwtService.issueRefreshToken(user),
                "Bearer"
        );
    }
}
