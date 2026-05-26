# RP2_VisualStudio
Dépôt RP2 Guichard Rafaël BTS SIO : code source de l'application Visual Studio, bases de données SQL, et documentations annexes.

GSB-Admin
Guide d'installation et d'utilisation
Projet BTS SIO SLAM — Session 2026 — Guichard Rafael
Projet
GSB-Admin — Application client lourd de gestion des utilisateurs GSB
Auteur
Guichard Rafael — N candidat 2248268444
Technologie
VB.NET (.NET Framework 4.8) — Visual Studio 2022
Base de donnees
MySQL 5.7 — gsb_frais (local WAMP)
Depot GitHub
https://github.com/rafale60700/RP2_VisualStudio


1. Installation et lancement de l'application
GSB-Admin est une application Windows Forms (client lourd) developpee en VB.NET. Elle fonctionne en local.

1.1 Prerequis
Un serveur local installé et lancé (icone verte dans la barre des taches)
Visual Studio 2022 avec .NET Framework 4.8
Package NuGet MySql.Data 9.6.0 (deja inclus dans le projet)

1.2 Mise en place de la base de donnees
1. Lancer le serveur local et ouvrir phpMyAdmin : http://localhost/phpmyadmin
2. Creer une base de donnees nommee gsb_frais2
3. Importer le fichier gsb_frais2.sql (disponible dans le depot GitHub)
4. Importer le fichier Create_user (disponible dans le depot GitHub)
5. Verifier que les tables et les 3 triggers sont bien presents

1.3 Configuration gsb.ini
Le fichier gsb.ini se trouve dans le dossier GSB-Admin/bin/Debug/ et contient les parametres de connexion. Son contenu doit etre :

[database]
server   = localhost
port     = 3306
name     = gsb_frais2
user     = gsb_user2
password = 12-Soleil&

[superadmin]
password = 0329cc7a8f0c75d022436a7727427279066225c4ae528579c512bbd217fed930

⚠️  Le mot de passe est stocke en hash SHA-256. Ne jamais mettre ce fichier sur GitHub avec le mot de passe en clair.

1.4 Lancement
5. Ouvrir GSB-Admin.sln dans Visual Studio 2022
6. Clic droit sur le projet > Rebuild Solution
7. Lancer avec F5 ou double-cliquer sur bin/Debug/GSB-Admin.exe
8. A l'ecran de connexion, saisir le mot de passe : "12-Soleil&"


2. Utilisation de l'application
GSB-Admin permet a un super-administrateur de gerer les comptes utilisateurs de GSB-AppliFrais via trois fonctionnalites principales.

2.1 Connexion

Mot de passe admin
12-Soleil&

Ce mot de passe est unique et stocke en hash SHA-256 dans gsb.ini. Il ne correspond a aucun login — c est le mot de passe de l application elle-meme.

2.2 Liste des utilisateurs
Menu principal > Liste des utilisateurs
Onglet Visiteurs : affiche les 26 visiteurs medicaux avec ID, nom, prenom, login, adresse, ville, date d embauche
Onglet Comptables : affiche les 5 comptables avec en plus le nombre de fiches refusees (mis a jour automatiquement par les triggers)
Bouton Actualiser : recharge les donnees depuis la base

2.3 Creer un utilisateur
Menu principal > Creer un utilisateur
Remplir tous les champs : nom, prenom, adresse, ville, code postal (5 chiffres), login (20 caracteres max), mot de passe
Selectionner le type : Visiteur (coche par defaut) ou Comptable
Choisir la date d embauche via le calendrier
Cliquer sur Creer le compte — un ID unique est genere automatiquement (lettre + 3 chiffres)
Le mot de passe est hache en SHA-256 avant stockage
Une transaction SQL garantit la coherence (rollback si erreur)

2.4 Reinitialiser un mot de passe
Menu principal > Reinitialiser un mot de passe
9. Rechercher l utilisateur par nom, prenom ou login
10. Selectionner l utilisateur dans le tableau de resultats
11. Saisir le nouveau mot de passe (6 caracteres minimum) et le confirmer
12. Cliquer sur Reinitialiser — le nouveau mot de passe est hache en SHA-256


3. Architecture technique

3.1 Hierarchie des classes POO
Le projet respecte une architecture orientee objet avec heritage et association :

Classe
Role
Utilisateur
Classe de base — id, nom, prenom, login, adresseRue, codePostal, ville, dateEmbauche
Visiteur (herite de Utilisateur)
Sous-classe specialisee pour les visiteurs medicaux
Comptable (herite de Utilisateur)
Sous-classe — ajoute NbFichesRefusees (mis a jour par trigger)
GestionnaireUtilisateurs
Classe de collection — List(Of Utilisateur) — charge visiteurs et comptables
ModConfig
Module — lit gsb.ini, chiffre le mot de passe BDD en AES, verifie le mot de passe admin (SHA-256)
ModDatabase
Module — fournit NouvelleConnexion() via MySql.Data

3.2 Structure de la base de donnees gsb_frais

Table
Role
utilisateur
Table principale — tous les utilisateurs (visiteurs + comptables)
visiteur
Heritage 1:1 — id FK vers utilisateur
comptable
Heritage 1:1 — id FK vers utilisateur + nbFichesRefusees
lignefraishorsforfait
Table source des triggers — idComptableRefus FK vers comptable
fichefrais
Fiches de frais mensuelles par visiteur
lignefraisforfait
Lignes de frais forfaitaires
fraisforfait
Types de frais (KM, REP, NUI, ETP)
etat
Etats des fiches (CR, CL, VA, RB)

3.3 Triggers MySQL corrigés
Le trigger original (increment_refus) incrementait nbFichesRefusees de +1 sans jamais decrementer. Il a ete remplace par 3 triggers independants qui recalculent par COUNT(*) reel :

after_insert_lfhf — recalcule apres INSERT sur lignefraishorsforfait
after_update_lfhf — recalcule apres UPDATE (ancien et nouveau comptable)
after_delete_lfhf — recalcule apres DELETE

Chaque trigger filtre sur idComptableRefus IS NOT NULL et effectue un SELECT COUNT(*) pour garantir une valeur toujours exacte.


4. Contenu du depot GitHub

URL du depot
https://github.com/rafale60700/RP2_VisualStudio

Dossier / Fichier
Contenu
GSB-Admin/
Code source VB.NET complet (formulaires + classes + modules)
  FrmConnexion.vb
Ecran de connexion — verification SHA-256 via ModConfig
  FrmMenu.vb
Menu principal — acces aux 3 fonctionnalites
  FrmListeUtilisateurs.vb
Liste visiteurs/comptables — utilise GestionnaireUtilisateurs
  FrmCreerUtilisateur.vb
Creation compte — transaction SQL + generation ID unique
  FrmReinitialisationMDP.vb
Reinitialisation MDP — recherche + hash SHA-256
  Utilisateur.vb
Classes POO : Utilisateur, Visiteur, Comptable (heritage)
  GestionnaireUtilisateurs.vb
Collection List(Of Utilisateur) — charge depuis BDD
  ModConfig.vb
Lecture gsb.ini, chiffrement AES, verification mot de passe
  ModDatabase.vb
NouvelleConnexion() — connexion PDO MySQL
  bin/Debug/gsb.ini
Configuration BDD et hash mot de passe admin
sql/
Scripts SQL
  gsb_frais2.sql
Structure complete + triggers corriges + toutes les donnees
gsb.ini.example
Modele de configuration sans mot de passe reel
doc/
Captures d ecran des formulaires


  L'ensemble des exigences de la fiche RP2 sont satisfaites. L application est fonctionnelle en local.
