package com.treino_abc_backend.controller;

import com.treino_abc_backend.dto.AlunoDTO;
import com.treino_abc_backend.entity.Aluno;
import com.treino_abc_backend.repository.AlunoRepository;
import com.treino_abc_backend.service.AlunoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/alunos")
@CrossOrigin(origins = "http://localhost:51521")
public class AlunoController {

    @Autowired
    private AlunoService alunoService;
    private AlunoRepository alunoRepository;

    @PostMapping
    public ResponseEntity<AlunoDTO> criar(@RequestBody AlunoDTO alunoDTO) {
        return ResponseEntity.ok(alunoService.salvar(alunoDTO));
    }

    @GetMapping
    public ResponseEntity<List<AlunoDTO>> listar() {
        return ResponseEntity.ok(alunoService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AlunoDTO> buscarPorId(@PathVariable UUID id) {
        try {
            AlunoDTO aluno = alunoService.buscarPorId(id);
            return ResponseEntity.ok(aluno);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(null);
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<AlunoDTO> atualizar(@PathVariable UUID id, @RequestBody AlunoDTO alunoDTO) {
        return ResponseEntity.ok(alunoService.atualizar(id, alunoDTO));
    }

    @GetMapping("/login")
    public ResponseEntity<AlunoDTO> login(@RequestParam String email, @RequestParam String cpf) {
        Optional<Aluno> aluno = alunoRepository.findByEmailAndCpf(email, cpf);

        return aluno.map(a -> ResponseEntity.ok(new AlunoDTO(a)))
                .orElse(ResponseEntity.status(401).build());
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<String> deletar(@PathVariable UUID id) {
        String nome = alunoService.deletar(id);
        if (nome != null) {
            return ResponseEntity.ok("Aluno " + nome + " deletado com sucesso!");
        } else {
            return ResponseEntity.status(404).body("Aluno não encontrado.");
        }
    }
}
