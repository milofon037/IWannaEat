package com.milofon.iwannaeat_back.app.user.repository;

import com.milofon.iwannaeat_back.app.user.entity.UserProfileEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface UserProfileRepository extends JpaRepository<UserProfileEntity, UUID> {
}
