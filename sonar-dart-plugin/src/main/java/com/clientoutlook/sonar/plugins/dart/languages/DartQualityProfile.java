package com.clientoutlook.sonar.plugins.dart.languages;

import org.sonar.api.server.profile.BuiltInQualityProfilesDefinition;

public final class DartQualityProfile implements BuiltInQualityProfilesDefinition {

	@Override
	public void define(Context context) {
		NewBuiltInQualityProfile profile = context.createBuiltInQualityProfile("Dart Rules", DartLanguage.KEY);
		profile.setDefault(true);

		profile.done();
	}
}