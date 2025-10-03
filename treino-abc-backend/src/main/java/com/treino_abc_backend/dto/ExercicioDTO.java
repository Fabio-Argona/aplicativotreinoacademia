package com.treino_abc_backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class ExercicioDTO {
    private UUID id;
    private String nome;
    private String grupoMuscular;
    private int series;
    private int repMin;
    private int repMax;
    private int pesoInicial;
    private String observacao;
}

