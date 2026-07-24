# Réserve produit — user stories non affectées à un lot

**Objet :** fonctionnalités `Could` / `Should` inscrites au périmètre du CDC (§4.1, §4.2) mais **non affectées à un lot** par le découpage §7. À planifier dans un lot existant après arbitrage de l'association / retours IME.
**État :** 🟡 Réserve (non planifié).
**Réf CDC :** §4.1, §4.2.

> Ce n'est pas un sprint : les sprints sont les lots 0 à 4. Ce fichier garantit qu'**aucune exigence du CDC n'est perdue**.

---

### US-R.01 · Limitation configurable de la longueur de la bande-phrase `Could`
> **En tant qu'**aidant, **je veux** limiter le nombre de pictogrammes de la bande-phrase, **afin d'**adapter la longueur des phrases au profil de l'utilisateur.

_Réf : C-08_

- [ ] Régler la longueur maximale de la bande-phrase (mode aidant)
- [ ] Empêcher l'ajout au-delà de la limite dans le mode communication

### US-R.02 · Marquage d'un pictogramme comme favori `Should`
> **En tant qu'**utilisateur final / aidant, **je veux** marquer un pictogramme comme favori, **afin de** regrouper les termes fonctionnels que le découpage thématique classe mal (« je veux », « attendre »…).

_Réf : C-09 · favoris = catégorie transversale, subsiste une fois le classeur local en place (§4.1) → à planifier après Lot 1_

- [x] Marquer / démarquer un pictogramme comme favori — cœur en surimpression sur la tuile, dans la gestion du classeur (mode aidant), avec retour par snackbar
- [x] Persistance du statut favori dans le classeur local — champ `isFavorite` du `manifest.json`, donc emporté par l'export / import (US-3.01/3.02)

### US-R.03 · Accès direct à la liste des favoris `Should`
> **En tant qu'**utilisateur final, **je veux** accéder directement à mes favoris, **afin de** retrouver rapidement le vocabulaire fréquent.

_Réf : C-10 · dépend de US-R.02_

- [x] Catégorie / vue transversale « Favoris » accessible depuis le mode communication — pastille en tête de la barre de catégories, affichant les favoris de toutes les catégories
- [x] Position stable de l'accès aux favoris (§3.1) — toujours en première position ; la pastille n'apparaît qu'une fois un favori marqué, donc les catégories ne bougent pas pendant l'usage
- [ ] Valider l'usage des favoris avec l'IME (pertinence du regroupement transversal)

### US-R.04 · Masquage temporaire d'un pictogramme `Could`
> **En tant qu'**aidant, **je veux** masquer temporairement un pictogramme, **afin de** le retirer de l'affichage sans le supprimer du classeur.

_Réf : A-15 · action réservée au mode aidant_

- [ ] Masquer / réafficher un pictogramme sans le supprimer
- [ ] Pictogramme masqué absent du mode communication, conservé au classeur

### US-R.05 · Consultation des pictogrammes les plus utilisés `Could`
> **En tant qu'**aidant, **je veux** consulter les pictogrammes les plus utilisés, **afin d'**ajuster le classeur aux usages réels.

_Réf : A-16 · consultation en mode aidant uniquement — ne doit **pas** réordonner l'affichage côté utilisateur final (stabilité spatiale §3.1)_

- [ ] Comptabiliser l'usage des pictogrammes (données locales uniquement)
- [ ] Afficher un classement dans le mode aidant
- [ ] Aucun impact sur l'ordre d'affichage du mode communication
