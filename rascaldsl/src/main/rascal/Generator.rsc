module Generator

import AST;
import Parser;
import Implode;
import IO;
import String;
import List;

data GenStatement = genStatement(str text = "", str statementType = "");

list[str] allVariables = [];
list[GenStatement] allStatements = [];

void generate(AProgram prog) {
    allVariables = [];
    allStatements = [];
    for (stmt <- prog.statements) {
        generate(stmt);
    }
}

void generate(assignment(str name, AExpression expr)) {
    allVariables += name;
    exprText = generateExpression(expr);
    allStatements += genStatement(text = "<name> = <exprText>", statementType = "assignment");
}

void generate(functionDefStmt(str name, list[str] params, list[AStatement] stmts, str endName)) {
    allVariables += name;
    paramList = intercalate(", ", params);
    allStatements += genStatement(text = "def <name>(<paramList>):", statementType = "function");
    
    for (stmt <- stmts) {
        generate(stmt);
    }
}

void generate(dataAbstraction(str name, list[str] identifiers, ARepDef repDef, 
                              list[AFunctionDef] functions, str endName)) {
    allVariables += name;
    allStatements += genStatement(text = "class <name>:", statementType = "data");
}

str generateExpression(variable(str name)) = name;

str generateExpression(literal(ALiteral lit)) = generateLiteral(lit);

str generateExpression(ifExpr(AExpression condition, AExpression thenPart, AExpression elsePart)) {
    cond = generateExpression(condition);
    thenE = generateExpression(thenPart);
    elseE = generateExpression(elsePart);
    return "(<thenE> if <cond> else <elseE>)";
}

str generateExpression(add(AExpression left, AExpression right)) {
    return "(<generateExpression(left)> + <generateExpression(right)>)";
}

str generateExpression(subtract(AExpression left, AExpression right)) {
    return "(<generateExpression(left)> - <generateExpression(right)>)";
}

str generateExpression(multiply(AExpression left, AExpression right)) {
    return "(<generateExpression(left)> * <generateExpression(right)>)";
}

str generateExpression(divide(AExpression left, AExpression right)) {
    return "(<generateExpression(left)> / <generateExpression(right)>)";
}

str generateExpression(power(AExpression base, AExpression exponent)) {
    return "(<generateExpression(base)> ** <generateExpression(exponent)>)";
}

str generateExpression(lessThan(AExpression left, AExpression right)) {
    return "(<generateExpression(left)> \< <generateExpression(right)>)";
}

str generateExpression(greaterThan(AExpression left, AExpression right)) {
    return "(<generateExpression(left)> \> <generateExpression(right)>)";
}

str generateExpression(equal(AExpression left, AExpression right)) {
    return "(<generateExpression(left)> == <generateExpression(right)>)";
}

str generateLiteral(numberLit(ANumber n)) = generateNumber(n);
str generateLiteral(stringLit(str s)) = s;
str generateLiteral(charLit(str c)) = "\'<c>\'";
str generateLiteral(boolLit(bool b)) = b ? "True" : "False";

str generateNumber(intNumber(int intVal)) = "<intVal>";
str generateNumber(floatNumber(real floatVal)) = "<floatVal>";

public str generatePython(loc file) {
    cast = parseALU(file);
    ast = implodeAST(cast);
    generate(ast);
    
    result = "# Generated Python code\n\n";
    for (stmt <- allStatements) {
        result += "<stmt.text>\n";
    }
    
    return result;
}

public void generateToFile(loc inputFile, loc outputFile) {
    code = generatePython(inputFile);
    writeFile(outputFile, code);
    println("Código generado en: <outputFile>");
}