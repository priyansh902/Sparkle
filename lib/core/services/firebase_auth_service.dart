import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/core/interfaces/auth_interface.dart';

class FirebaseAuthService implements AuthInterface {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        UserModel appUser;
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          appUser = UserModel(
            id: user.uid,
            email: user.email ?? email,
            name: data['name'] ?? user.displayName ?? '',
            nickname: data['nickname'],
            ageRange: data['ageRange'],
            lifeStage: data['lifeStage'] != null 
                ? _parseLifeStage(data['lifeStage']) 
                : null,
            cycleStatus: data['cycleStatus'] != null 
                ? _parseCycleStatus(data['cycleStatus']) 
                : null,
            conditions: List<String>.from(data['conditions'] ?? []),
            medications: List<String>.from(data['medications'] ?? []),
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        } else {
            await _auth.signOut();
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.keyUserId);
            await prefs.setBool(AppConstants.keyIsLoggedIn, false);

            return AuthResult(
              success: false,
              error: 'Account data is missing. Please contact support.',
            );
          // appUser = UserModel(
          //   id: user.uid,
          //   email: user.email ?? email,
          //   name: user.displayName ?? '',
          //   createdAt: DateTime.now(),
          // );
        }
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, user.uid);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        
        return AuthResult(
          success: true,
          userId: user.uid,
          user: appUser,
        );
      }
      return AuthResult(success: false, error: 'Login failed');
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        
        final appUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );
        
        // Save user to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(),
          'onboardingCompleted': false,
          'conditions': [],
          'medications': [],
        });
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, user.uid);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        
        return AuthResult(
          success: true,
          userId: user.uid,
          user: appUser,
        );
      }
      return AuthResult(success: false, error: 'Signup failed');
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
  }

  @override
  Future<bool> isLoggedIn() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    return _auth.currentUser != null;
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['onboardingCompleted'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool(AppConstants.keyOnboardingCompleted, completed);
      final user = _auth.currentUser;
      if (user == null) return;
      
      await _firestore.collection('users').doc(user.uid).set({
        'onboardingCompleted': completed,
    }, SetOptions(merge: true));
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    // Get additional data from Firestore
    final userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

        if (!userDoc.exists) {
          await _auth.signOut();

          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(AppConstants.keyUserId);
          await prefs.setBool(AppConstants.keyIsLoggedIn, false);

          return null;
        }

        final data = userDoc.data() as Map<String, dynamic>;

        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: data['name'] ?? firebaseUser.displayName ?? '',
          nickname: data['nickname'],
          ageRange: data['ageRange'],
          lifeStage: data['lifeStage'] != null
              ? _parseLifeStage(data['lifeStage'])
              : null,
          cycleStatus: data['cycleStatus'] != null
              ? _parseCycleStatus(data['cycleStatus'])
              : null,
          conditions: List<String>.from(data['conditions'] ?? []),
          medications: List<String>.from(data['medications'] ?? []),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
    
    // if (userDoc.exists) {
    //   final data = userDoc.data() as Map<String, dynamic>;
    //   return UserModel(
    //     id: firebaseUser.uid,
    //     email: firebaseUser.email ?? '',
    //     name: data['name'] ?? firebaseUser.displayName ?? '',
    //     nickname: data['nickname'],
    //     ageRange: data['ageRange'],
    //     lifeStage: data['lifeStage'] != null 
    //         ? _parseLifeStage(data['lifeStage']) 
    //         : null,
    //     cycleStatus: data['cycleStatus'] != null 
    //         ? _parseCycleStatus(data['cycleStatus']) 
    //         : null,
    //     conditions: List<String>.from(data['conditions'] ?? []),
    //     medications: List<String>.from(data['medications'] ?? []),
    //     createdAt: (data['createdAt'] as Timestamp).toDate(),
    //   );
    // }

    
    // // return UserModel(
    // //   id: firebaseUser.uid,
    // //   email: firebaseUser.email ?? '',
    // //   name: firebaseUser.displayName ?? '',
    // //   createdAt: DateTime.now(),
    // // );
  }

  @override
  Future<void> saveUserProfile(UserModel user) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.updateDisplayName(user.name);
      
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'name': user.name,
        'nickname': user.nickname,
        'ageRange': user.ageRange,
        'lifeStage': user.lifeStage?.toString().split('.').last,
        'cycleStatus': user.cycleStatus?.toString().split('.').last,
        'conditions': user.conditions,
        'medications': user.medications,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final userId = user.uid;
      
      // 1. Delete all user data from Firestore
      await _deleteUserFirestoreData(userId);
      
      // 2. Delete all files from Storage
      await _deleteUserStorageData(userId);
      
      // 3. Delete the user's authentication record
      await user.delete();
      
      // 4. Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserId);
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      await prefs.remove(AppConstants.keyOnboardingCompleted);
      
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please log out and log back in before deleting your account');
      }
      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> _deleteUserFirestoreData(String userId) async {
    // Delete all subcollections for the user
    final collections = [
      'symptoms',
      'healthRecords',
      'aiInsights',
      'doctorSummaries',
      'familyMembers',
    ];
    
    for (final collection in collections) {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(collection)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    
    // Delete the user document itself
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<void> _deleteUserStorageData(String userId) async {
    try {
      final storageRef = _storage.ref().child('users/$userId');
      final result = await storageRef.listAll();
      
      for (final item in result.items) {
        await item.delete();
      }
      for (final prefix in result.prefixes) {
        final nestedResult = await prefix.listAll();
        for (final item in nestedResult.items) {
          await item.delete();
        }
        await prefix.delete();
      }
    } catch (e) {
      // Storage might be empty or not configured, continue with deletion
      print('Storage deletion error (non-critical): $e');
    }
  }

  String _getAuthErrorMessage(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  LifeStage _parseLifeStage(String value) {
    return LifeStage.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => LifeStage.generalWellness,
    );
  }

  CycleStatus _parseCycleStatus(String value) {
    return CycleStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => CycleStatus.notSure,
    );
  }
}