# Sprint — Lot 0 · Reprise et diagnostic

**Objet :** reprendre le prototype existant, produire un APK et un état des lieux.
**Livrable :** APK fonctionnel + note d'audit.
**État :** ✅ Engagé (réalisé le 22 juillet 2026).
**Réf CDC :** §6, §7 (Lot 0).

---

### US-0.1 · Branche de sauvegarde `Must`
> **En tant que** mainteneur, **je veux** une branche de sauvegarde du dernier état connu, **afin de** repartir sans risque de perte.

- [x] Créer la branche `backup` sur le dernier état du dépôt
- [x] Laisser `main` inchangée

### US-0.2 · Compilation de l'APK `Must`
> **En tant que** mainteneur, **je veux** compiler l'APK release, **afin de** transmettre un produit exécutable à l'association.

- [x] Produire un APK release (~54 Mo)
- [x] Transmettre l'APK à l'association

### US-0.3 · Audit du code et note d'état des lieux `Must`
> **En tant que** mainteneur, **je veux** un audit statique du code, de la chaîne de build et des tests, **afin de** cadrer l'enjeu de la reprise.

- [x] Auditer l'architecture (couches `app / core / data / features / widgets`)
- [x] Vérifier la suite de tests (31 tests au vert)
- [x] Identifier l'écart de conception structurant (§6.3 — explorateur ARASAAC vs classeur possédé)
- [x] Rédiger la note d'audit (sections 6.1 à 6.4 du CDC)
- [x] Filtre « téléchargements minimum » retiré — l'API ARASAAC renvoie `downloads: 0` pour **tous** les pictogrammes, donc toute valeur positive vidait l'écran de communication sans aucun message. Curseur supprimé des Réglages + migration de schéma v3 qui remet la valeur à 0 sur les installations touchées
