package com.clientoutlook.sonar.plugins.dart.measures;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.Arrays;
import java.util.List;

import org.antlr.grammars.Dart2Lexer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.measures.CoreMetrics;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;

// Count the number of lines containing either command or commented-out code.
// Non-significant comment lines (empty comment lines, comment lines containing
// only special characters, etc.) do not increase the number of comment lines.
//
// /**                                    +0 => empty comment line
//  *                                     +0 => empty comment line
//  * This is my documentation            +1 => significant comment
//  * although I don't                    +1 => significant comment
//  * have much                           +1 => significant comment
//  * to say                              +1 => significant comment
//  *                                     +0 => empty comment line
//  ***************************           +0 => non-significant comment
//  *                                     +0 => empty comment line
//  * blabla...                           +1 => significant comment
//  */                                    +0 => empty comment line
// /**                                    +0 => empty comment line
//  * public String foo() {               +1 => commented-out code
//  *   System.out.println(message);      +1 => commented-out code
//  *   return message;                   +1 => commented-out code
//  * }                                   +1 => commented-out code
//  */        
public class DartCommentsMetric implements ITokenHandler {
	private static final Logger LOG = Loggers.get(DartCommentsMetric.class);
	private static final List<String> EMPTY_COMMENT_LINES = Arrays.asList("//", "/*", "*", "-", "=", "*/");
	private int numberOfComments;
	private Token startOfComment;

	@Override
	public void clear() {
		numberOfComments = 0;
	}

	@Override
	public void handle(Token token, TokenStream tokenStream) {
		switch (token.getType()) {
			case Dart2Lexer.SINGLE_LINE_COMMENT:
				numberOfComments += countCommentLines(tokenStream.getText(token, token));
				break;

			case Dart2Lexer.MULTI_LINE_COMMENT:
				if (startOfComment == null) {
					startOfComment = token;
				}
				break;

			default:
				checkForMultilineComment(token, tokenStream);
				break;
		}
	}

	@Override
	public void save(SensorContext context, InputFile file) {
		context.<Integer>newMeasure()
			.withValue(numberOfComments)
			.forMetric(CoreMetrics.COMMENT_LINES)
			.on(file)
			.save();
	}

	private void checkForMultilineComment(final Token token, final TokenStream tokenStream) {
		if (startOfComment != null) {
			final String comments = tokenStream.getText(startOfComment, token);
			numberOfComments += countCommentLines(comments);
			startOfComment = null;
		}
	}

	private int countCommentLines(final String comments) {
		int count = 0;
		String line;

		try (final BufferedReader reader = new BufferedReader(new StringReader(comments))) {
			while ((line = reader.readLine()) != null) {
				line = line.trim();
				for (String c : EMPTY_COMMENT_LINES) {
					line = line.replace(c, "");
				}
				if (!(line.trim().isEmpty())) {
					count++;
				}
			}
		} catch (IOException e) {
			LOG.warn("Error counting comment lines", e);
		}

		return count;
	}
}