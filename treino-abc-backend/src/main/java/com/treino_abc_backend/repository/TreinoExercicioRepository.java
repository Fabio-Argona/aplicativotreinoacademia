package com.treino_abc_backend.repository;

import com.treino_abc_backend.entity.TreinoExercicio;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface TreinoExercicioRepository extends JpaRepository<TreinoExercicio, UUID> {

}

