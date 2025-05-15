import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../model/tag/tag.dart';

class TagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Fetch the tags for the current user from Firebase
  final logger = Logger();
  Future<List<Tag>> fetchTags(String uid) async {
    try {
      final tagQuerySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tags')
          .get();

      return tagQuerySnapshot.docs
          .map((doc) => Tag(id: doc.id, name: doc['name'] as String))
          .toList();
    } catch (e) {
      logger.d('Error fetching tags: $e');
      return [];
    }
  }


  Future<void> createTag(String uid, String name) async {
    try {
      final newTag = Tag(id: const Uuid().v4(), name: name);
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tags')
          .doc(newTag.id)
          .set({'name': newTag.name,});

    } catch (e) {
      logger.d('Error adding tag: $e');
    }
  }

  Future<void> removeTag(String userId, String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tags')
          .doc(id)
          .delete();

    } catch (e) {
      logger.d('Error removing tag: $e');
    }
  }
}
