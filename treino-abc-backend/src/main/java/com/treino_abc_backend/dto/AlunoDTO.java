package com.treino_abc_backend.dto;

import com.treino_abc_backend.entity.Aluno;
import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class AlunoDTO {
    private UUID id;
    private String nome;
    private String cpf;
    private String telefone;
    private String email;
    private LocalDate dataNascimento;
    private String login;
    private String password;

    // ✅ Construtor personalizado
    public AlunoDTO(Aluno aluno) {
        this.id = aluno.getId();
        this.nome = aluno.getNome();
        this.cpf = aluno.getCpf();
        this.telefone = aluno.getTelefone();
        this.email = aluno.getEmail();
        this.dataNascimento = aluno.getDataNascimento();
        this.login = aluno.getLogin();
        this.password = aluno.getPassword();
    }
}
