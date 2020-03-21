package com.clientoutlook.sonar.plugins.dart.externalreport;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import org.sonar.api.batch.fs.FilePredicates;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.fs.TextPointer;
import org.sonar.api.batch.fs.TextRange;
import org.sonar.api.batch.rule.Severity;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.issue.NewExternalIssue;
import org.sonar.api.batch.sensor.issue.NewIssueLocation;
import org.sonar.api.rules.RuleType;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;
import org.sonarsource.analyzer.commons.ExternalRuleLoader;

/**
 * Expected format:
 * 
 * INFO|HINT|UNUSED_LOCAL_VARIABLE|c:\\src\\dev\\eunity\\eunityDart\\eunityViewer\\lib\\src\\components\\side_panels\\patient_worklist_study_pill_component.dart|87|17|11|The value of the local variable 'compareMode' isn't used.
 */
public class DartAnalyzerReader {
	private static final Logger LOG = Loggers.get(DartAnalyzerSensor.class);
	private static final Map<String, Severity> SEVERITY = severity();
	private static final Map<Severity, RuleType> RULETYPE = ruletype();

	public void read(SensorContext context, File file, ExternalRuleLoader ruleLoader) throws IOException {
		try (final BufferedReader reader = new BufferedReader(new FileReader(file))) {
			String line;
			int lineNumber = 1;
			while ((line = reader.readLine()) != null) {
				lineNumber++;
				try {
					createIssue(context, file, line.split("\\|"));
				} catch (Exception e) {
					LOG.warn("Error parsing line {} of file {}", lineNumber, file);
				}
			}
		}
	}

	private void createIssue(final SensorContext context, final File file, final String[] tokens) {
		final FilePredicates predicates = context.fileSystem().predicates();
		final String filename = tokens[3].replace("\\\\", "/");
		final InputFile inputFile = context.fileSystem().inputFile(predicates.hasPath(filename));
		if (inputFile == null) {
			// This becomes very tedious due to exclusions...
			//LOG.warn("No input file found for {}. No Dart analyzer issue will be imported on this file.", filename);
			return;
		}

		final TextRange textRange = getRange(inputFile, tokens);
		final Severity severity = SEVERITY.get(tokens[0]);

		final NewExternalIssue issue = context.newExternalIssue()
			.engineId(DartAnalyzerSensor.LINTER_KEY)
			.ruleId(tokens[2])
			.type(RULETYPE.get(severity))
			.severity(severity)
			.remediationEffortMinutes(2L);
		
		final NewIssueLocation location = issue.newLocation()
			.on(inputFile)
			.at(textRange)
			.message(tokens[7]);

		issue.at(location).save();
	}

	private TextRange getRange(final InputFile inputFile, final String[] tokens) {
		final int lineNumber = Integer.parseInt(tokens[4]);
		final int startPos = Math.max(Integer.parseInt(tokens[5]) - 1, 0);
		final int length = Integer.parseInt(tokens[6]);

		try {
			final TextPointer start = inputFile.newPointer(lineNumber, startPos);
			return getTextRange(inputFile, start, length);
		} catch (IllegalArgumentException e) {
			LOG.warn("Error with range given by dartanalyzer for file {} - using the whole line instead", inputFile);
			return inputFile.selectLine(lineNumber);
		}
	}

	private TextRange getTextRange(final InputFile inputFile, final TextPointer start, final int length) {
		try (final InputStream inputStream = new BufferedInputStream(inputFile.inputStream())) {
			int line = 1;
			int offset = 0;
			int remainingLength = -1;
			int value;
			while ((value = inputStream.read()) != -1) {
				if (value == '\n') {
					line++;
					offset = 0;
				} else {
					offset++;
				}

				if (remainingLength > 0) {
					if (--remainingLength == 0) {
						return inputFile.newRange(start, inputFile.newPointer(line, offset));
					}
				} else if (start.line() == line && start.lineOffset() == offset) {
					remainingLength = length;
				}
			}
		} catch (IOException e) {
			LOG.warn("Error with range given by dartanalyzer for file {} - using the whole line instead", inputFile);
		}

		return inputFile.selectLine(start.line());
	}

	private static Map<String, Severity> severity() {
		final Map<String, Severity> map = new HashMap<>();
		map.put("ERROR", Severity.MAJOR);
		map.put("WARNING", Severity.MINOR);
		map.put("INFO", Severity.INFO);
		return map;
	}

	private static Map<Severity, RuleType> ruletype() {
		final Map<Severity, RuleType> map = new HashMap<>();
		map.put(Severity.INFO, RuleType.CODE_SMELL);
		map.put(Severity.MAJOR, RuleType.BUG);
		map.put(Severity.MINOR, RuleType.BUG);
		return map;
	}
}