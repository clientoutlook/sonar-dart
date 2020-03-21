/*
 [The "BSD licence"]
 Copyright (c) 2020 Client Outlook
 Copyright (c) 2019 Wener
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

AB: 13-Apr-19; newExpression conflict , renamed to nayaExpression
AB: 13-Apr-19; Replaced `type` with `dtype` to fix golang code gen.
*/

// https://dart.dev/guides/language/specifications/DartLangSpec-v2.2.pdf

parser grammar Dart2Parser;

options {tokenVocab=Dart2Lexer;}

compilationUnit: libraryDefinition | partDeclaration;

// 8 Variables
// unused - see topLevelDefinition
// variableDeclaration
//   : declaredIdentifier (COMMA identifier)*
//   ;
declaredIdentifier
  : metadata COVARIANT? finalConstVarOrType identifier
  ;
finalConstVarOrType
  : FINAL dtype?
  | CONST dtype?
  | varOrType
  ;
varOrType
  : VAR
  | dtype
  ;
initializedVariableDeclaration
  : declaredIdentifier (ASSIGNMENT expression)? (COMMA initializedIdentifier)*
  ;
initializedIdentifier
  : identifier (ASSIGNMENT expression)?
  ;
initializedIdentifierList
  : initializedIdentifier (COMMA initializedIdentifier)*
  ;

// 9 Functions
functionSignature
  : metadata dtype? identifier formalParameterPart
  ;
formalParameterPart
  : typeParameters? formalParameterList
  ;
functionBody
  // making the ';' optional allows it to handle:
  // - function arguments: new Proxy("proxy", () => new Request())
  // - map literal functions: { "x" : e => create(e) } 
  : ASYNC? ARROW_FUNCTION expression SEMICOLON? // SEMICOLON optional does not match 2.2 spec
  | (ASYNC | ASYNC_STREAM | SYNC_STREAM)? block
  ;
block
  : OPEN_BRACE statements CLOSE_BRACE
  ;

// 9.2 Formal Parameters
formalParameterList
  : OPEN_PARENS CLOSE_PARENS
  | OPEN_PARENS normalFormalParameters CLOSE_PARENS
  | OPEN_PARENS normalFormalParameters (COMMA optionalFormalParameters)? CLOSE_PARENS
  | OPEN_PARENS optionalFormalParameters CLOSE_PARENS
  ;
normalFormalParameters
  : normalFormalParameter (COMMA normalFormalParameter)*
  ;
optionalFormalParameters
  : optionalPositionalFormalParameters
  | namedFormalParameters
  ;
optionalPositionalFormalParameters
  : OPEN_BRACKET defaultFormalParameter (COMMA defaultFormalParameter)* COMMA? CLOSE_BRACKET
  ;
namedFormalParameters
  : OPEN_BRACE defaultNamedParameter (COMMA defaultNamedParameter)* COMMA? CLOSE_BRACE
  ;

// 9.2.1 Required Formals
normalFormalParameter
  : functionFormalParameter
  | fieldFormalParameter
  | simpleFormalParameter
  ;
functionFormalParameter
  : metadata COVARIANT? dtype? identifier formalParameterPart
  ;
simpleFormalParameter
  : declaredIdentifier
  | metadata COVARIANT? identifier
  ;
fieldFormalParameter
  : metadata finalConstVarOrType? THIS DOT identifier formalParameterPart?
  ;

// 9.2.2 Optional Formals
defaultFormalParameter
  : normalFormalParameter (ASSIGNMENT expression)?
  ;
defaultNamedParameter
  : normalFormalParameter (ASSIGNMENT expression)?
  | normalFormalParameter (COLON expression)?
  ;

// 10 Classes
classDefinition
  : metadata ABSTRACT? CLASS identifier typeParameters?
    superclass? interfaces?
    OPEN_BRACE (metadata classMemberDefinition)* CLOSE_BRACE
  | metadata ABSTRACT? CLASS mixinApplicationClass
  ;
typeNotVoidList
  : typeNotVoid (COMMA typeNotVoid)*
  ;
classMemberDefinition
  : declaration SEMICOLON
  | methodSignature functionBody
  ;
methodSignature
  : constructorSignature initializers?
  | factoryConstructorSignature
  | STATIC? functionSignature
  | STATIC? getterSignature
  | STATIC? setterSignature
  | operatorSignature
  ;

