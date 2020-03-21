package com.clientoutlook.sonar.plugins.dart.utils;

import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.coverage.NewCoverage;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;

public class LCOVFormat {
	private static final Logger log = Loggers.get(LoggingErrorListener.class);
	private static final String SF = "SF:";
	private static final String DA = "DA:";
	private static final String BRDA = "BRDA:";
	private final SensorContext context;

	public LCOVFormat(final SensorContext context) {
		this.context = context;
	}

	public void applyCoverage(final File file) {
		if (file == null || !file.exists()) {
			throw new IllegalArgumentException("The given file does not exist");
		}
		try (Coverage coverage = new Coverage(context); Stream<String> lines = Files.lines(file.toPath())) {
			for (String line : lines.collect(Collectors.toList())) {
				applyLine(line, coverage);
			}
		} catch (IOException e) {
			log.error(String.format("Error reading content from LCOV file: %s", file.getAbsolutePath()), e);
		}
	}

	private void applyLine(final String line, final Coverage coverage) {
		if (line.startsWith(SF)) {
			coverage.setFile(parseSourceFile(line));
		} else if (coverage.active()) {
			if (line.startsWith(DA)) {
				applyLineCoverage(line, coverage);
			} else if (line.startsWith(BRDA)) {
				applyBranchCoverage(line, coverage);
			}
		}
	}

	/**
	 * Parse the Source File (SF) from the LCOV line:
	 *
	 * <p>
	 * SF:<absolute path to the source file>
	 * </p>
	 */
	private InputFile parseSourceFile(final String line) {
		final String path = line.substring(SF.length());
		final InputFile inputFile = context.fileSystem().inputFile(context.fileSystem().predicates().hasPath(path));
		if (inputFile == null) {
			log.debug("Could not resolve file path in LCOV file: {}", path);
		}
		return inputFile;
	}

	/**
	 * Apply the coverage provided by the LCOV line:
	 *
	 * <p>
	 * DA:<line number>,<execution count>[,<checksum>]
	 * </p>
	 */
	private void applyLineCoverage(final String line, final Coverage coverage) {
		try {
			final String[] tokens = line.substring(DA.length()).split(",");
			final int lineNumber = Integer.parseInt(tokens[0]);
			final int executionCount = Integer.parseInt(tokens[1]);
			coverage.lineHits(lineNumber, executionCount);
		} catch (Exception e) {
			log.error("error parsing line coverage from LCOV line: {}", line);
			log.error("parsing error", e);
		}
	}

	/**
	 * Apply the branch coverage provided by the LCOV line:
	 *
	 * <p>
	 * BRDA:<line number>,<block number>,<branch number>,<taken>
	 * </p>
	 * @param line The line of text
	 */
	private void applyBranchCoverage(final String line, final Coverage coverage) {
		try {
			final String[] tokens = line.substring(BRDA.length()).split(",");
			final int lineNumber = Integer.parseInt(tokens[0]);
			final int blockNumber = Integer.parseInt(tokens[1]);
			final int branchNumber = Integer.parseInt(tokens[2]);
			final int taken = "-".equals(tokens[3]) ? 0 : Integer.parseInt(tokens[3]);
			coverage.conditions(lineNumber, blockNumber + branchNumber, taken);
		} catch (Exception e) {
			log.error("error parsing branch coverage from LCOV line: {}", line);
			log.error("parsing error", e);
		}
	}

	private static final class Coverage implements Closeable {
		private final SensorContext context;
		private NewCoverage newCoverage;

		public Coverage(final SensorContext context) {
			this.context = context;
		}

		public void setFile(final InputFile inputFile) {
			applyCoverage();
			newCoverage = inputFile != null 
				? context.newCoverage().onFile(inputFile)
				: null;
		}

		public boolean active() {
			return newCoverage != null;
		}

		public void lineHits(int line, int hits) {
			newCoverage = newCoverage.lineHits(line, hits);
		}

		public void conditions(int line, int conditions, int coveredConditions) {
			newCoverage = newCoverage.conditions(line, conditions, coveredConditions);
		}

		@Override
		public void close() throws IOException {
			applyCoverage();
		}

		private void applyCoverage() {
			if (newCoverage != null) {
				newCoverage.save();
			}
		}
	}
}