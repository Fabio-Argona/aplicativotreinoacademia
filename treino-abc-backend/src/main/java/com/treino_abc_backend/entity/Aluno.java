package com.treino_abc_backend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;
import java.time.LocalDate;

@Setter
@Getter
@Entity
@Table(name = "aluno")
public class Aluno {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID id;

    private String nome;
    @Column(nullable = false, unique = true)
    private String cpf;
    private String telefone;
    private String email;
    private LocalDate dataNascimento;

    private String login;

    private String password;
}
