grammar Expr;

tokens {
	PRINT = 'PRINT';
	PRINTLN = 'PRINTLN';
	INTEGER='INTEGER';
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

| ID (' ')? '=' (' ')? expr NEWLINE {if (memory.get($ID.text) instanceof Integer) memory.put($ID.text, new Integer($expr.value));  else System.err.println("The variable " + $ID.text + " is not an integer.");}

| NEWLINE {System.out.println("A newline has been issued");}

| print NEWLINE	

| int_declaration NEWLINE	

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

int_declaration
: INTEGER ' ' ID {memory.put($ID.text, $INTEGER.type);}

;


multExpr returns [int value]

: e=atom {$value = $e.value;} ('*' e=atom {$value *= $e.value;})*

;


atom returns [int value]

: INT {$value = Integer.parseInt($INT.text);}

| ID
	

{

Integer v = (Integer)memory.get($ID.text);

if ( v!=null ) $value = v.intValue();

else System.err.println("undefined variable "+$ID.text);

}

| '(' expr ')' {$value = $expr.value;}

;


ID : ('a'..'z'|'A'..'Z')('a'..'z'|'A'..'Z'|'0'..'9')* ;

INT : '0'..'9'+ ;

STRING : '"'('a'..'z'|'A'..'Z'|'0'..'9' )('a'..'z'|'A'..'Z'|'0'..'9'|(' ')+)*'"';

NEWLINE:'\r'? '\n' ;

WS : (' '|'\t')+ {skip();} ;



