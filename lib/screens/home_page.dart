import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  //Shutter state update function (open/close) in the database
  void _setShutterState(String shutterId, bool isOpen) {
    shutters.doc(shutterId).update({'shutter_open': isOpen});
  }

  // function to get the shutter id from the database
  CollectionReference shutters =
      FirebaseFirestore.instance.collection('shutters');
  String shutterId = 'shutter_id_1';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Accueil'),
          ),
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _toggleLoading();
                    _setShutterState(shutterId, true);
                    Future.delayed(const Duration(seconds: 5), () {
                      _toggleLoading();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ouverture des volets terminée'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    fixedSize: const Size(150, 50),
                  ),
                  child: const Text('Ouvrir', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _toggleLoading();
                    _setShutterState(shutterId, false);
                    Future.delayed(const Duration(seconds: 5), () {
                      _toggleLoading();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fermeture des volets terminée'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    fixedSize: const Size(150, 50),
                  ),
                  child: const Text('Fermer', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
