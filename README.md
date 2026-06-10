# mobile_arquitetura_01

Aplicativo Flutter de CRUD de produtos com autenticação, desenvolvido com arquitetura MVVM e Clean Architecture.

## Como executar

```bash
flutter pub get
flutter run
```

**Credenciais de teste:** `emilys` / `emilyspass`

## Arquitetura

```
lib/
├── core/           # Utilitários (HttpClient, SessionController, erros)
├── data/           # Modelos, datasources, repositórios
├── domain/         # Entidades e contratos de repositório
└── presentation/   # ViewModels, estados e telas
```

## Gerenciamento de Estado

O projeto utiliza **`ValueNotifier<State>`** com **`ValueListenableBuilder`** — mecanismo nativo do Flutter equivalente ao `setState`, porém aplicado ao padrão MVVM. Cada ViewModel expõe um `ValueNotifier` que notifica a UI automaticamente quando o estado muda, sem dependências externas.

Essa abordagem substitui o `setState` diretamente nas páginas, mantendo a lógica de negócio separada da camada de apresentação.

## Funcionalidades

- Login com POST `/auth/login` (DummyJSON)
- Validação de campos e tratamento de erro
- Sessão de usuário (`SessionController`)
- Bloqueio de acesso sem login
- Lista de produtos via GET `/products`
- Detalhes via GET `/products/{id}`
- Favoritos com filtro e contador
- CRUD completo (criar, editar, excluir)
- Logout com retorno à tela de login

## API

[DummyJSON](https://dummyjson.com) — autenticação em `/auth/login`, produtos em `/products`.