declaration
  : constantConstructorSignature (redirection | initializers)?
  | constructorSignature (redirection | initializers)?
  | EXTERNAL constantConstructorSignature
  | EXTERNAL constructorSignature
  | (EXTERNAL STATIC?)? getterSignature
  | (EXTERNAL STATIC?)? setterSignature
  | EXTERNAL? operatorSignature
  | (EXTERNAL STATIC?)? functionSignature
  | STATIC (FINAL | CONST) dtype? staticFinalDeclarationList
  | FINAL dtype? initializedIdentifierList
  | (STATIC | COVARIANT)? varOrType initializedIdentifierList
  ;

staticFinalDeclarationList
  : staticFinalDeclaration (COMMA staticFinalDeclaration)*
  ;
staticFinalDeclaration
  : identifier ASSIGNMENT expression
  ;

// 10.1.1 Operators
operatorSignature
  : dtype? OPERATOR operator formalParameterList
  ;
operator
  : TILDE
  | binaryOperator
  | OPEN_BRACKET CLOSE_BRACKET // separate tokens to prevent collision with listLiteral
  | OPEN_BRACKET CLOSE_BRACKET ASSIGNMENT
  ;

binaryOperator
  : multiplicativeOperator
  | additiveOperator
  | shiftOperator
  | relationalOperator
  | equalityOperator
  | bitwiseOperator
  ;
// 10.2 Getters
getterSignature
  : dtype? GET identifier
  ;
// 10.2 Setters
setterSignature
  : dtype? SET identifier formalParameterList
  ;

// 10.6 Constructors
constructorSignature
  : identifier (DOT identifier)? formalParameterList
  ;
redirection
  : COLON THIS (DOT identifier)? arguments
  ;

initializers
  : COLON initializerListEntry (COMMA initializerListEntry)*
  ;
initializerListEntry
  : SUPER arguments
  | SUPER DOT identifier arguments
  | fieldInitializer
  | assertion
  ;
fieldInitializer
  : (THIS DOT)? identifier ASSIGNMENT conditionalExpression cascadeSection*
  ;

// 10.6.2 Factories
factoryConstructorSignature
  : FACTORY identifier (DOT identifier)? formalParameterList
  ;
redirectingFactoryConstructorSignature
  : CONST? FACTORY identifier (DOT identifier)? formalParameterList ASSIGNMENT
    typeNotVoid (DOT identifier)?
  ;
// 10.6.3 Constant Constructors
constantConstructorSignature: CONST qualified formalParameterList;

// 10.8 Superclasses
superclass
  : EXTENDS typeNotVoid mixins?
  | mixins
  ;
mixins
  : WITH typeNotVoidList
  ;

// 10.10 SUperinterfaces
interfaces: IMPLEMENTS typeNotVoidList;

// 12.1 Mixin Application
mixinApplicationClass
  : identifier typeParameters? ASSIGNMENT mixinApplication SEMICOLON
  ;
mixinApplication
  : typeNotVoid mixins interfaces?
  ;

// 12.2 Mixin Declaration
mixinDeclaration
  : metadata MIXIN identifier typeParameters?
    (ON typeNotVoidList)? interfaces?
    OPEN_BRACE (metadata classMemberDefinition)* CLOSE_BRACE
  ;

// 13 Enums
enumType
  : metadata ENUM identifier
    OPEN_BRACE enumEntry (COMMA enumEntry)* COMMA? CLOSE_BRACE
  ;

enumEntry
  : metadata identifier
  ;

// 14 Generics
typeParameter
  : metadata identifier (EXTENDS typeNotVoid)?
  ;
typeParameters
  : LT typeParameter (COMMA typeParameter)* GT
  ;

// 15 Metadata
metadata
  : (META qualified (DOT identifier)? arguments?)*
  ;

// 16 Expressions
expression
  : assignableExpression assignmentOperator expression
  | conditionalExpression cascadeSection*
  | throwExpression
  | StringInterpolationExpression
  ;
expressionWithoutCascade
  : assignableExpression assignmentOperator expressionWithoutCascade
  | conditionalExpression
  | throwExpressionWithoutCascade
  ;
expressionList
  : expression (COMMA expression)*
  ;
