# Socle — Mode communication existant (non-régression)

**Objet :** fonctions de base du mode communication déjà présentes et fonctionnelles dans le prototype (audit §6.2). Elles ne sont pas un lot de développement mais un **socle à préserver** : le critère d'acceptation §8 impose l'absence de régression sur ces fonctions.
**État :** 🔵 Existant — fonctionnel au diagnostic statique, **à valider en usage sur appareil réel**.
**Réf CDC :** §4.1, §6.2.

> Les cases cochées reflètent l'état « fonctionnel » de l'audit **statique** (code présent, cohérent, couvert par les tests), non une validation en usage.

---

### US-S.01 · Affichage des pictogrammes par catégories `Must`
> **En tant qu'**utilisateur final, **je veux** voir les pictogrammes rangés par catégories, **afin de** trouver ce que je veux dire.

_Réf : C-01_

- [x] Affichage des pictogrammes par catégories
- [ ] Validation sur appareil physique (zones tactiles larges, position stable)

### US-S.02 · Ajout d'un pictogramme à la bande-phrase `Must`
> **En tant qu'**utilisateur final, **je veux** ajouter un pictogramme à la bande-phrase d'un simple appui, **afin de** composer ma phrase.

_Réf : C-02 · appui simple, aucun geste complexe (§3.1)_

- [x] Ajout d'un pictogramme par appui
- [ ] Validation réponse < 100 ms sur appareil réel (§5.2)

### US-S.03 · Retrait du dernier pictogramme `Must`
> **En tant qu'**utilisateur final, **je veux** retirer le dernier pictogramme, **afin de** corriger ma phrase.

_Réf : C-03_

- [x] Retrait du dernier pictogramme de la bande-phrase

### US-S.04 · Effacement complet de la bande-phrase `Must`
> **En tant qu'**utilisateur final, **je veux** effacer toute la bande-phrase, **afin de** recommencer.

_Réf : C-04_

- [x] Effacement complet de la bande-phrase

### US-S.05 · Navigation entre catégories et retour à l'accueil `Must`
> **En tant qu'**utilisateur final, **je veux** naviguer entre catégories et revenir à l'accueil, **afin de** parcourir le classeur.

_Réf : C-05 · sortie impossible du mode communication (§3.1)_

- [x] Navigation entre catégories et retour à l'accueil
- [ ] Validation : aucune sortie accidentelle du mode communication

### US-S.06 · Lecture vocale de la bande-phrase complète `Must`
> **En tant qu'**utilisateur final, **je veux** faire lire toute la bande-phrase par un bouton dédié, **afin de** me faire entendre.

_Réf : C-06 (arbitré Must) · voir aussi US-2.02_

- [x] Lecture vocale de la bande-phrase complète (TTS local)

### US-S.07 · Restitution vocale du pictogramme à l'ajout `Must`
> **En tant qu'**utilisateur final, **je veux** entendre le pictogramme au moment où je l'ajoute, **afin d'**associer image et son.

_Réf : C-07 (arbitré Must) · voir aussi US-2.02_

- [x] Restitution vocale du pictogramme au moment de l'ajout

---

## Fonctions optionnelles / différées (renvois)

- **C-08** Limitation configurable de la longueur de la bande-phrase → user story [US-R.01](backlog-non-affecte.md)
- **C-09** Marquage d'un pictogramme comme favori → user story [US-R.02](backlog-non-affecte.md)
- **C-10** Accès direct à la liste des favoris → user story [US-R.03](backlog-non-affecte.md)
- **C-11 / C-12 / C-13** Phrases enregistrées — **masquées de l'interface, conservées au code** → [US-1.08](lot-1-fondations-classeur-local.md), arbitrage [US-2.04](lot-2-ergonomie-retours-terrain.md)
