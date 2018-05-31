grammar DM;

/*
antlr4 DM.g4 -o gen
javac gen/DM*.java
cd gen
grun DM startRule ../testfile.dm -gui
cd ..
*/

DATUM: 'datum' ;
TURF: 'turf' ;
ATOM : 'atom' ;
MOB : 'mob' ;
OBJ : 'obj' ;
WORLD : 'world' ;
PROC: 'proc' ;
VERB: 'verb' ;
VAR: 'var';
TMP: 'tmp';
NEW: 'new';

fragment DIGIT: [0-9] ;
NUMBER_LITERAL: DIGIT+ ;

OP_OUT: '<<' ;
OP_ASSIGN: '=' ;
OP_PATH: '/';

IDENTIFIER: [_a-zA-Z][_a-zA-Z0-9]*;

STRING_LITERAL : '"' (~["\\\r\n] | '\\' (. | EOF))* '"';
Whitespace : [ \t]+ -> skip;
Newline : ('\r''\n'?| '\n')  -> skip;
BlockComment :   '/*' .*? '*/' -> skip;
LineComment :   '//' ~[\r\n]* -> skip ;



startRule: (procDef | verbDef | objDef) + ;

objDef: className '/'? (variablesDecl|variableDecl)+ ;
procOverrideDef: methodOf '/'? functionName '()' statementList;
procDef: PROC (methodOf '/'?)? functionName '()' statementList;
verbDef: VERB (methodOf '/'?)? functionName '()' statementList;


methodOf: className ;
className: ATOM | DATUM | TURF | OBJ | MOB | IDENTIFIER;

functionName: IDENTIFIER ;


tmpsDecl: TMP '/'? variableDef+;
variablesDecl:  VAR (tmpsDecl|variableDef)+;
variableDecl: VAR '/' variableDef;
variableDef: leftSidePath? variableName (OP_ASSIGN (constructorCall|value))?;
variableName: IDENTIFIER;


constructorCall: NEW '/' path '()';

path: relativePath | absolutePath;

leftSidePath: (className OP_PATH)+;

relativePath: (className OP_PATH)* className;
absolutePath: OP_PATH relativePath;


statementList: statement+ ;
varName: IDENTIFIER ;

assignmentList: assignment+;
assignment: IDENTIFIER OP_ASSIGN NUMBER_LITERAL ;

value: NUMBER_LITERAL | STRING_LITERAL | IDENTIFIER;

statement
    : WORLD OP_OUT STRING_LITERAL
    | varName '=' NUMBER_LITERAL
    ;

/*
expressions
*/
expression
    : '(' expression ')' #bracketExpression
    | ('~' | '!' | '-' | '++' | '--') expression #oneArgExpression
    | '**' expression #powerExpression
    | expression ('*' | '/' | '%') expression #multExpression
    | expression ('+' | '-') expression #addExpression
    | expression ('<' | '<=' | '>' | '>=') expression #compExpression
    | expression ('<<' | '>>') expression #bitMoveExpression
    | expression ('==' | '!=' | '<>') expression #eqExpression
    | expression ('&' | '^' | '|') expression #bitExpression
    | '&&' expression #logAndExpression
    | '||' expression #logOrExpression
    | expression '?' trueExpression ':' falseExpression #tenaryExpression
    | expression ('=' | '+=' | '-=' | '*=' | '/=' | '&=' | '|=' | '^=' | '<<=' | '>>=') expression #assingExpression
    | value #valExpression
    ;
trueExpression: expression;
falseExpression: expression;