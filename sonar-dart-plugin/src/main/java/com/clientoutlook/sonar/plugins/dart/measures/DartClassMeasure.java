package com.clientoutlook.sonar.plugins.dart.measures;

import org.antlr.grammars.Dart2Parser.CatchPartContext;
import org.antlr.grammars.Dart2Parser.ClassDefinitionContext;
import org.antlr.grammars.Dart2Parser.ConstructorSignatureContext;
import org.antlr.grammars.Dart2Parser.DefaultCaseContext;
import org.antlr.grammars.Dart2Parser.DoStatementContext;
import org.antlr.grammars.Dart2Parser.ForStatementContext;
import org.antlr.grammars.Dart2Parser.FunctionSignatureContext;
import org.antlr.grammars.Dart2Parser.GetterSignatureContext;
import org.antlr.grammars.Dart2Parser.IfStatementContext;
import org.antlr.grammars.Dart2Parser.LogicalAndOperatorContext;
import org.antlr.grammars.Dart2Parser.LogicalOrOperatorContext;
import org.antlr.grammars.Dart2Parser.NullCoalescingOperatorContext;
import org.antlr.grammars.Dart2Parser.SetterSignatureContext;
import org.antlr.grammars.Dart2Parser.SwitchCaseContext;
import org.antlr.grammars.Dart2Parser.TernaryOperatorContext;
import org.antlr.grammars.Dart2Parser.ThrowExpressionContext;
import org.antlr.grammars.Dart2Parser.ThrowExpressionWithoutCascadeContext;
import org.antlr.grammars.Dart2Parser.WhileStatementContext;
import org.antlr.grammars.Dart2ParserBaseListener;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.measures.CoreMetrics;

/**
 * The Cyclomatic Complexity calculated based on the number of paths through the code. Whenever
 * the control flow of a function splits, the complexity counter gets incremented by one. Each
 * function has a minimum complexity of 1. This calculation varies slightly by language because
 * keywords and functionalities do.
 * 
 * Javascript:
 * Complexity is incremented by one for each: function (i.e non-abstract and non-anonymous constructors,
 * functions, procedures or methods), if, short-circuit (AKA lazy) logical conjunction (&amp;&amp;), short-circuit
 * (AKA lazy) logical disjunction (||), ternary conditional expressions, loop, case clause of a switch
 * statement, throw and catch statement.
 */
public class DartClassMeasure extends Dart2ParserBaseListener implements IMeasureListener {
	private int numberOfClasses;
	private int numberOfFunctions;
	private int cyclomaticComplexity;

	@Override
	public void clear() {
		numberOfClasses = 0;
		numberOfFunctions = 0;
		cyclomaticComplexity = 0;
	}

	@Override
	public void enterClassDefinition(ClassDefinitionContext ctx) {
		numberOfClasses++;
	}

	@Override
	public void enterConstructorSignature(ConstructorSignatureContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterFunctionSignature(FunctionSignatureContext ctx) {
		numberOfFunctions++;
		cyclomaticComplexity++;
	}

	@Override
	public void enterGetterSignature(GetterSignatureContext ctx) {
		numberOfFunctions++;
		cyclomaticComplexity++;
	}

	@Override
	public void enterSetterSignature(SetterSignatureContext ctx) {
		numberOfFunctions++;
		cyclomaticComplexity++;
	}

	// Conditionals

	@Override
	public void enterIfStatement(IfStatementContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterSwitchCase(SwitchCaseContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterDefaultCase(DefaultCaseContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterLogicalAndOperator(LogicalAndOperatorContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterLogicalOrOperator(LogicalOrOperatorContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterNullCoalescingOperator(NullCoalescingOperatorContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterTernaryOperator(TernaryOperatorContext ctx) {
		cyclomaticComplexity++;
	}

	// Loops

	@Override
	public void enterDoStatement(DoStatementContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterForStatement(ForStatementContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterWhileStatement(WhileStatementContext ctx) {
		cyclomaticComplexity++;
	}

	// exceptions

	@Override
	public void enterCatchPart(CatchPartContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterThrowExpression(ThrowExpressionContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void enterThrowExpressionWithoutCascade(ThrowExpressionWithoutCascadeContext ctx) {
		cyclomaticComplexity++;
	}

	@Override
	public void save(SensorContext context, InputFile file) {
		context.<Integer>newMeasure()
			.withValue(numberOfClasses)
			.forMetric(CoreMetrics.CLASSES)
			.on(file)
			.save();

		context.<Integer>newMeasure()
			.withValue(numberOfFunctions)
			.forMetric(CoreMetrics.FUNCTIONS)
			.on(file)
			.save();

		context.<Integer>newMeasure()
			.withValue(cyclomaticComplexity)
			.forMetric(CoreMetrics.COMPLEXITY)
			.on(file)
			.save();
	}
}