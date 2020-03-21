package com.clientoutlook.sonar.plugins.dart.externalreport;

import java.io.File;
import java.util.List;

import com.clientoutlook.sonar.plugins.dart.utils.LCOVFormat;

import org.sonar.api.batch.sensor.Sensor;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.SensorDescriptor;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;
import org.sonarsource.analyzer.commons.ExternalReportProvider;

public class DartCoverageSensor implements Sensor {
	public static final String REPORT_KEY = "sonar.dart.lcov.reportPaths";
	private static final Logger LOG = Loggers.get(DartCoverageSensor.class);

	@Override
	public void describe(SensorDescriptor descriptor) {
		descriptor
			.onlyWhenConfiguration(conf -> conf.hasKey(REPORT_KEY))
			.name("Dart Coverage");
	}

	@Override
	public void execute(SensorContext context) {
		final List<File> files = ExternalReportProvider.getReportFiles(context, REPORT_KEY);
		if (files.isEmpty()) {
			LOG.warn("No coverage information will be saved because all LCOV files cannot be found.");
			return;
		}

		final LCOVFormat lcovFormat = new LCOVFormat(context);
		for (File file : files) {
			if (file.exists()) {
				lcovFormat.applyCoverage(file);
			} else {
				LOG.warn("LCOV file not found: {}", file);
			}
		}
	}
}