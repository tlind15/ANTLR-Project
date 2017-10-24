grammar Expr;

tokens {
	PRINT = 'PRINT';
	PRINTLN = 'PRINTLN';
	INTEGER='INTEGER';
	LET = 'LET';
	INPUT = 'INPUT';
	END = 'END';
}

@header {

package expressionparser;
import java.util.HashMap;
import java.util.Scanner;
}

@lexer::header {

package expressionparser;

}
/*Comment*/


@members {

/** Map variable name to Integer object holding value */

HashMap memory = new HashMap();
Scanner mScanner = new Scanner(System.in);
}


prog: stat+ ;


stat: expr NEWLINE {System.out.println($expr.value);}

| ID (' ')? '=' (' ')? expr {memory.put($ID.text, $expr.value); System.out.println(memory.get($ID.text));} NEWLINE

| NEWLINE {System.out.println("A newline has been issued");}

| print NEWLINE	

| int_declaration NEWLINE

| initialization

| value_input	

| terminate		

;

expr returns [int value]

: e=atom {$value = $e.value;}

( (' ')? '+' (' ')? e=atom {$value += $e.value;}
| (' ')? '-' (' ')? e=atom {$value -= $e.value;}
| (' ')? '/' (' ')? e=atom {$value /= $e.value;}
| (' ')? '*' (' ')? e=atom {$value *= $e.value;}		
)*

;

print 
: PRINT ' ' expr {System.out.print($expr.value);}	

| PRINTLN ' ' expr {System.out.println($expr.value);}

| PRINT ' ' STRING {System.out.print($STRING.text.substring(1, $STRING.text.length()-1));}

| PRINTLN ' ' STRING {System.out.println($STRING.text.substring(1, $STRING.text.length()-1));}

;


multExpr returns [int value]

: e=atom {$value = $e.value;} ((' ')? '*' (' ')? e=atom {$value *= $e.value;})*

;

int_declaration
: INTEGER ' ' (int_id ((',')(' ')?)*)+ {System.out.println(memory.keySet().size());}

;

initialization

: LET (' ') ID (' ')? '=' (' ')? expr {if(memory.containsKey($ID.text)) memory.put($ID.text, $expr.value); else System.err.println("undefined variable "+$ID.text);} {System.out.println(memory.get($ID.text));}

;

value_input

: INPUT	' ' (input_id ((',')(' ')?)*)+  

{System.out.println(memory.get($input_id.text));}
;

input_id

: ID 

{	
	if(memory.containsKey($ID.text)) {
		int v = mScanner.nextInt();
		memory.put($ID.text, v);
	} else 
		System.err.println("undefined variable "+$ID.text);	
} 

;

int_id

: ID {memory.put($ID.text, null);}
;


atom returns [int value]

: INT {$value = Integer.parseInt($INT.text);}

| ID
	

{

Integer v = (Integer)memory.get($ID.text);


if ( v!=null ) {$value = v.intValue(); memory.put($ID.text, $value);}

/*else System.err.println("undefined variable "+$ID.text);*/

}

| '(' expr ')' {$value = $expr.value;}

;

terminate

: END {System.out.println("Program finished"); System.exit(0);}

;



ID : ('a'..'z'|'A'..'Z')('a'..'z'|'A'..'Z'|'0'..'9')* ;

INT : '0'..'9'+ ;

STRING : '"'('a'..'z'|'A'..'Z'|'0'..'9' )('\u0020'..'\u007E')* '"';

NEWLINE:'\r'? '\n' ;

WS : (' '|'\t')+ {skip();} ;



