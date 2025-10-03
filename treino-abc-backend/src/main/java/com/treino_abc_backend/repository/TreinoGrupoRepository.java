package com.treino_abc_backend.repository;

import com.treino_abc_backend.entity.TreinoGrupo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TreinoGrupoRepository extends JpaRepository<TreinoGrupo, UUID> {
    List<TreinoGrupo> findByAlunoId(UUID alunoId);
}

