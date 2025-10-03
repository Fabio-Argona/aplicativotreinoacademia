package com.treino_abc_backend.controller;

import com.treino_abc_backend.dto.TreinoDTO;
import com.treino_abc_backend.service.TreinoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/treinos")
@CrossOrigin
public class TreinoController {

    @Autowired
    private TreinoService treinoService;

    @GetMapping("/{grupoId}")
    public ResponseEntity<List<TreinoDTO>> listarPorGrupo(@PathVariable UUID grupoId) {
        List<TreinoDTO> treinos = treinoService.listarPorGrupo(grupoId);
        return ResponseEntity.ok(treinos);
    }

    @PostMapping
    public ResponseEntity<TreinoDTO> adicionar(@RequestBody TreinoDTO dto) {
        TreinoDTO salvo = treinoService.adicionar(dto);
        return ResponseEntity.ok(salvo);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remover(@PathVariable UUID id) {
        treinoService.remover(id);
        return ResponseEntity.noContent().build();
    }
}
