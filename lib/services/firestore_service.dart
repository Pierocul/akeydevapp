import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/contact.dart';
import '../models/message.dart';
import '../models/property.dart';

class FirestoreService {
  FirestoreService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _contactsCol => _firestore
      .collection('users')
      .doc(_uid)
      .collection('contacts');

  Future<void> addContact(String name) async {
    final doc = _contactsCol.doc();
    await doc.set({
      'name': name,
      'lastMessage': null,
      'lastMessageAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Obtiene o crea un contacto con un ID específico
  Future<Contact> getOrCreateContact(String contactId, String name) async {
    final contactDoc = await _contactsCol.doc(contactId).get();
    
    if (contactDoc.exists) {
      return Contact.fromMap(contactId, contactDoc.data()!);
    } else {
      // Crear el contacto
      await _contactsCol.doc(contactId).set({
        'name': name,
        'lastMessage': null,
        'lastMessageAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return Contact(
        id: contactId,
        name: name,
      );
    }
  }

  Stream<List<Contact>> watchContacts({bool sortByRecent = false}) {
    final query = sortByRecent
        ? _contactsCol.orderBy('lastMessageAt', descending: true)
        : _contactsCol.orderBy('name');
    return query.snapshots().asyncMap((snap) async {
      final contacts = <Contact>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        // Contar mensajes no leídos (mensajes del contacto que no son del usuario)
        final unreadCount = await _getUnreadCount(doc.id);
        contacts.add(Contact.fromMap(doc.id, {
          ...data,
          'unreadCount': unreadCount,
        }));
      }
      return contacts;
    });
  }

  Future<int> _getUnreadCount(String contactId) async {
    try {
      final messages = await _messagesCol(contactId)
          .where('sender', isEqualTo: 'contact')
          .where('read', isEqualTo: false)
          .get();
      return messages.docs.length;
    } catch (e) {
      // Si no existe el campo 'read', contar todos los mensajes del contacto
      try {
        final messages = await _messagesCol(contactId)
            .where('sender', isEqualTo: 'contact')
            .get();
        return messages.docs.length;
      } catch (e2) {
        return 0;
      }
    }
  }

  CollectionReference<Map<String, dynamic>> _messagesCol(String contactId) =>
      _contactsCol.doc(contactId).collection('messages');

  Stream<List<Message>> watchMessages(String contactId) {
    return _messagesCol(contactId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Message.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> sendMessage(String contactId, String text) async {
    final now = DateTime.now();
    final batch = _firestore.batch();

    final msgRef = _messagesCol(contactId).doc();
    batch.set(msgRef, {
      'text': text,
      'sender': 'me',
      'createdAt': now.millisecondsSinceEpoch,
    });

    final contactRef = _contactsCol.doc(contactId);
    batch.update(contactRef, {
      'lastMessage': text,
      'lastMessageAt': now.millisecondsSinceEpoch,
      'unreadCount': 0, // Resetear contador cuando se envía un mensaje
    });

    await batch.commit();
  }

  Future<void> markMessagesAsRead(String contactId) async {
    try {
      final batch = _firestore.batch();
      final unreadMessages = await _messagesCol(contactId)
          .where('sender', isEqualTo: 'contact')
          .where('read', isEqualTo: false)
          .get();
      
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      
      await batch.commit();
      
      // Actualizar el contador en el contacto
      await _contactsCol.doc(contactId).update({'unreadCount': 0});
    } catch (e) {
      // Si no existe el campo 'read', no hacer nada
    }
  }

  CollectionReference<Map<String, dynamic>> get _propertiesCol =>
      _firestore.collection('properties');

  Stream<List<Property>> watchProperties({bool onlyFeatured = false}) {
    Query<Map<String, dynamic>> query =
        _propertiesCol.orderBy('createdAt', descending: true);
    if (onlyFeatured) {
      query = query.where('isFeatured', isEqualTo: true);
    }
    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => Property.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addProperty({
    required String name,
    required String address,
    required String imageUrl,
    String? price,
    bool isFeatured = false,
    int bedrooms = 0,
    int bathrooms = 0,
    double area = 0.0,
    String description = '',
    List<String> features = const [],
    double? latitude,
    double? longitude,
  }) async {
    try {
      final doc = _propertiesCol.doc();
      final data = {
        'name': name,
        'address': address,
        'imageUrl': _sanitizeImageUrl(imageUrl),
        'price': price ?? '',
        'isFeatured': isFeatured,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'area': area,
        'description': description,
        'features': features,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      if (kDebugMode) {
        print('Guardando en Firestore:');
        print('Colección: properties');
        print('Documento ID: ${doc.id}');
        print('Datos: $data');
      }
      
      await doc.set(data);
      
      if (kDebugMode) {
        print('✓ Documento guardado exitosamente en Firestore');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('ERROR en addProperty:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow; // Re-lanzar el error para que se capture en el catch del llamador
    }
  }

  Future<void> updateProperty({
    required String propertyId,
    required String name,
    required String address,
    required String imageUrl,
    String? price,
    bool isFeatured = false,
    int bedrooms = 0,
    int bathrooms = 0,
    double area = 0.0,
    String description = '',
    List<String> features = const [],
    double? latitude,
    double? longitude,
  }) async {
    try {
      final doc = _propertiesCol.doc(propertyId);
      final data = {
        'name': name,
        'address': address,
        'imageUrl': _sanitizeImageUrl(imageUrl),
        'price': price ?? '',
        'isFeatured': isFeatured,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'area': area,
        'description': description,
        'features': features,
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (kDebugMode) {
        print('Actualizando propiedad en Firestore:');
        print('Colección: properties');
        print('Documento ID: $propertyId');
        print('Datos: $data');
      }
      
      await doc.update(data);
      
      if (kDebugMode) {
        print('✓ Propiedad actualizada exitosamente en Firestore');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('ERROR en updateProperty:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    try {
      if (kDebugMode) {
        print('Eliminando propiedad: $propertyId');
      }
      await _propertiesCol.doc(propertyId).delete();
      if (kDebugMode) {
        print('✓ Propiedad eliminada exitosamente');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('ERROR en deleteProperty:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  String _sanitizeImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return Property.defaultImageUrl;
    }
    
    final uri = Uri.tryParse(trimmed);
    final hasValidScheme =
        uri != null && (uri.isScheme('http') || uri.isScheme('https'));
    
    if (!hasValidScheme) {
      return Property.defaultImageUrl;
    }
    
    // Para URLs de Firebase Storage, pueden tener parámetros de consulta
    // Ejemplo: https://firebasestorage.googleapis.com/.../image.jpg?alt=media&token=...
    // Necesitamos verificar la extensión antes de los parámetros de consulta
    final urlWithoutQuery = uri.path; // Obtiene la ruta sin parámetros de consulta
    final hasImageExtension =
        RegExp(r'\.(png|jpe?g|gif|webp|webm)$', caseSensitive: false)
            .hasMatch(urlWithoutQuery);
    
    // También aceptar URLs de Firebase Storage que contengan 'firebasestorage'
    final isFirebaseStorageUrl = trimmed.contains('firebasestorage.googleapis.com');
    
    if (hasImageExtension || isFirebaseStorageUrl) {
      return trimmed;
    }
    
    return Property.defaultImageUrl;
  }
}


