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

def query(token, statement, parameters=None):
    if not parameters:
        parameters = dict()
        parameters['limit'] = 100

    headers = {
        'Authorization': f'Bearer {token["access_token"]}',
        'accept': 'application/json',
        'Content-Type': 'application/json',
    }
    data = {'parameters': parameters, 'statement': statement}
    print(data)
    response = requests.post('https://fc.opengpt-x.de/query?withTotalCount=true', json=data, headers=headers)
    response.raise_for_status()
    
    return response.json()

def preset_callback(s):
    st.session_state.user_input = s

QUERY_LLMs_OFFERING = """Match (n:ServiceOffering)-[:endpoint]-(m)
where \"LLM\" in n.keyword
RETURN n.name,m.endpointURL"""

with st.sidebar:
    st.button("Query Software Offering", on_click=preset_callback, args=("Match (n:SoftwareOffering) RETURN n",))
    st.button("Query Service Offering", on_click=preset_callback, args=("Match (n:ServiceOffering) RETURN n",))
    st.button("Query LLMs Offering", on_click=preset_callback, args=(QUERY_LLMs_OFFERING,))
        

form = st.form("my_form")
output = st.container()

def query_callback(statement):
    token = get_token()
    try:
        d = query(token, statement)
        with output:
            st.json(d)
    except requests.exceptions.HTTPError as e:
        st.write(e.response.content)


with form:
    st.write("Inside the form")
    user_intput = st.text_area("Query", """Match (n:ServiceOffering) RETURN n""", key="user_input")

    submitted = st.form_submit_button("Query")
    if submitted:
        query_callback(user_intput)