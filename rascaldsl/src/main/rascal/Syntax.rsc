module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r];
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "#" ![\n]* $;

start syntax Program = program: Statement* statements;

syntax Statement 
  = assignment: Assignment
  | functionDef: FunctionDef
  | dataDecl: DataAbstraction
  ;

syntax Assignment = assign: ID name TypeAnnotation? typeAnn "=" Expression expr;

syntax DataAbstraction 
  = dataAbstraction: ID name TypeAnnotation? typeAnn "=" "data" "with" {ID ","}+ identifiers
                     RepDef repDef
                     FunctionDef* functions
                     "end" ID endName
  ;

syntax RepDef = repDef: "rep" "=" StructValue structVal;

syntax FunctionDef 
  = functionDef: ID name "=" "function" "(" {Parameter ","}* params ")" TypeAnnotation? returnType "do"
                 Statement* stmts
                 "end" ID endName
  ;

syntax Parameter = param: ID name TypeAnnotation? typeAnn;

syntax TypeAnnotation = typeAnn: ":" Type typeRef;

syntax Type
  = basicIdType: ID typeName
  | intType: "Int"
  | floatType: "Float"
  | stringType: "String"
  | charType: "Char"
  | boolType: "Bool"
  | listType: "[" Type elemType "]"
  | tupleType: "(" Type fst "," Type snd ")"
  | structTypeRef: "struct" "(" {TypedField ","}+ fields ")"
  ;

syntax TypedField = typedField: ID name ":" Type fieldType;

syntax ControlFlow 
  = ifExpr: IfExpr ifExpression
  | condExpr: CondExpr condExpression
  | forExpr: ForExpr forExpression
  ;

syntax IfExpr 
  = ifExpr: "if" Expression condition
            "then" Expression thenPart
            "else" Expression elsePart
            "end"
  ;

syntax CondExpr 
  = condExpr: "cond" Expression expr "do"
              CondPost+ condPosts
              "end"
  ;

syntax CondPost = condPost: Expression condition "-\>" Expression result;

syntax ForExpr 
  = forExpr: "for" ID variable ForRange range "do"
             Statement* stmts
             "end"
  ;

syntax ForRange 
  = fromTo: "from" Expression from "to" Expression to
  | inExpr: "in" Expression collection
  ;

syntax StructValue 
  = structType: StructType
  | structInstance: StructInstance
  ;

syntax StructType = structType: "struct" "(" {StructField ","}+ fields ")";

syntax StructField 
  = simpleField: ID name
  | typedStructField: ID name ":" Type fieldType
  ;

syntax StructInstance = structInstance: "struct" "(" {Field ","}+ fields ")";

syntax Field = fieldDef: ID name ":" Expression expr;

syntax Expression
  = bracket "(" Expression ")"
  | ID name
  | lit: Literal
  | ifExpr: IfExpr
  | forExpr: ForExpr
  | condExpr: CondExpr
  | seq: "[" {Expression ","}* "]"
  | tup: "(" Expression "," Expression ")"
  | structLit: StructLiteral
  | iter: IteratorExpr
  > left call: Expression expr "(" {Expression ","}* args ")"
  > left fieldAcc: Expression expr "." ID fieldName
  > left dollarAcc: Expression expr "$" ID fieldName
  > right neg: "neg" Expression expr
  > right pow: Expression base "**" Expression exponent
  > left ( mul: Expression left "*" Expression right
         | divi: Expression left "/" Expression right
         | modu: Expression left "%" Expression right
         )
  > left ( add: Expression left "+" Expression right
         | sub: Expression left "-" Expression right
         )
  > non-assoc ( lt: Expression left "\<" Expression right
              | gt: Expression left "\>" Expression right
              | leq: Expression left "\<=" Expression right
              | geq: Expression left "\>=" Expression right
              | neq: Expression left "\<\>" Expression right
              | equ: Expression left "=" Expression right
              )
  > left andOp: Expression left "and" Expression right
  > left orOp: Expression left "or" Expression right
  ;

syntax StructLiteral 
  = structLit: "struct" "(" {Field ","}+ fields ")"
  | namedStruct: ID name "$" "(" {Field ","}+ fields ")"
  ;

syntax IteratorExpr 
  = iteratorExpr: "iterator" "(" Expression collection ")" 
                  "yielding" "(" ID variable ")"
  ;

syntax Literal 
  = numLit: Number
  | strLit: STRING
  | charLit: CHAR
  | boolLit: BOOLEAN
  ;

lexical ID = ([a-zA-Z][a-zA-Z0-9_\-]* !>> [a-zA-Z0-9_\-]) \ Reserved;

lexical Number 
  = INT
  | FLOAT
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
  // Los tipos agregados para la entrega 3
  | "Int" | "Float" | "String" | "Char" | "Bool"
  ;
