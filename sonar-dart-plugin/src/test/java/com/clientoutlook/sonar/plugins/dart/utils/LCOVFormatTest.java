package com.clientoutlook.sonar.plugins.dart.utils;

import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.expectLastCall;
import static org.easymock.EasyMock.isA;

import java.io.File;

import org.easymock.EasyMockSupport;
import org.junit.Before;
import org.junit.Test;
import org.sonar.api.batch.fs.FilePredicate;
import org.sonar.api.batch.fs.FilePredicates;
import org.sonar.api.batch.fs.FileSystem;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.coverage.NewCoverage;

public class LCOVFormatTest {
	private EasyMockSupport easyMockSupport;

	@Before
	public void before() {
		easyMockSupport = new EasyMockSupport();
	}

	@Test
	public void applyCoverage_withValidReport_appliesCoverageCorrectly() {
		// test setup
		final NewCoverage newCoverage = easyMockSupport.createStrictMock(NewCoverage.class);
		expect(newCoverage.onFile(isA(InputFile.class))).andReturn(newCoverage);
		expect(newCoverage.lineHits(1, 1)).andReturn(newCoverage);
		expect(newCoverage.lineHits(2, 1)).andReturn(newCoverage);
		expect(newCoverage.lineHits(3, 0)).andReturn(newCoverage);
		expect(newCoverage.conditions(2, 1, 0)).andReturn(newCoverage);
		expect(newCoverage.conditions(2, 2, 0)).andReturn(newCoverage);
		expect(newCoverage.conditions(2, 2, 1)).andReturn(newCoverage);
		expect(newCoverage.conditions(2, 3, 0)).andReturn(newCoverage);
		newCoverage.save();
		expectLastCall();
		final SensorContext context = createSensorContext(newCoverage);
		easyMockSupport.replayAll();

		// test
		final LCOVFormat format = new LCOVFormat(context);
		File lcov = getResourceFile("coverage/report1.lcov");
		format.applyCoverage(lcov);
		easyMockSupport.verifyAll();
	}

	@Test
	public void applyCoverage_withUnknownFile_coverageIsNotApplied() {
		File lcov = getResourceFile("coverage/report1.lcov");
		final SensorContext context = createSensorContextForMissingFile();
		easyMockSupport.replayAll();

		// test
		final LCOVFormat format = new LCOVFormat(context);
		format.applyCoverage(lcov);
		easyMockSupport.verifyAll();
	}

	@Test(expected = IllegalArgumentException.class)
	public void applyCoverage_withNullFile_ThrowsException() {
		new LCOVFormat(null).applyCoverage(null);
	}

	private SensorContext createSensorContext(NewCoverage newCoverage) {
		final FilePredicate filePredicate = easyMockSupport.createMock(FilePredicate.class);
		final FilePredicates filePredicates = easyMockSupport.createMock(FilePredicates.class);
		expect(filePredicates.hasPath(isA(String.class))).andReturn(filePredicate);

		final InputFile inputFile = easyMockSupport.createMock(InputFile.class);

		final FileSystem fileSystem = easyMockSupport.createMock(FileSystem.class);
		expect(fileSystem.predicates()).andReturn(filePredicates);
		expect(fileSystem.inputFile(filePredicate)).andReturn(inputFile);

		final SensorContext sensorContext = easyMockSupport.createMock(SensorContext.class);
		expect(sensorContext.fileSystem()).andReturn(fileSystem).times(2);
		expect(sensorContext.newCoverage()).andReturn(newCoverage);

		return sensorContext;
	}

	private SensorContext createSensorContextForMissingFile() {
		final FilePredicate filePredicate = easyMockSupport.createMock(FilePredicate.class);
		final FilePredicates filePredicates = easyMockSupport.createMock(FilePredicates.class);
		expect(filePredicates.hasPath(isA(String.class))).andReturn(filePredicate);

		final FileSystem fileSystem = easyMockSupport.createMock(FileSystem.class);
		expect(fileSystem.predicates()).andReturn(filePredicates);
		expect(fileSystem.inputFile(filePredicate)).andReturn(null);

		final SensorContext sensorContext = easyMockSupport.createMock(SensorContext.class);
		expect(sensorContext.fileSystem()).andReturn(fileSystem).times(2);

		return sensorContext;
	}

	private static File getResourceFile(String resourcePath) {
		final ClassLoader classLoader = LCOVFormatTest.class.getClassLoader();
		return new File(classLoader.getResource(resourcePath).getFile());
	}
}