package com.treino_abc_backend.service;

import com.treino_abc_backend.dto.TreinoDTO;
import com.treino_abc_backend.entity.Aluno;
import com.treino_abc_backend.entity.TreinoExercicio;
import com.treino_abc_backend.entity.TreinoExercicioAluno;
import com.treino_abc_backend.repository.AlunoRepository;
import com.treino_abc_backend.repository.TreinoExercicioAlunoRepository;
import com.treino_abc_backend.repository.TreinoExercicioRepository;
import com.treino_abc_backend.repository.TreinoGrupoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TreinoService {

    @Autowired
    private TreinoExercicioAlunoRepository treinoRepo;

    @Autowired
    private AlunoRepository alunoRepo;

    @Autowired
    private TreinoExercicioRepository exercicioRepo;

    @Autowired
    private TreinoGrupoRepository grupoRepo;

    public TreinoDTO adicionar(TreinoDTO dto) {
        TreinoExercicioAluno treino = new TreinoExercicioAluno();

        treino.setAluno(alunoRepo.findById(dto.getAlunoId())
                .orElseThrow(() -> new RuntimeException("Aluno não encontrado")));

        treino.setExercicio(exercicioRepo.findById(dto.getExercicioId())
                .orElseThrow(() -> new RuntimeException("Exercício não encontrado")));

        treino.setGrupo(grupoRepo.findById(dto.getGrupoId())
                .orElseThrow(() -> new RuntimeException("Grupo de treino não encontrado")));

        treino.setOrdem(dto.getOrdem());
        treino.setObservacao(dto.getObservacao());

        TreinoExercicioAluno salvo = treinoRepo.save(treino);

        dto.setId(salvo.getId());
        dto.setNomeExercicio(salvo.getExercicio().getNome());
        dto.setGrupoMuscular(salvo.getExercicio().getGrupoMuscular());

        return dto;
    }

    public List<TreinoDTO> listarPorGrupo(UUID grupoId) {
        return treinoRepo.findByGrupoId(grupoId).stream().map(treino -> {
            TreinoDTO dto = new TreinoDTO();
            dto.setId(treino.getId());
            dto.setAlunoId(treino.getAluno().getId());
            dto.setGrupoId(treino.getGrupo().getId());
            dto.setExercicioId(treino.getExercicio().getId());
            dto.setNomeExercicio(treino.getExercicio().getNome());
            dto.setGrupoMuscular(treino.getExercicio().getGrupoMuscular());
            dto.setOrdem(treino.getOrdem());
            dto.setObservacao(treino.getObservacao());
            return dto;
        }).collect(Collectors.toList());
    }

    public void remover(UUID id) {
        treinoRepo.deleteById(id);
    }
}
