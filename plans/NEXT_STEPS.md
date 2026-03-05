# DEVMOB – GestionBudgetaire : Prochaines Étapes

## État Actuel du Projet

### ✅ Ce qui est fait
- Structure du projet Flutter conforme à l'arborescence demandée
- Modèles de données : User, Category, Transaction, BudgetGoal
- Services : AuthService, TransactionService, BudgetService (mock/in-memory)
- Providers : AuthProvider, TransactionProvider, BudgetProvider, CategoryProvider
- Pages : Login, Register, Dashboard, TransactionList, AddTransaction, CategoryPage, CreateCategoryPage, ReportPage, ProfilePage, BudgetGoalPage
- Widgets réutilisables : TransactionTile, SpeedDialFab, EmptyState, SkeletonLoading
- Thème personnalisé (AppTheme)
- Graphiques avec fl_chart
- Navigation BottomNavigationBar (4 onglets)
- 8 commits Git poussés sur GitHub

### ❌ Ce qui manque (par rapport au cahier des charges)
- Authentification réelle (Firebase/Supabase) — actuellement mock
- Persistance des données (SQLite) — actuellement tout est en mémoire
- Catégories personnalisées connectées au stockage
- Objectifs budgétaires avec CRUD réel et vérification des plafonds
- Rapports complets (évolution mensuelle, vue tableau)
- Tests unitaires
- README professionnel
- 20 commits minimum (on en a 8)
- APK de démonstration

---

## Étapes à Réaliser

---

### Étape 1 : Intégration Firebase Authentication
**Priorité** : 🔴 Critique  
**Durée estimée** : 1-2 jours

**Pourquoi** : Le cahier des charges exige une "connexion/inscription sécurisée (Firebase, Supabase ou API perso)" et que "chaque utilisateur accède à ses propres données".

**Tâches** :
1. Ajouter `firebase_core`, `firebase_auth` dans `pubspec.yaml`
2. Créer un projet Firebase Console et configurer Android/iOS/Web
3. Ajouter les fichiers de config (`google-services.json`, `GoogleService-Info.plist`)
4. Modifier `AuthService` pour utiliser Firebase Auth (email/password)
5. Modifier `AuthProvider` pour gérer l'état Firebase (stream `authStateChanges`)
6. Modifier `LoginPage` et `RegisterPage` pour appeler Firebase
7. Ajouter la gestion des erreurs Firebase (email déjà utilisé, mot de passe faible, etc.)
8. Stocker le `userId` Firebase pour isoler les données par utilisateur

**Fichiers à modifier** :
- `pubspec.yaml`
- `lib/services/auth_service.dart`
- `lib/providers/auth_provider.dart`
- `lib/views/auth/login_page.dart`
- `lib/views/auth/register_page.dart`
- `lib/main.dart` (initialiser Firebase)
- `android/app/build.gradle.kts` (plugin Google Services)

**Commits suggérés** :
- `feat: configuration Firebase et ajout des dependances`
- `feat: implementation Firebase Auth (inscription et connexion)`

---

### Étape 2 : Persistance des Données avec SQLite
**Priorité** : 🔴 Critique  
**Durée estimée** : 2-3 jours

**Pourquoi** : Le cahier des charges exige "données stockées localement (SQLite)". Actuellement toutes les données sont perdues au redémarrage.

**Tâches** :
1. Créer `lib/database/database_helper.dart` — initialisation SQLite, création des tables, migrations
2. Tables à créer :
   - `users` (id, full_name, email, currency, created_at)
   - `transactions` (id, user_id, title, amount, date, category_id, type, description, created_at)
   - `categories` (id, user_id, name, icon_code_point, color_value, type, budget, is_custom)
   - `budget_goals` (id, user_id, name, category_id, target_amount, current_amount, month, is_active)
3. Créer `lib/repositories/` avec le pattern Repository :
   - `transaction_repository.dart` — CRUD transactions
   - `category_repository.dart` — CRUD catégories
   - `budget_repository.dart` — CRUD objectifs
4. Migrer `TransactionService` pour lire/écrire depuis SQLite
5. Migrer `BudgetService` pour lire/écrire depuis SQLite
6. Supprimer les données factices (sample data)
7. Tester la persistance : fermer l'app, rouvrir → les données sont là

**Fichiers à créer** :
- `lib/database/database_helper.dart`
- `lib/repositories/transaction_repository.dart`
- `lib/repositories/category_repository.dart`
- `lib/repositories/budget_repository.dart`

**Fichiers à modifier** :
- `lib/services/transaction_service.dart`
- `lib/services/budget_service.dart`
- `lib/providers/transaction_provider.dart`
- `lib/providers/budget_provider.dart`

