package com.treino_abc_backend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Getter
@Setter
@Table(name = "treino_exercicio_aluno")
public class TreinoExercicioAluno {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "aluno_id")
    private Aluno aluno;

    @ManyToOne
    @JoinColumn(name = "exercicio_id")
    private TreinoExercicio exercicio;

    @ManyToOne
    @JoinColumn(name = "grupo_id")
    private TreinoGrupo grupo;

    private int ordem;
    private String observacao;
}

