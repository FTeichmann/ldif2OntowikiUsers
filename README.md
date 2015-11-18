Parser for ldif->rdf to Import into Jena
===

This project uses the ldif parser from  
https://github.com/linkeddata/swap
to generate RDF (n3) out of ldif user data.

The triples are then expanded by a given ruleset to fit into the AKSW Ontowiki usergraph.
The Apache Jena Java API and the GenericRuleReasoner is used for this expansion.
All Materials for Jena can be found under https://jena.apache.org .
Java8 is needed to run Apache Jena.