**Commits suggérés** :
- `feat: creation du DatabaseHelper SQLite avec schema des tables`
- `feat: implementation des repositories (Transaction, Category, Budget)`
- `feat: migration des services vers la persistance SQLite`

---

### Étape 3 : Gestion des Catégories Personnalisées
**Priorité** : 🟠 Haute  
**Durée estimée** : 1 jour

**Pourquoi** : Le cahier des charges demande "création de catégories personnalisées" pour revenus et dépenses.

**Tâches** :
1. Connecter `CreateCategoryPage` au `CategoryRepository` pour sauvegarder en BDD
2. Ajouter suppression et modification de catégories
3. Mettre à jour `CategoryProvider` pour charger les catégories depuis SQLite
4. Afficher les catégories custom + par défaut dans `CategoryPage`
5. Utiliser les catégories custom dans `AddTransactionPage`

**Fichiers à modifier** :
- `lib/views/category/create_category_page.dart`
- `lib/views/category/category_page.dart`
- `lib/providers/category_provider.dart`
- `lib/views/transaction/add_transaction_page.dart`

**Commit suggéré** :
- `feat: gestion CRUD des categories personnalisees avec SQLite`

---

### Étape 4 : Objectifs Budgétaires Fonctionnels
**Priorité** : 🟠 Haute  
**Durée estimée** : 1 jour

**Pourquoi** : Le cahier des charges demande "fixation d'objectifs mensuels par catégorie" avec vérification des plafonds.

**Tâches** :
1. Connecter `BudgetGoalPage` au `BudgetRepository` (CRUD réel)
2. Ajouter un formulaire pour créer/modifier un objectif (catégorie, montant cible, mois)
3. Calculer le `current_amount` en temps réel à partir des transactions du mois
4. Afficher une alerte quand le plafond est dépassé (ex: "150DT restaurant")
5. Barre de progression basée sur dépenses réelles vs objectif

**Fichiers à modifier** :
- `lib/views/settings/budget_goal_page.dart`
- `lib/providers/budget_provider.dart`
- `lib/services/budget_service.dart`

**Commit suggéré** :
- `feat: objectifs budgetaires avec suivi en temps reel et alertes de plafond`

---

### Étape 5 : Amélioration des Rapports et Graphiques
**Priorité** : 🟠 Haute  
**Durée estimée** : 1-2 jours

**Pourquoi** : Le cahier des charges demande "graphiques par catégorie (dépenses vs revenus)" et "évolution mensuelle du solde" avec "vue tableau et camembert".

**Tâches** :
1. Corriger le sélecteur de période → doit filtrer les données réellement
2. Ajouter graphique camembert (PieChart) des dépenses par catégorie
3. Ajouter graphique en barres (BarChart) revenus vs dépenses par mois
4. Ajouter graphique d'évolution mensuelle du solde (LineChart)
5. Ajouter une vue tableau récapitulatif (DataTable)
6. Extraire les widgets graphiques dans `lib/widgets/` :
   - `pie_chart_widget.dart`
   - `bar_chart_widget.dart`

**Fichiers à modifier** :
- `lib/views/report/report_page.dart`

**Fichiers à créer** :
- `lib/widgets/pie_chart_widget.dart`
- `lib/widgets/bar_chart_widget.dart`

**Commits suggérés** :
- `feat: amelioration des rapports avec camembert et evolution mensuelle`
- `feat: ajout de la vue tableau recapitulatif des transactions`

---

### Étape 6 : Corrections de Bugs UI/UX
**Priorité** : 🟡 Moyenne  
**Durée estimée** : 0.5 jour

**Tâches** :
1. Corriger le bouton CTA de l'état vide dans `TransactionListPage` (ouvre AddTransaction au lieu de `maybePop()`)
2. Vérifier que le `TransactionProvider` charge les vraies données (pas de délai artificiel)
3. Ajouter pull-to-refresh sur la liste des transactions
4. S'assurer que l'ajout d'une transaction met à jour le dashboard en temps réel

**Fichiers à modifier** :
- `lib/views/transaction/transaction_list_page.dart`
- `lib/providers/transaction_provider.dart`
- `lib/views/dashboard/dashboard_page.dart`

**Commit suggéré** :
- `fix: corrections UX (etat vide, rafraichissement, mise a jour temps reel)`

---

### Étape 7 : Tests Unitaires
**Priorité** : 🟡 Moyenne (bonus mais attendu)  
**Durée estimée** : 1 jour

**Pourquoi** : Le cahier des charges mentionne "tests unitaires : calcul de solde, respect des plafonds, totaux par catégorie".

