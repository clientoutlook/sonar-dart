package com.clientoutlook.sonar.plugins.dart.measures;

import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.sensor.SensorContext;

public interface IMeasure {
	void clear();
	void save(SensorContext context, InputFile file);
}