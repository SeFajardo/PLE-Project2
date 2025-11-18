module Implode

import AST;
import Syntax;
import ParseTree;
import String;

public AProgram implodeAST(start[Program] tree) {
    return program([implodeStmt(s) | s <- tree.top.statements], src = tree@\loc);
}

public AStatement implodeStmt((Statement)`<Assignment a>`) = implodeAsgn(a);
public AStatement implodeStmt((Statement)`<FunctionDef f>`) = implodeFunStmt(f);
public AStatement implodeStmt((Statement)`<DataAbstraction d>`) = implodeDataAbs(d);

public AStatement implodeAsgn((Assignment)`<ID name> = <Expression e>`) {
    return assignment("<name>", noType(), implodeExpr(e), src = name@\loc);
}

public AStatement implodeAsgn((Assignment)`<ID name> <TypeAnnotation ta> = <Expression e>`) {
    return assignment("<name>", implodeTypeAnn(ta), implodeExpr(e), src = name@\loc);
}

public AStatement implodeFunStmt((FunctionDef)`<ID name> = function(<{Parameter ","}* params>) do <Statement* stmts> end <ID endName>`) {
    return functionDefStmt("<name>", [implodeParam(p) | p <- params], noType(), 
                          [implodeStmt(s) | s <- stmts], "<endName>", src = name@\loc);
}

public AStatement implodeFunStmt((FunctionDef)`<ID name> = function(<{Parameter ","}* params>) <TypeAnnotation rt> do <Statement* stmts> end <ID endName>`) {
    return functionDefStmt("<name>", [implodeParam(p) | p <- params], implodeTypeAnn(rt), 
                          [implodeStmt(s) | s <- stmts], "<endName>", src = name@\loc);
}

public AStatement implodeDataAbs((DataAbstraction)`<ID name> = data with <{ID ","}+ ids> <RepDef rd> <FunctionDef* funs> end <ID endName>`) {
    return dataAbstraction("<name>", noType(), ["<id>" | id <- ids], implodeRepDef(rd), 
                          [implodeFunDef(f) | f <- funs], "<endName>", src = name@\loc);
}

public AStatement implodeDataAbs((DataAbstraction)`<ID name> <TypeAnnotation ta> = data with <{ID ","}+ ids> <RepDef rd> <FunctionDef* funs> end <ID endName>`) {
    return dataAbstraction("<name>", implodeTypeAnn(ta), ["<id>" | id <- ids], implodeRepDef(rd), 
                          [implodeFunDef(f) | f <- funs], "<endName>", src = name@\loc);
}

public AParameter implodeParam((Parameter)`<ID name>`) {
    return param("<name>", noType());
}

public AParameter implodeParam((Parameter)`<ID name> <TypeAnnotation ta>`) {
    return param("<name>", implodeTypeAnn(ta));
}

// Implode de los tipos de anotación nuevos
public AType implodeTypeAnn((TypeAnnotation)`:<Type t>`) = implodeType(t);

public AType implodeType((Type)`<ID typeName>`) = basicType("<typeName>");
public AType implodeType((Type)`Int`) = basicType("Int");
public AType implodeType((Type)`Float`) = basicType("Float");
public AType implodeType((Type)`String`) = basicType("String");
public AType implodeType((Type)`Char`) = basicType("Char");
public AType implodeType((Type)`Bool`) = basicType("Bool");
public AType implodeType((Type)`[<Type et>]`) = listType(implodeType(et));
public AType implodeType((Type)`(<Type f>, <Type s>)`) = tupleType(implodeType(f), implodeType(s));
public AType implodeType((Type)`struct(<{TypedField ","}+ fields>)`) {
    return structTypeRef([implodeTypedField(tf) | tf <- fields]);
}

public ATypedField implodeTypedField((TypedField)`<ID name>:<Type t>`) {
    return typedField("<name>", implodeType(t));
}

public ARepDef implodeRepDef((RepDef)`rep = <StructValue sv>`) = repDef(implodeStructValue(sv));

public AStructValue implodeStructValue((StructValue)`<StructType st>`) = implodeStructType(st);
public AStructValue implodeStructValue((StructValue)`<StructInstance si>`) = implodeStructInstance(si);

public AStructValue implodeStructType((StructType)`struct(<{StructField ","}+ fields>)`) {
    return structType([implodeStructField(sf) | sf <- fields]);
}

public AStructField implodeStructField((StructField)`<ID name>`) = simpleField("<name>");
public AStructField implodeStructField((StructField)`<ID name>:<Type t>`) = typedStructField("<name>", implodeType(t));

public AStructValue implodeStructInstance((StructInstance)`struct(<{Field ","}+ fields>)`) {
    return structInstance([implodeField(f) | f <- fields]);
}

public AFunctionDef implodeFunDef((FunctionDef)`<ID name> = function(<{Parameter ","}* params>) do <Statement* stmts> end <ID endName>`) {
    return afunctionDef("<name>", [implodeParam(p) | p <- params], noType(), 
                       [implodeStmt(s) | s <- stmts], "<endName>", src = name@\loc);
}

