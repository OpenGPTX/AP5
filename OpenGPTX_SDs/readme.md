```
source .config/.env
TOKEN=$(./fc_login.sh -u $FC_USER -p $FC_PASSWORD -s $FC_CLIENT_SECRET $FC_URI)
```


```
java -jar fc-tools-signer-1.3.0-full.jar m=did:web:opengpt-x.de prk=$SIGNER_PRK sd=./OpenGPT-X-24EU-4T-Instruct-TEUKEN-chat_SD2.jsonld ssd=./signed.jsonld
```


```
r=$(curl -s -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d @./signed.jsonld \
    https://fc.opengpt-x.de/self-descriptions
)
echo $r | jq -r .
```


```
r=$(curl -s -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    https://fc.opengpt-x.de/self-descriptions/3206fa3bbc28460a1a90fc259f5d525716b83ef6cac59cb7b927c60f0e0c22f1
)
echo $r | jq -r 
```


```
r=$(             
    curl -s -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        https://fc.opengpt-x.de/self-descriptions
)
echo $r | jq -r . > text.json
```

```
curl -X "DELETE" -H "Authorization: Bearer $TOKEN"     -H "Content-Type: application/json"     https://fc.opengpt-x.de/self-descriptions/
```