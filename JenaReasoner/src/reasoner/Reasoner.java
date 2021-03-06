package reasoner;

import org.apache.jena.rdf.model.*;
import org.apache.jena.reasoner.rulesys.GenericRuleReasoner;
import org.apache.jena.reasoner.rulesys.Rule;
import org.apache.jena.util.FileManager;
import org.apache.log4j.varia.NullAppender;

import java.io.*;

public class Reasoner{

    
    public static void main (String args[]) {
    	//initiate Filename Variables and check command line arguments
		if(args == null || args.length < 2){
			throw new IllegalArgumentException("Please use java -jar Reasoner inputfile mappingfile");
		}
		String inputFileName = args[0];
		String mappingrulesFileName = args[1];
    	//deactivate log4j logging
    	org.apache.log4j.BasicConfigurator.configure(new NullAppender());
        // create an empty model
        Model model = ModelFactory.createDefaultModel();
        //open input Stream 
        InputStream in = FileManager.get().open( inputFileName );
        if (in == null) {
            throw new IllegalArgumentException( "File: " + inputFileName + " not found");
        }
        // read the RDF/XML file
        model.read(in, "");
        //generate Reasoner instance
        GenericRuleReasoner reasoner = new GenericRuleReasoner(Rule.rulesFromURL(
        													"file:"+mappingrulesFileName));
        //generate inferred Model
        InfModel infModel = ModelFactory.createInfModel(reasoner, model);
        infModel.prepare();
        //gather only deducted Triples
        Model deductions = infModel.getDeductionsModel();
        // write it to standard out
        deductions.write(System.out);            
    }
}