public AFunctionDef implodeFunDef((FunctionDef)`<ID name> = function(<{Parameter ","}* params>) <TypeAnnotation rt> do <Statement* stmts> end <ID endName>`) {
    return afunctionDef("<name>", [implodeParam(p) | p <- params], implodeTypeAnn(rt), 
                       [implodeStmt(s) | s <- stmts], "<endName>", src = name@\loc);
}

public AField implodeField((Field)`<ID name>:<Expression e>`) {
    return fieldDef("<name>", implodeExpr(e), src = name@\loc);
}

public AExpression implodeExpr((Expression)`<ID name>`) = variable("<name>", src = name@\loc);
public AExpression implodeExpr((Expression)`<Literal lit>`) = literal(implodeLit(lit), src = lit@\loc);
public AExpression implodeExpr((Expression)`(<Expression e>)`) = implodeExpr(e);

public AExpression implodeExpr((Expression)`if <Expression cond> then <Expression thenE> else <Expression elseE> end`) {
    return ifExpr(implodeExpr(cond), implodeExpr(thenE), implodeExpr(elseE), src = cond@\loc);
}

public AExpression implodeExpr((Expression)`for <ID var> <ForRange range> do <Statement* stmts> end`) {
    return forExpr("<var>", implodeForRange(range), [implodeStmt(s) | s <- stmts], src = var@\loc);
}

public AExpression implodeExpr((Expression)`cond <Expression e> do <CondPost+ posts> end`) {
    return condExpr(implodeExpr(e), [implodeCondPost(cp) | cp <- posts], src = e@\loc);
}

public AExpression implodeExpr((Expression)`[<{Expression ","}* elems>]`) {
    return sequence([implodeExpr(e) | e <- elems], src = elems@\loc);
}

public AExpression implodeExpr((Expression)`(<Expression f>,<Expression s>)`) {
    return tup(implodeExpr(f), implodeExpr(s), src = f@\loc);
}

public AExpression implodeExpr((Expression)`<StructLiteral sl>`) {
    return structLiteral(implodeStructLit(sl), src = sl@\loc);
}

public AExpression implodeExpr((Expression)`iterator(<Expression coll>) yielding(<ID var>)`) {
    return iterator(implodeExpr(coll), "<var>", src = coll@\loc);
}

public AExpression implodeExpr((Expression)`<Expression e>(<{Expression ","}* args>)`) {
    return call(implodeExpr(e), [implodeExpr(a) | a <- args], src = e@\loc);
}

public AExpression implodeExpr((Expression)`<Expression e>.<ID field>`) {
    return fieldAccess(implodeExpr(e), "<field>", src = e@\loc);
}

public AExpression implodeExpr((Expression)`<Expression e>$<ID field>`) {
    return dollarAccess(implodeExpr(e), "<field>", src = e@\loc);
}

public AExpression implodeExpr((Expression)`neg <Expression e>`) = neg(implodeExpr(e), src = e@\loc);
public AExpression implodeExpr((Expression)`<Expression l> ** <Expression r>`) = power(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> * <Expression r>`) = multiply(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> / <Expression r>`) = divide(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> % <Expression r>`) = modulo(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> + <Expression r>`) = add(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> - <Expression r>`) = subtract(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> \< <Expression r>`) = lessThan(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> \> <Expression r>`) = greaterThan(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> \<= <Expression r>`) = lessOrEqual(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> \>= <Expression r>`) = greaterOrEqual(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> \<\> <Expression r>`) = notEqual(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> = <Expression r>`) = equal(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> and <Expression r>`) = andOp(implodeExpr(l), implodeExpr(r), src = l@\loc);
public AExpression implodeExpr((Expression)`<Expression l> or <Expression r>`) = orOp(implodeExpr(l), implodeExpr(r), src = l@\loc);

default AExpression implodeExpr(Expression e) { 
    throw "Expression no implementada: <e>"; 
}

public AForRange implodeForRange((ForRange)`from <Expression f> to <Expression t>`) = fromTo(implodeExpr(f), implodeExpr(t));
public AForRange implodeForRange((ForRange)`in <Expression c>`) = inRange(implodeExpr(c));

public ACondPost implodeCondPost((CondPost)`<Expression cond> -\> <Expression res>`) {
    return condPost(implodeExpr(cond), implodeExpr(res));
}

public AStructLiteral implodeStructLit((StructLiteral)`struct(<{Field ","}+ fields>)`) {
    return structLit([implodeField(f) | f <- fields], src = fields@\loc);
}

public AStructLiteral implodeStructLit((StructLiteral)`<ID name>$(<{Field ","}+ fields>)`) {
    return namedStruct("<name>", [implodeField(f) | f <- fields], src = name@\loc);
}

public ALiteral implodeLit((Literal)`<Number n>`) = numberLit(implodeNum(n));
public ALiteral implodeLit((Literal)`<STRING s>`) { 
    str c = "<s>"; 
    return stringLit(c[1..-1]); 
}
public ALiteral implodeLit((Literal)`<CHAR c>`) { 
    str ch = "<c>"; 
    return charLit(ch[1..-1]); 
}
public ALiteral implodeLit((Literal)`<BOOLEAN b>`) = boolLit("<b>" == "true");

public ANumber implodeNum((Number)`<INT i>`) = intNumber(toInt("<i>"));
public ANumber implodeNum((Number)`<FLOAT f>`) = floatNumber(toReal("<f>"));
