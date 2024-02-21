> https://wjw465150.gitbooks.io/keycloak-documentation/content/server_admin/topics/export-import.html

Export script:

```bash
path/to/keycloak/bin/standalone.sh \
-Dkeycloak.migration.action=export \
-Dkeycloak.migration.provider=dir \
-Dkeycloak.migration.dir=/tmp/keycloak-export \
-Dkeycloak.migration.usersExportStrategy=SAME_FILE \
-Djboss.http.port=8888 \
-Djboss.https.port=9999 \
-Djboss.management.http.port=7777
```

Import script:

```bash
path/to/keycloak/bin/standalone.sh \
-Dkeycloak.migration.action=import \
-Dkeycloak.migration.provider=dir \
-Dkeycloak.migration.dir=/tmp/keycloak-export \
-Dkeycloak.migration.strategy=OVERWRITE_EXISTING \
-Djboss.http.port=8888 \
-Djboss.https.port=9999 \
-Djboss.management.http.port=7777
```
