import streamlit as st
import requests
import pandas as pd

from keycloak import KeycloakOpenID


keycloak_openid = KeycloakOpenID(
    server_url=st.secrets.keycloak["url"],
    client_id=st.secrets.keycloak["client_id"],
    realm_name=st.secrets.keycloak["realm"],
    client_secret_key=st.secrets.keycloak["client_secret"]
)
config_well_known = keycloak_openid.well_known()

def get_token():
    return keycloak_openid.token(st.secrets.keycloak["user"], st.secrets.keycloak["password"])

def get_selfdescriptions():
    token = get_token()
    headers = {
        'Authorization': f'Bearer {token["access_token"]}',
        'accept': 'application/json',
        'Content-Type': 'application/json',
    }
    response = requests.get('https://fc.opengpt-x.de/self-descriptions', headers=headers)
    payload = response.json()

    self_descriptions = payload["items"]
    return self_descriptions

def get_sd(sdhash):
    token = get_token()
    headers = {
        'Authorization': f'Bearer {token["access_token"]}',
        'accept': 'application/json',
        'Content-Type': 'application/json',
    }
    response = requests.get('https://fc.opengpt-x.de/self-descriptions/' + sdhash, headers=headers)
    payload = response.json()
    vc = payload["verifiableCredential"][0]
    cs = vc["credentialSubject"]
    sd = {
        "issuer": vc["issuer"],
        "issuanceDate": vc["issuanceDate"],
        "id": cs["@id"],
        "type": cs["@type"],
        "name": cs["gax-trust-framework:name"],
        "description": cs["dct:description"],
        "keyword": cs["dcat:keyword"],
        "landingPage": cs["dcat:landingPage"]["@id"],
    }
    return sd

def get_sds(sds):
    elements = []
    for x in sds:
        try:
            el = get_sd(x['meta']['sdHash'])
            elements.append(el)
        except Exception as e:
            print(e)
    return elements


self_descriptions = get_selfdescriptions()
df = pd.DataFrame.from_dict(get_sds(self_descriptions))

st.dataframe(df[["name", "type", "issuer", "issuanceDate", "landingPage"]].drop_duplicates(subset="landingPage", ignore_index=True))