# Cloakman

DDBJ account management system built with Rails 8.1 and Ruby 4.0. Manages user accounts stored in OpenLDAP, with Keycloak as the identity provider (IdP).

## Architecture

- **No ActiveRecord models for users** — `User` and `Reader` inherit from `LDAPEntry`, a custom ActiveModel-based class that reads/writes directly to OpenLDAP via `net-ldap`.
- **Keycloak** for authentication (via OmniAuth OpenID Connect). Cloakman is a Keycloak client (`cloakman`).
- **Two LDAP directories**: an internal OpenLDAP (`LDAP`) for account data, and an external NIG LDAP (`ExtLDAP`) for cross-referencing and syncing (`User::ExtLDAPSync`).
- **SQLite** for the Rails app database (Solid Cache, Solid Queue). User data lives in LDAP, not SQLite.
- **Redis** for UID number sequence generation.

## Development

```sh
bin/setup     # Install deps, prepare DB, start dev server
bin/dev       # Start all services (Rails, dartsass, Keycloak, OpenLDAP, ext-OpenLDAP, Mailpit)
```

`bin/dev` runs `Procfile.dev`, which starts the supporting services with `docker compose -f compose.dev.yaml up`. Requires Docker.

Environment variables for development are managed in `.mise.toml`.

## Testing

```sh
bin/rails test          # Unit and controller tests
bin/rails test:system   # System tests (Chrome)
bin/ci                  # Full CI: rubocop, brakeman, importmap audit, tests, seed check
```

CI requires OpenLDAP, ext-OpenLDAP, and Redis services (see `.github/workflows/ci.yml`).

## Linting

```sh
bin/rubocop
```

Uses `rubocop-rails-omakase` with overrides in `.rubocop.yml`:
- Single quotes for strings
- No space inside array/hash brackets
- Space inside block braces, no space before block parameters

## Deployment

Deployed with **Kamal** to staging and production. Always requires a destination:

```sh
bin/kamal deploy -d staging
bin/kamal deploy -d production
```

- Deploy config: `config/deploy.yml` (common), `config/deploy.staging.yml`, `config/deploy.production.yml`
- Secrets: `.kamal/secrets-common` — all secrets are read via `bin/rails credentials:fetch` with `$KAMAL_DESTINATION`
- Accessories: Keycloak, Keycloak-Postgres, OpenLDAP, Redis

### Credentials

Per-environment encrypted credentials in `config/credentials/{staging,production}.yml.enc`. Keys in `.key` files (gitignored).

```sh
bin/rails credentials:edit -e staging
bin/rails credentials:edit -e production
bin/rails credentials:fetch <dotted.path> -e <environment>
```

## Key models

- `LDAPEntry` — Base class implementing ActiveModel-compatible CRUD over LDAP
- `User` — LDAP user entry (`ddbjUser` objectClass). Maps ~30 LDAP attributes. Status managed via `inetUserStatus` (active/inactive/deleted)
- `Reader` — LDAP reader entry for service accounts
- `ApiKey` — ActiveRecord model for API authentication

## Routes

- `/` — Landing page
- `/auth/:provider/callback` — Keycloak SSO callback
- `/account/new` — Sign up
- `/profile/edit` — Edit profile
- `/password/edit` — Change password
- `/ssh_keys` — Manage SSH keys
- `/admin/users` — Admin user management (requires ddbj/nbdc account type)
- `/admin/readers` — Admin reader management
- `/admin/api_keys` — Admin API key management
- `/api/users` — API for user creation
