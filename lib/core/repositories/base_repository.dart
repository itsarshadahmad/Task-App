import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/app_constants.dart';

abstract class BaseRepository<T> {
  final String collectionName;
  final String boxName;
  final String userId;
  final ProviderRef? ref;

  BaseRepository({
    required this.collectionName,
    required this.boxName,
    required this.userId,
    this.ref,
  });

  T fromFirestore(DocumentSnapshot doc);
  T fromHive(dynamic data);
  Map<String, dynamic> toJson(T item);

  Future<Box<dynamic>> _getBox() async {
    return await Hive.openBox<dynamic>(boxName);
  }

  Future<List<T>> _getFromHive() async {
    final box = await _getBox();
    final items = box.values.where((item) => item != null).toList();
    return items.map((item) => fromHive(item)).toList();
  }

  Future<List<T>> _getFromFirebase(Query? query) async {
    try {
      final snapshot = query != null 
        ? await query.get() 
        : await FirebaseFirestore.instance
            .collection(collectionName)
            .where('userId', isEqualTo: userId)
            .get();
      
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<T>> getAll() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    if (result == ConnectivityResult.none) {
      return await _getFromHive();
    }
    
    try {
      final firebaseItems = await _getFromFirebase(null);
      if (firebaseItems.isNotEmpty) {
        final box = await _getBox();
        await box.clear();
        for (final item in firebaseItems) {
          await box.add(toJson(item));
        }
      }
      return firebaseItems;
    } catch (e) {
      return await _getFromHive();
    }
  }

  Future<T?> getById(String id) async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    if (result == ConnectivityResult.none) {
      final box = await _getBox();
      final item = box.values.firstWhere(
        (item) => item['id'] == id,
        orElse: () => null,
      );
      return item != null ? fromHive(item) : null;
    }
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(id)
          .get();
      
      if (doc.exists) {
        final item = fromFirestore(doc);
        final box = await _getBox();
        await box.put(id, toJson(item));
        return item;
      }
      return null;
    } catch (e) {
      final box = await _getBox();
      final item = box.values.firstWhere(
        (item) => item['id'] == id,
        orElse: () => null,
      );
      return item != null ? fromHive(item) : null;
    }
  }

  Future<String> create(T item) async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    if (result == ConnectivityResult.none) {
      final box = await _getBox();
      final id = toJson(item)['id'] as String;
      await box.put(id, toJson(item));
      return id;
    }
    
    try {
      final docRef = await FirebaseFirestore.instance
          .collection(collectionName)
          .add(toJson(item));
      
      final newItem = toJson(item)..['id'] = docRef.id;
      final box = await _getBox();
      await box.put(docRef.id, newItem);
      
      return docRef.id;
    } catch (e) {
      final box = await _getBox();
      final id = toJson(item)['id'] as String;
      await box.put(id, toJson(item));
      return id;
    }
  }

  Future<void> update(T item) async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    final itemJson = toJson(item);
    final id = itemJson['id'] as String;
    
    if (result == ConnectivityResult.none) {
      final box = await _getBox();
      await box.put(id, itemJson);
      return;
    }
    
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(id)
          .update(itemJson);
      
      final box = await _getBox();
      await box.put(id, itemJson);
    } catch (e) {
      final box = await _getBox();
      await box.put(id, itemJson);
    }
  }

  Future<void> delete(String id) async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    if (result == ConnectivityResult.none) {
      final box = await _getBox();
      await box.delete(id);
      return;
    }
    
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(id)
          .delete();
      
      final box = await _getBox();
      await box.delete(id);
    } catch (e) {
      final box = await _getBox();
      await box.delete(id);
    }
  }

  Future<void> syncToCloud() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    if (result == ConnectivityResult.none) return;
    
    try {
      final box = await _getBox();
      final localItems = box.values.where((item) => item != null).toList();
      
      for (final item in localItems) {
        final id = item['id'] as String;
        final doc = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(id)
            .get();
        
        if (!doc.exists) {
          await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(id)
              .set(item);
        }
      }
    } catch (e) {
      // Sync failed, will retry later
    }
  }
}
