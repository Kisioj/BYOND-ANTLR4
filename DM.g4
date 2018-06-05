grammar DM;

/*
antlr4 DM.g4 -o gen
javac gen/DM*.java
cd gen
grun DM startRule ../testfile.dm -gui
cd ..
*/

@lexer::members {
  // A queue where extra tokens are pushed on (see the NEWLINE lexer rule).
  private java.util.LinkedList<Token> tokens = new java.util.LinkedList<>();
  // The stack that keeps track of the indentation level.
  private java.util.Stack<Integer> indents = new java.util.Stack<>();
  // The amount of opened braces, brackets and parenthesis.
  private int opened = 0;

  @Override
  public void emit(Token token) {
    //System.out.println("emit: " + token);
    super.setToken(token);
    tokens.offer(token);
  }

 @Override
  public Token nextToken() {
    // Check if the end-of-file is ahead and there are still some DEDENTS expected.
    if (_input.LA(1) == EOF && !this.indents.isEmpty()) {
      // Remove any trailing EOF tokens from our buffer.
      for (int i = tokens.size() - 1; i >= 0; i--) {
        if (tokens.get(i).getType() == EOF) {
          tokens.remove(i);
        }
      }

      CommonToken ct = commonToken(DMParser.NEWLINE);
      ct.setText("<NEWLINE>");
      this.emit(ct);
      while (!indents.isEmpty()) {
        ct = commonToken(DMParser.DEDENT);
        ct.setText("<DEDENT>");
        this.emit(ct);

        indents.pop();
      }
      this.emit(commonToken(DMParser.EOF));
    }

    Token next = super.nextToken();
    return tokens.isEmpty() ? next : tokens.poll();
  }

  private CommonToken commonToken(int type, String text, int start) {
    int stop = start + text.length() - 1;
    return new CommonToken(this._tokenFactorySourcePair, type, DEFAULT_TOKEN_CHANNEL, start, stop);
  }

  private CommonToken commonToken(int type) {
    int start =  this.getCharIndex();
    int stop = start - 1;
    CommonToken token = new CommonToken(this._tokenFactorySourcePair, type, DEFAULT_TOKEN_CHANNEL, start, stop);
    return token;
  }

  boolean atStartOfInput() {
    return super.getCharPositionInLine() == 0 && super.getLine() == 1;
  }
}

//tokens { INDENT, DEDENT }  // if usinbg this, grun shows token name as <23> instead of <INDENT>
INDENT: ('DUPAJASIA1'|'JASIADUPA1');
DEDENT: ('DUPAJASIA2'|'JASIADUPA2');


NEWLINE
 : ( {atStartOfInput()}?   SPACES
   | ( '\r'? '\n' | '\r' | '\f' ) SPACES?
   )
   {
     String newLine = getText().replaceAll("[^\r\n\f]+", "");
     String spaces = getText().replaceAll("[\r\n\f]+", "");
     CommonToken ct;

     int next = _input.LA(1);
     if (opened > 0 || next == '\r' || next == '\n' || next == '\f') {
       skip();
     } else if (next == '/' ) {
        next = _input.LA(2);
        if (next == '/' || next == '*') {
            skip();
        }
     }
     else {
       int startIndex = this._tokenStartCharIndex;
       int startIndexSpaces = startIndex + newLine.length();

       ct = commonToken(DMParser.NEWLINE, newLine, startIndex);
       ct.setLine(this._tokenStartLine);
       ct.setCharPositionInLine(this._tokenStartCharPositionInLine);
       ct.setText("<NEWLINE>");
       emit(ct);

       int indent = spaces.length();
       int previous = indents.isEmpty() ? 0 : indents.peek();
       if (indent == previous) {
         skip();
       }
       else if (indent > previous) {
         for(int i=0; i < (indent-previous); ++i) {
           indents.push(indent);
           ct = commonToken(DMParser.INDENT, spaces, startIndexSpaces);
           ct.setText("<INDENT>");
           ct.setCharPositionInLine(0);
           emit(ct);
         }
       }
       else {
         for(int i=0; i < (previous-indent); ++i) {
           ct = commonToken(DMParser.DEDENT, spaces, startIndexSpaces);
           ct.setText("<DEDENT>");
           ct.setCharPositionInLine(0);
           emit(ct);
           indents.pop();
         }
       }
     }
   }
 ;


/* BYOND reserved keywords */
SWITCH : 'switch';
IF : 'if';
ELSE : 'else';
FOR : 'for';
WHILE : 'while';
DO : 'do';
BREAK : 'break';
CONTINUE : 'continue';
IN : 'in';

VAR : 'var';
CONST : 'const';

DEL : 'del';
RETURN : 'return';
SET : 'set';
TO : 'to';
AS : 'as';
GOTO : 'goto';
NEW : 'new';
SPAWN : 'spawn';

TRY : 'try';
CATCH : 'catch';

