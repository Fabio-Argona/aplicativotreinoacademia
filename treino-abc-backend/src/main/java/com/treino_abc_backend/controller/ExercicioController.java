package com.treino_abc_backend.controller;

import com.treino_abc_backend.entity.Exercicio;
import com.treino_abc_backend.service.ExercicioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/exercicios")
public class ExercicioController {

    private final ExercicioService service;

    public ExercicioController(ExercicioService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<Exercicio>> listar() {
        return ResponseEntity.ok(service.getTodos());
    }

    @PostMapping
    public ResponseEntity<Exercicio> criar(@RequestBody Exercicio exercicio) {
        Exercicio salvo = service.salvar(exercicio);
        return ResponseEntity.status(201).body(salvo);
    }

    @PostMapping("/lista")
    public ResponseEntity<List<Exercicio>> criarLista(@RequestBody List<Exercicio> exercicios) {
        List<Exercicio> salvos = service.salvarTodos(exercicios);
        return ResponseEntity.status(201).body(salvos);
    }


    @PutMapping("/{id}")
    public ResponseEntity<Exercicio> atualizar(@PathVariable String id, @RequestBody Exercicio exercicio) {
        exercicio.setId(UUID.fromString(id));
        return service.atualizar(exercicio)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable String id) {
        service.deletar(id);
        return ResponseEntity.ok().build();
    }

    // -------------------- Endpoints específicos para Treino --------------------

    @PostMapping("/treino/{treinoNome}")
    public ResponseEntity<Exercicio> adicionarAoTreino(@PathVariable String treinoNome, @RequestBody Exercicio exercicio) {
        // Aqui podemos salvar normalmente, o Flutter decide qual treino
        Exercicio salvo = service.adicionarAoTreino(exercicio);
        return ResponseEntity.ok(salvo);
    }

    @DeleteMapping("/treino/{treinoNome}/{id}")
    public ResponseEntity<Void> removerDoTreino(@PathVariable String treinoNome, @PathVariable String id) {
        service.removerDoTreino(id);
        return ResponseEntity.ok().build();
    }
}
