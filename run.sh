#!bin/bash
##read in variables
# Transform long options to short ones
for arg in "$@"; do
    shift
    case "$arg" in
        "--reasoner") set -- "$@" "-r" ;;
        "--input") set -- "$@" "-i" ;;
        "--mapping") set -- "$@" "-m" ;;
        "--parser") set -- "$@" "-p" ;;
        "--verbose") set -- "$@" "-v" ;;
        *)        set -- "$@" "$arg"
    esac
done
# Default behavior
verbose=false
# Parse short options
OPTIND=1
while getopts ":r:i:m:p:v" opt
do
    case "$opt" in
        "r") reasoner=$OPTARG ;;
        "i") input=$OPTARG ;;
        "m") mapping=$OPTARG ;;
        "p") parser=$OPTARG ;;
        "v") verbose=true ;;
        "?") exit 1 ;;
    esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters
##validate variables to catch errors
if [ -z "$reasoner" -o -z "$input" -o -z "$mapping" -o -z "$parser" ]
    then
        echo -e "One or more of the required arguments is missing \nplease use     run.sh
              --input [ldif input file] 
              --reasoner [/path/to/reasoner.jar] 
              --mapping [mappingfile] 
              --parser [/path/to/pythonParser]
              optional: --verbose"
        exit 1
fi
##checking input
if [ $verbose == true ]
    then
        echo "Verbose mode, starting work"
        echo "checking input files for existence"
fi
#is is a regular file, readable and not empty
if [ ! -f $reasoner -o ! -r $reasoner -o ! -s $reasoner ]
    then
        echo "$reasoner could not be found"
        exit 1;
fi
if [ ! -f $mapping -o ! -r $mapping -o ! -s $mapping ]
    then
        echo "$mapping could not be found"
        exit 1;
fi
if [ ! -f $parser -o ! -r $parser -o ! -s $parser ]
    then
        echo "$parser could not be found"
        exit 1;
fi
#parsing ldif to n3 with python parser
if [ $verbose == true ]
    then 
        echo "Parsing your ldif File to n3 with Python"
fi
#function to generate temporary files
tempfile() {
    tempprefix=$(basename "$0")
    mktemp /tmp/${tempprefix}.XXXXXX
}
parsingResult=$(tempfile)
eval python $parser $input > $parsingResult
if [ $verbose == true ]
    then
        n3=`cat $parsingResult`
        echo "Parser answer:"
        echo "$n3"
fi
##using rapper to save as rdf/xml
if [ $verbose == true ]
    then
        echo "using rapper to save the result as rdf/xml"
fi
parsingResultXML=$(tempfile)
if [ $verbose == true ]
    then
        eval rapper -i turtle -o rdfxml $parsingResult > $parsingResultXML
        rdfxml=`cat $parsingResultXML`
        echo "Rapper answer:"
        echo "$rdfxml"
    else
        eval rapper -q -i turtle -o rdfxml $parsingResult > $parsingResultXML
fi
##mapping n3 to ontowiki Usergraph
if [ $verbose == true ]
    then
        echo "Mapping the parsed File to Ontowiki Usergraph"
fi
mappedGraph=$(tempfile)
eval java -jar $reasoner $parsingResultXML $mapping > $mappedGraph
finalResult=`cat $mappedGraph`
if [ $verbose == true ]
    then
        echo "got a final Result from Jena Reasoner"        
fi
echo "$finalResult"
