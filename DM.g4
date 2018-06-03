grammar DM;

/*
antlr4 DM.g4 -o gen
javac gen/DM*.java
cd gen
grun DM startRule ../testfile.dm -gui
cd ..
*/

@header {
    import java.lang.reflect.Field;
}

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

      this.emit(commonToken(DMParser.NEWLINE));
      while (!indents.isEmpty()) {
        this.emit(commonToken(DMParser.DEDENT));
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
     if (opened > 0 || next == '\r' || next == '\n' || next == '\f' || next == '#') {
       skip();
     }
     else {
       int startIndex = this._tokenStartCharIndex;
       int startIndexSpaces = startIndex + newLine.length();

       ct = commonToken(DMParser.NEWLINE, newLine, startIndex);
       ct.setLine(this._tokenStartLine);
       ct.setCharPositionInLine(this._tokenStartCharPositionInLine);
       emit(ct);

       int indent = spaces.length();
       int previous = indents.isEmpty() ? 0 : indents.peek();
       if (indent == previous) {
         skip();
       }
       else if (indent > previous) {
         indents.push(indent);
         ct = commonToken(DMParser.INDENT, spaces, startIndexSpaces);
         ct.setCharPositionInLine(0);
         emit(ct);
       }
       else {
         while(!indents.isEmpty() && indents.peek() > indent) {
           ct = commonToken(DMParser.DEDENT, spaces, startIndexSpaces);
           ct.setCharPositionInLine(0);
           this.emit(ct);
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
PATH_LITERAL : '\'' (~["\\\r\n\f])* '\'';

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
 : '//' ( STRING_ESCAPE_SEQ | ~[\\\r\n\f"] )*
 ;


fragment MULTILINE_COMMENT
 : '/*' .*? '*/'
 ;


UNKNOWN_CHAR
 : .
 ;


startRule: SLASH;

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

/*
expressions
*/
//expression
//    : '(' expression ')' #bracketExpression
//    | ('~' | '!' | '-' | '++' | '--') expression #oneArgExpression
//    | '**' expression #powerExpression
//    | expression ('*' | '/' | '%') expression #multExpression
//    | expression ('+' | '-') expression #addExpression
//    | expression ('<' | '<=' | '>' | '>=') expression #compExpression
//    | expression ('<<' | '>>') expression #bitMoveExpression
//    | expression ('==' | '!=' | '<>') expression #eqExpression
//    | expression ('&' | '^' | '|') expression #bitExpression
//    | '&&' expression #logAndExpression
//    | '||' expression #logOrExpression
//    | expression '?' trueExpression ':' falseExpression #tenaryExpression
//    | expression ('=' | '+=' | '-=' | '*=' | '/=' | '&=' | '|=' | '^=' | '<<=' | '>>=') expression #assingExpression
//    | value #valExpression
//    ;
//trueExpression: expression;
//falseExpression: expression;