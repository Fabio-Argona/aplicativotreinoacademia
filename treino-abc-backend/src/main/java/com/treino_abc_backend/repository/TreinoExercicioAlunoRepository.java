package com.treino_abc_backend.repository;

import com.treino_abc_backend.entity.TreinoExercicioAluno;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TreinoExercicioAlunoRepository extends JpaRepository<TreinoExercicioAluno, UUID> {
    List<TreinoExercicioAluno> findByGrupoId(UUID grupoId);
}


