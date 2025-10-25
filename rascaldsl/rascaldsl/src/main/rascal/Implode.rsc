module Implode

import AST;
import Syntax;
import ParseTree;

public AProgram implodeAST(start[Program] tree) {
    return implode(#AProgram, tree);
}