package com.treino_abc_backend.service;

import com.treino_abc_backend.entity.Exercicio;
import com.treino_abc_backend.repository.ExercicioRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ExercicioService {

    private final ExercicioRepository repository;

    public ExercicioService(ExercicioRepository repository) {
        this.repository = repository;
    }

    public List<Exercicio> getTodos() {
        return repository.findAll();
    }

    public Exercicio salvar(Exercicio exercicio) {
        return repository.save(exercicio);
    }

    public Optional<Exercicio> atualizar(Exercicio novo) {
        Optional<Exercicio> existente = repository.findById(novo.getId());
        if (existente.isEmpty()) return Optional.empty();

        Exercicio exercicio = existente.get();
        exercicio.setNome(novo.getNome());
        exercicio.setGrupoMuscular(novo.getGrupoMuscular());
        exercicio.setSeries(novo.getSeries());
        exercicio.setRepMin(novo.getRepMin());
        exercicio.setRepMax(novo.getRepMax());
        exercicio.setPesoInicial(novo.getPesoInicial());
        exercicio.setObservacao(novo.getObservacao());

        return Optional.of(repository.save(exercicio));
    }


    public void deletar(String id) {
        repository.deleteById(UUID.fromString(id));
    }

    public List<Exercicio> salvarTodos(List<Exercicio> exercicios) {
        return repository.saveAll(exercicios);
    }

    public Exercicio adicionarAoTreino(Exercicio exercicio) {
        return repository.save(exercicio);
    }

    public void removerDoTreino(String id) {
        repository.deleteById(UUID.fromString(id));
    }
}