**Tâches** :
1. Test : calcul du solde total (revenus - dépenses)
2. Test : totaux par catégorie
3. Test : respect des plafonds budgétaires (objectif dépassé ou non)
4. Test : validation des modèles (TransactionModel, CategoryModel)
5. Test widget : vérifier l'affichage de la liste des transactions

**Fichiers à créer** :
- `test/models/transaction_model_test.dart`
- `test/services/transaction_service_test.dart`
- `test/providers/budget_provider_test.dart`
- `test/widgets/transaction_tile_test.dart`

**Commits suggérés** :
- `test: ajout des tests unitaires (solde, plafonds, totaux par categorie)`
- `test: ajout des tests widgets pour la liste des transactions`

---

### Étape 8 : Mise à Jour du README
**Priorité** : 🟡 Moyenne  
**Durée estimée** : 0.5 jour

**Tâches** :
1. Description du projet et objectifs
2. Captures d'écran des pages principales
3. Architecture du projet (arborescence)
4. Technologies utilisées (Flutter, Firebase, SQLite, Provider, fl_chart)
5. Instructions d'installation et de lancement
6. Fonctionnalités implémentées
7. Auteurs

**Fichier à modifier** :
- `README.md`

**Commit suggéré** :
- `docs: mise a jour du README avec description, architecture et instructions`

---

### Étape 9 : Build APK de Démonstration
**Priorité** : 🟡 Moyenne  
**Durée estimée** : 0.5 jour

**Tâches** :
1. `flutter build apk --release`
2. Tester l'APK sur un appareil réel
3. Ajouter l'APK dans les releases GitHub ou lien de téléchargement

**Commit suggéré** :
- `build: generation de l'APK de demonstration`

---

## Récapitulatif des Commits Restants

On a actuellement **8 commits**. Il en faut **20 minimum**. Voici les **12+ commits** à ajouter :

| # | Commit | Étape |
|---|--------|-------|
| 9 | `feat: configuration Firebase et ajout des dependances` | 1 |
| 10 | `feat: implementation Firebase Auth (inscription et connexion)` | 1 |
| 11 | `feat: creation du DatabaseHelper SQLite avec schema des tables` | 2 |
| 12 | `feat: implementation des repositories (Transaction, Category, Budget)` | 2 |
| 13 | `feat: migration des services vers la persistance SQLite` | 2 |
| 14 | `feat: gestion CRUD des categories personnalisees avec SQLite` | 3 |
| 15 | `feat: objectifs budgetaires avec suivi en temps reel et alertes` | 4 |
| 16 | `feat: amelioration des rapports avec camembert et evolution mensuelle` | 5 |
| 17 | `feat: ajout de la vue tableau recapitulatif des transactions` | 5 |
| 18 | `fix: corrections UX (etat vide, rafraichissement, temps reel)` | 6 |
| 19 | `test: tests unitaires (solde, plafonds, totaux par categorie)` | 7 |
| 20 | `test: tests widgets pour la liste des transactions` | 7 |
| 21 | `docs: mise a jour du README avec description et architecture` | 8 |
| 22 | `build: generation de l'APK de demonstration` | 9 |

**Total estimé : 22 commits** (bien au-dessus des 20 requis)

---

## Planning Suggéré

| Jour | Étapes | Durée |
|------|--------|-------|
| Jour 1 | Étape 1 — Firebase Auth | 1-2j |
| Jour 2-3 | Étape 2 — SQLite Persistance | 2-3j |
| Jour 4 | Étape 3 — Catégories CRUD | 1j |
| Jour 4 | Étape 4 — Objectifs budgétaires | 1j |
| Jour 5 | Étape 5 — Rapports et graphiques | 1-2j |
| Jour 6 | Étape 6 — Corrections bugs | 0.5j |
| Jour 6 | Étape 7 — Tests unitaires | 1j |
| Jour 7 | Étape 8 — README | 0.5j |
| Jour 7 | Étape 9 — Build APK | 0.5j |

**Durée totale estimée : ~7-8 jours de travail**

---

## Critères d'Évaluation — Où on en est

| Critère | Requis | Statut Actuel | Après Étapes |
|---------|--------|---------------|--------------|
| Durée du travail | 1 mois minimum | ✅ | ✅ |
| Commits Git | 20 minimum, bien nommés | ❌ (8/20) | ✅ (22+) |
| Fonctionnel | Toutes les fonctionnalités | ⚠️ Partiel | ✅ |
| Architecture | MVC / Clean Architecture | ⚠️ Partiel | ✅ |
| Qualité du code | Structuré, modulaire | ✅ | ✅ |
| Interface | Responsive et agréable | ✅ | ✅ |
| Déploiement | APK ou démo | ❌ | ✅ |
| Tests (bonus) | Tests unitaires/widgets | ❌ | ✅ |
