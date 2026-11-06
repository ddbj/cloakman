# Cloakman

DDBJ account management system built with Rails 8.1 and Ruby 4.0. Manages user accounts stored in OpenLDAP, with Keycloak as the identity provider (IdP).

## Architecture

- **No ActiveRecord models for users** — `User` and `Reader` inherit from `LDAPEntry`, a custom ActiveModel-based class that reads/writes directly to OpenLDAP via `net-ldap`.
- **Keycloak** for authentication (via OmniAuth OpenID Connect). Cloakman is a Keycloak client (`cloakman`).
- **Two LDAP directories**: an internal OpenLDAP (`LDAP`) for account data, and an external NIG LDAP (`ExtLDAP`) for cross-referencing and syncing (`User::ExtLDAPSync`).
- **PostgreSQL** for the Rails app database (API keys, Solid Cache, Solid Queue). User data lives in LDAP, not PostgreSQL.
- **Redis** for UID number sequence generation.

## Development

```sh
bin/setup     # Install deps, prepare DB, start dev server
bin/dev       # Start all services (Rails, dartsass, Keycloak, OpenLDAP, ext-OpenLDAP, Mailpit)
```

`bin/dev` runs `Procfile.dev`, which starts the supporting services with `docker compose -f compose.dev.yaml up`. Requires Docker, plus PostgreSQL and Redis running locally.

Environment variables for development are managed in `.mise.toml`.

## Testing

```sh
bin/rails test          # Unit and controller tests
bin/rails test:system   # System tests (Chrome)
bin/ci                  # Full CI: rubocop, brakeman, importmap audit, tests, seed check
```

CI requires OpenLDAP, ext-OpenLDAP, PostgreSQL, and Redis services (see `.github/workflows/ci.yml`).

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
- Accessories: Keycloak, Keycloak-Postgres, OpenLDAP, Postgres, Redis
- Persistent data lives on Lustre (under `~/volumes/`), because local disks are tied to the physical host and the VM can move between hosts

### Postgres

The `postgres` accessory needs its data directory before the first boot. `kamal deploy` doesn't boot accessories:

```sh
ssh w3const@<host> mkdir -p volumes/cloakman-<env>/postgres
bin/kamal accessory boot postgres -d <env>
```

The data directory is mounted so that postgres won't start if it's missing.

`BackupDatabaseJob` dumps the primary database to `~/volumes/cloakman-<env>/storage/backups` every night and keeps 30 days. To restore, stop the app and run this on the host:

```sh
docker exec -i cloakman-postgres pg_restore -U postgres -d cloakman --clean --if-exists --single-transaction --exit-on-error < <dump>
```

`--clean` leaves tables created after the dump. If the dump predates a migration, recreate the database first.

### After a host reboot

Lustre isn't mounted automatically, so Docker can start containers before it's available. They can then run on empty local directories and look healthy: Keycloak without its clients, OpenLDAP without its users, Redis with a reset UID counter. Anything written in that state becomes invisible once Lustre is mounted, so avoid creating users until this is done. `/up` doesn't detect any of this.

Once Lustre is mounted, run this on the host:

```sh
mountpoint /lustre9/open
docker restart cloakman-keycloak-postgres cloakman-postgres cloakman-openldap cloakman-redis
docker restart cloakman-keycloak kamal-proxy
docker restart $(docker ps --all --quiet --latest --filter label=service=cloakman --filter label=role=web)
```

Then check that the data is back and that sign-in works:

```sh
docker exec cloakman-keycloak-postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "select count(*) from client"'
docker exec cloakman-postgres psql -U postgres -d cloakman -c 'select count(*) from api_keys'
```

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
- `APIKey` — ActiveRecord model for API authentication

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
