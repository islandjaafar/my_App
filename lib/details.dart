import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> clothing;
  final String clothingId;

  const DetailsPage({Key? key, required this.clothing, required this.clothingId})
      : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String? _cartItemId; // ID de l'article dans le panier
  int _quantity = 0; // Quantité actuelle
  bool _hasUpdated = false; // Flag pour signaler une mise à jour

  @override
  void initState() {
    super.initState();
    _checkCartStatus();
  }

  // Vérifier si l'article est déjà dans le panier
  Future<void> _checkCartStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('Panier')
        .where('userId', isEqualTo: user.uid)
        .where('clothingId', isEqualTo: widget.clothingId)
        .get();

    if (query.docs.isNotEmpty) {
      final cartItem = query.docs.first;
      setState(() {
        _cartItemId = cartItem.id;
        _quantity = int.tryParse(cartItem['quantity'] ?? '0') ?? 0;
      });
    }
  }

  // Ajouter l'article au panier
  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = await FirebaseFirestore.instance.collection('Panier').add({
        'clothingId': widget.clothingId,
        'userId': user.uid,
        'titre': widget.clothing['titre'],
        'taille': widget.clothing['taille'],
        'prix': widget.clothing['prix'],
        'url': widget.clothing['url'],
        'quantity': 1, // Quantité initiale
      });

      setState(() {
        _cartItemId = docRef.id;
        _quantity = 1;
        _hasUpdated = true; // Signale qu'une mise à jour a eu lieu
      });
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout au panier : $e');
    }
  }

  // Augmenter la quantité
  Future<void> _increaseQuantity() async {
    if (_cartItemId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('Panier')
          .doc(_cartItemId)
          .update({'quantity': (_quantity + 1).toString()});
      setState(() {
        _quantity += 1;
        _hasUpdated = true; // Signale qu'une mise à jour a eu lieu
      });
    } catch (e) {
      debugPrint('Erreur lors de l\'augmentation de la quantité : $e');
    }
  }

  // Réduire la quantité
  Future<void> _decreaseQuantity() async {
    if (_cartItemId == null) return;

    try {
      if (_quantity > 1) {
        await FirebaseFirestore.instance
            .collection('Panier')
            .doc(_cartItemId)
            .update({'quantity': (_quantity - 1).toString()});
        setState(() {
          _quantity -= 1;
          _hasUpdated = true; // Signale qu'une mise à jour a eu lieu
        });
      } else {
        await FirebaseFirestore.instance.collection('Panier').doc(_cartItemId).delete();
        setState(() {
          _cartItemId = null;
          _quantity = 0;
          _hasUpdated = true; // Signale qu'une mise à jour a eu lieu
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la réduction de la quantité : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Retourne "true" si des modifications ont été effectuées
        Navigator.pop(context, _hasUpdated);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails du vêtement'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du vêtement
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.clothing['url'] ?? '',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 200),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Titre
              Text(
                widget.clothing['titre'] ?? 'Sans titre',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Catégorie
              Text(
                'Catégorie : ${widget.clothing['type'] ?? 'Non spécifié'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              // Taille
              Text(
                'Taille : ${widget.clothing['taille'] ?? 'Non spécifiée'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              // Marque
              Text(
                'Marque : ${widget.clothing['marque'] ?? 'Non spécifiée'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              // Prix
              Text(
                'Prix : ${widget.clothing['prix'] ?? 'Non spécifié'} €',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const Spacer(),
              // Boutons
              Center(
                child: _cartItemId == null
                    ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addToCart,
                  child: const Text('Ajouter au panier'),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle,
                          color: Colors.orange),
                      onPressed: _decreaseQuantity,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: Colors.green),
                      onPressed: _increaseQuantity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
