package com.clientoutlook.sonar.plugins.dart.languages;

import org.sonar.api.config.Configuration;
import org.sonar.api.resources.AbstractLanguage;

public class DartLanguage extends AbstractLanguage {
	public static final String KEY = "dart";
	public static final String NAME = "Dart";

	private static final String[] SUFFIXES = new String[] { "dart" };

	public DartLanguage(Configuration configuration) {
		super(KEY, NAME);
	}

	@Override
	public String[] getFileSuffixes() {
		return SUFFIXES;
	}
}