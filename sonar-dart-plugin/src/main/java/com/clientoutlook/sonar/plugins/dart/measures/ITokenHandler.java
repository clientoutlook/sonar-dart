package com.clientoutlook.sonar.plugins.dart.measures;

import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;

public interface ITokenHandler extends IMeasure {
	void handle(Token token, TokenStream tokenStream);
}