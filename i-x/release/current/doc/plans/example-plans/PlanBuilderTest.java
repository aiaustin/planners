/* Author: Jeff Dalton <J.Dalton@ed.ac.uk>
 * Updated: Mon Apr  7 03:41:05 2003 by Jeff Dalton
 * Copyright: (c) 2003, AIAI, University of Edinburgh
 */

package ix.test;

import java.util.*;
import java.io.*;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.output.XMLOutputter;

import ix.icore.*;
import ix.icore.domain.*;
import ix.icore.process.state.*;
import ix.util.*;
import ix.util.xml.*;
import ix.util.lisp.*;

/**
 * Constructs a plan and outputs it in XML.  By default, it uses
 * an {@link ExamplePlanBuilder} to construct the plan, but a
 * different {@link PlanBuilder} class may be tested by giving
 * an instance to {@link #test(PlanBuilder)}.
 */
public class PlanBuilderTest {

    protected XMLOutputter out = XML.makePrettyXMLOutputter();

    public PlanBuilderTest() {
    }

    /**
     * Main program for testing.
     */
    public static void main (String[] argv) throws IOException {
	Class builderClass = 
	    Parameters.getClass("plan-builder-class",
				ExamplePlanBuilder.class);
	PlanBuilder pb = makePlanBuilder(builderClass);
	new PlanBuilderTest().test(pb);
    }

    /**
     * Makes a PlanBuilder by calling the 0-argument constuctor
     * of the specified class.
     */
    public static PlanBuilder makePlanBuilder(Class c) {
	return (PlanBuilder)Util.makeInstance(c);
    }

    /**
     * Calls {@link #makeExamplePlan(PlanBuilder)} and prints the
     * resulting plan as XML to System.out.
     *
     * @see XML#objectToDocument(Object)
     */
    public void test(PlanBuilder pb) throws IOException {
	Plan plan = makeExamplePlan(pb);
	Document doc = XML.objectToDocument(plan);
	out.output(doc, System.out);
    }

    /**
     * Constructs a simple plan containing some issues, activities,
     * constraints, and annotations.  Some of the issues have subissues,
     * and some of the activities have subactivities, to show how
     * such subitems are represented in a plan.
     */
    public Plan makeExamplePlan(PlanBuilder pb) {

	// Issues
	Issue issue1 = new Issue("why do that");
	pb.addIssue(issue1);
	pb.addSubissue(issue1, new Issue("why start"));
	pb.addSubissue(issue1, new Issue("why finish"));

	Issue issue2 = new Issue("why not");
	pb.addIssue(issue2);

	// Activities
	Activity act1 = new Activity("do something");
	pb.addActivity(act1);
	pb.addSubactivity(act1, new Activity("step one"));
	Activity act1_2 = new Activity("step two");
	pb.addSubactivity(act1, act1_2);
	pb.addSubactivity(act1_2, new Activity("step two part one"));

	Activity act2 = new Activity("do something else");
	pb.addActivity(act2);

	// Constraints
	Constraint c1 =
	    // This time we explicitly construct Symbols.
	    new Constraint(Symbol.intern("plan-validity"),
			   Symbol.intern("use-before"),
			   Lisp.list("10 Mar 2004"));
	pb.addConstraint(c1);
	Constraint c2 =
	    // This time we use a more convenient constructor that
	    // makes the Symbols for us.
	    new Constraint("plan-validity", "ix-version",
			   Lisp.list("3.0"));
	c2.setAnnotation("status", "just an example");
	pb.addConstraint(c2);

	// Annotations
	pb.setAnnotation("generated-by", getClass().getName());
	pb.setAnnotation("plan-builder-class", pb.getClass().getName());

	// Annotation containing a literal document.
	pb.setAnnotation
	    ("an example document",
	     new LiteralDocument
	         (new Element("test-element")
	              .setAttribute("test-attrib", "atrib-value")
	              .addContent(new Element("test-subelement"))));
	

	return pb.getPlan();	
    }

}
