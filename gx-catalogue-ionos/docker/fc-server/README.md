# Docker image creation for federated catalog server application

In order to build the image, federated catalog server jar file needs to be present in this directory. Name it "fc-service-server-1.0.0.jar".\
Gitlab URL to [federated catalog server](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/tree/main/fc-service-server).

Required Environment variables:
- GRAPHSTORE_URI (Neo4j service URI)
```
bolt://fc-neo4j:7687
```
- SPRING_DATASOURCE_URL (Postgres database URI)
```
jdbc:postgresql://fc-postgres:5432/postgres
```
- KEYCLOAK_CREDENTIALS_SECRET
(Keycloak client's service account secret)
```
KswaP3ok8u8nFhkRnIqLCi3XmUKSVvAo
```
- GRAPHSTORE_QUERY_TIMEOUT_IN_SECONDS (Neo4j query timeout)
```
"5"
```
- DATASTORE_FILE_PATH (File path to datastore)
```
/var/lib/fc-service/filestore
```
- KEYCLOAK_AUTH_SERVER_URL (Keycloak URL)
```
http://fc-key-server-balancer-service:8080
```
- SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI (Keycloak realm URI)
```
http://fc-key-server-balancer-service:8080/realms/gaia-x
```