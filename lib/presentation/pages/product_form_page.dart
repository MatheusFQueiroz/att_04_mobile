import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';

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
  late final TextEditingController _thumbnailController;
  late final TextEditingController _categoryController;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _thumbnailController = TextEditingController(text: widget.product?.thumbnail ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _thumbnailController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = double.parse(_priceController.text);
    final thumbnail = _thumbnailController.text;

    bool success;
    if (isEditing) {
      final updatedProduct = Product(
        id: widget.product!.id,
        title: title,
        description: description,
        price: price,
        thumbnail: thumbnail,
        category: _categoryController.text,
        stock: widget.product!.stock,
        rating: widget.product!.rating,
        favorite: widget.product!.favorite,
      );
      success = await widget.viewModel.updateProduct(updatedProduct);
    } else {
      success = await widget.viewModel.createProduct(
        title,
        description,
        price,
        thumbnail,
        _categoryController.text,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Produto atualizado com sucesso!' : 'Produto criado com sucesso!'),
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
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Informe o título do produto' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (v) => (v == null || v.isEmpty) ? 'Informe a descrição do produto' : null,
                  ),
                  const SizedBox(height: 16),
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe o preço do produto';
                      if (double.tryParse(v) == null) return 'Preço inválido';
                      if (double.parse(v) <= 0) return 'O preço deve ser maior que zero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _thumbnailController,
                    decoration: const InputDecoration(
                      labelText: 'URL da Thumbnail',
                      hintText: 'https://exemplo.com/thumb.jpg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a URL da thumbnail';
                      if (!v.startsWith('http')) return 'URL inválida (deve começar com http/https)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      hintText: 'ex: electronics, beauty',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Informe a categoria do produto' : null,
                  ),
                  const SizedBox(height: 24),
                  if (state.saveError != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(state.saveError!, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: state.isSaving ? null : _saveProduct,
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(state.isSaving ? 'Salvando...' : (isEditing ? 'Atualizar' : 'Cadastrar')),
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
