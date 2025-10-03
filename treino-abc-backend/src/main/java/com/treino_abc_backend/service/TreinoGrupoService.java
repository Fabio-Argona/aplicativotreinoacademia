package com.treino_abc_backend.service;

import com.treino_abc_backend.dto.TreinoGrupoDTO;
import com.treino_abc_backend.entity.Aluno;
import com.treino_abc_backend.entity.TreinoGrupo;
import com.treino_abc_backend.repository.AlunoRepository;
import com.treino_abc_backend.repository.TreinoGrupoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TreinoGrupoService {

    @Autowired
    private TreinoGrupoRepository grupoRepo;

    @Autowired
    private AlunoRepository alunoRepo;

    public TreinoGrupoDTO criar(TreinoGrupoDTO dto) {
        Aluno aluno = alunoRepo.findById(dto.getAlunoId())
                .orElseThrow(() -> new RuntimeException("Aluno não encontrado"));

        TreinoGrupo grupo = new TreinoGrupo();
        grupo.setNome(dto.getNome());
        grupo.setAluno(aluno);

        TreinoGrupo salvo = grupoRepo.save(grupo);
        dto.setId(salvo.getId());
        return dto;
    }

    public List<TreinoGrupoDTO> listarPorAluno(UUID alunoId) {
        return grupoRepo.findByAlunoId(alunoId).stream().map(grupo -> {
            TreinoGrupoDTO dto = new TreinoGrupoDTO();
            dto.setId(grupo.getId());
            dto.setAlunoId(grupo.getAluno().getId());
            dto.setNome(grupo.getNome());
            return dto;
        }).collect(Collectors.toList());
    }

    public void remover(UUID id) {
        grupoRepo.deleteById(id);
    }
}
