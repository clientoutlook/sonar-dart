package com.clientoutlook.sonar.plugins.dart.measures;

import java.util.HashSet;
import java.util.Set;

import org.antlr.grammars.Dart2Lexer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.measures.CoreMetrics;

/**
 * Count the number of physical lines that contain at least one character which is neither a whitespace nor
 * a tabulation nor part of a comment.
 */
public class DartLinesOfCodeMetric implements ITokenHandler {
	private final Set<Integer> codeLines = new HashSet<>();

	@Override
	public void clear() {
		codeLines.clear();
	}

	@Override
	public void handle(final Token token, final TokenStream tokenStream) {
		switch (token.getType()) {
			case Dart2Lexer.SINGLE_LINE_COMMENT:
			case Dart2Lexer.MULTI_LINE_COMMENT:
			case Dart2Lexer.NEWLINE:
			case Dart2Lexer.WHITESPACE:
				break;

			default:
				codeLines.add(token.getLine());
				break;
		}
	}

	@Override
	public void save(final SensorContext context, final InputFile file) {
		context.<Integer>newMeasure()
			.withValue(codeLines.size())
			.forMetric(CoreMetrics.NCLOC)
			.on(file)
			.save();
	}
}