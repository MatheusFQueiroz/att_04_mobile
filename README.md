# att_04_mobile — Loja de Produtos com Favoritos

Aplicativo Flutter que exibe uma lista de produtos consumida da [FakeStore API](https://fakestoreapi.com/), com sistema completo de controle de favoritos.

---

## Funcionalidades

| Funcionalidade                | Descricao                                                              |
| ----------------------------- | ---------------------------------------------------------------------- |
| **Listagem de produtos**      | Busca e exibe produtos da FakeStore API com imagem, titulo e preco     |
| **Marcar/desmarcar favorito** | Toque na estrela em qualquer produto para alternar o favorito          |
| **Contador de favoritos**     | A AppBar exibe o total de produtos favoritados                         |
| **Filtro de favoritos**       | Botao na AppBar alterna entre "todos os produtos" e "apenas favoritos" |
| **Destaque visual**           | Produtos favoritados recebem borda dourada e fundo amarelado           |
| **Estado vazio inteligente**  | Mensagem especifica quando o filtro esta ativo mas nao ha favoritos    |
| **Atualizacao manual**        | Botao de refresh (FAB) recarrega os produtos da API                    |
| **Tratamento de erros**       | Exibe mensagem de erro com botao "Tentar novamente"                    |

---

## Melhoria: Cache Local como Fallback

Foi implementado um mecanismo de **cache em memória** (`ProductCacheDatasource`) que funciona como fallback quando a API não está disponível:

### Como funciona o cache

```
Tentativa de carregar produtos
        │
        ▼
┌──────────────────┐
│ Chama API        │
│ (remote datasource)│
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
Sucesso    Falha
    │         │
    ▼         ▼
Salva no   Verifica cache
  cache         │
    │      ┌────┴────┐
    │      │         │
    │   Tem dados  Vazio
    │      │         │
    ▼      ▼         ▼
Retorna  Retorna   Lança
 dados   do cache   erro
```

### Benefícios

- **Offline-first**: Usuário pode ver dados mesmo sem internet (se já carregou antes)
- **Experiência contínua**: Transparência na falha da API
- **Arquitetura limpa**: Cache implementado na camada Data, sem afetar Domain ou Presentation

---

## Estrategia de Gerenciamento de Estado

O projeto usa **ValueNotifier + ValueListenableBuilder** — solucao nativa do Flutter, sem dependencias externas.

### Como funciona (padrao Observer)

```
ProductViewModel
    └── ValueNotifier<ProductState>  <── notifica quando state.value muda
            ↑
    ValueListenableBuilder           <── escuta e reconstroi a UI
            ↑
    ProductPage (UI)
```

### Fluxo do toggle de favorito

```
Usuario toca na estrela
    → ProductPage chama viewModel.toggleFavorite(id)
    → ViewModel cria nova lista com o produto atualizado
    → state.value = novo ProductState (nova referencia)
    → ValueNotifier detecta mudanca e notifica listeners
    → ValueListenableBuilder reconstroi apenas o trecho afetado
```

> **Por que nova lista?** O `ValueNotifier` compara referencias (`==`). Mutar a lista existente nao dispararia a notificacao. Por isso `toggleFavorite` sempre cria uma nova `List<Product>`.

---

## Arquitetura: Clean Architecture + MVVM

```
lib/
├── core/
│   ├── errors/
│   │   └── failure.dart              # Classe de erro de dominio
│   └── network/
│       └── http_client.dart          # Wrapper do http.Client
│
├── data/
│   ├── datasources/
│   │   ├── product_remote_datasource.dart  # Chamada a FakeStore API
│   │   └── product_cache_datasource.dart   # Cache em memória
│   ├── models/
│   │   └── product_model.dart        # DTO de deserializacao JSON
│   └── repositories/
│       └── product_repository_impl.dart    # Implementacao do repositorio
│
├── domain/
│   ├── entities/
│   │   └── product.dart              # Entidade de dominio (id, title, price, image, favorite)
│   └── repositories/
│       └── product_repository.dart   # Interface/contrato do repositorio
│
├── presentation/
│   ├── pages/
│   │   └── product_page.dart         # UI principal com lista e favoritos
│   └── viewmodels/
│       ├── product_state.dart        # Estado imutavel (+ getters favoriteCount, displayedProducts)
│       └── product_viewmodel.dart    # Logica: loadProducts, toggleFavorite, toggleFavoriteFilter
│
└── main.dart                         # Entry point + injecao de dependencias manual

test/
├── widget_test.dart                  # Teste de smoke: app renderiza corretamente
└── favorites_test.dart               # Testes unitarios do sistema de favoritos (21 casos)
```

---

## Como Executar

### Pre-requisitos

- Flutter SDK >= 3.11.1
- Dart SDK >= 3.0
- Conexao com a internet (para buscar produtos da API)

### Passos

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Executar o app
flutter run

# 3. Executar os testes
flutter test

# 4. Verificar analise estatica
flutter analyze
```

---

## Screenshots (descricao textual)

### Tela principal — todos os produtos

```
+-------------------------------------+
| Produtos              [star]  [FAB] |  <- AppBar: botao filtro + FAB refresh
+-------------------------------------+
| [img] Fjallraven Backpack    R$109 [star_border] |
| [img] Mens Casual T-Shirt    R$ 22  [star_border] |
| [img] Mens Cotton Jacket     R$ 55  [star_border] |
| ...                                  |
+-------------------------------------+
```

### Tela com favoritos marcados

```
+-------------------------------------+
| Produtos       [star]2  [star]  [FAB] |  <- contador: "2"
+-------------------------------------+
| *[img] Fjallraven Backpack  R$109 [star]* |  <- borda dourada
| [img] Mens Casual T-Shirt   R$ 22  [star_border] |
| *[img] Mens Cotton Jacket   R$ 55 [star]* |  <- segundo favorito
+-------------------------------------+
```

### Filtro de favoritos ativo

```
+-------------------------------------+
| Produtos       [star]2  [STAR]  [FAB] |  <- estrela preenchida = filtro ativo
+-------------------------------------+
| *[img] Fjallraven Backpack  R$109 [star]* |
| *[img] Mens Cotton Jacket   R$ 55 [star]* |
+-------------------------------------+
```

### Estado vazio de favoritos

```
+-------------------------------------+
| Produtos              [STAR]  [FAB] |  <- filtro ativo, sem contador
+-------------------------------------+
|                                      |
|         [star_border grande]         |
|                                      |
|   Nenhum produto favoritado ainda.   |
|   Toque na estrela para favoritar!   |
|                                      |
+-------------------------------------+
```

---

## Dependencias

| Pacote            | Versao | Uso                                   |
| ----------------- | ------ | ------------------------------------- |
| `flutter`         | SDK    | Framework principal                   |
| `http`            | ^1.2.0 | Requisicoes HTTP para a FakeStore API |
| `cupertino_icons` | ^1.0.8 | Icones iOS                            |
| `flutter_lints`   | ^6.0.0 | Analise estatica (dev)                |

> Nenhuma dependencia externa foi adicionada para o sistema de favoritos — usa apenas `ValueNotifier` nativo do Flutter.

---

## Questionário de Reflexão

### 1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.

O cache foi implementado na **camada Data**. Essa decisão é adequada porque:

- O cache é uma fonte de dados (em memória), similar ao datasource remoto
- A camada Data é responsável por todas as operações de I/O e acesso a dados
- Mantém a separação de responsabilidades: a camada Domain não precisa saber de onde vêm os dados
- Permite que o repositório decida a estratégia de onde buscar os dados (API ou cache)
- Facilita testes unitários, pois o cache pode ser mockado facilmente

### 2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?

O ViewModel não deve realizar chamadas HTTP porque:

- **Violaria a separação de responsabilidades**: o ViewModel coordena o estado da UI, não faz I/O
- **Dificultaria testes**: precisaria mockar HTTP diretamente, tornando os testes mais complexos
- **Acoplamento excessivo**: ligaria a lógica de apresentação a detalhes de infraestrutura
- **Quebraria a arquitetura**: a presentation dependeria diretamente de detalhes técnicos
- **Manutenibilidade**: mudanças na API exigiriam mudanças no ViewModel

### 3. O que poderia acontecer se a interface acessasse diretamente o DataSource?

Se a interface acessasse diretamente o DataSource:

- **Quebraria a arquitetura em camadas**: acoplamento direto entre UI e infraestrutura
- **Mudanças custosas**: toda mudança na API exigiria mudanças na interface
- **Testes difíceis**: dificultaria testes unitários da UI devido às dependências de rede
- **Perda de flexibilidade**: perderia a capacidade de ter múltiplas fontes de dados transparentes
- **Violação de princípios**: quebraria o Princípio da Inversão de Dependência (DIP)
- **Duplicação de lógica**: lógica de mapeamento e tratamento de erros seria espalhada

### 4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?

A arquitetura facilita porque:

- **Contrato estável**: basta criar um novo datasource (ex: `ProductLocalDatasource`) que implemente a mesma interface/contrato
- **Isolamento de mudanças**: o repositório pode ser configurado para usar o novo datasource sem alterar o domínio
- **UI inalterada**: a interface e o ViewModel não precisam ser modificados
- **Contrato do Domain**: `ProductRepository` na camada Domain permanece o mesmo
- **Poder do DIP**: demonstra o poder da inversão de dependência e separação de concerns
- **Testes facilitados**: a nova implementação pode ser testada isoladamente
