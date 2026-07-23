# Backlog — Projet Mot-Zaïque (V3 reprise)

Backlog produit dérivé du **CDC v0.2 (22 juillet 2026)**. Le découpage en sprints suit le découpage en lots du CDC (§7).

- Chaque **sprint** = un lot du CDC = un fichier `.md`.
- Chaque **user story** porte un identifiant `US-<lot>.<n>`, une priorité MoSCoW et les références CDC.
- Les **cases à cocher** listent les critères d'acceptation / tâches de la story.

## Sprints (5 lots — découpage CDC §7)

| Sprint | Fichier | Objet | Livrable | État |
|---|---|---|---|---|
| Lot 0 | [lot-0-reprise-diagnostic.md](lot-0-reprise-diagnostic.md) | Reprise et diagnostic | APK fonctionnel + note d'audit | ✅ Engagé |
| Lot 1 | [lot-1-fondations-classeur-local.md](lot-1-fondations-classeur-local.md) | Fondations et classeur local | APK présentable en IME | 🟢 En cours (priorité) |
| Lot 2 | [lot-2-ergonomie-retours-terrain.md](lot-2-ergonomie-retours-terrain.md) | Ergonomie et retours terrain | Version testable par les premiers utilisateurs | ⏳ À venir |
| Lot 3 | [lot-3-continuite-confort.md](lot-3-continuite-confort.md) | Continuité et confort | Version candidate à la publication | ⏳ À venir |
| Lot 4 | [lot-4-diffusion.md](lot-4-diffusion.md) | Diffusion | Publication + doc de reprise | ⏳ À venir |

## Références complémentaires (hors sprints)

| Fichier | Objet | État |
|---|---|---|
| [socle-communication-existant.md](socle-communication-existant.md) | Mode communication existant — non-régression (C-01→C-07) | 🔵 Existant |
| [backlog-non-affecte.md](backlog-non-affecte.md) | Réserve produit — stories `Could`/`Should` non affectées à un lot (C-08, C-09, C-10, A-15, A-16) | 🟡 Non planifié |

## Couverture des exigences CDC

Toutes les exigences fonctionnelles du CDC sont tracées :

- **Mode communication C-01 → C-13** : C-01→C-07 dans le [socle](socle-communication-existant.md) (+ C-06/C-07 dans le Lot 2) ; C-08/C-09/C-10 en [réserve](backlog-non-affecte.md) ; C-11→C-13 dans le [Lot 1](lot-1-fondations-classeur-local.md) (masquage) et arbitrés au [Lot 2](lot-2-ergonomie-retours-terrain.md).
- **Mode aidant A-01 → A-17** : A-01→A-06, A-17 dans le [Lot 1](lot-1-fondations-classeur-local.md) ; A-12/A-13/A-14 dans le [Lot 2](lot-2-ergonomie-retours-terrain.md) ; A-07/A-08/A-09/A-10/A-11 dans le [Lot 3](lot-3-continuite-confort.md) ; A-15/A-16 en [réserve](backlog-non-affecte.md).

## Règles projet

- **Ne jamais travailler / committer sur `main`.** Branche de travail dédiée.
- **Design tranché par le CDC** `CDC-MOT-ZAIQUE-v0.2.pdf` (source de vérité).
- **Confidentialité structurante** : aucune donnée ne quitte l'appareil (§5.1).
- Les lots 2 et 3 sont **susceptibles d'être réarbitrés** après les retours de l'IME (§7).

## Priorités (MoSCoW)

`Must` incontournable · `Should` important · `Could` souhaitable · `Won't` hors périmètre (§4.3).

## Convention des user stories

> **En tant que** \<rôle\>, **je veux** \<capacité\>, **afin de** \<bénéfice\>.

Rôles : **Utilisateur final** (personne non-verbalisante) · **Aidant** (parent / éducateur spécialisé / orthophoniste) · **Mainteneur** (association).
