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


prog: stat+ terminate ;


stat: expr ((' ')* COMMENT_STRING)? {System.out.println($expr.value);}

| NEWLINE

| print ((' ')* COMMENT_STRING)?

| int_declaration ((' ')* COMMENT_STRING)? 

| initialization //theres no comment string here bc expr alreadd allows for a comment string

| value_input ((' ')* COMMENT_STRING)?

| COMMENT_STRING	  	
	
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
: PRINT (' '|'\t') expr {System.out.print($expr.value);}	

| PRINTLN (' '|'\t') expr {System.out.println($expr.value);}

| PRINT (' '|'\t') STRING {System.out.print($STRING.text.substring(1, $STRING.text.length()-1));}

| PRINTLN (' '|'\t') STRING {System.out.println($STRING.text.substring(1, $STRING.text.length()-1));}

;


int_declaration
: INTEGER (' '|'\t') (int_id ((',')(' ')?)*)+ 

;

initialization

: LET (' '|'\t') ID (' ')? '=' (' ')? expr 

{
	System.out.println($expr.value);
		if(memory.containsKey($ID.text)) 
			memory.put($ID.text, $expr.value); 
		else 
			System.err.println("undefined variable "+$ID.text);	
}

;

value_input

: INPUT	(' '|'\t') (input_id ((',')(' ')?)*)+  

;

input_id

: ID 

{	
	int v;
	if(memory.containsKey($ID.text)) 
		try {
			v = mScanner.nextInt();
		} catch (java.util.InputMismatchException e) {
			System.err.println("Error: Could not store value as type 'INTEGER'");
			System.exit(0);
		}
		
	else 
		System.err.println("undefined variable "+$ID.text);	
} 

;

int_id

: ID {if (!memory.containsKey($ID.text)) memory.put($ID.text, null); else System.err.println("A variable with name " + $ID.text + " is already defined in this scope");}
;


atom returns [int value]

: INT 
{
	if (Integer.parseInt($INT.text) > Integer.MIN_VALUE && Integer.parseInt($INT.text) < Integer.MAX_VALUE)
		$value = Integer.parseInt($INT.text);
	else
		System.err.println("Value " + $INT.text + " out of range");
}

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



ID : ('a'..'z'|'A'..'Z')('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;

INT : '0'..'9'+ ;

STRING : '"'('a'..'z'|'A'..'Z'|'0'..'9' )('\u0020'..'\u007E')* '"';

COMMENT_STRING : '//' (' ')* ('a'..'z'|'A'..'Z'|'0'..'9' )('\u0020'..'\u007E')* ;

NEWLINE:'\r'? '\n' ;

WS : (' '|'\t')+ {skip();};




