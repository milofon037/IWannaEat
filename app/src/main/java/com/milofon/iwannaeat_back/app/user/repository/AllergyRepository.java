package com.milofon.iwannaeat_back.app.user.repository;

import com.milofon.iwannaeat_back.app.user.entity.AllergyEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface AllergyRepository extends JpaRepository<AllergyEntity, Integer> {
    List<AllergyEntity> findAllByIdIn(Collection<Integer> ids);
    Optional<AllergyEntity> findByNameIgnoreCase(String name);
}
