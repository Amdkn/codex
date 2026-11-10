# aspace-codex-adapter

Contrat A'Space pour le fork `Amdkn/codex` (gel `27fcd7c`, Apache-2.0).
Seul code A'Space du fork : le code amont est byte-identique au gel (D-N048 H-M2).

## Construire le binaire

```sh
cd codex-rs
cargo build --locked -p codex-cli   # Rust 1.95.0 (rust-toolchain.toml)
# binaire : codex-rs/target/debug/codex
```

## Surface exposée (contrat seul, §1.5)

Sous-commandes qui parlent seulement, toujours avec les overrides
télémétrie et une maison scratch :

```sh
export CODEX_HOME="$(mktemp -d)"
export OTEL_SDK_DISABLED=1
codex -c analytics.enabled=false -c feedback.enabled=false --version
codex -c analytics.enabled=false -c feedback.enabled=false --help
codex -c analytics.enabled=false -c feedback.enabled=false exec --help
```

## Jamais

- `codex exec` / `review` (appel modèle), `login` / `logout` (auth),
  `update`, `app-server` / `exec-server`, `fork` (session interactive).
- Aucun appel réseau : les commandes exposées passent en namespace sans
  interface (`unshare -n`, vérifié par le smoke test).
- Aucune configuration d'exporteur OTLP ; variables `OTEL_*` démontées.

## Télémétrie

Voir `codex-TELEMETRY-AUDIT.md` (domicile V5) : analytics premier parti
vers le backend ChatGPT (ON par défaut pour le CLI), coupés par
`-c analytics.enabled=false` ; Sentry limité au feedback explicite
(jamais invoqué), coupé par `-c feedback.enabled=false` ; OTEL sans
exporteur par défaut ; zéro SDK tiers.

## Vérification

```sh
bash aspace-codex-adapter/smoke_test.sh [chemin-du-binaire]
```

## Règles maison

- Tout changement de commit gelé exige un amendement de design (D5),
  jamais un fast-forward silencieux.
- La racine `CLAUDE.md` amont n'est PAS éditée (H-M2).
