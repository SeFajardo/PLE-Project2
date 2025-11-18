module Checker

import AST;
import Syntax;
import Implode;
import Parser;

import analysis::typepal::TypePal;

import ParseTree;
import IO;
import Set;
import String;
import List;

data AluType
  = intType()
  | floatType()
  | stringType()
  | charType()
  | boolType()
  | listType(AluType elemType)
  | tupleType(AluType fst, AluType snd)
  | structType(str name, map[str, AluType] fields)
  | functionType(list[AluType] paramTypes, AluType returnType)
  | anyType()
  ;

str prettyPrintAluType(intType()) = "Int";
str prettyPrintAluType(floatType()) = "Float";
str prettyPrintAluType(stringType()) = "String";
str prettyPrintAluType(charType()) = "Char";
str prettyPrintAluType(boolType()) = "Bool";
str prettyPrintAluType(listType(AluType et)) = "[<prettyPrintAluType(et)>]";
str prettyPrintAluType(tupleType(AluType f, AluType s)) = "(<prettyPrintAluType(f)>, <prettyPrintAluType(s)>)";
str prettyPrintAluType(structType(str name, map[str, AluType] fields)) = "struct <name>";
str prettyPrintAluType(functionType(list[AluType] params, AluType ret)) = 
    "function(<intercalate(", ", [prettyPrintAluType(p) | p <- params])>) : <prettyPrintAluType(ret)>";
str prettyPrintAluType(anyType()) = "Any";

AluType convertAType(basicType(str name)) {
    switch(name) {
        case "Int": return intType();
        case "Float": return floatType();
        case "String": return stringType();
        case "Char": return charType();
        case "Bool": return boolType();
        default: return anyType();
    }
}

AluType convertAType(listType(AType et)) = listType(convertAType(et));
AluType convertAType(tupleType(AType f, AType s)) = tupleType(convertAType(f), convertAType(s));
AluType convertAType(structTypeRef(list[ATypedField] fields)) {
    map[str, AluType] fieldMap = ();
    for (typedField(str name, AType t) <- fields) {
        fieldMap[name] = convertAType(t);
    }
    return structType("", fieldMap);
}
AluType convertAType(noType()) = anyType();

data IdRole
  = variableId()
  | functionId()
  | dataTypeId()
  | parameterId()
  | fieldId()
  ;

str prettyRole(variableId()) = "variable";
str prettyRole(functionId()) = "function";
str prettyRole(dataTypeId()) = "data type";
str prettyRole(parameterId()) = "parameter";
str prettyRole(fieldId()) = "field";

data PathRole
  = importPath()
  ;

tuple[list[str] typeNames, set[IdRole] idRoles] aluGetTypeNamesAndRole(AluType _) {
    return <[], {}>;
}

bool aluIsSubType(AluType t1, AluType t2) {
    return t1 == t2 || t2 == anyType() || t1 == anyType();
}

TypePalConfig aluConfig() = tconfig(
    getTypeNamesAndRole = aluGetTypeNamesAndRole,
    isSubType = aluIsSubType
);

void collect(AProgram prog, Collector c) {
    for (stmt <- prog.statements) {
        collectStatement(stmt, c);
    }
}

void collectStatement(AStatement stmt, Collector c) {
    loc src = stmt@src;
    
    switch(stmt) {
        case assignment(str name, AType typeAnn, AExpression expr): {
            c.define(name, variableId(), src, defType(convertAType(typeAnn)));
            collectExpression(expr, c);
            
            if (typeAnn != noType()) {
                c.requireEqual(convertAType(typeAnn), expr, error(src, "El tipo de la expresión no coincide con la anotación"));
            }
        }
        
        case functionDefStmt(str name, list[AParameter] params, AType returnType, 
                             list[AStatement] stmts, str endName): {
            if (name != endName) {
                c.report(error(src, "El nombre de cierre \'<endName>\' no coincide con el nombre de función \'<name>\'"));
            }
        
            list[AluType] paramTypes = [convertAType(p.typeAnn) | p <- params];
            AluType funType = functionType(paramTypes, convertAType(returnType));
            c.define(name, functionId(), src, defType(funType));
            
            for (param(str pname, AType ptype) <- params) {
                c.define(pname, parameterId(), src, defType(convertAType(ptype)));
            }
            
            for (s <- stmts) {
                collectStatement(s, c);
            }
        }
        
        case dataAbstraction(str name, AType typeAnn, list[str] identifiers, 
                            ARepDef repDef, list[AFunctionDef] functions, str endName): {
            if (name != endName) {
                c.report(error(src, "El nombre de cierre \'<endName>\' no coincide con el nombre de data \'<name>\'"));
            }
            
            map[str, AluType] structFields = ();
            
            if (structType(list[AStructField] fields) := repDef.structVal) {
                for (field <- fields) {
                    switch(field) {
                        case simpleField(str fname):
                            structFields[fname] = anyType();
                        case typedStructField(str fname, AType ftype):
                            structFields[fname] = convertAType(ftype);
                    }
                }
            } else if (structInstance(list[AField] fieldDefs) := repDef.structVal) {
                for (fieldDef(str fname, AExpression expr) <- fieldDefs) {
                    structFields[fname] = anyType();
                    collectExpression(expr, c);
                }
            }
            
            for (id <- identifiers) {
                if (id notin structFields) {
                    c.report(error(src, "El identificador \'<id>\' no existe en la definición de la estructura. Campos disponibles: <intercalate(", ", [k | k <- structFields])>"));
                }
            }
            
            AluType dataType = structType(name, structFields);
            c.define(name, dataTypeId(), src, defType(dataType));
            
            for (fun <- functions) {
                collectFunctionDef(fun, name, c);
            }
        }
    }
}