/* BYOND not reserved keywords (for this grammar they will be reserved) */
VERB : 'verb';
PROC : 'proc';

GLOBAL : 'global';
STATIC : 'static';
ARG : 'arg';
TMP : 'tmp';

/* built-in functions*/
//INPUT : 'input';


/*  */
OPEN_BRACK : '[' {opened++;};
CLOSE_BRACK : ']' {opened--;};
OPEN_PAREN : '(' {opened++;};
CLOSE_PAREN : ')' {opened--;};
DOT : '.';
COMMA : ',';
STAR : '*';
PERCENT : '%';
SLASH : '/';
fragment BACKSLASH : '\\';
COLON : ':';
QUESTION_MARK : '?';

NOT_OP : '~';
NEG_OP : '!';
MINUS : '-';
PLUS : '+';
INCREMENT : '++';
DECREMENT : '--';

POWER : '**';

LESS_THAN : '<';
GREATER_THAN : '>';
LESS_THAN_OR_EQUAL : '<=';
GREATER_THAN_OR_EQUAL : '>=';

SHIFT_LEFT : '<<';
SHIFT_RIGHT : '>>';

EQUAL : '==';
NOT_EQUAL : '!=';
NOT_EQUAL_2 : '<>';

BIT_AND : '&' ;
BIT_OR : '|';
BIT_XOR : '^' ;

LOG_AND : '&&';
LOG_OR : '||';

ASSIGN : '=';
ADD_ASSIGN : '+=';
SUB_ASSIGN : '-=';
MULT_ASSIGN : '*=';
DIV_ASSIGN : '/=';
MOD_ASSIGN : '%=';
BIT_AND_ASSIGN : '&=';
BIT_OR_ASSIGN : '|=';
XOR_ASSIGN : '^=';
LEFT_SHIFT_ASSIGN : '<<=';
RIGHT_SHIFT_ASSIGN : '>>=';


/* other */

SEMICOLON : ';';

IDENTIFIER: [_a-zA-Z][_a-zA-Z0-9]*;

