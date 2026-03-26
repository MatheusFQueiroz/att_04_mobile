import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';

/// Página de formulário para cadastro e edição de produtos.
///
/// Se [product] for null, exibe formulário de cadastro.
/// Se [product] tiver valor, exibe formulário de edição preenchido.
class ProductFormPage extends StatefulWidget {
  final ProductViewModel viewModel;
  final Product? product;

  const ProductFormPage({super.key, required this.viewModel, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;

  /// Retorna true se estiver editando um produto existente.
  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _imageController = TextEditingController(text: widget.product?.image ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  /// Valida e salva o produto (cria ou atualiza).
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = double.parse(_priceController.text);
    final image = _imageController.text;

    bool success;
    if (isEditing) {
      final updatedProduct = Product(
        id: widget.product!.id,
        title: title,
        description: description,
        price: price,
        image: image,
        favorite: widget.product!.favorite,
      );
      success = await widget.viewModel.updateProduct(updatedProduct);
    } else {
      success = await widget.viewModel.createProduct(
        title,
        description,
        price,
        image,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Produto atualizado com sucesso!'
                : 'Produto criado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.viewModel.state,
        builder: (context, state, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Nome do produto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o título do produto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Descrição
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Descrição do produto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a descrição do produto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Preço
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o preço do produto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Preço inválido';
                      }
                      final price = double.parse(value);
                      if (price <= 0) {
                        return 'O preço deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo URL da Imagem
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      labelText: 'URL da Imagem',
                      hintText: 'https://exemplo.com/imagem.jpg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a URL da imagem';
                      }
                      if (!value.startsWith('http')) {
                        return 'URL inválida (deve começar com http/https)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Mensagem de erro
                  if (state.saveError != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.saveError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (state.saveError != null) const SizedBox(height: 16),

                  // Botão Salvar
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: state.isSaving ? null : _saveProduct,
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(
                        state.isSaving
                            ? 'Salvando...'
                            : (isEditing ? 'Atualizar' : 'Cadastrar'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
