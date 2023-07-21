## Docker images
### Github workflow

Everytime there is an update in the ```main``` branch of the repository, Github workflow is started. This workflow will build and push the new images to the Github organization registry(ghcr.io). It will give each image two tags - ```latest``` and last commit SHA.

### For automatic build and push to docker registry

It is required to have these environment variables set:
- REGISTRY_HOST (docker registry's hostname)
- DESIRED_TAG (tag for the new images)
- TOKEN_USERNAME (docker registry token's username parameter)
- TOKEN_PASSWORD (docker registry token's password parameter)

and these packages available:
- mvn
- docker
- git

Tested with:
- Apache Maven 3.6.0
- openjdk 11.0.9
- git 2.20.1
- Docker 20.10.21

It may or it may not work with other versions of the packages.

If you have these variables set and these packages available you can run the script ```build_and_push.sh``` from the `federated-catalogue/docker` directory. After the script is done you will have the images push to the docker registry. The created images are using the code from this commit ```bfbd93db0a5547ef0e136ed4149139f0a11bcffa```.

### Verify image

Images that are pushed to github repository are signed. It is required for you to have ```cosign``` package available. You can verify the sign with this command:
```sh
# install cosign package
go install github.com/sigstore/cosign/v2/cmd/cosign@v2.0.0

# verify the images
cd ../
cosign verify --key ./federated-catalogue/docker/image.pub ghcr.io/digital-ecosystems/fc-server:latest
cosign verify --key ./federated-catalogue/docker/image.pub ghcr.io/digital-ecosystems/demo-portal:latest
```

### For manual build and push to docker registry

In order to build the images for demo-portal should execute this command in the `federated-catalogue/docker/demo-portal` directory:
```
docker build . -t gaiax.cr.de-fra.ionos.com/demo-portal:<desired tag>
```
\
In order to build the images for fc-server should execute this command in the `federated-catalogue/docker/fc-server` directory:
```
docker build . -t gaiax.cr.de-fra.ionos.com/fc-server:<desired tag>
```

For more information regarding the images you should read the README files in the application directories.

In order to push the images to the docker regitry you will need an "docker registry token" with "push" permissions. Before pushing the image you should first build it. After building the image you should authenticate to the registry with this command (it will promt you to enter the token's password.):
```
docker login -u <token username> gaiax.cr.de-fra.ionos.com
```
After authenticating to the registry this command will push it to the registry:
```
docker push gaiax.cr.de-fra.ionos.com/<desired image>:<desired tag>
```

***
