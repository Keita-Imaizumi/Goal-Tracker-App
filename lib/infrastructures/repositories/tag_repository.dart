import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../../domains/entities/tag/tag.dart';

part 'tag_repository.g.dart';

@riverpod
TagRepository tagRepository(Ref ref) {
  return TagRepository();
}

class TagRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final logger = Logger();

  Future<List<Tag>> fetchTags(String userId) async {
    try {
      final tagQuerySnapshot = await _firestore
          .collection('users')
          .doc(userId)
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


  Future<void> createTag(String userId, String name) async {
    try {
      final newTag = Tag(id: const Uuid().v4(), name: name);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tags')
          .doc(newTag.id)
          .set({'name': newTag.name,});

    } catch (e) {
      logger.d('Error adding tag: $e');
    }
  }

  Future<void> removeTag(String userId, String tagId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tags')
          .doc(tagId)
          .delete();

    } catch (e) {
      logger.d('Error removing tag: $e');
    }
  }
}
