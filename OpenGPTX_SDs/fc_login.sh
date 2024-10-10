#!/bin/bash

# Parse arguments
usage() {
    echo "Login to federated catalogue and get authentication token."
    echo "Usage: $0 [-h] [-p PASSWORD] [-u USERNAME] [<fc-key-server>]"
    echo "  -h  Help. Display this message and quit."
    echo "  -p  Specify login password PASSWORD."
    echo "  -u  Specify login username USERNAME."
    echo "  -s  Specify client secret SECRET."
    echo "  <fc-key-server> uri to the federated catalogue server."
    exit
}

optspec="hp:u:s:"
while getopts "$optspec" optchar
do
    case "${optchar}" in
        h)
            usage
            ;;
        p)
            password=${OPTARG}
            ;;
        u)
            username=${OPTARG}
            ;;
        s)
            secret=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [  -z "${1}" ]; then
    echo -e "Missing mandatory argument <fc-key-server>"
    exit 1
fi
uri=$1

if [  -z "${username}" ]; then
    read -p "Username: " username
fi

if [  -z "${password}" ]; then
    read -s -p "Password: " password
    echo
fi

if [  -z "${secret}" ]; then
    read -s -p "Secret: " secret
    echo
fi

ACCESS_TOKEN=$(
    curl -s \
    -d "client_id=federated-catalogue" \
    -d "client_secret=${secret}" \
    -d "username=${username}" \
    -d "password=${password}" \
    -d "grant_type=password" \
    "http://${uri}/realms/gaia-x/protocol/openid-connect/token" | jq '.access_token' | tr -d '"'
)
echo $ACCESS_TOKEN