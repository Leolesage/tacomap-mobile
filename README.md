# TacoMap France Mobile (Flutter)

Application mobile Flutter connectee a `tacomap-api` pour l'entite `TacosPlace`.

## Fonctionnalites
- Liste paginee avec infinite scroll (chargement a 80%).
- Ecran detail (tous les champs + photo + coordonnees).
- Ajout d'un `TacosPlace` avec:
  - geolocalisation du device (latitude/longitude obligatoires)
  - saisie des autres champs
  - upload photo
- Login JWT admin + stockage securise (`flutter_secure_storage`).

## Installation
```bash
flutter pub get
```

## Configuration API
1. Copier `.env.example` (reference des variables attendues).
2. Lancer avec `--dart-define` (optionnel si vous gardez la valeur par defaut):
```bash
flutter run --dart-define=API_BASE_URL=http://10.176.130.138:8001
```

Notes:
- Android emulator: `http://10.0.2.2:8001`
- iOS simulator: `http://localhost:8001`
- Device physique: IP LAN de votre machine (ex: `http://10.176.130.138:8001`)

## Identifiants demo
- Email: `admin@tacomap.local`
- Password: `Password123!`

## Permissions geolocalisation
- Android: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` (deja presents)
- iOS: `NSLocationWhenInUseUsageDescription` (deja present)

## Parcours de verification
1. Ouvrir l'app, consulter la liste.
2. Scroller a 80%: page suivante charge automatiquement.
3. Ouvrir un detail.
4. Aller onglet `Admin`, se connecter.
5. Ajouter un `TacosPlace` (photo + geoloc device).

