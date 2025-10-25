module AST

data AProgram = program(list[AStatement] statements);

data AStatement 
  = assignment(str name, AExpression expr)
  | functionDef(str name, list[str] params, list[AStatement] stmts, str endName)
  | dataAbstraction(str name, list[str] identifiers, ARepDef repDef, 
                    list[AFunctionDef] functions, str endName)
  ;

data ARepDef = repDef(AStructValue structVal);

data AFunctionDef = functionDef(str name, list[str] params, list[AStatement] stmts, str endName);

data AExpression
  = variable(str name)
  | literal(ALiteral lit)
  | ifExpr(AExpression condition, AExpression thenPart, AExpression elsePart)
  | forExpr(str var, AForRange range, list[AStatement] stmts)
  | condExpr(AExpression expr, list[ACondPost] condPosts)
  | sequence(list[AExpression] elements)
  | tup(AExpression fst, AExpression snd)
  | structLiteral(AStructLiteral structLit)
  | iterator(AExpression collection, str var)
  | call(AExpression expr, list[AExpression] args)
  | fieldAccess(AExpression expr, str fieldName)
  | dollarAccess(AExpression expr, str fieldName)
  | neg(AExpression expr)
  | power(AExpression base, AExpression exponent)
  | multiply(AExpression left, AExpression right)
  | divide(AExpression left, AExpression right)
  | modulo(AExpression left, AExpression right)
  | add(AExpression left, AExpression right)
  | subtract(AExpression left, AExpression right)
  | lessThan(AExpression left, AExpression right)
  | greaterThan(AExpression left, AExpression right)
  | lessOrEqual(AExpression left, AExpression right)
  | greaterOrEqual(AExpression left, AExpression right)
  | notEqual(AExpression left, AExpression right)
  | equal(AExpression left, AExpression right)
  | andOp(AExpression left, AExpression right)
  | orOp(AExpression left, AExpression right)
  ;

data AForRange
  = fromTo(AExpression from, AExpression to)
  | inRange(AExpression collection)
  ;

data ACondPost = condPost(AExpression condition, AExpression result);

data AStructValue
  = structType(list[str] fieldNames)
  | structInstance(list[AField] fieldDefs)
  ;

data AField = fieldDef(str name, AExpression expr);

data AStructLiteral
  = structLit(list[AField] fieldList)
  | namedStruct(str name, list[AField] fieldList)
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