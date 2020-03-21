package com.clientoutlook.sonar.plugins.dart;

import com.clientoutlook.sonar.plugins.dart.externalreport.DartAnalyzerSensor;
import com.clientoutlook.sonar.plugins.dart.externalreport.DartCoverageSensor;
import com.clientoutlook.sonar.plugins.dart.externalreport.ExternalRulesDefinition;
import com.clientoutlook.sonar.plugins.dart.languages.DartLanguage;
import com.clientoutlook.sonar.plugins.dart.languages.DartQualityProfile;
import com.clientoutlook.sonar.plugins.dart.rules.DartSensor;

import org.sonar.api.Plugin;
import org.sonar.api.config.PropertyDefinition;
import org.sonar.api.resources.Qualifiers;
import org.sonar.api.utils.Version;

public class DartPlugin implements Plugin {

	@Override
	public void define(Context context) {
		context.addExtensions(
			DartLanguage.class,
			DartQualityProfile.class,
			DartSensor.class,
			DartAnalyzerSensor.class,
			DartCoverageSensor.class
		);

		boolean externalIssuesSupported = context.getSonarQubeVersion().isGreaterThanOrEqual(Version.create(7,2));
		if (externalIssuesSupported) {
			context.addExtension(new ExternalRulesDefinition(DartAnalyzerSensor.RULE_LOADER, DartAnalyzerSensor.LINTER_KEY));
			context.addExtension(PropertyDefinition.builder(DartAnalyzerSensor.REPORT_KEY)
				.name("Dart Analyzer Output")
				.description("The dart analyzer output with --format=machine.")
				.category("External Analyzers")
				.subCategory(DartLanguage.NAME)
				.onQualifiers(Qualifiers.PROJECT)
				.multiValues(true)
				.build()
			);

			context.addExtension(PropertyDefinition.builder(DartCoverageSensor.REPORT_KEY)
				.name("LCOV Files")
				.description("Paths (absolute or relative) to the files with LCOV data.")
				.category("External Analyzers")
				.subCategory("Tests and Coverage")
				.onQualifiers(Qualifiers.PROJECT)
				.multiValues(true)
				.build()
			);
		}
	}
}