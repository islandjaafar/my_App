import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  // Méthode pour calculer le total général
  Future<void> _calculateTotal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final QuerySnapshot cartItems = await FirebaseFirestore.instance
        .collection('Panier')
        .where('userId', isEqualTo: user.uid)
        .get();

    double total = 0.0;
    for (var item in cartItems.docs) {
      final data = item.data() as Map<String, dynamic>;

      // Convertir les données (prix et quantité) de String en double/int
      double price = double.tryParse(data['prix'] ?? '0') ?? 0.0;
      int quantity = int.tryParse(data['quantity'] ?? '0') ?? 0;

      total += price * quantity;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  // Méthode pour augmenter la quantité
  Future<void> _increaseQuantity(String docId, int currentQuantity) async {
    await FirebaseFirestore.instance
        .collection('Panier')
        .doc(docId)
        .update({'quantity': (currentQuantity + 1).toString()}); // Stocker en String
    _calculateTotal(); // Recalculer le total après modification
  }

  // Méthode pour diminuer la quantité ou supprimer l'article
  Future<void> _decreaseQuantity(String docId, int currentQuantity) async {
    if (currentQuantity > 1) {
      await FirebaseFirestore.instance
          .collection('Panier')
          .doc(docId)
          .update({'quantity': (currentQuantity - 1).toString()}); // Stocker en String
    } else {
      await FirebaseFirestore.instance.collection('Panier').doc(docId).delete();
    }
    _calculateTotal(); // Recalculer le total après modification
  }

  // Méthode pour supprimer un article
  Future<void> _removeItem(String docId) async {
    await FirebaseFirestore.instance.collection('Panier').doc(docId).delete();
    _calculateTotal(); // Recalculer le total après suppression
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text('Veuillez vous connecter pour voir votre panier.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Panier')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Votre panier est vide.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final cartItems = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    final data = cartItem.data() as Map<String, dynamic>;

                    // Convertir les données de String en valeurs utilisables
                    double price = double.tryParse(data['prix'] ?? '0') ?? 0.0;
                    int quantity = int.tryParse(data['quantity'] ?? '0') ?? 0;

                    return GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              clothing: data,
                              clothingId: cartItem['clothingId'],
                            ),
                          ),
                        );
                        if (updated == true) {
                          _calculateTotal(); // Rafraîchir le total si une modification a été faite
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  data['url'] ?? '',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['titre'] ?? 'Sans titre',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Taille: ${data['taille'] ?? ''} | Prix: $price €',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Quantité: $quantity',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    onPressed: () {
                                      _increaseQuantity(cartItem.id, quantity);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.orange),
                                    onPressed: () {
                                      _decreaseQuantity(cartItem.id, quantity);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _removeItem(cartItem.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Afficher le total général
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total :',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_totalPrice €',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
