package com.treino_abc_backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class TreinoDTO {
    private UUID id;               // ID do vínculo treino-exercício
    private UUID grupoId;         // ID do grupo de treino
    private UUID alunoId;         // ID do aluno
    private UUID exercicioId;     // ID do exercício
    private String nomeExercicio; // Nome do exercício (para exibição)
    private String grupoMuscular; // Grupo muscular (para exibição)
    private int ordem;            // Ordem no treino
    private String observacao;    // Observações específicas
}