STRING_LITERAL : SHORT_STRING | LONG_STRING;
ICON_PATH : '\'' (~["\\\r\n\f])* '\'';

fragment SHORT_STRING : '"' ( STRING_ESCAPE_SEQ | ~[\\\r\n\f"] )* '"';
fragment LONG_STRING :  '{"' LONG_STRING_ITEM*? '"}';

fragment LONG_STRING_ITEM
 : LONG_STRING_CHAR
 | STRING_ESCAPE_SEQ
 ;

fragment LONG_STRING_CHAR
 : ~'\\'
 ;

fragment STRING_ESCAPE_SEQ
 : '\\' .
 | '\\' NEWLINE
 ;

NUMBER
 : INTEGER
 | FLOAT_NUMBER
 ;

INTEGER
 : DECIMAL_INTEGER
 | HEX_INTEGER
 ;

DECIMAL_INTEGER : DIGIT+;
HEX_INTEGER : '0x' HEX_DIGIT+ ;

fragment DIGIT : [0-9];
fragment HEX_DIGIT : [0-9a-fA-F];

FLOAT_NUMBER
 : POINT_FLOAT
 | EXPONENT_FLOAT
 ;

fragment POINT_FLOAT
 : INT_PART? FRACTION
 | INT_PART '.'
 ;

fragment EXPONENT_FLOAT
: INT_PART FRACTION? EXPONENT
 ;

fragment INT_PART : DIGIT+;
fragment FRACTION : '.' DIGIT+;
fragment EXPONENT : [eE] [+-]? DIGIT+;



/* skip */
SKIP_
 : ( SPACES | COMMENT ) -> skip
 ;

fragment SPACES
 : [ \t]+
 ;


COMMENT : INLINE_COMMENT | MULTILINE_COMMENT ;

fragment INLINE_COMMENT
 : '//' ( STRING_ESCAPE_SEQ | ~[\\\r\n\f] )*
 ;


fragment MULTILINE_COMMENT
 : '/*' .*? '*/'
 ;


UNKNOWN_CHAR
 : .
 ;


/* parser rules */
startRule: (var_block | classdef | NEWLINE)*;


objdef : funcdef | classdef;




var_block
 : 'var' NEWLINE INDENT (classref (NEWLINE|';')?)+ DEDENT
 | 'var' '/' classref
 ;

classref
 : IDENTIFIER NEWLINE INDENT (classref (NEWLINE|';'))+ DEDENT
 | IDENTIFIER '/' classref
 | vardef
 ;

vardef
 :  IDENTIFIER ('=' value)?;




classdef
 : IDENTIFIER NEWLINE INDENT objdef+ DEDENT
 | IDENTIFIER '/' objdef
 ;

funcdef
 : func_type? NEWLINE INDENT func_header DEDENT
 | (func_type '/')? func_header
 ;
func_type: 'proc' | 'verb';
func_header
 : IDENTIFIER '(' ')' NEWLINE INDENT func_settings stmt_list DEDENT
 ;

func_settings: (func_setting (NEWLINE|';'))*;
func_setting: 'set' IDENTIFIER ('=' | 'in') expr;

stmt_list: (statement (NEWLINE|';'))+;
statement
 : var_inline
 | expr
 ;

var_inline: 'var' path IDENTIFIER ('=' expr)?;
path: ('/' IDENTIFIER)* '/';

/*




procdef: path OPEN_PAREN parameters? CLOSE_PAREN NEWLINE INDENT (varBlock|inlineVar)+ DEDENT;
verbdef: path OPEN_PAREN parameters? CLOSE_PAREN NEWLINE INDENT (varBlock|inlineVar)+ DEDENT;
//classdef: path NEWLINE INDENT (varBlock|inlineVar|funcOverride)+ DEDENT;

funcOverride: IDENTIFIER OPEN_PAREN parameters? CLOSE_PAREN NEWLINE INDENT funcBlock DEDENT;
funcBlock: (expr NEWLINE?)+;


functionCall: dotPath OPEN_PAREN arguments? CLOSE_PAREN asType? inList?;
asType: AS IDENTIFIER;
inList: IN expr;

tmpsDecl: TMP '/'? variableDef+;
varBlock:  VAR NEWLINE INDENT (tmpsDecl|variableDef)+ DEDENT;
inlineVar: VAR '/' variableDef;
variableDef: leftSidePath? variableName (ASSIGN (constructorCall|value))? NEWLINE+;
variableName: IDENTIFIER;

parameters: IDENTIFIER (COMMA IDENTIFIER)*;
arguments: expr (COMMA expr)*;

value: STRING_LITERAL | ICON_PATH | NUMBER | path | dotPath | IDENTIFIER;
constructorCall: NEW absolutePath (OPEN_PAREN expr? CLOSE_PAREN)?;
destructorCall
 : DEL (OPEN_PAREN expr CLOSE_PAREN)?
 | DEL expr
 ;

path: relativePath | absolutePath;

leftSidePath: (IDENTIFIER SLASH)+;

relativePath: ((IDENTIFIER|notReservedKeyword) SLASH)* IDENTIFIER;
absolutePath: SLASH relativePath;
dotPath: IDENTIFIER ('.' IDENTIFIER)*;

notReservedKeyword : VERB | PROC ;
*/
/*
expressions
*/


expr
    : '(' expr ')' #bracketExpression
    | ('~' | '!' | '-' | '++' | '--') expr #oneArgExpression
    | '**' expr #powerExpression
    | expr ('*' | '/' | '%') expr #multExpression
    | expr ('+' | '-') expr #addExpression
    | expr ('<' | '<=' | '>' | '>=') expr #compExpression
    | expr ('<<' | '>>') expr #bitMoveExpression
    | expr ('==' | '!=' | '<>') expr #eqExpression
    | expr ('&' | '^' | '|') expr #bitExpression
    | '&&' expr #logAndExpression
    | '||' expr #logOrExpression
    | expr '?' expr ':' expr #tenaryExpression
    | expr ('=' | '+=' | '-=' | '*=' | '/=' | '&=' | '|=' | '^=' | '<<=' | '>>=') expr #assignExpression
    | value #valExpression
    ;

value: STRING_LITERAL | ICON_PATH | NUMBER | IDENTIFIER;




//startRule: (procDef | verbDef | objDef) + ;
//startRule: objDef+ ;
//objDef: className NEWLINE INDENT (variablesDecl|variableDecl)+ DEDENT;



/*
procOverrideDef: methodOf INDENT functionName '()' statementList;
procDef: PROC (methodOf '/'?)? functionName '()' statementList;
verbDef: VERB (methodOf '/'?)? functionName '()' statementList;
*/

//methodOf: className ;
//className: ATOM | DATUM | TURF | OBJ | MOB | IDENTIFIER;

//functionName: IDENTIFIER ;


//tmpsDecl: TMP '/'? variableDef+;
//variablesDecl:  VAR NEWLINE INDENT (tmpsDecl|variableDef)+ DEDENT;
//variableDecl: VAR '/' variableDef;
//variableDef: leftSidePath? variableName (OP_ASSIGN (constructorCall|value))?;
//variableName: IDENTIFIER;


//constructorCall: NEW '/' path '()';

//path: relativePath | absolutePath;

//leftSidePath: (className OP_PATH)+;

//relativePath: (className OP_PATH)* className;
//absolutePath: OP_PATH relativePath;


//statementList: statement+ ;
//varName: IDENTIFIER ;

//assignmentList: assignment+;
//assignment: IDENTIFIER OP_ASSIGN NUMBER_LITERAL ;

//value: NUMBER_LITERAL | STRING_LITERAL | IDENTIFIER;

//statement
//    : WORLD OP_OUT STRING_LITERAL
//    | varName '=' NUMBER_LITERAL
//    ;

