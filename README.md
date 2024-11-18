# **Flutter Clothing Store App**

## **Description**

Cette application Flutter permet aux utilisateurs de :

- Naviguer à travers une liste de vêtements disponibles.
- Consulter les détails d'un vêtement.
- Ajouter des articles à un panier.
- Gérer leur panier en augmentant, réduisant ou supprimant les quantités.
- Consulter et modifier leur profil.
- Ajouter un nouvel article depuis la page Profil.

## **Fonctionnalités**

1. **Navigation principale** :

   - Trois onglets principaux via une `BottomNavigationBar` :
     - **Acheter** : Liste des vêtements affichés en grille (2 articles par ligne).
     - **Panier** : Liste des articles ajoutés avec gestion des quantités et affichage du total.
     - **Profil** : Informations utilisateur et possibilité d'ajouter un nouvel article.

2. **Détails d'un article** :

   - Affiche les informations détaillées d'un vêtement (image, taille, prix, catégorie, etc.).
   - Permet d'ajouter l'article au panier ou de modifier la quantité si déjà ajouté.

3. **Gestion du panier** :

   - Augmenter, diminuer ou supprimer les articles du panier.
   - Calcul automatique du total.

4. **Profil utilisateur** :

   - Affiche les informations utilisateur (email, anniversaire, adresse, etc.).
   - Possibilité de modifier les données et de les sauvegarder.
   - Bouton pour ajouter un nouvel article à la base de données.

5. **Ajout d'article** :
   - Un formulaire permet d'ajouter un nouveau vêtement avec téléchargement d'une image sur Firebase Storage.

---

## **Technologies utilisées**

- **Framework** : Flutter
- **Backend** : Firebase (Firestore et Authentication)
- **Cloud Storage** : Firebase Storage pour la gestion des images.

---

## **Dépendances**

### SDK Android

- Assurez-vous d'utiliser un **SDK Android** compatible avec Flutter, idéalement la version **SDK 30** ou supérieure, pour une meilleure compatibilité avec les fonctionnalités Firebase.

---

## **Installation et configuration**

1. **Cloner le projet :**

```bash
git clone https://github.com/islandjaafar/my_App.git
```

2. **Tester avec la base de données existante :**

   - Vous pouvez tester directement l'application en utilisant les comptes de test ci-dessous.
   - Assurez-vous de lancer l'application avec les fichiers de configuration Firebase fournis.

3. **Installer les dépendances :**

   ```bash
   flutter pub get
   ```

4. **Lancer l'application sur un émulateur Android :**

   - Assurez-vous d'avoir installé Android Studio et configuré un émulateur Android.
   - Ouvrez Android Studio, allez dans **Tools > AVD Manager** et démarrez un émulateur Android.
   - Dans le terminal, lancez la commande :
     ```bash
     flutter run
     ```
   - Assurez-vous que l'émulateur est bien actif avant de lancer l'application.

   > **Remarque** : L'émulateur Android est recommandé pour tester l'application, car la configuration est plus simple et bien intégrée avec Android Studio.

---

## **Comptes de test**

Vous pouvez utiliser ces comptes pour tester l'application :

- **Email :** `test1@test.com` | **Mot de passe :** `123456`
- **Email :** `test2@test.com` | **Mot de passe :** `123456`

---

## **Structure du projet**

```
lib/
├── add_clothing.dart    # Page pour ajouter un nouvel article
├── cart.dart            # Page panier
├── details.dart         # Page détails d'un vêtement
├── home_page.dart       # Page principale avec navigation
├── login_page.dart      # Page de connexion
├── profile.dart         # Page profil utilisateur
├── firebase_options.dart# Configuration Firebase générée
├── main.dart            # Point d'entrée principal de l'application
```

## **Captures d'écran**

1. **Page Acheter** :
   - Liste des vêtements affichés en grille.
2. **Page Panier** :
   - Gestion des articles ajoutés avec affichage du total.
3. **Page Profil** :
   - Gestion des informations utilisateur et ajout d'articles.
4. **Page Détails** :
   - Visualisation et gestion de la quantité d'un vêtement.

---

## **Auteur**

- **Nom** : El Bakkali Mohamed Jaafar
- **Email** : jaafarbaccali@gmail.com
- **Organisation** : M2 MIAGE IA2

---