primary
  : thisExpression
  | SUPER unconditionalAssignableSelector
  | functionExpression
  | literal
  | identifier
  | nayaExpression
  | constObjectExpression
  | OPEN_PARENS expression CLOSE_PARENS
  ;

// 16.3 Constants

literal
  : nullLiteral
  | booleanLiteral
  | numericLiteral
  | StringLiteral
  | symbolLiteral
  | listLiteral
  | setOrMapLiteral  
  ;

// 16.4 Null

nullLiteral
  : NULL
  ;

// 16.5 Numbers
numericLiteral
  : NUMBER
  | HEX_NUMBER
  ;

// 16.6 Booleans
booleanLiteral
  : TRUE
  | FALSE
  ;

// 16.7 Strings - see lexer

// 16.8 Symbols
symbolLiteral
  : HASH (operator | (identifier (COMMA identifier)*))
  ;

// 16.9 Collection Literals (2.3 Draft 5)
listLiteral
  : CONST? typeArguments? OPEN_BRACKET elements? CLOSE_BRACKET
  ;

setOrMapLiteral
  : CONST? typeArguments? OPEN_BRACE elements? CLOSE_BRACE
  ;

elements
  : element (COMMA element)* COMMA?
  ;

element
  : expressionElement
  | mapElement
  | spreadElement
  | ifElement
  | forElement
  ;

expressionElement
  : expression
  ;

mapElement
  : expression COLON expression
  ;

spreadElement
  : (SPREAD | SPREAD_CONDITIONAL) expression
  ;

ifElement
  : IF OPEN_PARENS expression CLOSE_PARENS element (ELSE element)?
  ;

forElement
  : AWAIT? FOR OPEN_PARENS forLoopParts CLOSE_PARENS element
  ;

// 16.11 Sets
setLiteral
  : CONST? typeArguments?
    OPEN_BRACE expression (COMMA expression)* COMMA? CLOSE_BRACE
  ;

// 16.12 Throw
throwExpression
  : THROW expression
  ;
throwExpressionWithoutCascade
  : THROW expressionWithoutCascade
  ;

// 16.13 Function Expressions
functionExpression
  : formalParameterPart functionBody
  ;

// 16.14 This
thisExpression: THIS;

// 16.15.1 New
nayaExpression
  : NEW typeNotVoid (DOT identifier)? arguments
  ;

// 16.15.2 Const
constObjectExpression
  : CONST typeNotVoid (DOT identifier)? arguments
  ;

// 16.17.1 Actual Argument List Evaluation
arguments
  : OPEN_PARENS (argumentList COMMA?)? CLOSE_PARENS
  ;
argumentList
  : namedArgument (COMMA namedArgument)*
  | expressionList (COMMA namedArgument)*
  ;
namedArgument
  : label expression
  ;

// 16.21.2 Cascaded Invocations
cascadeSection
  : CASCADE (cascadeSelector argumentPart*)
         (assignableSelector argumentPart*)*
         (assignmentOperator expressionWithoutCascade)?
  ;
cascadeSelector
  : OPEN_BRACKET expression CLOSE_BRACKET
  | identifier
  ;
argumentPart
  : typeArguments? arguments
  ;

// // 16.23 Assignment
assignmentOperator
  : ASSIGNMENT
  | compoundAssignmentOperator
  ;

// 16.20.1 Compound Assignment
compoundAssignmentOperator
  : MULTIPLY_ASSIGNMENT
  | DIVIDE_ASSIGNMENT
  | TRUNCATE_DIVIDE_ASSIGNMENT
  | MODULO_ASSIGNMENT
  | ADD_ASSIGNMENT
  | SUBTRACT_ASSIGNMENT
  | SHIFT_LEFT_ASSIGNMENT
  | GT GT ASSIGNMENT // separate tokens to prevent collision with nested dtype (Set<Set<int>>)
  | GT GT GT ASSIGNMENT
  | BINARY_AND_ASSIGNMENT
  | BINARY_XOR_ASSIGNMENT
  | BINARY_OR_ASSIGNMENT
  | NULL_ASSIGNMENT
  ;

// 16.24 Conditional
conditionalExpression
  : ifNullExpression
    (ternaryOperator expressionWithoutCascade COLON expressionWithoutCascade)?
  ;
ternaryOperator
  : TERNARY
  ;
// 16.25 If-null Expression
ifNullExpression
  : logicalOrExpression (nullCoalescingOperator logicalOrExpression)*
  ;

