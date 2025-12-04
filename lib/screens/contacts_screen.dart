import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key, required this.fs});

  final FirestoreService fs;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  int _selectedFilter = 0; // 0: Todos, 1: No Leídos, 2: Favoritos
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                await widget.fs.addContact(controller.text.trim());
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
                await widget.fs.addContact(controller.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Mismo día: mostrar hora
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute$period';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  List<Contact> _filterContacts(List<Contact> contacts) {
    var filtered = contacts;

    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) =>
          c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Aplicar filtro de tabs
    if (_selectedFilter == 1) {
      // No Leídos
      filtered = filtered.where((c) => c.unreadCount > 0).toList();
    } else if (_selectedFilter == 2) {
      // Favoritos
      filtered = filtered.where((c) => c.isFavorite).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pinkColor = colorScheme.primary;
    final purpleColor = const Color(0xFF3605EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Título "Contactos"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contactos',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: purpleColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Barra de búsqueda y botón +
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '| Buscar',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón circular rosa con +
                  GestureDetector(
                    onTap: () => _addContactDialog(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: pinkColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tabs de filtro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab('Todos', 0, pinkColor),
                  const SizedBox(width: 16),
                  _buildFilterTab('No Leídos', 1, pinkColor),
                  const SizedBox(width: 16),
                  _buildFilterTab('Favoritos', 2, pinkColor),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de contactos
            Expanded(
              child: StreamBuilder<List<Contact>>(
                stream: widget.fs.watchContacts(sortByRecent: true),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final contacts = snap.data ?? const <Contact>[];
                  final filteredContacts = _filterContacts(contacts);

                  if (filteredContacts.isEmpty) {
                    return Center(
                      child: Text(
                        contacts.isEmpty
                            ? 'Sin contactos. Agrega uno con +'
                            : 'No hay contactos que coincidan',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredContacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final c = filteredContacts[index];
                      return _buildContactItem(c, pinkColor, purpleColor);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, int index, Color pinkColor) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? pinkColor : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: pinkColor,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget _buildContactItem(Contact contact, Color pinkColor, Color purpleColor) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(fs: widget.fs, contact: contact),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Foto de perfil
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              child: contact.name.isNotEmpty
                  ? Text(
                      contact.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            // Nombre y mensaje
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (contact.lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      contact.lastMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Timestamp y badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(contact.lastMessageAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (contact.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: purpleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        contact.unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
