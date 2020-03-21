package com.clientoutlook.sonar.plugins.dart.externalreport;

import org.sonar.api.server.rule.RulesDefinition;
import org.sonarsource.analyzer.commons.ExternalRuleLoader;

public class ExternalRulesDefinition implements RulesDefinition {
	private final ExternalRuleLoader loader;
	private final String key;

	public ExternalRulesDefinition(ExternalRuleLoader loader, String key) {
		this.loader = loader;
		this.key = key;
	}

	@Override
	public void define(Context context) {
		loader.createExternalRuleRepository(context);
	}

	@Override
	public String toString() {
		return key + "-rules-definition";
	}
}