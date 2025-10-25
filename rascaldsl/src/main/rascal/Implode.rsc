module Implode

import AST;
import Syntax;
import ParseTree;
import String;

public AProgram implodeAST(start[Program] tree) {
    return program([implodeStmt(s) | s <- tree.top.statements]);
}

public AStatement implodeStmt((Statement)`<Assignment a>`) = implodeAsgn(a);
public AStatement implodeStmt((Statement)`<FunctionDef f>`) = implodeFun(f);

public AStatement implodeAsgn((Assignment)`<ID name> = <Expression e>`) {
    return assignment("<name>", implodeExpr(e));
}

public AStatement implodeFun((FunctionDef)`<ID name> = function(<{ID ","}* params>) do <Statement* stmts> end <ID endName>`) {
    return functionDefStmt("<name>", ["<p>" | p <- params], [implodeStmt(s) | s <- stmts], "<endName>");
}

public AExpression implodeExpr((Expression)`<ID name>`) = variable("<name>");
public AExpression implodeExpr((Expression)`<Literal lit>`) = literal(implodeLit(lit));
public AExpression implodeExpr((Expression)`if <Expression cond> then <Expression thenE> else <Expression elseE> end`) {
    return ifExpr(implodeExpr(cond), implodeExpr(thenE), implodeExpr(elseE));
}
public AExpression implodeExpr((Expression)`<Expression l> ** <Expression r>`) = power(implodeExpr(l), implodeExpr(r));
public AExpression implodeExpr((Expression)`<Expression l> * <Expression r>`) = multiply(implodeExpr(l), implodeExpr(r));
public AExpression implodeExpr((Expression)`<Expression l> / <Expression r>`) = divide(implodeExpr(l), implodeExpr(r));
public AExpression implodeExpr((Expression)`<Expression l> + <Expression r>`) = add(implodeExpr(l), implodeExpr(r));
public AExpression implodeExpr((Expression)`<Expression l> - <Expression r>`) = subtract(implodeExpr(l), implodeExpr(r));
public AExpression implodeExpr((Expression)`<Expression l> \< <Expression r>`) = lessThan(implodeExpr(l), implodeExpr(r));
public AExpression implodeExpr((Expression)`<Expression l> \> <Expression r>`) = greaterThan(implodeExpr(l), implodeExpr(r));
public AExpression implodeExpr((Expression)`<Expression l> = <Expression r>`) = equal(implodeExpr(l), implodeExpr(r));

default AExpression implodeExpr(Expression e) { throw "No implementado: <e>"; }

public ALiteral implodeLit((Literal)`<Number n>`) = numberLit(implodeNum(n));
public ALiteral implodeLit((Literal)`<STRING s>`) { str c = "<s>"; return stringLit(c[1..-1]); }
public ALiteral implodeLit((Literal)`<CHAR c>`) { str ch = "<c>"; return charLit(ch[1..-1]); }
public ALiteral implodeLit((Literal)`<BOOLEAN b>`) = boolLit("<b>" == "true");

public ANumber implodeNum((Number)`<INT i>`) = intNumber(toInt("<i>"));
public ANumber implodeNum((Number)`<FLOAT f>`) = floatNumber(toReal("<f>"));