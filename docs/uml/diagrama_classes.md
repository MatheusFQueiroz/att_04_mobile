# Diagrama de Classes — att_04_mobile

Diagrama gerado a partir do PlantUML em `docs/uml/diagrama_classes.puml`.
Representa a arquitetura MVVM + Clean Architecture do aplicativo Flutter de CRUD de Produtos.

```mermaid
classDiagram

%% ─── core.errors ───
class Failure {
    +message : String
    +Failure(message String)
}

%% ─── core.network ───
class HttpClient {
    -_client : http.Client
    +HttpClient(client http.Client)
    +get(url String) Future~Response~
    +post(url String, headers Map, body Object) Future~Response~
    +put(url String, headers Map, body Object) Future~Response~
    +delete(url String) Future~Response~
}

%% ─── domain.entities ───
class Product {
    +id : int
    +title : String
    +description : String
    +price : double
    +image : String
    +category : String
    +favorite : bool
    +Product(id, title, description, price, image, category, favorite)
}

%% ─── domain.repositories ───
class ProductRepository {
    <<abstract>>
    +getProducts() Future~List~Product~~
    +createProduct(product Product) Future~Product~
    +updateProduct(product Product) Future~Product~
    +deleteProduct(id int) Future~void~
}

%% ─── data.models ───
class ProductModel {
    +id : int
    +title : String
    +description : String
    +price : double
    +image : String
    +category : String
    +ProductModel(id, title, description, price, image, category)
    +fromJson(json Map) ProductModel$
    +toJson() Map~String_dynamic~
}

%% ─── data.datasources ───
class ProductRemoteDatasource {
    +client : HttpClient
    -baseUrl : String$
    +ProductRemoteDatasource(client HttpClient)
    +getProducts() Future~List~ProductModel~~
    +createProduct(product ProductModel) Future~ProductModel~
    +updateProduct(product ProductModel) Future~ProductModel~
    +deleteProduct(id int) Future~void~
}

class ProductCacheDatasource {
    -_cache : List~ProductModel~
    +save(products List~ProductModel~) void
    +get() List~ProductModel~
    +clear() void
    +hasData() bool
}

%% ─── data.repositories ───
class ProductRepositoryImpl {
    +remoteDatasource : ProductRemoteDatasource
    +cacheDatasource : ProductCacheDatasource
    +ProductRepositoryImpl(remoteDatasource, cacheDatasource)
    +getProducts() Future~List~Product~~
    +createProduct(product Product) Future~Product~
    +updateProduct(product Product) Future~Product~
    +deleteProduct(id int) Future~void~
    -_mapToEntity(m ProductModel) Product
}

%% ─── presentation.viewmodels ───
class ProductState {
    +isLoading : bool
    +isSaving : bool
    +products : List~Product~
    +error : String
    +saveError : String
    +showOnlyFavorites : bool
    +selectedProduct : Product
    +favoriteCount : int
    +displayedProducts : List~Product~
    +ProductState()
    +copyWith() ProductState
}

class ProductViewModel {
    +repository : ProductRepository
    +state : ValueNotifier~ProductState~
    +ProductViewModel(repository ProductRepository)
    +loadProducts() Future~void~
    +createProduct(title, description, price, image, category) Future~bool~
    +updateProduct(product Product) Future~bool~
    +deleteProduct(id int) Future~bool~
    +selectProduct(product Product) void
    +toggleFavorite(productId int) void
    +toggleFavoriteFilter() void
}

%% ─── presentation.pages ───
class ProductListPage {
    <<Widget>>
    +viewModel : ProductViewModel
    +ProductListPage(viewModel ProductViewModel)
    +build(context BuildContext) Widget
    -_navigateToDetail(context, product Product) void
    -_navigateToForm(context, product Product) void
    -_confirmDelete(context, product Product) Future~void~
}

class ProductDetailPage {
    <<Widget>>
    +product : Product
    +ProductDetailPage(product Product)
    +build(context BuildContext) Widget
}

class ProductFormPage {
    <<Widget>>
    +viewModel : ProductViewModel
    +product : Product
    +ProductFormPage(viewModel, product)
    +createState() State~ProductFormPage~
}

class _ProductFormPageState {
    -_formKey : GlobalKey~FormState~
    -_titleController : TextEditingController
    -_descriptionController : TextEditingController
    -_priceController : TextEditingController
    -_imageController : TextEditingController
    -_categoryController : TextEditingController
    +isEditing : bool
    +initState() void
    +dispose() void
    -_saveProduct() Future~void~
    +build(context BuildContext) Widget
}

%% ─── presentation.widgets ───
class ProductCard {
    <<Widget>>
    +product : Product
    +onTap : VoidCallback
    +onEdit : VoidCallback
    +onDelete : VoidCallback
    +onToggleFavorite : VoidCallback
    +ProductCard(product, onTap, onEdit, onDelete, onToggleFavorite)
    +build(context BuildContext) Widget
}

%% ─── main ───
class MyApp {
    <<Widget>>
    +viewModel : ProductViewModel
    +MyApp(viewModel ProductViewModel)
    +build(context BuildContext) Widget
}

%% ─── RELATIONSHIPS ───

%% core.errors
Failure ..|> Exception : implements

%% core.network
HttpClient o-- http.Client : uses

%% domain
ProductRepository ..> Product : uses
ProductRepositoryImpl ..|> ProductRepository : implements

%% data.models
ProductModel ..> Product : maps to

%% data.datasources
ProductRemoteDatasource --> HttpClient : uses
ProductCacheDatasource *-- ProductModel : caches

%% data.repositories
ProductRepositoryImpl --> ProductRemoteDatasource : uses
ProductRepositoryImpl --> ProductCacheDatasource : uses
ProductRepositoryImpl ..> Failure : throws

%% presentation.viewmodels
ProductViewModel --> ProductRepository : uses
ProductViewModel *-- ProductState : has state
ProductState o-- Product : contains / selectedProduct

%% presentation.pages
ProductListPage --> ProductViewModel : uses
ProductListPage ..> ProductDetailPage : navigates to
ProductListPage ..> ProductFormPage : navigates to
ProductListPage --> ProductCard : renders
ProductDetailPage --> Product : displays
ProductFormPage --> ProductViewModel : uses
ProductFormPage o-- Product : edits
ProductFormPage *-- _ProductFormPageState : creates state
_ProductFormPageState --> ProductViewModel : via widget

%% presentation.widgets
ProductCard --> Product : displays

%% main
MyApp --> ProductViewModel : owns
MyApp ..> ProductListPage : root widget
```
