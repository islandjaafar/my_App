import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_clothing.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();

  String? _email;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        final docSnapshot = await FirebaseFirestore.instance
            .collection('client')
            .doc(_userId)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          setState(() {
            _email = data['email']?.toString() ?? '';
            _passwordController.text = "********"; // Masqué
            _birthdayController.text =
                (data['anniversaire'] as List<dynamic>).join("/") ?? '';
            _addressController.text = data['adresse']?.toString() ?? '';
            _postalCodeController.text = data['codepostal']?.toString() ?? '';
            _cityController.text = data['ville']?.toString() ?? '';
            _nameController.text = data['nom']?.toString() ?? '';
            _firstNameController.text = data['prenom']?.toString() ?? '';
            _genderController.text = data['sex']?.toString() ?? '';
            _ageController.text = data['age']?.toString() ?? '';
          });
        } else {
          setState(() {
            _email = "Aucun profil trouvé.";
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération : ${e.toString()}')),
      );
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('client').doc(_userId).update({
          'anniversaire': _birthdayController.text.split("/"),
          'adresse': _addressController.text,
          'codepostal': _postalCodeController.text,
          'ville': _cityController.text,
          'nom': _nameController.text,
          'prenom': _firstNameController.text,
          'sex': _genderController.text,
          'age': _ageController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informations mises à jour')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
      ),
      body: _email == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Login (readonly)
              _buildTextInput(
                label: 'Email (readonly)',
                controller: TextEditingController(text: _email),
                isReadOnly: true,
              ),
              const SizedBox(height: 16),

              // Password (readonly)
              _buildTextInput(
                label: 'Mot de passe',
                controller: _passwordController,
                isObscured: true,
                isReadOnly: true,
              ),
              const SizedBox(height: 16),

              // Nom
              _buildTextInput(
                label: 'Nom',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              // Prénom
              _buildTextInput(
                label: 'Prénom',
                controller: _firstNameController,
              ),
              const SizedBox(height: 16),

              // Sexe
              _buildTextInput(
                label: 'Sexe',
                controller: _genderController,
              ),
              const SizedBox(height: 16),

              // Âge
              _buildTextInput(
                label: 'Âge',
                controller: _ageController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Anniversaire
              _buildTextInput(
                label: 'Anniversaire (JJ/MM/AAAA)',
                controller: _birthdayController,
              ),
              const SizedBox(height: 16),

              // Adresse
              _buildTextInput(
                label: 'Adresse',
                controller: _addressController,
              ),
              const SizedBox(height: 16),

              // Code postal
              _buildTextInput(
                label: 'Code postal',
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Ville
              _buildTextInput(
                label: 'Ville',
                controller: _cityController,
              ),
              const SizedBox(height: 32),

              // Boutons Valider et Se déconnecter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _saveUserData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Valider',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Se déconnecter',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Bouton Ajouter un vêtement
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddClothingPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Ajouter un vêtement',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    bool isReadOnly = false,
    bool isObscured = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      obscureText: isObscured,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (!isReadOnly && (value == null || value.isEmpty)) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }
}
