#!/bin/bash

TOKEN=$(./fc_login.sh -u $FC_USER -p $FC_PASSWORD -s $FC_CLIENT_SECRET $FC_URI)

echo "SIGNING SELF DESCRIPTION"
java -jar fc-tools-signer-1.3.0-full.jar m=did:web:opengpt-x.de prk=$SIGNER_PRK sd=./ELG_RESOURCE_SD.jsonld ssd=./ELG_RESOURCE_SD_signed.jsonld
echo

echo "VERIFYING SELF DESCRIPTION"
r=$(
    curl -s -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d @./signed.jsonld \
        https://fc.opengpt-x.de/verification?verifySemantics=true&verifySchema=true&verifySignatures=true
)
echo $r | jq -r .
echo

echo "PUBLISHING SELF DESCRIPTION"
r=$(
    curl -s -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d @./signed.jsonld \
        https://fc.opengpt-x.de/self-descriptions
)
echo $r | jq -r .