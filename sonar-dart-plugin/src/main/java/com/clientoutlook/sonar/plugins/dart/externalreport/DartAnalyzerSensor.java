package com.clientoutlook.sonar.plugins.dart.externalreport;

import java.io.File;
import java.util.List;

import com.clientoutlook.sonar.plugins.dart.languages.DartLanguage;

import org.sonar.api.batch.sensor.Sensor;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.SensorDescriptor;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;
import org.sonarsource.analyzer.commons.ExternalReportProvider;
import org.sonarsource.analyzer.commons.ExternalRuleLoader;

public class DartAnalyzerSensor implements Sensor {
	private static final Logger LOG = Loggers.get(DartAnalyzerSensor.class);
	public static final String REPORT_KEY = "sonar.dart.analyzer";
	public static final String LINTER_KEY = "dartanalyzer";
	public static final String LINTER_NAME = "Dart Analyzer";
	public static final ExternalRuleLoader RULE_LOADER = new ExternalRuleLoader(
		LINTER_KEY,
		LINTER_NAME,
		"com/clientoutlook/sonar/dart/rules/analyzer/rules.json",
		DartLanguage.KEY);

	@Override
	public void describe(SensorDescriptor descriptor) {
		descriptor
			.onlyWhenConfiguration(conf -> conf.hasKey(REPORT_KEY))
			.name("Import of Dart Analyzer issues");
	}

	@Override
	public void execute(SensorContext context) {
		final List<File> analyzerFiles = ExternalReportProvider.getReportFiles(context, REPORT_KEY);
		for (File file : analyzerFiles) {
			if (file.exists()) {
				importReport(context, file);
			} else {
				LOG.warn("{} report not found: {}", LINTER_NAME, file);
			}
		}
	}

	private void importReport(SensorContext context, File file) {
		final DartAnalyzerReader reader = new DartAnalyzerReader();
		try {
			LOG.info("Importing {}", file);
			reader.read(context, file, RULE_LOADER);
		} catch (Exception e) {
			LOG.error("Failed to import external issues from dart analyzer: " + file.getAbsolutePath(), e);
		}
	}
}