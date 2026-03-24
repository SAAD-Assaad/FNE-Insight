# Page de présentation FNE Insight

Cette page est une landing page statique pour présenter l'application (démonstration client).

## Fichiers

- `index.html` — landing page modernisée (hero, fonctionnalités, screenshots, GIFs, CTA)
- `styles.css` — styles (palette alignée sur l’app)
- `assets/` — images de démonstration. Par défaut : SVG **placeholders** à remplacer par des captures PNG ou GIF de l’interface réelle.
- `demo-vitrine-demo-data.sql` — petit jeu de données **PostgreSQL** (quelques factures + avoirs). Utile pour un test rapide sans Node.
- **Jeu massif recommandé** : script Node/Prisma `backend/prisma/seed-vitrine-bulk.ts` — génère des ventes aléatoires (200–400/mois/PDV) et **835 achats** (répartition non ronde), avec 3 établissements et 2 points de vente par établissement.

## Lancer en local

Option simple : ouvrir `index.html` dans un navigateur.

Option serveur local (recommandé pour les chemins d’assets) :

```bash
cd presentation-site
python -m http.server 8080
```

Puis ouvrir : `http://localhost:8080`

## Données de démo (vitrine)

### Grosse démo (recommandé)

Depuis le dossier `backend`, avec `DATABASE_URL` pointant vers votre PostgreSQL :

```bash
cd backend
npm run seed:vitrine
```

Pour **supprimer** une exécution précédente (références `VIT-*`) puis regénérer :

```bash
npm run seed:vitrine -- --clean
```

Variables utiles : `VITRINE_NCC` (défaut `9012345V`), `VITRINE_USER_PASSWORD` (défaut `DemoVitrine2025`).

- **Société démo** : NCC au format `1234567K`, ex. `9012345V`.
- **Compte** : `demo.vitrine` / **`DemoVitrine2025`** (sauf si `VITRINE_USER_PASSWORD` est défini).

### Petit jeu SQL

Après migrations Prisma, vous pouvez aussi exécuter `demo-vitrine-demo-data.sql` (quelques lignes + avoirs). Les préfixes de référence diffèrent (`DEMO-*` dans le SQL vs `VIT-*` dans le script bulk).

> **Note** : autre SGBD que PostgreSQL → adapter types et script, ou ne garder que la logique métier du fichier `.ts`.

## Remplacer les placeholders visuels (screens + GIFs)

Dans `index.html`, remplacez les `src` des blocs Screens et GIFs, par exemple :

- `assets/capture-dashboard.png`
- `assets/capture-import.png`
- `assets/capture-rapports.png`
- `assets/demo-import.gif`
- `assets/demo-recherche-export.gif`

Mettez à jour les `src` en conséquence.
