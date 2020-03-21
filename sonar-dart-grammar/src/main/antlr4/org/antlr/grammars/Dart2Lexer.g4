/*
 * [The "BSD license"]
 *  Copyright (c) 2020 Client Outlook
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* A grammar for Dart 2 tokens */
lexer grammar Dart2Lexer;

// @lexer::header {
// import java.io.IOException;
// import java.nio.file.Files;
// import java.nio.file.Paths;
// import java.nio.file.StandardOpenOption;
// }

// @lexer::members {
//   void write(String message) {
//     try {
//       message += '\n';
//       Files.write(Paths.get("c:\\temp\\antlr-debug.log"), message.getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
//     } catch(IOException e) {
//     }
//   }
// }

// keywords
ABSTRACT:                'abstract';
AS:                      'as';
ASSERT:                  'assert';
ASYNC:                   'async';
ASYNC_STREAM:            'async*';
AWAIT:                   'await';
BREAK:                   'break';
CASE:                    'case';
CATCH:                   'catch';
CLASS:                   'class';
CONST:                   'const';
CONTINUE:                'continue';
COVARIANT:               'covariant';
DEFAULT:                 'default';
DEFERRED:                'deferred';
DYNAMIC:                 'dynamic';
DO:                      'do';
ELSE:                    'else';
ENUM:                    'enum';
EXPORT:                  'export';
EXTENDS:                 'extends';
EXTERNAL:                'external';
FACTORY:                 'factory';
FALSE:                   'false';
FUNCTION:                'Function';
FINAL:                   'final';
FINALLY:                 'finally';
FOR:                     'for';
GET:                     'get';
HIDE:                    'hide';
IF:                      'if';
IMPLEMENTS:              'implements';
IMPORT:                  'import';
IN:                      'in';
INTERFACE:               'interface';
IS:                      'is';
LIBRARY:                 'library';
MIXIN:                   'mixin';
NEW:                     'new';
NULL:                    'null';
OF:                      'of';
ON:                      'on';
OPERATOR:                'operator';
PART:                    'part';
RETHROW:                 'rethrow';
RETURN:                  'return';
SET:                     'set';
SHOW:                    'show';
STATIC:                  'static';
SUPER:                   'super';
SWITCH:                  'switch';
SYNC_STREAM:             'sync*';
THIS:                    'this';
THROW:                   'throw';
TRUE:                    'true';
TRY:                     'try';
TYPEDEF:                 'typedef';
VAR:                     'var';
VOID:                    'void';
WHILE:                   'while';
WITH:                    'with';
YIELD:                   'yield';
YIELD_EACH:              'yield*';

// symbols

OPEN_BRACE:              '{';
CLOSE_BRACE:             '}';
OPEN_PARENS:             '(';
CLOSE_PARENS:            ')';
OPEN_BRACKET:            '[';
CLOSE_BRACKET:           ']';
LT:                      '<';
GT:                      '>';
LE:                      '<=';
GE:                      '>=';
EQ:                      '==';
NE:                      '!=';
ADD:                     '+';
ADD_ASSIGNMENT:          '+=';
AND:                     '&&';
ARROW_FUNCTION:          '=>';
ASSIGNMENT:              '=';
BACKSLASH:               '\\';
BINARY_AND:              '&';
BINARY_AND_ASSIGNMENT:   '&=';
BINARY_OR:               '|';
BINARY_OR_ASSIGNMENT:    '|=';
BINARY_XOR:              '^';
BINARY_XOR_ASSIGNMENT:   '^=';
CASCADE:                 '..';
CONDITIONAL_DOT:         '?.';
COMMA:                   ',';
COLON:                   ':';
DECREMENT:               '--';
DIVIDE:                  '/';
DIVIDE_ASSIGNMENT:       '/=';
DOT:                     '.';
DOUBLE_QUOTE:            '"';
DOUBLE_QUOTE_RAW:        'r"';
HASH:                    '#';
HASH_BANG:               '#!';
INCREMENT:               '++';
META:                    '@';
MODULO:                  '%';
MODULO_ASSIGNMENT:       '%=';
MULTIPLY:                '*';
MULTIPLY_ASSIGNMENT:     '*=';
NEGATION:                '!';
NULL_COALESCE:           '??';
NULL_ASSIGNMENT:         '??=';
OR:                      '||';
SEMICOLON:               ';';
SHIFT_LEFT:              '<<';
SHIFT_LEFT_ASSIGNMENT:   '<<=';
SINGLE_QUOTE:            '\'';
SINGLE_QUOTE_RAW:        'r\'';
SPREAD:                  '...';
SPREAD_CONDITIONAL:      '...?';
SUBTRACT:                '-';
SUBTRACT_ASSIGNMENT:     '-=';
TERNARY:                 '?';
TILDE:                   '~';
TRIPLE_DOUBLE_QUOTE:     '"""';
TRIPLE_DOUBLE_QUOTE_RAW: 'r"""';
TRIPLE_SINGLE_QUOTE:     '\'\'\'';
TRIPLE_SINGLE_QUOTE_RAW: 'r\'\'\'';
TRUNCATE_DIVIDE:         '~/';
TRUNCATE_DIVIDE_ASSIGNMENT: '~/=';

WHITESPACE
  : [ \t\r\n\u000C]+ -> channel(HIDDEN)
  ;

// 16.5 Numbers
NUMBER
  : DIGIT+ ('.' DIGIT+)? EXPONENT?
  | '.' DIGIT+ EXPONENT?
  ;
