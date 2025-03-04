import 'dart:io';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import rootBundle for assets

class FirebaseAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // For creating an account for authentication
  Future<User?> signupWithEmailandPasswordStudent({
    required String email,
    required String password,
    required String enrollmentNumber,
    required String? department,
    required String? club,
    required int? semester,
    required DateTime? dob,
    required String name,
    required String phoneNumber,
    required BuildContext context,
    required String section,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = credential.user;
      if (user != null) {
        // **Step 1: User created in Firebase Authentication successfully.  We now have 'user.uid'**

        // Get default profile image as bytes from assets
        final ByteData bytes =
            await rootBundle.load('assets/images/default_profile.png');
        final Uint8List defaultProfileImageBytes = bytes.buffer.asUint8List();

        // Upload default profile image to Firebase Storage
        firebase_storage.FirebaseStorage storage =
            firebase_storage.FirebaseStorage.instance;
        firebase_storage.Reference ref = storage.ref().child(
            'student_profile_images/${user.uid}_default_profile.png'); // unique name using user uid
        firebase_storage.UploadTask uploadTask =
            ref.putData(defaultProfileImageBytes);
        firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

        // Get image URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // **Step 2: Create Firestore document using user.uid as Document ID**
        await _firestore
            .collection(
                'Students') // Replace 'students' with your collection name
            .doc(user.uid) // **Use user.uid as Firestore Document ID!**
            .set({
          'uid': user.uid, // Optionally store UID as a field
          'name': name,
          'enrollment Number': enrollmentNumber,
          'email': email,
          'department': department,
          'club': club,
          'semester': semester,
          'date of birth': dob,
          'phone number': phoneNumber,
          'section': section,
          'profilePhotoURL': downloadUrl,
          'profileImageUrl': downloadUrl, // Store the default profile image URL
          'createdAt': FieldValue.serverTimestamp(),
          // ... other user data ...
        });
      }

      await sendEmailVerification(context);

      return credential.user;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }

  Future<User?> signupWithEmailandPasswordHod({
    required String email,
    required String password,
    required String name,
    required String? department,
    required String facultyID,
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      if (user != null) {
        // **Step 1: User created in Firebase Authentication successfully.  We now have 'user.uid'**

        // Get default profile image as bytes from assets
        final ByteData bytes =
            await rootBundle.load('assets/images/default_profile.png');
        final Uint8List defaultProfileImageBytes = bytes.buffer.asUint8List();

        // Upload default profile image to Firebase Storage
        firebase_storage.FirebaseStorage storage =
            firebase_storage.FirebaseStorage.instance;
        firebase_storage.Reference ref = storage.ref().child(
            'hod_profile_images/${user.uid}_default_profile.png'); // unique name using user uid
        firebase_storage.UploadTask uploadTask =
            ref.putData(defaultProfileImageBytes);
        firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

        // Get image URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // **Step 2: Create Firestore document using user.uid as Document ID**
        await _firestore
            .collection(
                'Heads of Departments') // Replace 'students' with your collection name
            .doc(user.uid) // **Use user.uid as Firestore Document ID!**
            .set({
          'uid': user.uid, // Optionally store UID as a field
          'name': name,
          'faculty ID': facultyID,
          'email': email,
          'department': department,
          'phone number': phoneNumber,
          'profilePhotoURL': downloadUrl,
          'profileImageUrl': downloadUrl, // Store the default profile image URL
          'createdAt': FieldValue.serverTimestamp(),
          // ... other user data ...
        });
      }

      await sendEmailVerification(context);
      showSnackBar(
          context, "Registration successful! Email verification sent.");
      return credential.user;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }
// for signing for authentication

  Future<User?> loginInWithEmailandPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!_auth.currentUser!.emailVerified) {
        await sendEmailVerification(context);
      }
      return credential.user;

      //await sendEmailVerification(context);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message!);
    }
    return null;
  }

  // for signing out...

  Future<void> signout(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // for email verification

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      await _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, "Email verification sent!");
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
