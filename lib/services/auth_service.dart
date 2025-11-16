import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/models/user_model.dart';

//Metodo de inicio de sesion con email y contraseña.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e.code)),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  //Mensajes de error
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No se encontró un usuario con ese email.';
      case 'invalid-credential':
        return 'Credenciales incorrectas. Revisa tu email y contraseña.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El formato del email no es válido.';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      case 'email-already-in-use':
        return 'Este email ya está en uso por otra cuenta.';
      default:
        return 'Ocurrió un error inesperado.';
    }
  }

  //Metodo Registro
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          id: user.uid,
          email: user.email!,
          displayName: '',
          address: '',
          phone: '',
          calle: '',
          numExt: '',
          numInt: '',
          colonia: '',
          ciudad: '',
          estado: '',
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson());
      }
      return user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e.code)),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // Metodo Recuperacion
  Future<void> sendPasswordResetEmail(
    String email,
    BuildContext context,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email para recuperacion enviado.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e.code)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Cerrar sesion
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
