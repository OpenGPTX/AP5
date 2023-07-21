# Docker image creation for demo-portal application

In order to build the image, demo portal jar file needs to be present in this directory. Name it "demo-portal-1.0.0.jar".\
Gitlab URL to [demo-portal](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/tree/main/demo-portal).

Required Environment variables:
- FEDERATED_CATALOGUE_BASE_URI (Federated catalogue base URI)
```
http://fc-service:8081
```
- SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_KEYCLOAK_ISSUER_URI (Keycloak realm URI)
```
http://fc-key-server-balancer-service:8080/realms/gaia-x
```
- SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_FC_CLIENT_OIDC_CLIENT_SECRET
(Keycloak client's service account secret)
```
KswaP3ok8u8nFhkRnIqLCi3XmUKSVvAo
```