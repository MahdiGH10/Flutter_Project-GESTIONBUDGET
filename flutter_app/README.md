# DEVMOB – Gestion Budgetaire

Application Flutter de gestion budgétaire permettant à un utilisateur de suivre ses revenus et dépenses, organiser ses transactions par catégories, visualiser son solde en temps réel, consulter des rapports graphiques et gérer des objectifs budgétaires mensuels.

## Objectif du projet

Ce projet répond au cahier des charges **PROJET 9 – Gestion Budgétaire et Suivi de Dépenses** :

- Suivi des revenus et dépenses
- Catégorisation des transactions
- Visualisation du solde en temps réel
- Rapports par catégorie et évolution mensuelle
- Objectifs mensuels par catégorie
- Authentification par utilisateur

## Fonctionnalités implémentées

### Authentification

- Inscription et connexion via **Firebase Auth**
- Réinitialisation du mot de passe
- Session restaurée automatiquement au démarrage
- Données isolées par utilisateur

### Gestion de transactions

- Ajout de transaction **Revenu** / **Dépense**
- Champs: montant, date, catégorie, note optionnelle
- Liste des transactions avec filtres (type + catégorie)
- Calcul automatique des totaux et du solde

### Catégories

- Catégories par défaut (revenus + dépenses)
- Création, modification et suppression de catégories personnalisées
- Page catégories accessible directement depuis la navigation principale

### Objectifs budgétaires

- Création d’objectifs mensuels par catégorie
- Suivi automatique de la progression à partir des dépenses réelles
- Alerte visuelle en cas de dépassement / seuil d’alerte

### Rapports et visualisation

- Vue statistiques avec:
	- Bar chart revenus vs dépenses
	- Pie chart dépenses par catégorie
	- Courbe d’évolution du solde
	- Tableau des transactions
- Filtres temporels: jour / semaine / mois / année

### Profil & paramètres

- Édition du profil (nom/email)
- Changement de devise avec persistance locale
- Actions notifications / confidentialité / support marquées clairement **coming soon**
- Accès direct aux objectifs budgétaires depuis les paramètres

## Pages principales (exigence maquette)

Les 8 pages demandées sont accessibles dans l’application:

1. Connexion / Inscription
2. Accueil (solde global)
3. Liste des transactions récentes
4. Ajouter une transaction
5. Vue catégories
6. Graphiques & rapports
7. Objectifs mensuels
8. Profil / Paramètres

## Stack technique

- **Flutter** (Dart)
- **Firebase Core**
- **Firebase Authentication**
- **Cloud Firestore**
- **Provider** (state management)
- **fl_chart** (visualisation)
- **Shared Preferences** (persistance locale légère, ex: devise utilisateur)

## Architecture du projet

Le projet suit une architecture modulaire inspirée de la séparation en couches :

- `models/` : entités métier (`UserModel`, `Transaction`, `Category`, `BudgetGoal`)
- `repositories/` : accès Firestore
- `services/` : logique métier applicative
- `providers/` : état UI + coordination services
- `views/` : écrans
- `widgets/` : composants UI réutilisables

Structure principale:

- `lib/models`
- `lib/services`
- `lib/repositories`
- `lib/providers`
- `lib/views/auth`
- `lib/views/dashboard`
- `lib/views/transaction`
- `lib/views/category`
- `lib/views/report`
- `lib/views/settings`
- `lib/widgets`

## Sécurité et données

- Données stockées dans Firestore sous des collections scindées par utilisateur (`users/{uid}/...`)
- Authentification obligatoire pour accéder aux données privées
- Devise utilisateur persistée localement

> Note: les règles Firestore doivent être configurées côté console/projet Firebase pour garantir l’accès restreint à l’utilisateur connecté.

## Lancer le projet

### Prérequis

- Flutter SDK (version compatible avec `sdk: ^3.10.8`)
- Compte Firebase + projet Firebase configuré
- Android Studio / VS Code + émulateur ou appareil physique

### Installation

1. Récupérer les dépendances: `flutter pub get`
2. Vérifier la configuration Firebase (`google-services.json`, `firebase_options.dart`)
3. Lancer l’application: `flutter run`

## Tests

- Tests unitaires disponibles dans `test/unit/`
- Exécution: `flutter test`

Couverture actuelle ciblée:

- Calcul de solde
- Totaux par catégorie
- Vérification de plafonds/alertes budgétaires

## État actuel / Roadmap

### Terminé

- Flux principal budgétaire complet
- Navigation avec accès direct aux vues exigées
- Authentification et données par utilisateur
- Rapports graphiques et objectifs mensuels

### À améliorer (itérations suivantes)

- Paramètres notifications/confidentialité complets (au-delà du mode “coming soon”)
- Renforcement des tests widget/intégration
- Pipeline CI/CD GitHub Actions
- Documentation des règles Firestore + captures d’écran de démonstration

---

Projet réalisé dans le cadre de **DEVMOB – GestionBudgetaire**.
