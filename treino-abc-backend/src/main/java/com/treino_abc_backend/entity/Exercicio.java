package com.treino_abc_backend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Getter
@Setter
@Table(name = "treino_exercicio")
public class Exercicio {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "BINARY(16)")
    private UUID id;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false)
    private String grupoMuscular;

    @Column(nullable = false)
    private int series;

    @Column(nullable = false)
    private int repMin;

    @Column(nullable = false)
    private int repMax;

    @Column(nullable = false)
    private int pesoInicial;

    @Column(length = 500)
    private String observacao;
}

