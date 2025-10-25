module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r];
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "#" ![\n]* $;

start syntax Program = program: Statement* statements;



syntax Statement 
  = assignment: ID name "=" Expression expr
  | functionDef: FunctionDef
  | dataAbstraction: ID name "=" "data" "with" {ID ","}+ identifiers
                     RepDef repDef
                     FunctionDef* functions
                     "end" ID endName
  ;

syntax RepDef = repDef: "rep" "=" StructValue structVal;

syntax FunctionDef 
  = functionDef: ID name "=" "function" "(" {ID ","}* params ")" "do"
                 Statement* stmts
                 "end" ID endName
  ;

// Expresiones
syntax Expression
  = bracket "(" Expression ")"
  | variable: ID name
  | literal: Literal lit
  
  | ifExpr: "if" Expression condition
            "then" Expression thenPart
            "else" Expression elsePart
            "end"
  
  | forExpr: "for" ID var ForRange range "do"
             Statement* stmts
             "end"
             
  | condExpr: "cond" Expression expr "do"
              CondPost+ condPosts
              "end"
              
  | sequence: "[" {Expression ","}* elements "]"
  | tup: "(" Expression fst "," Expression snd ")"
  | structLiteral: StructLiteral structLit
  | iterator: "iterator" "(" Expression collection ")" 
              "yielding" "(" ID var ")"
              
  > left call: Expression expr "(" {Expression ","}* args ")"
  > left fieldAccess: Expression expr "." ID fieldName
  > left dollarAccess: Expression expr "$" ID fieldName
  > right neg: "neg" Expression expr
  > right power: Expression base "**" Expression exponent
  > left ( multiply: Expression left "*" Expression right
         | divide: Expression left "/" Expression right
         | modulo: Expression left "%" Expression right
         )
  > left ( add: Expression left "+" Expression right
         | subtract: Expression left "-" Expression right
         )
  > non-assoc ( lessThan: Expression left "\<" Expression right
              | greaterThan: Expression left "\>" Expression right
              | lessOrEqual: Expression left "\<=" Expression right
              | greaterOrEqual: Expression left "\>=" Expression right
              | notEqual: Expression left "\<\>" Expression right
 
              | equal: Expression left "=" Expression right
              )
  > left andOp: Expression left "and" Expression right
  > left orOp: Expression left "or" Expression right
  ;

syntax CondPost = condPost: Expression condition "-\>" Expression result;

syntax ForRange 
  = fromTo: "from" Expression from "to" Expression to
  | inRange: "in" Expression collection
  ;

//EN ESTRUCTURAS DE DATOS

syntax StructValue 
  = structType: StructType
  | structInstance: StructInstance
  ;
  
syntax StructType = structType: "struct" "(" {ID ","}+ fieldNames ")"; 

syntax StructInstance = structInstance: "struct" "(" {Field ","}+ fieldDefs ")"; 

syntax Field = fieldDef: ID name ":" Expression expr; 

syntax StructLiteral 
  = structLit: "struct" "(" {Field ","}+ fieldList ")" 
  | namedStruct: ID name "$" "(" {Field ","}+ fieldList ")" 
  ;
  
syntax Literal 
  = numberLit: Number number
  | stringLit: STRING string
  | charLit: CHAR char
  | boolLit: BOOLEAN boolean
  ;

lexical ID = ([a-zA-Z][a-zA-Z0-9_\-]* !>> [a-zA-Z0-9_\-]) \ Reserved;

lexical Number 
  = intNumber: INT intVal
  | floatNumber: FLOAT floatVal
  ;

lexical INT = [\-]? [0-9]+ !>> [0-9];
lexical FLOAT = [\-]? [0-9]+ "." [0-9]+ !>> [0-9];
lexical STRING = "\"" ![\"\\]* "\"";
lexical CHAR = "\'" ![\'\n\\] "\'";
lexical BOOLEAN = "true" | "false";

keyword Reserved 
  = "cond" | "do" | "data" | "end" | "for" 
  | "from" | "then" | "function" | "else" | "if" | "in" 
  | "iterator" | "sequence" | "struct" | "to" | "tuple" 
  | "type" | "with" | "yielding" | "and" | "or" | "neg"
  | "true" | "false" | "rep"
  ;