void collectFunctionDef(AFunctionDef funDef, str dataName, Collector c) {
    loc src = funDef@src;
    
    switch(funDef) {
        case afunctionDef(str name, list[AParameter] params, AType returnType,
                         list[AStatement] stmts, str endName): {
            if (name != endName) {
                c.report(error(src, "El nombre de cierre \'<endName>\' no coincide con el nombre de función \'<name>\'"));
            }
            
            list[AluType] paramTypes = [convertAType(p.typeAnn) | p <- params];
            AluType funType = functionType(paramTypes, convertAType(returnType));
            
            c.define(name, functionId(), src, defType(funType));
            
            for (param(str pname, AType ptype) <- params) {
                c.define(pname, parameterId(), src, defType(convertAType(ptype)));
            }
            
            for (stmt <- stmts) {
                collectStatement(stmt, c);
            }
        }
    }
}

void collectExpression(AExpression expr, Collector c) {
    loc src = expr@src;
    
    switch(expr) {
        case variable(str name): {
            c.use(name, {variableId(), parameterId(), functionId(), dataTypeId()}, src);
        }
        
        case literal(ALiteral lit): {
            c.fact(src, getLiteralType(lit));
        }
        
        case ifExpr(AExpression condition, AExpression thenPart, AExpression elsePart): {
            collectExpression(condition, c);
            collectExpression(thenPart, c);
            collectExpression(elsePart, c);
            
            c.requireEqual(boolType(), condition, 
                error(condition@src, "La condición debe ser de tipo Bool"));
            c.requireEqual(thenPart, elsePart, 
                error(src, "Las ramas then y else deben tener el mismo tipo"));
            
            c.fact(src, anyType());
        }
        
        case forExpr(str var, AForRange range, list[AStatement] stmts): {
            switch(range) {
                case fromTo(AExpression from, AExpression to): {
                    collectExpression(from, c);
                    collectExpression(to, c);
                    c.requireEqual(intType(), from, error(from@src, "El valor inicial debe ser de tipo Int"));
                    c.requireEqual(intType(), to, error(to@src, "El valor final debe ser de tipo Int"));
                    c.define(var, variableId(), src, defType(intType()));
                }
                case inRange(AExpression collection): {
                    collectExpression(collection, c);
                    c.define(var, variableId(), src, defType(anyType()));
                }
            }
            
            for (stmt <- stmts) {
                collectStatement(stmt, c);
            }
            
            c.fact(src, anyType());
        }
        
        case condExpr(AExpression expr, list[ACondPost] condPosts): {
            collectExpression(expr, c);
            for (condPost(AExpression condition, AExpression result) <- condPosts) {
                collectExpression(condition, c);
                collectExpression(result, c);
                c.requireEqual(boolType(), condition, error(condition@src, "La condición debe ser de tipo Bool"));
            }
            c.fact(src, anyType());
        }
        
        case sequence(list[AExpression] elements): {
            AluType elemType = anyType();
            for (elem <- elements) {
                collectExpression(elem, c);
            }
            c.fact(src, listType(elemType));
        }
        
        case tup(AExpression fst, AExpression snd): {
            collectExpression(fst, c);
            collectExpression(snd, c);
            c.fact(src, tupleType(anyType(), anyType()));
        }
        
        case structLiteral(AStructLiteral structLit): {
            switch(structLit) {
                case structLit(list[AField] fields): {
                    for (fieldDef(str fname, AExpression fexpr) <- fields) {
                        collectExpression(fexpr, c);
                    }
                    c.fact(src, anyType());
                }
                case namedStruct(str name, list[AField] fields): {
                    c.use(name, {dataTypeId()}, structLit@src);
                    
                    for (fieldDef(str fname, AExpression fexpr) <- fields) {
                        collectExpression(fexpr, c);
                    }
                    
                    c.fact(src, anyType());
                }
            }
        }
        
        case iterator(AExpression collection, str var): {
            collectExpression(collection, c);
            c.fact(src, anyType());
        }
        
        case call(AExpression callee, list[AExpression] args): {
            collectExpression(callee, c);
            for (arg <- args) {
                collectExpression(arg, c);
            }
            c.fact(src, anyType());
        }
        
        case fieldAccess(AExpression obj, str fieldName): {
            collectExpression(obj, c);
            c.fact(src, anyType());
        }
        
        case dollarAccess(AExpression obj, str fieldName): {
            collectExpression(obj, c);
            c.fact(src, anyType());
        }
        
        case neg(AExpression operand): {
            collectExpression(operand, c);
            c.requireEqual(intType(), operand, error(operand@src, "neg solo se puede aplicar a Int"));
            c.fact(src, intType());
        }
        
        case power(AExpression base, AExpression exponent): {
            collectExpression(base, c);
            collectExpression(exponent, c);
            c.requireEqual(intType(), base, error(base@src, "La base debe ser de tipo Int"));
            c.requireEqual(intType(), exponent, error(exponent@src, "El exponente debe ser de tipo Int"));
            c.fact(src, intType());
        }
        
        case multiply(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.calculate("multiply type", src, [left, right],
                AluType(Solver s) {
                    ltype = s.getType(left);
                    rtype = s.getType(right);
                    if (ltype == intType() && rtype == intType()) return intType();
                    if ((ltype == floatType() || ltype == intType()) && 
                        (rtype == floatType() || rtype == intType())) return floatType();
                    return anyType();
                }
            );
        }
        
        case divide(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.calculate("divide type", src, [left, right],
                AluType(Solver s) {
                    ltype = s.getType(left);
                    rtype = s.getType(right);
                    if ((ltype == floatType() || ltype == intType()) && 
                        (rtype == floatType() || rtype == intType())) return floatType();
                    return anyType();
                }
            );
        }
        
        case modulo(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.requireEqual(intType(), left, error(left@src, "El operando izquierdo debe ser Int"));
            c.requireEqual(intType(), right, error(right@src, "El operando derecho debe ser Int"));
            c.fact(src, intType());
        }
        
        case add(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.calculate("add type", src, [left, right],
                AluType(Solver s) {
                    ltype = s.getType(left);
                    rtype = s.getType(right);
                    if (ltype == intType() && rtype == intType()) return intType();
                    if ((ltype == floatType() || ltype == intType()) && 
                        (rtype == floatType() || rtype == intType())) return floatType();
                    if (ltype == stringType() && rtype == stringType()) return stringType();
                    return anyType();
                }
            );
        }
        
        case subtract(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.calculate("subtract type", src, [left, right],
                AluType(Solver s) {
                    ltype = s.getType(left);
                    rtype = s.getType(right);
                    if (ltype == intType() && rtype == intType()) return intType();
                    if ((ltype == floatType() || ltype == intType()) && 
                        (rtype == floatType() || rtype == intType())) return floatType();
                    return anyType();
                }
            );
        }
        
        case lessThan(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.fact(src, boolType());
        }
        
        case greaterThan(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.fact(src, boolType());
        }
        
        case lessOrEqual(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.fact(src, boolType());
        }
        
        case greaterOrEqual(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.fact(src, boolType());
        }
        
        case notEqual(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.fact(src, boolType());
        }
        
        case equal(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.fact(src, boolType());
        }
        
        case andOp(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.requireEqual(boolType(), left, error(left@src, "El operando izquierdo debe ser Bool"));
            c.requireEqual(boolType(), right, error(right@src, "El operando derecho debe ser Bool"));
            c.fact(src, boolType());
        }
        
        case orOp(AExpression left, AExpression right): {
            collectExpression(left, c);
            collectExpression(right, c);
            c.requireEqual(boolType(), left, error(left@src, "El operando izquierdo debe ser Bool"));
            c.requireEqual(boolType(), right, error(right@src, "El operando derecho debe ser Bool"));
            c.fact(src, boolType());
        }
    }
}

AluType getLiteralType(numberLit(intNumber(_))) = intType();
AluType getLiteralType(numberLit(floatNumber(_))) = floatType();
AluType getLiteralType(stringLit(_)) = stringType();
AluType getLiteralType(charLit(_)) = charType();
AluType getLiteralType(boolLit(_)) = boolType();

public TModel checkALU(start[Program] tree) {
    AProgram ast = implodeAST(tree);
    return checkALU(ast, tree@\loc);
}

public TModel checkALU(AProgram ast, loc origin) {
    c = newCollector("ALU", ast, aluConfig());
    
    collect(ast, c);
    
    return validate(c);
}

public TModel checkALU(loc file) {
    start[Program] tree = parseALU(file);
    return checkALU(tree);
}

public void checkAndReport(loc file) {
    try {
        TModel tm = checkALU(file);
        if (tm.messages == {}) {
            println("Verificación exitosa: No se encontraron errores de tipos");
        } else {
            println("Se encontraron <size(tm.messages)> error(es):");
            for (msg <- tm.messages) {
                println("  - <msg>");
            }
        }
    } catch e: {
        println("Error durante la verificación: <e>");
    }
}