fragment
EXPONENT
  : ('e' | 'E') ('+' | '-')? DIGIT+
  ;
HEX_NUMBER
  : '0x' HEX_DIGIT+
  | '0X' HEX_DIGIT+
  ;
fragment
HEX_DIGIT
  : [a-f]
  | [A-F]
  | DIGIT
  ;

// // 16.7 Strings
StringLiteral
  : (MultiLineString | SingleLineString)+
  ;

fragment
SingleLineString
  : DOUBLE_QUOTE StringContentDQ* DOUBLE_QUOTE
  | SINGLE_QUOTE StringContentSQ* SINGLE_QUOTE
  | SINGLE_QUOTE_RAW (~('\'' | '\n' | '\r'))* SINGLE_QUOTE
  | DOUBLE_QUOTE_RAW (~('"' | '\n' | '\r'))* DOUBLE_QUOTE
  ;

fragment
MultiLineString
  : TRIPLE_DOUBLE_QUOTE StringContentTDQ* TRIPLE_DOUBLE_QUOTE
  | TRIPLE_SINGLE_QUOTE StringContentTSQ* TRIPLE_SINGLE_QUOTE
  | TRIPLE_DOUBLE_QUOTE_RAW (~'"' | '"' ~'"' | '""' ~'"')* TRIPLE_DOUBLE_QUOTE
  | TRIPLE_SINGLE_QUOTE_RAW (~'\'' | '\'' ~'\'' | '\'\'' ~'\'')* TRIPLE_SINGLE_QUOTE
  ;

fragment
ESCAPE_SEQUENCE
  : '\\n'
  | '\\r'
  | '\\f'
  | '\\b'
  | '\\t'
  | '\\v'
  | '\\x' HEX_DIGIT HEX_DIGIT
  | '\\u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
  | '\\u{' HEX_DIGIT_SEQUENCE '}'
  ;

fragment
HEX_DIGIT_SEQUENCE
  : HEX_DIGIT HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT?
  ;

fragment
StringContentDQ
  : ~('\\' | '"' | '$' | '\n' | '\r')
  | BACKSLASH ~('\n' | '\r')
  | StringInterpolation
  ;

fragment
StringContentSQ
  : ~('\\' | '\'' | '$' | '\n' | '\r')
  | BACKSLASH ~('\n' | '\r')
  | StringInterpolation
  ;

fragment
StringContentTDQ
  : ~('\\' | '"' | '$')
  | '"' ~'"'
  | '""' ~'"'
  | BACKSLASH ~('\n' | '\r')
  | StringInterpolation
  ;

fragment
StringContentTSQ
  : ~('\\' | '\'' | '$')
  | '\'' ~'\''
  | '\'\'' ~'\''
  | BACKSLASH ~('\n' | '\r')
  | StringInterpolation
  ;

fragment
StringInterpolation
  : StringInterpolationExpression
  | StringInterpolationVariable
  | StringInterpolationLiteral
  ;

fragment
StringInterpolationVariable
  : '$' ~'{'
  ;

StringInterpolationExpression
  : '${' StringInterpolationContents* '}'
  ;

fragment
StringInterpolationContents
  : ~('$' | '}')
  | '$' ~'{'
  | StringInterpolation
  ;

fragment
StringInterpolationLiteral
  : '$'
  ;

NEWLINE
  : '\n'
  | '\r'
  | '\r\n'
  ;

  // 20.2 Lexical Rules
// 20.1.1 Reserved Words
//assert, break, case, catch, class, const, continue, default, do, else,
//enum, extends, false, final, finally, for, if, in, is, new, null, rethrow,
//return, super, switch, this, throw, true, try, var, void, while, with.

IDENTIFIER
  : IDENTIFIER_START IDENTIFIER_PART*
  ;

// 20.1.2 Comments
SINGLE_LINE_COMMENT
//  : '//' ~(NEWLINE)* (NEWLINE)? // Origin Syntax
  : '//' ~[\r\n]* -> channel(HIDDEN)
  ;
MULTI_LINE_COMMENT
//  : '/*' (MULTI_LINE_COMMENT | ~'*/')* '*/' // Origin Syntax
  : '/*' .*? '*/' -> channel(HIDDEN)
  ;

//BUILT_IN_IDENTIFIER
//  : 'abstract'
//  | 'as'
//  | 'covariant'
//  | 'deferred'
//  | 'dynamic'
//  | 'export'
//  | 'external'
//  | 'factory'
//  | 'Function'
//  | 'get'
//  | 'implements'
//  | 'import'
//  | 'interface'
//  | 'library'
//  | 'operator'
//  | 'mixin'
//  | 'part'
//  | 'set'
//  | 'static'
//  | 'typedef'
//  ;
fragment
IDENTIFIER_NO_DOLLAR
  : IDENTIFIER_START_NO_DOLLAR
    IDENTIFIER_PART_NO_DOLLAR*
  ;
fragment
IDENTIFIER_START
  : IDENTIFIER_START_NO_DOLLAR
  | '$'
  ;
fragment
IDENTIFIER_START_NO_DOLLAR
  : LETTER
  | '_'
  ;
fragment
IDENTIFIER_PART_NO_DOLLAR
  : IDENTIFIER_START_NO_DOLLAR
  | DIGIT
  ;
fragment
IDENTIFIER_PART
  : IDENTIFIER_START
  | DIGIT
  ;

// 20.1.1 Reserved Words
fragment
LETTER
  : [a-z]
  | [A-Z]
  ;
fragment
DIGIT
  : [0-9]
  ;
