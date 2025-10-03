package com.treino_abc_backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class TreinoGrupoDTO {
    private UUID id;
    private UUID alunoId;
    private String nome;
}


