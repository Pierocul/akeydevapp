import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, required this.fs});

  final FirestoreService fs;

  Future<void> _addContactDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo contacto'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ej. Juan Pérez',
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Ingresa un nombre'
                : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) async {
              if (formKey.currentState!.validate()) {
                await fs.addContact(controller.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await fs.addContact(controller.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Contact>>(
        stream: fs.watchContacts(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snap.data ?? const <Contact>[];
          if (contacts.isEmpty) {
            return const Center(child: Text('Sin contactos. Agrega uno con +'));
          }
          return ListView.separated(
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = contacts[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(c.name),
                subtitle: c.lastMessage != null ? Text(c.lastMessage!) : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(fs: fs, contact: c),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addContactDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}


