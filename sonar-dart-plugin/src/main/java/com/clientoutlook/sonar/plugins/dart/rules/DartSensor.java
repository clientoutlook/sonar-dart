package com.clientoutlook.sonar.plugins.dart.rules;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import com.clientoutlook.sonar.plugins.dart.languages.DartLanguage;
import com.clientoutlook.sonar.plugins.dart.measures.DartClassMeasure;
import com.clientoutlook.sonar.plugins.dart.measures.DartCommentsMetric;
import com.clientoutlook.sonar.plugins.dart.measures.DartLinesOfCodeMetric;
import com.clientoutlook.sonar.plugins.dart.measures.IMeasure;
import com.clientoutlook.sonar.plugins.dart.measures.IMeasureListener;
import com.clientoutlook.sonar.plugins.dart.measures.ITokenHandler;
import com.clientoutlook.sonar.plugins.dart.utils.LoggingErrorListener;

import org.antlr.grammars.Dart2Lexer;
import org.antlr.grammars.Dart2Parser;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.sonar.api.batch.fs.FilePredicates;
import org.sonar.api.batch.fs.FileSystem;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.fs.InputFile.Type;
import org.sonar.api.batch.sensor.Sensor;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.SensorDescriptor;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;

public class DartSensor implements Sensor {
	private static final Logger LOG = Loggers.get(DartSensor.class);
	private final List<ITokenHandler> tokenHandlers;
	private final List<IMeasureListener> listeners;
	private final List<IMeasure> measures;

	public DartSensor() {
		this.tokenHandlers = Arrays.asList(
			new DartCommentsMetric(),
			new DartLinesOfCodeMetric()
		);
		this.listeners = Arrays.asList(
			new DartClassMeasure()
		);
		this.measures = Stream
			.concat(tokenHandlers.stream(), listeners.stream())
			.collect(Collectors.toList());
	}

	@Override
	public void describe(SensorDescriptor descriptor) {
		descriptor
			.onlyOnLanguage(DartLanguage.KEY)
			.name(this.getClass().getSimpleName())
			.onlyOnFileType(Type.MAIN);
	}

	@Override
	public void execute(SensorContext context) {
		final FileSystem fileSystem = context.fileSystem();
		final Charset encoding = context.fileSystem().encoding();
		final FilePredicates p = fileSystem.predicates();
		final Iterable<InputFile> files = fileSystem.inputFiles(
			p.and(
				p.hasLanguage(DartLanguage.KEY),
				p.hasType(InputFile.Type.MAIN)
			)
		);
		computeMetrics(context, files, encoding);
	}

	private void computeMetrics(final SensorContext context, final Iterable<InputFile> inputFiles, final Charset encoding) {
		for (InputFile file : inputFiles) {
			measures.forEach((measure) -> measure.clear());
			try (final InputStream inputStream = file.inputStream()) {
				final CharStream stream = CharStreams.fromStream(inputStream, encoding);
				final Dart2Lexer lexer = new Dart2Lexer(stream);

				// remove error: line 10:16 token recognition error at: ''\r'
				lexer.removeErrorListeners();

				final CommonTokenStream tokenStream = new CommonTokenStream(lexer);
				tokenStream.fill();

				processTokenHandlers(tokenStream);
				processListeners(tokenStream, file.filename());
			} catch (IOException e) {
				LOG.error("Error reading file: " + file.filename(), e);
			} finally {
				measures.forEach((measure) -> measure.save(context, file));
			}
		}
	}

	private void processTokenHandlers(final CommonTokenStream tokenStream) throws IOException {
		for (Token token : tokenStream.getTokens()) {
			for (ITokenHandler handler : tokenHandlers) {
				handler.handle(token, tokenStream);
			}
		}
	}

	private void processListeners(final CommonTokenStream tokenStream, final String filename) throws IOException {
		final Dart2Parser parser = new Dart2Parser(tokenStream);
		parser.removeErrorListeners();
		parser.addErrorListener(new LoggingErrorListener(filename));

		final ParseTree tree = parser.compilationUnit();
		final ParseTreeWalker walker = new ParseTreeWalker();

		// process the listeners
		listeners.forEach((listener) -> walker.walk(listener, tree));
	}
}