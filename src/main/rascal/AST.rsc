module AST

import ParseTree;

// Tipo opcional para anotaciones
data AType
  = basicType(str typeName)
  | listType(AType elemType)
  | tupleType(AType fst, AType snd)
  | structTypeRef(list[ATypedField] fields)
  | noType()
  ;

data ATypedField = typedField(str name, AType fieldType);

data AProgram = program(list[AStatement] statements, loc src = |unknown:///|);

data AStatement 
  = assignment(str name, AType typeAnn, AExpression expr, loc src = |unknown:///|)
  | functionDefStmt(str name, list[AParameter] params, AType returnType, 
                    list[AStatement] stmts, str endName, loc src = |unknown:///|)
  | dataAbstraction(str name, AType typeAnn, list[str] identifiers, 
                    ARepDef repDef, list[AFunctionDef] functions, str endName, loc src = |unknown:///|)
  ;

data AParameter = param(str name, AType typeAnn);

data AFunctionDef = afunctionDef(str name, list[AParameter] params, AType returnType,
                                 list[AStatement] stmts, str endName, loc src = |unknown:///|);

data ARepDef = repDef(AStructValue structVal);

data AExpression
  = variable(str name, loc src = |unknown:///|)
  | literal(ALiteral lit, loc src = |unknown:///|)
  | ifExpr(AExpression condition, AExpression thenPart, AExpression elsePart, loc src = |unknown:///|)
  | forExpr(str var, AForRange range, list[AStatement] stmts, loc src = |unknown:///|)
  | condExpr(AExpression expr, list[ACondPost] condPosts, loc src = |unknown:///|)
  | sequence(list[AExpression] elements, loc src = |unknown:///|)
  | tup(AExpression fst, AExpression snd, loc src = |unknown:///|)
  | structLiteral(AStructLiteral structLit, loc src = |unknown:///|)
  | iterator(AExpression collection, str var, loc src = |unknown:///|)
  | call(AExpression expr, list[AExpression] args, loc src = |unknown:///|)
  | fieldAccess(AExpression expr, str fieldName, loc src = |unknown:///|)
  | dollarAccess(AExpression expr, str fieldName, loc src = |unknown:///|)
  | neg(AExpression expr, loc src = |unknown:///|)
  | power(AExpression base, AExpression exponent, loc src = |unknown:///|)
  | multiply(AExpression left, AExpression right, loc src = |unknown:///|)
  | divide(AExpression left, AExpression right, loc src = |unknown:///|)
  | modulo(AExpression left, AExpression right, loc src = |unknown:///|)
  | add(AExpression left, AExpression right, loc src = |unknown:///|)
  | subtract(AExpression left, AExpression right, loc src = |unknown:///|)
  | lessThan(AExpression left, AExpression right, loc src = |unknown:///|)
  | greaterThan(AExpression left, AExpression right, loc src = |unknown:///|)
  | lessOrEqual(AExpression left, AExpression right, loc src = |unknown:///|)
  | greaterOrEqual(AExpression left, AExpression right, loc src = |unknown:///|)
  | notEqual(AExpression left, AExpression right, loc src = |unknown:///|)
  | equal(AExpression left, AExpression right, loc src = |unknown:///|)
  | andOp(AExpression left, AExpression right, loc src = |unknown:///|)
  | orOp(AExpression left, AExpression right, loc src = |unknown:///|)
  ;

data AForRange
  = fromTo(AExpression from, AExpression to)
  | inRange(AExpression collection)
  ;

data ACondPost = condPost(AExpression condition, AExpression result);

data AStructValue
  = structType(list[AStructField] fields)
  | structInstance(list[AField] fieldDefs)
  ;

data AStructField
  = simpleField(str name)
  | typedStructField(str name, AType fieldType)
  ;

data AField = fieldDef(str name, AExpression expr, loc src = |unknown:///|);

data AStructLiteral
  = structLit(list[AField] fieldList, loc src = |unknown:///|)
  | namedStruct(str name, list[AField] fieldList, loc src = |unknown:///|)
  ;

data ALiteral
  = numberLit(ANumber number)
  | stringLit(str string)
  | charLit(str char)
  | boolLit(bool boolean)
  ;

data ANumber
  = intNumber(int intVal)
  | floatNumber(real floatVal)
  ;
