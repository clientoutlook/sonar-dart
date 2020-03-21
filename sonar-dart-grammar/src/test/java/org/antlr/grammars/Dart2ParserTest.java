package org.antlr.grammars;

import static org.junit.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collection;
import java.util.stream.Collectors;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeListener;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.antlr.v4.runtime.tree.TerminalNode;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

@RunWith(Parameterized.class)
public class Dart2ParserTest {
	private final Path path;

	public Dart2ParserTest(Path path) {
		this.path = path;
	}

	/**
	 * Inject the path parameter for testing
	 */
	@Parameters(name = "{0}")
	public static Collection<Path> dartFiles() throws IOException {
		return Files.walk(new File("src/test/resources").toPath())
			.filter(p -> p.toString().endsWith(".dart"))
			.collect(Collectors.toList());
	}

	@Test
	public void test() throws IOException {
		try (final InputStream inputStream = Files.newInputStream(path)) {
			final CharStream stream = CharStreams.fromStream(inputStream, StandardCharsets.UTF_8);
			final Dart2Lexer lexer = new Dart2Lexer(stream);
			final FailTestErrorListener errorListener = new FailTestErrorListener(path.getFileName().toString());
			lexer.removeErrorListeners();
			lexer.addErrorListener(errorListener);

			final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
			tokenStream.fill();

			final Dart2Parser parser = new Dart2Parser(tokenStream);
			parser.removeErrorListeners();
			parser.addErrorListener(errorListener);

			final ParseTree tree = parser.compilationUnit();
			final ParseTreeWalker walker = new ParseTreeWalker();

			// process the listeners
			final ParseTreeListener listener = new TestListener();
			walker.walk(listener, tree);
		}
	}

	private static class FailTestErrorListener extends BaseErrorListener {
		private final String filename;
		public FailTestErrorListener(String filename) {
			this.filename = filename;
		}
		@Override
		public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
			fail("file: " + filename + " line " + line + ":" + charPositionInLine + " " + msg);
		}
	}

	private static class TestListener implements ParseTreeListener {
		@Override
		public void visitErrorNode(ErrorNode node) {
			// do nothing
		}

		@Override
		public void visitTerminal(TerminalNode node) {
			// do nothing
		}

		@Override
		public void enterEveryRule(ParserRuleContext ctx) {
			// do nothing
		}

		@Override
		public void exitEveryRule(ParserRuleContext ctx) {
			// do nothing
		}
	}
}