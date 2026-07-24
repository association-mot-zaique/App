# Sprint — Lot 3 · Continuité et confort

**Objet :** assurer la portabilité du classeur d'un appareil à l'autre et le confort d'organisation.
**Livrable :** version candidate à la publication.
**État :** ⏳ À venir (susceptible d'être réarbitré avec le Lot 2).
**Réf CDC :** §7 (Lot 3).

---

### US-3.01 · Export du classeur vers un fichier transférable `Must`
> **En tant qu'**aidant, **je veux** exporter le classeur vers un fichier réellement transférable, **afin de** ne pas devoir tout reconstruire en cas de changement d'appareil.

_Réf : A-09 · le service existant écrit dans le répertoire privé, non récupérable (§6.2) — objectif non atteint_

- [x] Exporter le classeur (catégories, pictos, **images incluses**) vers un fichier — **archive zip** (`manifest.json` + `images/`)
- [x] Écrire dans un emplacement récupérable par l'aidant (hors répertoire privé) — sélecteur système (`FilePicker.saveFile`), sans permission
- [x] Fichier autonome, réimportable sur un autre appareil — vérifié par test (export → import dans une autre racine)
- [ ] Valider un export/import entre **deux appareils réels**

### US-3.02 · Import d'un classeur depuis un fichier `Must`
> **En tant qu'**aidant, **je veux** importer un classeur depuis un fichier, **afin de** restaurer le classeur sur un nouvel appareil sans reconstruction.

_Réf : A-10, §3.2 (aucune reconstruction en cas de changement d'appareil)_

- [x] Importer un fichier de classeur exporté — sélecteur système (`FilePicker.pickFiles`)
- [x] Restaurer catégories, pictogrammes et images sur le disque local
- [x] Gérer les conflits / le remplacement du classeur courant — **confirmation explicite** avant remplacement ; archive invalide **refusée sans rien modifier**

### US-3.03 · Gestion de profils multiples `Should`
> **En tant qu'**aidant, **je veux** gérer plusieurs profils, **afin de** partager un même appareil entre plusieurs utilisateurs.

_Réf : A-11 · l'onglet est protégé par le PIN existant (§6.2)_

- [ ] Créer / renommer / supprimer un profil
- [ ] Classeur et réglages propres à chaque profil
- [ ] Bascule entre profils depuis le mode aidant

### US-3.04 · Déplacement d'un pictogramme entre catégories `Should`
> **En tant qu'**aidant, **je veux** déplacer un pictogramme d'une catégorie à une autre, **afin de** réorganiser le classeur.

_Réf : A-07_

- [ ] Déplacer un pictogramme vers une autre catégorie

### US-3.05 · Réorganisation de l'ordre d'affichage `Should`
> **En tant qu'**aidant, **je veux** réorganiser l'ordre d'affichage des pictogrammes et catégories, **afin de** préserver une disposition stable et pertinente.

_Réf : A-08 · attention à la stabilité spatiale (§3.1) : réorganisation réservée au mode aidant_

- [ ] Réordonner les pictogrammes au sein d'une catégorie
- [ ] Réordonner les catégories
- [ ] Réorganisation possible **uniquement** depuis le mode aidant (position stable côté utilisateur final)

---

## Critères d'acceptation du lot (§8)

- [ ] L'APK compile sans erreur via la CI
- [ ] Export puis import sur un **autre appareil** vérifié sur matériel réel
- [ ] Aucune régression sur les lots précédents
- [ ] Cibles de performance (§5.2) respectées
- [ ] Non-sortie des données vérifiée
- [ ] Livraison validée par le président de l'association