nullCoalescingOperator
  : NULL_COALESCE
  ;
// 16.26 Logical Boolean Expressions
logicalOrExpression
  : logicalAndExpression (logicalOrOperator logicalAndExpression)*
  ;
logicalOrOperator
  : OR
  ;
logicalAndExpression
  : equalityExpression (logicalAndOperator equalityExpression)*
  ;
logicalAndOperator
  : AND
  ;
// 16.27 Equality
equalityExpression
  : relationalExpression (equalityOperator relationalExpression)?
  | SUPER equalityOperator relationalExpression
  ;
equalityOperator
  : EQ
  | NE
  ;

// 16.28 Relational Expressions
relationalExpression
  : bitwiseOrExpression
    (
      typeTest
      | typeCast
      | relationalOperator bitwiseOrExpression
    )?
  | SUPER relationalOperator bitwiseOrExpression
  ;
relationalOperator
  : GE
  | GT
  | LE
  | LT
  ;

// 16.29 Bitwize Expression
bitwiseOrExpression
  : bitwiseXorExpression (BINARY_OR bitwiseXorExpression)*
  | SUPER (BINARY_OR bitwiseOrExpression)+
  ;
bitwiseXorExpression
  : bitwiseAndExpression (BINARY_XOR bitwiseAndExpression)*
  | SUPER (BINARY_XOR bitwiseAndExpression)+
  ;
bitwiseAndExpression
  : shiftExpression (BINARY_AND shiftExpression)*
  | SUPER (BINARY_AND shiftExpression)+
  ;
bitwiseOperator
  : BINARY_AND
  | BINARY_XOR
  | BINARY_OR
  ;

// 16.30 Shift
shiftExpression
  : additiveExpression (shiftOperator additiveExpression)*
  | SUPER (shiftOperator additiveExpression)+
  ;
shiftOperator
  : SHIFT_LEFT
  | GT GT // separate tokens to prevent collision with nested dtype (Set<Set<int>>)
  | GT GT GT
  ;

// 16.31 Additive Expression
additiveExpression
  : multiplicativeExpression (additiveOperator multiplicativeExpression)*
  | SUPER (additiveOperator multiplicativeExpression)+
  ;
additiveOperator
  : ADD
  | SUBTRACT
  ;

// 16.32 Multiplicative Expression
multiplicativeExpression
  : unaryExpression (multiplicativeOperator unaryExpression)*
  | SUPER (multiplicativeOperator unaryExpression)+
  ;
multiplicativeOperator
  : MULTIPLY
  | DIVIDE
  | MODULO
  | TRUNCATE_DIVIDE
  ;

// 16.33 Unary Expression
unaryExpression
  : prefixOperator unaryExpression
  | awaitExpression
  | postfixExpression
  | (minusOperator | tildeOperator) SUPER
  | incrementOperator assignableExpression
  ;
prefixOperator
  : minusOperator
  | negationOperator
  | tildeOperator
  ;
minusOperator
  : SUBTRACT
  ;
negationOperator
  : NEGATION
  ;
tildeOperator
  : TILDE
  ;

// 16.34 Await Expressions
awaitExpression
  : AWAIT unaryExpression
  ;

// 16.35 Postfix Expressions
postfixExpression
  : assignableExpression postfixOperator
  | constructorInvocation selector*
  | primary selector*
  ;
postfixOperator
  : incrementOperator
  ;
constructorInvocation
  : typeName typeArguments DOT identifier arguments
  ;
selector
  : assignableSelector
  | argumentPart
  ;
incrementOperator
  : INCREMENT
  | DECREMENT
  ;

// 16.36 Assignable Expressions
// NOTE
// primary (argumentPart* assignableSelector)+ -> primary (argumentPart* assignableSelector)?
assignableExpression
  : primary assignableSelectorPart*
  | SUPER unconditionalAssignableSelector
  | constructorInvocation assignableSelectorPart+ identifier
  ;
assignableSelectorPart
  : argumentPart* assignableSelector
  ;
unconditionalAssignableSelector
  : OPEN_BRACKET expression CLOSE_BRACKET
  | DOT identifier
  ;
assignableSelector
  : unconditionalAssignableSelector
  | CONDITIONAL_DOT identifier
  ;

