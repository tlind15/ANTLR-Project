grammar Expr;

tokens {
	PRINT = 'PRINT';
	PRINTLN = 'PRINTLN';
	INTEGER='INTEGER';
	END = 'END';
}

@header {

package expressionparser;
import java.util.HashMap;

}

@lexer::header {

package expressionparser;

}
/*Comment*/


@members {

/** Map variable name to Integer object holding value */

HashMap memory = new HashMap();

}


prog: stat+ ;


stat: expr NEWLINE {System.out.println($expr.value);}

| ID (' ')? '=' (' ')? expr NEWLINE {}

| NEWLINE {System.out.println("A newline has been issued");}

| print NEWLINE	

| int_declaration NEWLINE

| terminate		

;

expr returns [int value]

: e=multExpr {$value = $e.value;}

( '+' e=multExpr {$value += $e.value; } 
| '-' e=multExpr {$value -= $e.value;}
| '/' e=multExpr {$value /= $e.value;}
)*

;

print 
: PRINT ' ' expr {System.out.print($expr.value);}

| PRINTLN ' ' expr {System.out.println($expr.value);}

| PRINT ' ' STRING {System.out.print($STRING.text.substring(1, $STRING.text.length()-1));}

| PRINTLN ' ' STRING {System.out.println($STRING.text.substring(1, $STRING.text.length()-1));}

;


multExpr returns [int value]

: e=atom {$value = $e.value;} ('*' e=atom {$value *= $e.value;})*

;

int_declaration
: INTEGER ' ' ((',')? (' ')? ID)+

;


atom returns [int value]

: INT {$value = Integer.parseInt($INT.text);}

| ID 
	

{

Integer v = (Integer)memory.get($ID.text);

if ( v!=null ) {$value = v.intValue(); memory.put($ID.text, $value);}

else System.err.println("undefined variable "+$ID.text);

}

| '(' expr ')' {$value = $expr.value;}

;

terminate

: END {System.out.println("Program finished"); System.exit(0);}

;



ID : ('a'..'z'|'A'..'Z')('a'..'z'|'A'..'Z'|'0'..'9')* ;

INT : '0'..'9'+ ;

STRING : '"'('a'..'z'|'A'..'Z'|'0'..'9' )('a'..'z'|'A'..'Z'|'0'..'9'|(' ')+)*'"';

NEWLINE:'\r'? '\n' ;

WS : (' '|'\t')+ {skip();} ;



