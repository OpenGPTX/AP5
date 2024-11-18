import json
import time

import streamlit as st

H = 68 * (2**3)
MAPPING = {
    "OPENGPTX_PARTICIPANT": {},
    "TEUKEN": {},
}
with open("files/OPENGPTX_PARTICIPANT_SD.jsonld", "r") as f:
    MAPPING["OPENGPTX_PARTICIPANT"]["sd"] = f.read()
with open("files/OPENGPTX_PARTICIPANT_SD_signed.jsonld", "r") as f:
    MAPPING["OPENGPTX_PARTICIPANT"]["signed"] = f.read()
with open("files/OPENGPTX_PARTICIPANT_SD_response.json", "r") as f:
    MAPPING["OPENGPTX_PARTICIPANT"]["response"] = json.load(f)

with open("files/OpenGPT-X-24EU-4T-Instruct-TEUKEN-chat_SD.jsonld", "r") as f:
    MAPPING["TEUKEN"]["sd"] = f.read()
with open("files/OpenGPT-X-24EU-4T-Instruct-TEUKEN-chat_SD_signed.jsonld", "r") as f:
    MAPPING["TEUKEN"]["signed"] = f.read()
with open("files/OpenGPT-X-24EU-4T-Instruct-TEUKEN-chat_SD_response.json", "r") as f:
    MAPPING["TEUKEN"]["response"] = json.load(f)

if "key" not in st.session_state:
    st.session_state["key"] = ""
if "sd" not in st.session_state:
    st.session_state["sd"] = ""
if "sd_signed" not in st.session_state:
    st.session_state["sd_signed"] = ""


def preset_callback(s):
    st.session_state["key"] = s
    st.session_state["sd"] = MAPPING[s]["sd"]
    st.session_state["sd_signed"] = ""
    # st.session_state.user_input = st.session_state["sd"]


with st.sidebar:
    st.button(
        "OpenGPT-X Participant",
        on_click=preset_callback,
        args=("OPENGPTX_PARTICIPANT",),
    )
    st.button(
        "Teuken ServiceOffering",
        on_click=preset_callback,
        args=("TEUKEN",),
    )

st.html(
    """
<style>
[data-testid="stSidebarContent"] {
    background-color: #6360b1;
}
</style>
"""
)

st.logo(
    "images/logo.svg",
    size="large",
)

form = st.form("my_form")

with form:
    st.write("Self Description Signer")

    sd_container = st.container()
    with sd_container:
        user_intput = st.text_area(
            "Self Description", value=st.session_state["sd"], key="user_input", height=H
        )
        submitted = st.form_submit_button("Sign Self Description")

    signed_container = st.container()
    with signed_container:
        signed_bloc = st.text_area(
            "Signed Self Description",
            value=st.session_state["sd_signed"],
            key="signed_bloc",
            height=H,
        )
        sent = st.form_submit_button("Send")

    if submitted:
        st.session_state["sd_signed"] = MAPPING[st.session_state["key"]]["signed"]
        st.rerun()

    if sent:
        with st.spinner("Wait for it..."):
            time.sleep(3)
            st.write(MAPPING[st.session_state["key"]]["response"])
