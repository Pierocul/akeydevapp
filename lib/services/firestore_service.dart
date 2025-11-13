import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Stream<List<Contact>> watchContacts({bool sortByRecent = false}) {
    final query = sortByRecent
        ? _contactsCol.orderBy('lastMessageAt', descending: true)
        : _contactsCol.orderBy('name');
    return query.snapshots().map((snap) => snap.docs
        .map((d) => Contact.fromMap(d.id, d.data()))
        .toList());
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
    });

    await batch.commit();
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
  }) async {
    final doc = _propertiesCol.doc();
    await doc.set({
      'name': name,
      'address': address,
      'imageUrl': _sanitizeImageUrl(imageUrl),
      'price': price ?? '',
      'isFeatured': isFeatured,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _sanitizeImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return Property.defaultImageUrl;
    }
    final uri = Uri.tryParse(trimmed);
    final hasValidScheme =
        uri != null && (uri.isScheme('http') || uri.isScheme('https'));
    final hasImageExtension =
        RegExp(r'\.(png|jpe?g|gif|webp)$', caseSensitive: false)
            .hasMatch(trimmed);

    if (hasValidScheme && hasImageExtension) {
      return trimmed;
    }
    return Property.defaultImageUrl;
  }
}


