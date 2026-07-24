# Sprint — Lot 2 · Ergonomie et retours terrain

**Objet :** confronter le produit aux éducateurs de l'IME, arbitrer les questions de terrain, adapter l'ergonomie.
**Livrable :** version testable par les premiers utilisateurs.
**État :** ⏳ À venir (susceptible d'être réarbitré après retours IME).
**Réf CDC :** §7 (Lot 2), §11.

> Les stories US-2.03 et US-2.04 portent des **questions à statuer** renvoyées aux éducateurs de l'IME (§11) — à ne pas trancher unilatéralement.

---

### US-2.01 · Présentation en IME et recueil des retours `Must`
> **En tant que** mainteneur, **je veux** présenter le produit en IME et recueillir les retours des éducateurs spécialisés, **afin d'**orienter l'ergonomie sur des usages réels.

_Réf : §7 (Lot 2)_

- [ ] Organiser la présentation en IME
- [ ] Recueillir et consigner les retours des éducateurs
- [ ] Prioriser les adaptations issues des retours

### US-2.02 · Restitution vocale — au picto et lecture globale `Must`
> **En tant qu'**utilisateur final, **je veux** entendre chaque picto au moment de l'ajout et faire lire toute la bande-phrase d'un geste, **afin de** communiquer.

_Réf : C-06, C-07 (arbitrés en Must le 22/07/2026) · socle TTS existant (§6.2) · **livré** (anticipé depuis le Lot 1)_

- [x] C-07 : restitution vocale du picto au moment de son ajout à la bande-phrase — sur **les deux** écrans (classeur + explorateur ARASAAC)
- [x] C-06 : lecture vocale de la bande-phrase complète via un bouton dédié (TTS local)
- [x] Un seul geste pour la lecture complète — bouton « Lire la phrase »
- [x] TTS vérifié sur appareil (utterances `started`/`completed`, audio émis)
- [ ] Valider le confort d'écoute avec l'IME (vitesse, voix, langue)

### US-2.03 · Arbitrage prioritaire — stabilité spatiale des repères `Must`
> **En tant qu'**éducateur IME, **je veux** trancher si l'accès aux pictos par recherche est utilisable ou si une disposition fixe est indispensable, **afin de** respecter les utilisateurs qui mémorisent l'emplacement plutôt que l'image.

_Réf : §3.1, §6.3, §11 (question 1) · **décideur : éducateurs IME**_

- [ ] Statuer : recherche acceptable vs disposition fixe indispensable
- [ ] Garantir la **position stable des pictogrammes** conformément à la décision
- [ ] Adapter l'interface communication en conséquence

### US-2.04 · Arbitrage prioritaire — devenir des phrases enregistrées `Must`
> **En tant qu'**éducateur IME, **je veux** décider entre suppression définitive et maintien en option activable des phrases enregistrées (C-11 à C-13), **afin de** ne pas risquer de faire abandonner l'intention de communiquer.

_Réf : C-11→C-13, §4.1, §11 (question 2) · **décideur : éducateurs IME**_

- [ ] Statuer : suppression définitive vs maintien en option (via A-17)
- [ ] Appliquer la décision à l'interface

### US-2.05 · Réglage de la taille et du nombre de pictogrammes par écran `Should`
> **En tant qu'**aidant, **je veux** régler la taille et le nombre de pictogrammes affichés par écran, **afin d'**adapter l'affichage aux profils hétérogènes.

_Réf : A-12, §11 (question 3, nombre par défaut à statuer par l'IME) · **livré**_

- [x] Régler le nombre de pictogrammes par écran — `AppSettings.gridColumns` (0 = Automatique, 2→6) + menu dans les Réglages, appliqué aux **deux** écrans de communication
- [x] Régler la taille des pictogrammes (zones tactiles larges) — curseur « Taille des pictogrammes » existant
- [ ] Statuer sur le nombre par défaut (retour IME) — défaut actuel : **Automatique** (selon la largeur d'écran)

### US-2.06 · Réglage de la vitesse d'élocution `Must`
> **En tant qu'**aidant, **je veux** régler la vitesse d'élocution, **afin de** garantir l'intelligibilité pour l'utilisateur final.

_Réf : A-13 (reclassé en Must) · vitesse figée à 0,42 dans le code (§6.2) · **livré** (anticipé depuis le Lot 1)_

- [x] Exposer la vitesse d'élocution en paramètre configurable — `AppSettings.speechRate` (défaut 0,42) + curseur dans les Réglages
- [x] Appliquer le réglage à la restitution au picto (C-07) et à la lecture globale (C-06) — passé à `SpeechService.speak(rate:)`
- [ ] Valider la plage/valeur par défaut avec l'IME (motricité/intelligibilité)

### US-2.07 · Affichage optionnel du texte sous l'image `Should`
> **En tant qu'**aidant, **je veux** activer ou masquer le texte sous le pictogramme, **afin d'**adapter l'affichage au profil de la personne.

_Réf : A-14 · **livré**_

- [x] Option d'affichage/masquage du libellé sous l'image — `AppSettings.showPictogramLabel` (défaut : affiché), appliqué aux **deux** écrans de communication
- [x] Réglage disponible dans le mode aidant — interrupteur « Afficher le texte sous le pictogramme » dans les Réglages (protégés par PIN)

---

## Critères d'acceptation du lot (§8)

- [ ] L'APK compile sans erreur via la CI
- [ ] Fonctionnalités vérifiées sur appareil physique réel
- [ ] Aucune régression sur les lots précédents
- [ ] Cibles de performance (§5.2) respectées
- [ ] Non-sortie des données vérifiée
- [ ] Livraison validée par le président de l'association
