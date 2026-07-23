# Sprint — Lot 4 · Diffusion

**Objet :** documenter, publier et garantir la reprise du projet par un tiers.
**Livrable :** publication + documentation de reprise.
**État :** ⏳ À venir.
**Réf CDC :** §7 (Lot 4), §5.5, §9.

---

### US-4.01 · Documentation utilisateur `Must`
> **En tant qu'**aidant, **je veux** une documentation utilisateur, **afin de** prendre en main l'application sans accompagnement.

_Réf : §7 (Lot 4)_

- [ ] Guide de prise en main du mode communication
- [ ] Guide du mode aidant (classeur, sources d'alimentation, réglages, PIN)
- [ ] Guide export / import et profils

### US-4.02 · Publication sur Google Play `Must`
> **En tant que** mainteneur, **je veux** publier l'application sur Google Play, **afin de** la diffuser aux familles et structures.

_Réf : §7 (Lot 4) · Publication App Store hors périmètre (§4.3)_

- [ ] Préparer la fiche Google Play (description, captures, politique de confidentialité)
- [ ] Publier l'APK / bundle signé
- [ ] Vérifier la conformité confidentialité de la fiche (aucune collecte de données)

### US-4.03 · Documentation technique de reprise `Must`
> **En tant que** développeur tiers, **je veux** une documentation d'installation et d'architecture, **afin de** reprendre le projet sans accompagnement.

_Réf : §5.5, §9.2 · objectif de pérennité (licence GPL v3.0)_

- [ ] Documentation d'installation dans le dépôt
- [ ] Documentation d'architecture (couches, services, persistance, CI)
- [ ] Procédure de build et de publication

---

## Critères d'acceptation du lot (§8)

- [ ] L'APK compile sans erreur via la CI
- [ ] Fonctionnalités vérifiées sur appareil physique réel
- [ ] Aucune régression sur les lots précédents
- [ ] Cibles de performance (§5.2) respectées
- [ ] Non-sortie des données vérifiée (inspection du trafic réseau)
- [ ] Livraison validée par le président de l'association
