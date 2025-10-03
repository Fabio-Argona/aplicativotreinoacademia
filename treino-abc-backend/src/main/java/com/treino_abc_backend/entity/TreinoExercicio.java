package com.treino_abc_backend.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "treino_exercicio")
public class TreinoExercicio {
    @Id
    @GeneratedValue
    private UUID id;

    private String nome;
    private String grupoMuscular;
    private int series;
    private int repMin;
    private int repMax;
    private int pesoInicial;
    private String observacao;
}
