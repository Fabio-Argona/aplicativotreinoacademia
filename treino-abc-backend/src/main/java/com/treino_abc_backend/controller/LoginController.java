package com.treino_abc_backend.controller;

import com.treino_abc_backend.entity.Aluno;
import com.treino_abc_backend.repository.AlunoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "http://localhost:51521")
public class LoginController {

    @Autowired
    private AlunoRepository alunoRepository;

    @PostMapping("/login")
    public ResponseEntity<Aluno> login(@RequestBody LoginRequest request) {
        return alunoRepository.findAll().stream()
                .filter(a -> a.getEmail().equals(request.getEmail()) &&
                        a.getCpf().equals(request.getCpf()))
                .findFirst()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(401).build());
    }

    public static class LoginRequest {
        private String email;
        private String cpf;

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }

        public String getCpf() { return cpf; }
        public void setCpf(String cpf) { this.cpf = cpf; }
    }
}
