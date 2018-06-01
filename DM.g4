grammar DM;

/*
antlr4 DM.g4 -o gen
javac gen/DM*.java
cd gen
grun DM startRule ../testfile.dm -gui
cd ..
*/



@lexer::members {
  // A queue where extra tokens are pushed on (see the lexer rule).
  private java.util.LinkedList<Token> tokens = new java.util.LinkedList<>();
  // The stack that keeps track of the indentation level.
  private java.util.Stack<Integer> indents = new java.util.Stack<>();
  // The amount of opened braces, brackets and parenthesis.
  private int opened = 0;
  // The most recently produced token.
  private Token lastToken = null;

  @Override
  public void emit(Token t) {
    System.out.println("emit: " + t);
    super.setToken(t);
    tokens.offer(t);
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

      // First emit an extra line break that serves as the end of the statement.
      emit(commonToken(NEWLINE));
      //emitNewline();

      // Now emit as much DEDENT tokens as needed.
      while (!indents.isEmpty()) {
        this.emit(createDedent());
        //System.out.println("createDedent");
        indents.pop();
      }

      // Put the EOF back on the token stream.
      this.emit(commonToken(DMParser.EOF));
    }


    System.out.println("nextToken");
    Token next = super.nextToken();
    System.out.println("1. nextToken: next.getLine(): " + next.getLine() + ", " + next.getText());
    if (!tokens.isEmpty()){
        System.out.println("2. nextToken: tokens.peek().getLine(): " + tokens.peek().getLine() + ", " + tokens.peek().getText());
    }

    if (next.getChannel() == Token.DEFAULT_CHANNEL) {
      // Keep track of the last token on the default channel.
      this.lastToken = next;
    }

    return tokens.isEmpty() ? next : tokens.poll();
  }

  private void emitNewline() {
    CommonToken newline = commonToken(DMParser.NEWLINE);
    newline.setLine(this.lastToken.getLine());
    System.out.println("newline.getLine(): " + newline.getLine());
    emit(newline);
  }

  private Token createDedent() {
    CommonToken dedent = commonToken(DMParser.DEDENT);
    dedent.setLine(this.lastToken.getLine());
    return dedent;
  }

  private CommonToken commonToken(int type, String text, int start) {
    int stop = start + text.length() - 1;
    //System.out.println("commonToken: , start: " + start + ", stop: " + stop + ", char_index: " + this.getCharIndex() + ", type: " + type + ", text: " + text);
    return new CommonToken(this._tokenFactorySourcePair, type, DEFAULT_TOKEN_CHANNEL, start, stop);
  }

  private CommonToken commonToken(int type) {
    int start =  this.getCharIndex();
    int stop = start;
    //System.out.println("commonToken: , start: " + start + ", stop: " + stop + ", char_index: " + this.getCharIndex() + ", type: " + type);
    CommonToken token = new CommonToken(this._tokenFactorySourcePair, type, DEFAULT_TOKEN_CHANNEL, start, stop);
    //token.setText("");
    return token;
  }

  static int getIndentationCount(String spaces) {
    int count = 0;
    for (char ch : spaces.toCharArray()) {
      switch (ch) {
        case '\t':
          count += 8 - (count % 8);
          break;
        default:
          count++;
      }
    }

    return count;
  }

  boolean atStartOfInput() {
    return super.getCharPositionInLine() == 0 && super.getLine() == 1;
  }
}

//tokens { INDENT, DEDENT }  // if usinbg this, grun shows token name as <23> instead of <INDENT>
INDENT: ('DUPAJASIA1'|'JASIADUPA1') -> skip;
DEDENT: ('DUPAJASIA2'|'JASIADUPA2') -> skip;


NEWLINE
 : ( {atStartOfInput()}?   SPACES
   | ( '\r'? '\n' | '\r' | '\f' ) SPACES?
   )
   {
     System.out.println("super.getLine(): " + super.getLine() + ", " + super.getText());
     String newLine = getText().replaceAll("[^\r\n\f]+", "");
     String spaces = getText().replaceAll("[\r\n\f]+", "");
     ////System.out.println("getText(): [" + getText() + "], newLine: [" + newLine + "], spaces: [" + spaces + "]" );

     int next = _input.LA(1);
     //System.out.println("next: " + next + " (" + (char)next + ")");
     if (opened > 0 || next == '\r' || next == '\n' || next == '\f' || next == '#') {
       // If we're inside a list or on a blank line, ignore all indents,
       // dedents and line breaks.
       skip();
     }
     else {
       int startIndex = this.getCharIndex() - getText().length();

       CommonToken token = commonToken(NEWLINE, newLine, startIndex);
       //token.setLine(0);
       emit(token);


       //this.emitNewline();



       int indent = getIndentationCount(spaces);
       int previous = indents.isEmpty() ? 0 : indents.peek();
       if (indent == previous) {
         // skip indents of the same size as the present indent-size
         skip();
       }
       else if (indent > previous) {
         indents.push(indent);
         startIndex = this.getCharIndex() - spaces.length();
         emit(commonToken(DMParser.INDENT, spaces, startIndex));
       }
       else {
         // Possibly emit more than 1 DEDENT token.
         while(!indents.isEmpty() && indents.peek() > indent) {
           startIndex = this.getCharIndex() - spaces.length();
           this.emit(createDedent());
           indents.pop();
         }
       }
     }
   }
 ;

DATUM: 'datum' ;
TURF: 'turf' ;
ATOM : 'atom' ;
MOB : 'mob' {
     System.out.println("super.getLine(): " + super.getLine() + ", " + super.getText());
     };
OBJ : 'obj' ;
WORLD : 'world' ;
PROC: 'proc' ;
VERB: 'verb' ;
VAR: 'var';
TMP: 'tmp';
NEW: 'new';

SKIP_
 : ( SPACES | COMMENT ) -> skip
 ;

fragment SPACES
 : [ \t]+
 ;

fragment COMMENT
 : '//' ~[\r\n\f]*
 ;



fragment DIGIT: [0-9] ;
NUMBER_LITERAL: DIGIT+ ;

OP_OUT : '<<' ;
OP_ASSIGN : '=' ;
OP_PATH : '/';

IDENTIFIER: [_a-zA-Z][_a-zA-Z0-9]*;

STRING_LITERAL : '"' (~["\\\r\n] | '\\' (. | EOF))* '"';
BlockComment :   '/*' .*? '*/' -> skip;
LineComment :   '//' ~[\r\n]* -> skip ;


UNKNOWN_CHAR
 : .
 ;


startRule: OP_PATH;

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