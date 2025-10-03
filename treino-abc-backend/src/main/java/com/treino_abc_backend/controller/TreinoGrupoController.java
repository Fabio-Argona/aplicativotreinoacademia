package com.treino_abc_backend.controller;

import com.treino_abc_backend.dto.TreinoGrupoDTO;
import com.treino_abc_backend.service.TreinoGrupoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/treinos/grupo")
@CrossOrigin(origins = "http://localhost:51521")
public class TreinoGrupoController {

    @Autowired
    private TreinoGrupoService grupoService;

    @PostMapping
    public ResponseEntity<TreinoGrupoDTO> criar(@RequestBody TreinoGrupoDTO dto) {
        return ResponseEntity.ok(grupoService.criar(dto));
    }

    @GetMapping
    public ResponseEntity<List<TreinoGrupoDTO>> listarPorAluno(@RequestParam UUID alunoId) {
        if (alunoId == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(grupoService.listarPorAluno(alunoId));
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remover(@PathVariable UUID id) {
        grupoService.remover(id);
        return ResponseEntity.noContent().build();
    }
}
