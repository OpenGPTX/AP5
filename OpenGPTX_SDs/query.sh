curl 'https://fc.opengpt-x.de/query' \
    -H "Authorization: Bearer $TOKEN" \
    -H 'content-type: application/json;charset=UTF-8' \
    -d '{"statement": "call db.labels()"}'

curl 'https://fc.opengpt-x.de/query?withTotalCount=true' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'content-type: application/json;charset=UTF-8' \
  -d '{"statement": "Match (n:ServiceOffering) where \"LLM\" in n.keyword RETURN n","parameters": {"limit": 10}}'

curl 'https://fc.opengpt-x.de/query?withTotalCount=true' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'content-type: application/json;charset=UTF-8' \
  -d '{"statement": "Match (n:ServiceOffering)-[r]->(m) where \"LLM\" in n.keyword RETURN n,r,m","parameters": {"limit": 10}}'

curl 'https://fc.opengpt-x.de/query?withTotalCount=true' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'content-type: application/json;charset=UTF-8' \
  -d '{"statement": "Match (n:ServiceOffering)-[:endpoint]-(m) where \"LLM\" in n.keyword RETURN n,m.endpointURL","parameters": {"limit": 10}}'