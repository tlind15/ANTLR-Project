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


@members {

/** Map variable name to Integer object holding value */

HashMap memory = new HashMap(); //serves as symbol table for this language
Scanner mScanner = new Scanner(System.in); //new this so multiple values can be input on one line
}

//================================Parser Rules=============================================================================

prog: stat+ terminate ; //defines the program structure as at least one statement followed by a termination clause 

//stat represents all valud statements in this grammar
stat: expr (COMMENT_STRING)? {System.out.println($expr.value);}

| NEWLINE

| print (COMMENT_STRING)?

| int_declaration (COMMENT_STRING)? 

| initialization //theres no comment string here bc expr alreadd allows for a comment string

| value_input (COMMENT_STRING)?

| COMMENT_STRING	  	
	
;

//expr reppesents expressions in this grammar. Only the 4 basic arithmetic expressions are defined
expr returns [int value]

: e=atom {$value = $e.value;}

( (' ')? '+' (' ')? e=atom {$value += $e.value;}
| (' ')? '-' (' ')? e=atom {$value -= $e.value;}
| (' ')? '/' (' ')? e=atom {$value /= $e.value;}
| (' ')? '*' (' ')? e=atom {$value *= $e.value;}		
)*

;

//print will display an expression or string literal to the console with or without CF & LF
print 
: PRINT (' '|'\t')+ expr {System.out.print($expr.value);}	

| PRINTLN (' '|'\t')+ expr {System.out.println($expr.value);}

| PRINT (' '|'\t')+ STRING {System.out.print($STRING.text.substring(1, $STRING.text.length()-1));}

| PRINTLN (' '|'\t')+ STRING {System.out.println($STRING.text.substring(1, $STRING.text.length()-1));}

;


//defines the behavior of ID in the context of the INTEGER token
//gives us the ability to define behavior for each ID when the user declares many in a list such as INTEGER a,b,c
int_id

: ID  
{	
	if (!memory.containsKey($ID.text)) //make sure the variable HAS NOT been previously declared
		memory.put($ID.text, null);
		
	else { //show error if variable has been declared already
	 	System.err.println("A variable with name " + $ID.text + " is already defined in this scope");
	 	System.exit(0);
	 }
}
;


//int_declaration describes the syntax for variable declaration
int_declaration
: INTEGER (' '|'\t')+ (int_id ((',')(' ')?)*)+  //can have a single identifier or an identifier list separated by commas

;

//describes the syntax ofr initialization 
initialization

: LET (' '|'\t')+ ID (' ')? '=' (' ')? expr 

{ //ensure that the variable being initialized has been previously declared
	if(memory.containsKey($ID.text)) 
		memory.put($ID.text, $expr.value); 
	else 
		System.err.println("undefined variable "+$ID.text);	
}

;

//describes the behavior of ID used in the context of an INPUT token.
//also gives ability to assign behavior to each individual ID when the user calls INPUT with a list of IDs 
input_id

: ID 

{//ensure that the data entered by the user is a valid 4 byte integer	
	int v;
	if(memory.containsKey($ID.text)) //make sure the ID has been declared 
		try {
			v = mScanner.nextInt();
		} catch (java.util.InputMismatchException e) {
			System.err.println("Error: Could not store value as type 'INTEGER'");
			System.exit(0);
		}
		
	else //show error if ID not prrviously declared
		System.err.println("undefined variable "+$ID.text);	
} 

;

//describes the syntax for using the INPUT token. This allows the program to read in input from the keyboard
value_input

: INPUT	(' '|'\t')+ (input_id ((',')(' ')?)*)+ //We can read in values to one input_id or a list separated by commas. 

;


//describes the smallest unit of value
atom returns [int value]

: INT 
{//convert the numeric text string into an actual integer value
	try { //make sure that the numeric string when parsed is a valid 4 byte integer
		$value = Integer.parseInt($INT.text);
		
	} catch (java.lang.NumberFormatException e) { //throw exception if the numeric string is not a valid 4 byte integer
		System.err.println("Error: Value out of range");
		System.exit(0);
	}
	
}

| ID //this definition of ID refers to the behavior of ID as an autonomous unit
	

{
	//make sure that an ID used to represent a value in an expression has been previously initialized
	Integer v = (Integer)memory.get($ID.text);
	if ( v!=null ) 
		$value = v.intValue(); 
	else { //show an error if the ID has not been previoosly initialized
		System.err.println("Error: undefined variable "+$ID.text);
		System.exit(0);
	}

}

| '(' expr ')' {$value = $expr.value;}

;


//describes termination of the program
terminate

: END {System.out.println("Program finished"); System.exit(0);}

;

//=================Lexer Rules=========================================

ID : ('a'..'z'|'A'..'Z')('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ;

INT : ('-')? '0'..'9'+ ;

STRING : '"'('a'..'z'|'A'..'Z'|'0'..'9' )('\u0020'..'\u007E')* '"';

COMMENT_STRING : (' '|'\t')* '//' (' ')* ('\u0020'..'\u007E')* ;

NEWLINE:'\r'? '\n' ;





