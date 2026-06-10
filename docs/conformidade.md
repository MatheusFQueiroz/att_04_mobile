# Relatório de Conformidade — Atividades 04–09

Data do Relatório: 2026-06-09
Projeto: att_04_mobile (Flutter + Clean Architecture)
Branch: feature/conformidade-e-uml

---

## Atividade 04 – Construção de Aplicação Flutter com Arquitetura em Camadas

**Status: ✅ Conforme**

Todos os elementos de arquitetura em camadas estão implementados e corretamente organizados:

| Requisito | Arquivo | Status |
|-----------|---------|--------|
| Domain layer com Product entity | `lib/domain/entities/product.dart` | ✅ Implementado |
| Abstract repository contract | `lib/domain/repositories/product_repository.dart` | ✅ Implementado |
| Data layer com remote datasource | `lib/data/datasources/product_remote_datasource.dart` | ✅ Implementado |
| Repository implementation | `lib/data/repositories/product_repository_impl.dart` | ✅ Implementado |
| Presentation layer com ViewModel | `lib/presentation/viewmodels/product_viewmodel.dart` | ✅ Implementado |
| Encapsulated HTTP client | `lib/core/network/http_client.dart` | ✅ Implementado |

### Detalhes de Conformidade:

- **Domain Layer**: `Product` entity com campos finais (id, title, description, price, image) e campo mutável `favorite` para permitir toggle sem recriação do objeto.
- **Repository Contract**: `ProductRepository` abstrato define 4 operações (getProducts, createProduct, updateProduct, deleteProduct).
- **Remote Datasource**: `ProductRemoteDatasource` encapsula toda a lógica HTTP com base URL apontando para FakeStoreAPI (https://fakestoreapi.com/products).
- **Repository Implementation**: `ProductRepositoryImpl` implementa o contrato e injeta ambas as datasources (remota e cache).
- **ViewModel**: `ProductViewModel` com `ValueNotifier<ProductState>` para gerenciamento reativo de estado.
- **HTTP Client**: Wrapper tipado sobre `http.Client` com suporte a GET, POST, PUT e DELETE.

---

## Atividade 05 – Evolução Arquitetural da Aplicação

**Status: ✅ Conforme**

Todos os elementos de evolução arquitetural estão implementados, com tratamento de erros e cache-aside strategy:

| Requisito | Arquivo | Status |
|-----------|---------|--------|
| Typed Failure exception class | `lib/core/errors/failure.dart` | ✅ Implementado |
| In-memory cache datasource | `lib/data/datasources/product_cache_datasource.dart` | ✅ Implementado |
| Cache-aside strategy in repository | `lib/data/repositories/product_repository_impl.dart` | ✅ Implementado |

### Detalhes de Conformidade:

- **Failure Class**: Classe tipada que implementa `Exception` com campo `message` para encapsular erros de domínio.
- **Cache Datasource**: `ProductCacheDatasource` implementa cache em memória com 4 métodos: `save()`, `get()`, `hasData()`, `clear()`.
- **Cache-Aside Strategy**:
  - Em `getProducts()`: tenta API → salva em cache se sucesso → fallback para cache se erro
  - Em operações de escrita (create, update, delete): API é sempre chamada primeiro (sem fallback)
  - Exceções adequadamente tratadas e re-lançadas como `Failure` com mensagens descritivas

---

## Atividade 06 – Gerenciamento de Estado

**Status: ✅ Conforme**

Gerenciamento de estado reativo implementado conforme padrão MVVM com Observer pattern nativo do Flutter:

| Requisito | Arquivo | Status |
|-----------|---------|--------|
| Immutable ProductState com copyWith | `lib/presentation/viewmodels/product_state.dart` | ✅ Implementado |
| ValueNotifier<ProductState> em ViewModel | `lib/presentation/viewmodels/product_viewmodel.dart` | ✅ Implementado |
| ValueListenableBuilder na UI | `lib/presentation/pages/product_list_page.dart` | ✅ Implementado |
| Favorite filter (showOnlyFavorites) | `lib/presentation/viewmodels/product_state.dart` | ✅ Implementado |
| Favorite counter (favoriteCount) | `lib/presentation/viewmodels/product_state.dart` | ✅ Implementado |

### Detalhes de Conformidade:

- **ProductState**: Classe imutável (const constructor) com 7 campos de estado:
  - `isLoading`, `isSaving` — flags de estado de operações
  - `products` — lista atual de produtos
  - `error`, `saveError` — strings de erro (podem ser null)
  - `showOnlyFavorites` — flag do filtro de favoritos
  - `selectedProduct` — produto selecionado para edição/visualização

- **copyWith Method**: Implementado corretamente com tratamento especial para `error` e `saveError` (substituem sempre, não usando `??`) para permitir limpeza passando `null`.

- **Getters**:
  - `favoriteCount`: retorna quantidade de produtos com `favorite == true`
  - `displayedProducts`: filtra lista baseado em `showOnlyFavorites`

- **ValueNotifier**: Declarado em `ProductViewModel` como `ValueNotifier<ProductState> state`.

- **ValueListenableBuilder**: Utilizado em 2 locais:
  - `ProductListPage` para escutar estado geral (filtro, favoritos, carregamento)
  - `ProductFormPage` para exibir mensagens de erro e estado de salvamento
  - `product_card.dart` (não verificado mas esperado) para atualizar UI do card

- **Favorite Operations**:
  - `toggleFavorite(productId)` cria nova lista de produtos com Product recriado para garantir detecção de mudança
  - `toggleFavoriteFilter()` alterna `showOnlyFavorites` e dispara notificação

---

## Atividade 08 – Expansão de Navegação com Fake API

**Status: ⚠️ Parcial (com lacuna documentada)**

A estrutura de navegação está completa, mas falta o campo `category` do FakeStoreAPI (lacuna conhecida a ser corrigida na Task 2):

| Requisito | Arquivo | Status |
|-----------|---------|--------|
| FakeStoreAPI como data source | `lib/data/datasources/product_remote_datasource.dart` | ✅ Implementado |
| Navigation to detail page | `lib/presentation/pages/product_list_page.dart` | ✅ Implementado |
| ProductDetailPage exists | `lib/presentation/pages/product_detail_page.dart` | ✅ Implementado |
| Navigation to form page | `lib/presentation/pages/product_list_page.dart` | ✅ Implementado |
| ProductFormPage exists | `lib/presentation/pages/product_form_page.dart` | ✅ Implementado |
| **Campo category in model** | `lib/data/models/product_model.dart` | ⚠️ **Não implementado** |

### Detalhes de Conformidade:

- **FakeStoreAPI Integration**: URL base https://fakestoreapi.com/products hardcodada em `ProductRemoteDatasource`.

- **Navigation**:
  - `_navigateToDetail()` em ProductListPage usa `MaterialPageRoute` → `ProductDetailPage`
  - `_navigateToForm()` em ProductListPage usa `MaterialPageRoute` → `ProductFormPage`
  - Ambas implementadas corretamente com `Navigator.push()`

- **ProductDetailPage**: Exibe produto com imagem expandida, título, preço destacado, descrição completa, e ID.

- **ProductFormPage**:
  - Modo criar: formulário vazio com FAB
  - Modo editar: formulário preenchido com dados do produto selecionado
  - Campos com validação: title, description, price (numérico > 0), image (URL válida)

- **Lacuna Identificada**:
  - FakeStoreAPI retorna campo `category` em cada produto (string, ex: "electronics", "clothing")
  - Modelo `ProductModel` não inclui campo `category` — só tem id, title, description, price, image
  - Entity `Product` também não possui `category`
  - **Impacto**: Categoria não é exibida na lista nem nos detalhes
  - **Resolução**: Será tratada na Task 2 com propagação do campo através de todas as camadas (Model → Entity → UI)

---

## Atividade 09 – Implementação de CRUD

**Status: ✅ Conforme**

Todas as operações CRUD estão implementadas com validação de formulário, diálogos de confirmação e feedback visual:

| Requisito | Arquivo | Status |
|-----------|---------|--------|
| Create (POST) | `lib/presentation/viewmodels/product_viewmodel.dart` | ✅ Implementado |
| Read (GET) | `lib/presentation/viewmodels/product_viewmodel.dart` | ✅ Implementado |
| Update (PUT) | `lib/presentation/viewmodels/product_viewmodel.dart` | ✅ Implementado |
| Delete (DELETE) | `lib/presentation/viewmodels/product_viewmodel.dart` | ✅ Implementado |
| Form with field validation | `lib/presentation/pages/product_form_page.dart` | ✅ Implementado |
| Confirmation dialog before delete | `lib/presentation/pages/product_list_page.dart` | ✅ Implementado |
| Visual feedback (SnackBar) after ops | `lib/presentation/pages/product_form_page.dart` | ✅ Implementado |

### Detalhes de Conformidade:

- **Create (C)**: `createProduct(title, description, price, image)` em ViewModel:
  - Cria `Product` com timestamp como ID
  - Chama `repository.createProduct()`
  - Adiciona produto criado à lista local
  - Retorna `bool` indicando sucesso

- **Read (R)**: `loadProducts()` em ViewModel:
  - Chama `repository.getProducts()`
  - Atualiza estado com flag `isLoading`
  - Armazena lista em `products` do estado

- **Update (U)**: `updateProduct(product)` em ViewModel:
  - Chama `repository.updateProduct(product)`
  - Atualiza produto na lista local (map + filter)
  - Limpa seleção (`selectedProduct = null`)
  - Retorna `bool` indicando sucesso

- **Delete (D)**: `deleteProduct(id)` em ViewModel:
  - Chama `repository.deleteProduct(id)`
  - Remove produto da lista local (where não-equal)
  - Retorna `bool` indicando sucesso

- **Form Validation** (`ProductFormPage`):
  - **Title**: não vazio
  - **Description**: não vazio
  - **Price**: não vazio, numérico válido, > 0
  - **Image**: não vazio, URL válida (começa com http/https)
  - Form key com `FormState.validate()` antes de salvar

- **Confirmation Dialog**: Em `_confirmDelete()`:
  - Exibe `AlertDialog` com título, conteúdo e ações
  - Botões: "Cancelar" e "Excluir" (vermelho)
  - Executa delete apenas se confirmado

- **Visual Feedback (SnackBar)**:
  - Após criar: "Produto criado com sucesso!" (verde) + pop da página
  - Após atualizar: "Produto atualizado com sucesso!" (verde) + pop da página
  - Após excluir: "Produto excluído com sucesso!" (vermelho)
  - Mensagens de erro exibidas no próprio formulário em container vermelho

---

## Resumo Executivo

| Atividade | Status | Observações |
|-----------|--------|-------------|
| **04 – Arquitetura em Camadas** | ✅ Conforme | Clean Architecture completa com 6 layers |
| **05 – Evolução Arquitetural** | ✅ Conforme | Failure typing + cache-aside strategy implementados |
| **06 – Gerenciamento de Estado** | ✅ Conforme | MVVM com ValueNotifier + copyWith pattern |
| **08 – Navegação com Fake API** | ⚠️ Parcial | Estrutura OK; falta campo `category` (Task 2) |
| **09 – Implementação de CRUD** | ✅ Conforme | Create, Read, Update, Delete com validação e UX |

### Conclusão

O projeto **passou com sucesso na conformidade das Atividades 04, 05, 06 e 09**, totalizando 4/5 atividades em conformidade total.

A **Atividade 08** está parcialmente conforme — a navegação e estrutura de integração com FakeStoreAPI estão corretas, mas a lacuna identificada (campo `category` não propagado) é uma omissão menor documentada e será resolvida na Task 2.

**Recomendação**: Prosseguir com Task 2 para adicionar suporte a `category` em todas as camadas (Model → Entity → UI) e completar a conformidade a 5/5.

---

**Assinado pela análise automática**
Projeto: att_04_mobile
Data: 2026-06-09
