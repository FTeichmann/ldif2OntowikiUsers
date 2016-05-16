Parser for ldif->rdf to import into OntowikiUsers Graph
===

This project uses the ldif parser from
https://github.com/linkeddata/swap
to generate RDF (n3) out of ldif user data.

The triples are then expanded by a given ruleset to fit into the AKSW Ontowiki usergraph.

The Apache Jena Java API and the GenericRuleReasoner is used for this expansion.

All Materials for Jena can be found under https://jena.apache.org .

Java8 is needed to run Apache Jena.


Run
===
To run this program, simply use run.sh
```
run.sh
    --input [ldif input file] 
    --reasoner [/path/to/reasoner.jar] 
    --mapping [mappingfile] 
    --parser [/path/to/pythonParser]
    optional: --verbose"
```

Cronjob
===

To enable an user data update routine, fill in config.tpl and
```
mv config.tpl config.php
```
See cron.php for details.
