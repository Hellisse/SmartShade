import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fermeture_tempo.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<User?>(
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text(
                      'Erreur lors de la récupération de l\'utilisateur');
                } else if (snapshot.hasData) {
                  final User user = snapshot.data!;
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email de l\'utilisateur : ${user.email}'),
                          Text('UID de l\'utilisateur : ${user.uid}'),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Text('Utilisateur non connecté');
                }
              },
            ),
            ElevatedButton(
                onPressed: () {
                  _launchUrl();
                },
                child: const Text('Politique de confidentialité')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    try {
                      _logout(context);
                    } catch (e) {
                      print('Erreur lors de la déconnexion : $e');
                    }
                  },
                  child: const Text('Déconnexion'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showDeleteUserDialog(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: const Text('Supprimer le compte',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FermetureTempoScreen()),
                );
              },
              child: const Text('Menu gestion des capteurs'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer votre compte utilisateur ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteCurrentUser(context);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCurrentUser(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        String houseId = '';

        if (userSnapshot.exists) {
          houseId = userSnapshot['houseId'];
          if (houseId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('houses')
                .doc(houseId)
                .delete();
          }
        }

        // Supprimer l'utilisateur de la base de données
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .delete();

        // Déconnectez l'utilisateur
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(seconds: 1));

        // Redirigez l'utilisateur vers l'écran de connexion
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de la suppression de l\'utilisateur : $e');
        }
        // Gérer l'erreur, par exemple, afficher un message à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression de l\'utilisateur'),
          ),
        );
      }
    }
  }

  // Fonction pour déconnecter l'utilisateur
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (FirebaseAuth.instance.currentUser == null) {
        print('Utilisateur déconnecté');
      } else {
        print('Erreur lors de la déconnexion de l\'utilisateur');
      }
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la déconnexion de l\'utilisateur : $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la déconnexion de l\'utilisateur'),
        ),
      );
    }
  }

  Future<void> _launchUrl() async {
    Uri politiqueUrl = Uri.https(
        'www.iubenda.com', '/privacy-policy/50669483', {'q': '{https}'});

    try {
      await launchUrl(politiqueUrl);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du lancement de l\'URL : $e');
      }
      throw 'Impossible de lancer l\'URL';
    }
  }
}
