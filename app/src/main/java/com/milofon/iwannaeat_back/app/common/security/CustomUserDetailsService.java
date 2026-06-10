package com.milofon.iwannaeat_back.app.common.security;

import com.milofon.iwannaeat_back.app.auth.repository.UserRepository;
import com.milofon.iwannaeat_back.app.common.error.UnauthorizedException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) {
        UUID userId = UUID.fromString(username);
        return userRepository.findById(userId)
                .map(UserPrincipal::new)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
    }
}
