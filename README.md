# Sonar Dart Plugin

A Dart SonarQube plugin compatible with SonarQube 8.x.

This plugin relies on the output of the [dartanalyzer](https://dart.dev/tools/dartanalyzer) for the generation of SonarQube issues.  Please refer to the configuration key `sonar.dart.analyzer`.

## Requirements
* SonarQube 8.x
* A Dart 2.x code base

### Installing

Copy the jar file downloaded from the [Releases](https://github.com/ClientOutlook/sonar-dart/releases) to the `extensions/plugins` folder of your SonarQube server, and restart SonarQube.

### Building and Deploying

* Ensure you meet the following development dependencies:
  * Java 11+
  * Apache Maven 3.x
* Run ```mvn clean install```
* Copy the jar file from `sonar-dart-plugin/target` to the SonarQube `extensions/plugins` folder
* Restart the SonarQube server

## Configuration

### Example project configuration
This is an example project configuration file (`sonar-project.properties`):
```
sonar.host.url=http://sonar:9000
sonar.login=<my key>
sonar.projectKey=company:my-application
sonar.projectName=My Application
sonar.projectVersion=1.0
sonar.sourceEncoding=UTF-8
sonar.inclusions=**/lib/src/**
sonar.exclusions=**/.dart_tool/**,**/*.g.dart,**/*.reflectable.dart
sonar.dart.analyzer=dartanalyzer.out
sonar.dart.lcov.reportPaths=lcov.out
```
* See [SonarQube's Analysis Parameters](https://docs.sonarqube.org/latest/analysis/analysis-parameters/) documentation for general configuration options.
* See [SonarQube's Narrowing the Focus](https://docs.sonarqube.org/latest/project-administration/narrowing-the-focus/) documentation for filtering which files get analyzed.

### Plugin Configuration

<table>
<thead>
<tr><th>Key</th><th>Description</th></thead>
</thead>
<tbody>
<tr>
<td>sonar.dart.analyzer</td>
<td>Path to the collected output of [dartanalyzer](https://dart.dev/tools/dartanalyzer). It must be run with --format=machine. For example:
<pre>dartanalyzer --lints --format=machine --packages=.packages . 2>dartanalyzer.out</pre>
</td>
</tr>
<tr>
<td>sonar.dart.lcov.reportPaths</td>
<td>A comma separated list of dart test coverage data formatted with [coverage:format_coverage](https://pub.dev/packages/coverage). For example:
<pre>pub run test --coverage coverage && pub run coverage:format_coverage --packages=.packages -i coverage --lcov --out=lcov.out</pre>
</td>
</tr>
</tbody>
</table>

## License

Copyright 2020 Client Outlook

Licensed under [The 3-Clause BSD License](https://opensource.org/licenses/BSD-3-Clause)