import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foundita/models/user.dart';

class UserManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Bannir un utilisateur
  Future<void> banUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
      });
    } catch (e) {
      print('Erreur lors du bannissement: $e');
      rethrow;
    }
  }
  
  // Réactiver un utilisateur
  Future<void> unbanUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBanned': false,
      });
    } catch (e) {
      print('Erreur lors de la réactivation: $e');
      rethrow;
    }
  }
  
  // Obtenir la liste de tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            // Ajouter l'ID du document aux données
            data['userId'] = doc.id;
            return User.fromJson(data);
          })
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      rethrow;
    }
  }
  
  // Obtenir un utilisateur spécifique par son ID
  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        data['userId'] = userDoc.id;
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      rethrow;
    }
  }
  
  // Rechercher des utilisateurs par nom ou email
  Future<List<User>> searchUsers(String query) async {
    try {
      QuerySnapshot nameQuery = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();
      
      QuerySnapshot emailQuery = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + 'z')
          .get();
      
      Set<User> users = {};
      users.addAll(nameQuery.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['userId'] = doc.id;
        return User.fromJson(data);
      }));
      
      users.addAll(emailQuery.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['userId'] = doc.id;
        return User.fromJson(data);
      }));
      
      return users.toList();
    } catch (e) {
      print('Erreur lors de la recherche d\'utilisateurs: $e');
      rethrow;
    }
  }
}