identifier
  : IDENTIFIER
  | keyword
  ;
keyword
  : ABSTRACT
  | AS
  | ASYNC
  | COVARIANT
  | DEFERRED
  | DYNAMIC
  | EXPORT
  | EXTERNAL
  | FACTORY
  | FUNCTION
  | GET
  | HIDE
  | IMPLEMENTS
  | IMPORT
  | INTERFACE
  | LIBRARY
  | ON
  | OPERATOR
  | MIXIN
  | PART
  | SET
  | SHOW
  | STATIC
  | TYPEDEF
  ;
qualified
  : identifier (DOT identifier)?
  ;
// 16.35 Type Test
typeTest
  : isOperator typeNotVoid
  ;
isOperator
  : IS '!'?
  ;

// 16.36 Type Cast
typeCast
  : asOperator typeNotVoid
  ;
asOperator
  : AS
  ;
// 17 Statements
statements
  : statement*
  ;
statement
  : label* nonLabledStatment
  ;
nonLabledStatment
  : block
  | localVariableDeclaration
  | forStatement
  | whileStatement
  | doStatement
  | switchStatement
  | ifStatement
  | rethrowStatment
  | tryStatement
  | breakStatement
  | continueStatement
  | returnStatement
  | yieldStatement
  | yieldEachStatement
  | expressionStatement
  | assertStatement
  | localFunctionDeclaration
  ;

// 17.2 Expression Statements
expressionStatement
  : expression? SEMICOLON
  ;

// 17.3 Local Variable Declaration
localVariableDeclaration
  : initializedVariableDeclaration SEMICOLON
  ;
// 17.4 Local Function Declaration
localFunctionDeclaration
  : functionSignature functionBody
  ;
// 17.5 If
ifStatement
  : IF OPEN_PARENS expression CLOSE_PARENS statement (ELSE statement)?
  ;

// 17.6 For for
forStatement
  : AWAIT? FOR OPEN_PARENS forLoopParts CLOSE_PARENS statement
  ;
forLoopParts
  : forInitializerStatement expression? SEMICOLON expressionList?
  | declaredIdentifier IN expression
  | identifier IN expression
  ;
forInitializerStatement
  : localVariableDeclaration
  | expression? SEMICOLON
  ;

// 17.7 While

whileStatement
  : WHILE OPEN_PARENS expression CLOSE_PARENS statement
  ;
// 17.8 Do
doStatement
  : DO statement WHILE OPEN_PARENS expression CLOSE_PARENS SEMICOLON
  ;
// 17.9 Switch
switchStatement
  : SWITCH OPEN_PARENS expression CLOSE_PARENS OPEN_BRACE switchCase* defaultCase? CLOSE_BRACE
  ;
switchCase
  : label* CASE expression COLON statements
  ;
defaultCase
  : label* DEFAULT COLON statements
  ;

// 17.10 Rethrow
rethrowStatment
  : RETHROW SEMICOLON
  ;

// 17.11 Try
tryStatement
  : TRY block (onPart+ finallyPart? | finallyPart)
  ;
onPart
  : catchPart block
  | ON typeNotVoid catchPart? block
  ;
catchPart
  : CATCH OPEN_PARENS identifier (COMMA identifier)? CLOSE_PARENS
  ;
finallyPart
  : FINALLY block
  ;

// 17.12 Return

returnStatement
  : RETURN expression? SEMICOLON
  ;

// 17.13 Labels
label
  : identifier COLON
  ;

// 17.13 Break
breakStatement
  : BREAK identifier? SEMICOLON
  ;

// 17.13 Continue
continueStatement
  : CONTINUE identifier? SEMICOLON
  ;

// 17.16.1 Yield
yieldStatement
  : YIELD expression SEMICOLON
  ;
// 17.16.1 Yield-Each
yieldEachStatement
  : YIELD_EACH expression SEMICOLON
  ;

// 17.17 Assert
assertStatement
  : assertion SEMICOLON
  ;
assertion
  : ASSERT OPEN_PARENS expression (COMMA expression )? COMMA? CLOSE_PARENS
  ;

