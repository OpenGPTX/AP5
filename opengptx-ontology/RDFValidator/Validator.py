from rdflib import Graph
g = Graph()
try:
    result = g.parse("Sample.ttl", format="turtle")
    print("RDF file is valid.")
except Exception as e:
    print("Error in RDF file:", e)
