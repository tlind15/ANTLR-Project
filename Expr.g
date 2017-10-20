grammar Expr;

tokens {
	PRINT = 'PRINT';
	PRINTLN = 'PRINTLN';
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

| ID '=' expr NEWLINE

{memory.put($ID.text, new Integer($expr.value));}

| NEWLINE {System.out.println("A newline has been issued");}

| print NEWLINE	

;

expr returns [int value]

: e=multExpr {$value = $e.value;}

( '+' e=multExpr {$value += $e.value; } 
| '-' e=multExpr {$value -= $e.value;}

| '/' e=multExpr {$value /= $e.value;}

)*

;

print 
: PRINT '"'expr'"' {System.out.print($expr.value);}

| PRINTLN '"'expr'"' {System.out.println($expr.value);}

| PRINT STRING {System.out.print($STRING.text);}

| PRINTLN STRING {System.out.println($STRING.text);}

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


ID : ('a'..'z'|'A'..'Z')+ ;

INT : '0'..'9'+ ;

STRING	:'"'('a'..'z'|'A'..'Z'|'0'..'9' )('a'..'z'|'A'..'Z'|'0'..'9'|(' ')+)*'"';

NEWLINE:'\r'? '\n' ;

WS : (' '|'\t')+ {skip();} ;



