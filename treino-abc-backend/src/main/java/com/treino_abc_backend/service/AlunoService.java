package com.treino_abc_backend.service;

import com.treino_abc_backend.dto.AlunoDTO;
import com.treino_abc_backend.entity.Aluno;
import com.treino_abc_backend.repository.AlunoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AlunoService {

    @Autowired
    private AlunoRepository alunoRepository;

    public AlunoDTO salvar(AlunoDTO dto) {
        if (alunoRepository.existsByCpf(dto.getCpf())) {
            throw new RuntimeException("Já existe um aluno cadastrado com o CPF: " + dto.getCpf());
        }

        Aluno aluno = new Aluno();
        aluno.setNome(dto.getNome());
        aluno.setCpf(dto.getCpf());
        aluno.setTelefone(dto.getTelefone());
        aluno.setEmail(dto.getEmail());
        aluno.setDataNascimento(dto.getDataNascimento());
        aluno.setLogin(dto.getLogin());
        aluno.setPassword(dto.getPassword());

        Aluno salvo = alunoRepository.save(aluno);
        dto.setId(salvo.getId());
        return dto;
    }

    public AlunoDTO atualizar(UUID id, AlunoDTO dto) {
        Optional<Aluno> opt = alunoRepository.findById(id);
        if (opt.isPresent()) {
            Aluno aluno = opt.get();
            aluno.setNome(dto.getNome());
            aluno.setCpf(dto.getCpf());
            aluno.setTelefone(dto.getTelefone());
            aluno.setEmail(dto.getEmail());
            aluno.setDataNascimento(dto.getDataNascimento());
            aluno.setLogin(dto.getLogin());
            aluno.setPassword(dto.getPassword());
            alunoRepository.save(aluno);
            dto.setId(aluno.getId());
            return dto;
        } else {
            throw new RuntimeException("Aluno não encontrado.");
        }
    }

    public String deletar(UUID id) {
        Optional<Aluno> alunoOpt = alunoRepository.findById(id);
        if (alunoOpt.isPresent()) {
            String nome = alunoOpt.get().getNome();
            alunoRepository.deleteById(id);
            return nome;
        } else {
            return null;
        }
    }

    public AlunoDTO buscarPorId(UUID id) {
        Optional<Aluno> opt = alunoRepository.findById(id);
        if (opt.isPresent()) {
            Aluno aluno = opt.get();
            AlunoDTO dto = new AlunoDTO();
            dto.setId(aluno.getId());
            dto.setNome(aluno.getNome());
            dto.setCpf(aluno.getCpf());
            dto.setTelefone(aluno.getTelefone());
            dto.setEmail(aluno.getEmail());
            dto.setDataNascimento(aluno.getDataNascimento());
            dto.setLogin(aluno.getLogin());
            dto.setPassword(aluno.getPassword());
            return dto;
        } else {
            throw new RuntimeException("Aluno não encontrado.");
        }
    }


    public List<AlunoDTO> listarTodos() {
        return alunoRepository.findAll().stream().map(aluno -> {
            AlunoDTO dto = new AlunoDTO();
            dto.setId(aluno.getId());
            dto.setNome(aluno.getNome());
            dto.setCpf(aluno.getCpf());
            dto.setTelefone(aluno.getTelefone());
            dto.setEmail(aluno.getEmail());
            dto.setDataNascimento(aluno.getDataNascimento());
            dto.setLogin(dto.getLogin());
            dto.setPassword(dto.getPassword());
            return dto;
        }).collect(Collectors.toList());
    }
}
