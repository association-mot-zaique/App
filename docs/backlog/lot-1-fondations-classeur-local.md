# Sprint — Lot 1 · Fondations et classeur local

**Objet :** construire la couche « classeur local » par-dessus l'existant. Le point central n'est plus la correction d'anomalies mais **la construction du modèle de données manquant**.
**Livrable :** APK présentable en IME.
**État :** 🟢 En cours (priorité actuelle).
**Réf CDC :** §6.3, §6.4, §7 (Lot 1).

> ⚠️ Écart structurant (§6.3) : le prototype est un **explorateur de la banque ARASAAC** en ligne, pas un classeur possédé. Ce lot ajoute une couche « classeur local » où images et pictogrammes appartiennent à l'utilisateur et vivent sur le disque.

---

### US-1.01 · Modèle de données du classeur local `Must`
> **En tant que** mainteneur, **je veux** un modèle de données de classeur possédé par l'utilisateur, **afin d'**être indépendant de toute URL distante.

_Réf : §6.3, §6.4 · dérive A-05→A-08 · **couche data livrée** (branche `feat/lot1-classeur-local`)_

- [x] Entité `Catégorie` (id, nom, ordre d'affichage) — `LocalCategory`
- [x] Entité `Pictogramme` (id, libellé, chemin image **locale**, catégorie, favori) — `LocalPictogram`
- [x] Stockage des images sur le disque (répertoire privé de l'application) — `LocalClasseurRepository.storeImageBytes` + `path_provider`
- [x] Persistance locale au-delà de `shared_preferences` (base locale) — manifeste JSON sur disque (`manifest.json`)
- [x] Aucune dépendance à une URL distante pour l'affichage d'un picto possédé — `LocalPictogram` n'a aucun champ URL
- [ ] Branchement dans l'app (fourniture du repository, chargement au démarrage) — avec US-1.05/1.06

### US-1.02 · Source d'alimentation — import depuis les fichiers `Must`
> **En tant qu'**aidant, **je veux** importer un pictogramme depuis les fichiers de l'appareil, **afin de** garnir le classeur avec mes propres images.

_Réf : A-02 · **livré** via `image_picker` (galerie/fichiers) · sélecteur de source dans « Ajouter un pictogramme »_

- [x] Sélectionner une image depuis les fichiers/galerie de l'appareil (`ImageSource.gallery`)
- [x] Copier l'image dans le stockage local du classeur (format d'origine préservé — transparence PNG conservée)
- [x] Créer le pictogramme (libellé saisi, catégorie courante) à partir de l'image importée
- [ ] Valider sur appareil réel (Photo Picker Android, sans permission)

### US-1.03 · Source d'alimentation — prise de photo directe `Must`
> **En tant qu'**aidant, **je veux** prendre une photo pour créer un pictogramme, **afin d'**intégrer des objets, lieux et visages familiers de l'environnement réel de la personne.

_Réf : A-03 · condition de viabilité (§6.3) · **livré** via `image_picker` (`ImageSource.camera`)_

- [x] Déclencher la prise de photo (permission caméra gérée par l'app caméra système, au moment de l'usage)
- [x] Enregistrer la photo dans le stockage local du classeur
- [x] Créer le pictogramme à partir de la photo
- [ ] Valider sur appareil réel (permission caméra, taille des fichiers)

### US-1.04 · Source d'alimentation — recherche et import ARASAAC `Must`
> **En tant qu'**aidant, **je veux** rechercher et importer un pictogramme depuis ARASAAC, **afin de** compléter le classeur — mais **jamais comme seule source**.

_Réf : A-04 · seule connexion sortante autorisée (§5.1) · ARASAAC à parité avec fichier et photo · **partiellement livré** via `ArasaacImportScreen` (utilisé pour la création de pictos US-1.06)_

- [x] Rechercher par mot-clé sur `api.arasaac.org`
- [x] **Télécharger et copier l'image sur le disque** au moment de l'import (picto possédé, plus jamais re-sollicité en réseau)
- [x] Import accessible **depuis le mode aidant uniquement** (entrée dans Réglages → Gérer le classeur)
- [ ] Repli automatique sur le cache en cas d'échec réseau
- [ ] Réutiliser le service de recherche existant (filtres qualité) plutôt qu'un `ArasaacApi` dédié

### US-1.05 · Écran de gestion — catégories `Must`
> **En tant qu'**aidant, **je veux** créer, renommer et supprimer des catégories, **afin d'**organiser le classeur.

_Réf : A-05 · **livré** (branche `feat/lot1-classeur-local`) — `LocalClasseurController` + `ClasseurManagementScreen`, accessible depuis Réglages_

- [x] Créer une catégorie
- [x] Renommer une catégorie
- [x] Supprimer une catégorie (supprime aussi ses pictos et leurs images)

### US-1.06 · Écran de gestion — pictogrammes `Must`
> **En tant qu'**aidant, **je veux** renommer et supprimer des pictogrammes, **afin de** maintenir le classeur à jour.

_Réf : A-06 · **livré** — gestion par catégorie, création via ARASAAC (voir US-1.04)_

- [x] Renommer un pictogramme
- [x] Supprimer un pictogramme (et l'image locale associée)
- [x] Créer un pictogramme via ARASAAC (`ArasaacImportScreen`) — télécharge l'image sur le disque
- [ ] Valider l'objectif **< 30 s** sur appareil réel (§3.2)
- [ ] Sources fichier (US-1.02) et photo (US-1.03) — à venir (nouvelle dépendance à décider)

### US-1.07 · Extension du verrou PIN à tout le mode aidant `Must`
> **En tant qu'**aidant, **je veux** que l'intégralité du mode aidant (Réglages compris) soit protégée par code PIN, **afin d'**empêcher l'utilisateur final d'y accéder accidentellement.

_Réf : A-01 · le verrou existe mais Réglages restait accessible sans code (§6.2) · **livré**_

- [x] Protéger tous les écrans du mode aidant par le PIN — zone aidant = Favoris + Réglages (+ Gérer le classeur, atteint depuis Réglages)
- [x] Protéger l'écran Réglages (fuite constatée à corriger) — l'onglet Réglages passe désormais par le même verrou
- [x] Conserver le verrou salé (dérivation existante) et le code de récupération — `PinRepository` réutilisé sans modification
- [x] Reverrouillage automatique au retour sur l'onglet communication

### US-1.08 · Masquage des phrases enregistrées dans le mode communication `Should`
> **En tant que** mainteneur, **je veux** masquer les fonctions de phrases enregistrées (C-11 à C-13) de l'interface communication, tout en les **conservant dans le code**, **afin de** ne pas court-circuiter la composition tout en préservant la non-régression.

_Réf : C-11→C-13, A-17 · décision du 22 juillet 2026 · **livré** (réglage `savedPhrasesEnabled`, défaut off)_

- [x] Retirer C-11 (enregistrement sous un nom) de l'interface communication — bouton « Enregistrer » masqué
- [x] Retirer C-12 (rappel d'une phrase) de l'interface communication — bande des phrases enregistrées masquée
- [x] Retirer C-13 (suppression d'une phrase) de l'interface communication — masquée avec la bande
- [x] Conserver le code fonctionnel — `PhraseBookController` et widgets intacts (non-régression §8)
- [x] Rendre ces fonctions **activables depuis le mode aidant** (bascule A-17) — switch « Activer les phrases enregistrées » dans les Réglages

### US-1.09 · Conformité confidentialité — `allowBackup="false"` `Must`
> **En tant que** mainteneur, **je veux** interdire la remontée silencieuse des classeurs vers Google Drive, **afin de** garantir qu'aucune donnée ne quitte l'appareil.

_Réf : §5.1, §6.2 · attribut absent du manifeste (correction d'une ligne) · **livré**_

- [x] Ajouter `android:allowBackup="false"` au manifeste Android (+ `fullBackupContent="false"`)
- [ ] Vérifier l'absence de sauvegarde système du classeur sur appareil réel (`adb backup`)

### US-1.10 · Conformité confidentialité — permissions et attribution `Must`
> **En tant que** mainteneur, **je veux** des permissions au strict nécessaire et l'attribution ARASAAC visible, **afin de** respecter les exigences légales et de licence.

_Réf : §5.1, §5.4 · **livré**_

- [x] Réduire les permissions au strict nécessaire — manifeste = `INTERNET` seul (galerie/photo via Photo Picker / app caméra système, sans permission)
- [x] Aucune bibliothèque d'analytics ou de télémétrie (confirmé à l'audit)
- [x] Écran « À propos » : attribution ARASAAC (CC BY-NC-SA, auteur Sergio Palao, Gouvernement d'Aragon)
- [x] Mention de la licence du code (GNU GPL v3.0) — section « Licence » ajoutée aux Crédits

### US-1.11 · Bascule de la langue par défaut sur le français `Must`
> **En tant qu'**utilisateur francophone, **je veux** que l'application démarre en français, **afin de** l'utiliser dans ma langue.

_Réf : §6.2 (langue par défaut : espagnol, à basculer)_

- [x] Langue par défaut = **automatique** : suit la langue du système Android (liste ordonnée par priorité)
- [x] Repli **français** quand aucune langue du système n'est supportée (`fr` en tête de `supportedLocales`)
- [x] Option « Automatique (langue du système) » ajoutée au sélecteur des Réglages ; choix manuel prioritaire et réversible
- [ ] Vérifier la traduction française complète des écrans sur appareil réel

### US-1.12 · Caractérisation du symptôme bande-phrase `Should`
> **En tant que** mainteneur, **je veux** caractériser le symptôme signalé à la lecture de la bande-phrase sur appareil physique, **afin de** décider s'il nécessite correction.

_Réf : §6.2 (symptôme signalé, aucun défaut détecté à l'analyse statique)_

- [ ] Reproduire / caractériser le symptôme sur appareil physique
- [ ] Documenter le constat (corriger ou clore)

### US-1.13 · Compilation automatique (GitHub Actions) `Must`
> **En tant que** mainteneur, **je veux** une compilation automatique de l'APK à chaque modification, **afin de** garantir la reprise du projet par un tiers sans accompagnement.

_Réf : §5.5, §7 (Lot 1) · **livré** (`.github/workflows/ci.yml`, Flutter 3.44.1 épinglé)_

- [x] Pipeline GitHub Actions compilant l'APK à chaque push/PR (`flutter build apk --release`) + artefact APK téléchargeable
- [x] Build en échec bloquant : `flutter analyze` + `flutter test` + build échouent le job (critère §8.1)
- [ ] Vérifier le premier run vert une fois la branche poussée (rien poussé pour l'instant)

### US-1.14 · Mode communication alimenté par le classeur local `Must`
> **En tant qu'**utilisateur final, **je veux** composer ma phrase à partir des pictogrammes **possédés** de mon classeur, **afin de** communiquer 100 % hors-ligne, sans dépendre d'ARASAAC.

_Réf : §6.3, §6.4 (« le classeur local devient le cœur du lot 1 ») · **livré**_

- [x] `Pictogram` porte une image locale optionnelle (`localImagePath`) ; rendu disque via `PictogramImage`
- [x] `ClasseurCommunicationScreen` : catégories possédées → pictos du disque, bande-phrase partagée + TTS (C-06/C-07)
- [x] L'onglet Communiquer affiche le classeur dès qu'il contient une catégorie ; sinon repli sur l'explorateur ARASAAC (amorçage)
- [x] Aucune requête réseau pour parcourir/afficher le classeur possédé
- [ ] À terme : retirer complètement l'explorateur ARASAAC du mode communication (décision de bascule à valider avec l'IME — Lot 2)

---

## Critères d'acceptation du lot (§8)

- [ ] L'APK compile sans erreur via la CI
- [ ] Les fonctionnalités du lot sont vérifiées sur appareil physique réel
- [ ] Aucune régression sur les fonctions existantes (y compris C-11 à C-13 conservées au code)
- [ ] Cibles de performance respectées (ajout picto < 100 ms, ouverture catégorie < 200 ms, démarrage à froid < 3 s — §5.2)
- [ ] Non-sortie des données vérifiée (inspection du trafic réseau)
- [ ] Livraison validée par le président de l'association