// 18 Libraries and Scripts
topLevelDefinition
  : classDefinition
  | mixinDeclaration // not mentioned in the standard, but implied in 12.2
  | enumType
  | typeAlias
  | metadata EXTERNAL? functionSignature SEMICOLON // added metadata to support toplevel metadata
  | metadata EXTERNAL? getterSignature SEMICOLON
  | metadata EXTERNAL? setterSignature SEMICOLON
  | functionSignature functionBody
  | dtype? GET identifier functionBody
  | dtype? SET identifier formalParameterList functionBody
  | (FINAL | CONST) dtype? staticFinalDeclarationList SEMICOLON
  | initializedVariableDeclaration SEMICOLON
  ;

getOrSet
  : GET
  | SET
  ;
libraryDefinition
  : scriptTag? libraryName? importOrExport* partDirective*
    topLevelDefinition*
  ;
scriptTag
  : HASH_BANG (~NEWLINE)* NEWLINE
  ;

libraryName
  : metadata LIBRARY dottedIdentifierList SEMICOLON
  ;
importOrExport
  : libraryimport
  | libraryExport
  ;
dottedIdentifierList
  : identifier (COMMA identifier)*
  ;

libraryimport
  : metadata importSpecification
  ;

importSpecification
  : IMPORT configurableUri (AS identifier)? combinator* SEMICOLON
//  | IMPORT uri DEFERRED AS identifier combinator* SEMICOLON
  ;

combinator
  : SHOW identifierList
  | HIDE identifierList
  ;
identifierList
  : identifier (COMMA identifier)*
  ;

// 18.2 Exports
libraryExport
  : metadata EXPORT configurableUri combinator* SEMICOLON
  ;

// 18.3 Parts
partDirective
  : metadata PART uri SEMICOLON
  ;
partHeader
  : metadata PART OF identifier (DOT identifier)* SEMICOLON
  ;
partDeclaration
  : partHeader topLevelDefinition* EOF
  ;

// 18.5 URIs
uri
  : StringLiteral
  ;
configurableUri
  : uri configurationUri*
  ;
configurationUri
  : IF OPEN_PARENS uriTest CLOSE_PARENS uri
  ;
uriTest
  : dottedIdentifierList (EQ StringLiteral)?
  ;

// 19.1 Static Types
dtype
  : functionTypeTails
  | typeNotFunction functionTypeTails
  | typeNotFunction
  ;
typeNotFunction
  : typeNotVoidNotFunction
  | VOID
  ;
typeNotVoidNotFunction
  : typeName typeArguments?
  | FUNCTION
  ;
typeName
  : identifier (DOT identifier)?
  ;
typeArguments
  : LT typeList GT
  ;
typeList
  : dtype (COMMA dtype)*
  ;
typeNotVoidNotFunctionList
  : typeNotVoidNotFunction (COMMA typeNotVoidNotFunction)*
  ;
typeNotVoid
  : functionType
  | typeNotVoidNotFunction
  ;
functionType
  : functionTypeTails
  | typeNotFunction functionTypeTails
  ;
functionTypeTails
  : functionTypeTail functionTypeTails
  | functionTypeTail
  ;
functionTypeTail
  : FUNCTION typeParameters? parameterTypeList
  ;
parameterTypeList
  : OPEN_PARENS CLOSE_PARENS
  | OPEN_PARENS normalParameterTypes COMMA optionalParameterTypes CLOSE_PARENS
  | OPEN_PARENS normalParameterTypes COMMA? CLOSE_PARENS
  | OPEN_PARENS optionalParameterTypes CLOSE_PARENS
  ;
normalParameterTypes
  : normalParameterType (COMMA normalParameterType)*
  ;
normalParameterType
  : typedIdentifier
  | dtype
  ;
optionalParameterTypes
  : optionalPositionalParameterTypes
  | namedParameterTypes
  ;
optionalPositionalParameterTypes
  : OPEN_BRACKET normalParameterTypes COMMA? CLOSE_BRACKET
  ;
namedParameterTypes
  : OPEN_BRACE typedIdentifier (COMMA typedIdentifier)* COMMA? CLOSE_BRACE
  ;
typedIdentifier
  : dtype identifier
  ;

// 19.3 Type Aliases
typeAlias
  : metadata TYPEDEF identifier typeParameters? ASSIGNMENT functionType SEMICOLON
  | metadata TYPEDEF functionTypeAlias
  ;
functionTypeAlias
  : functionPrefix formalParameterPart SEMICOLON
  ;
functionPrefix
  : dtype? identifier
  ;
