package reasoner;

import org.apache.jena.rdf.model.*;
import org.apache.jena.reasoner.rulesys.GenericRuleReasoner;
import org.apache.jena.reasoner.rulesys.Rule;
import org.apache.jena.util.FileManager;
import org.apache.log4j.varia.NullAppender;

import java.io.*;

public class Reasoner{

    static final String inputFileName  = "answer.xml";
    
    public static void main (String args[]) {
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
        GenericRuleReasoner reasoner = new GenericRuleReasoner(Rule.rulesFromURL("file:mappingrules"));
        //generate inferred Model
        InfModel infModel = ModelFactory.createInfModel(reasoner, model);
        infModel.prepare();
        Model deductions = infModel.getDeductionsModel();
        // write it to standard out
        deductions.write(System.out);            
    }
}