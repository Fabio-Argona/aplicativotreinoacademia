package com.treino_abc_backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class TreinoExercicioAlunoDTO {
    private UUID id;
    private UUID alunoId;
    private UUID exercicioId;
    private char dia;
    private int ordem;
    private String observacao;
}

