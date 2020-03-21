package com.clientoutlook.sonar.plugins.dart.utils;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;

public final class LoggingErrorListener extends BaseErrorListener {
	private static final Logger log = Loggers.get(LoggingErrorListener.class);
	private final String filename;

	public LoggingErrorListener(String filename) {
		this.filename = filename;
	}

	@Override
	public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
		log.error("file: " + filename + " line " + line + ":" + charPositionInLine + " " + msg);
	}
}