# Contacts — Application Flutter de gestion de contacts

Application mobile Android développée avec Flutter, permettant de gérer
un carnet d'adresses complet avec photos, groupes, et synchronisation
avec l'API randomuser.me.
---

## Fonctionnalités

- **Écran d'accueil** : liste alphabétique groupée, barre de recherche, compteur de contacts
- **Ajout / modification** : formulaire complet (prénom, nom, téléphones, e-mails, adresses,
  dates importantes, sites Web, relations, comptes de messagerie, sonnerie, notes)
- **Formatage automatique** des numéros (Haïti, USA/Canada, France, Royaume-Uni, etc.)
- **Sélection d'image** : galerie ou caméra (image_picker)
- **Gestion des permissions** : galerie, caméra, appel, SMS
- **Actions directes** : appel, SMS, e-mail depuis la fiche du contact
- **Partage** de contacts (texte ou vCard simplifié via share_plus)
- **Corbeille** avec restauration et suppression définitive
- **Importation** de 10 contacts fictifs depuis randomuser.me (API REST)
- **Paramètres** : mode sombre, tri personnalisable, emplacement de stockage
- **À propos** : informations du développeur et de l'institution

---

## Prérequis

- Flutter SDK ≥ 3.2.0
- Android SDK ≥ 21 (Android 5.0)
- Dart ≥ 3.2.0

---

## Installation et lancement

```bash
# Cloner le dépôt
git clone <url-du-repo>
cd contacts_app

# Installer les dépendances
flutter pub get

# Générer les icônes de lancement (après avoir placé assets/images/app_icon.png)
dart run flutter_launcher_icons

# Lancer sur un appareil ou émulateur connecté
flutter run