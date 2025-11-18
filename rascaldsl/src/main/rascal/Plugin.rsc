module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;
import Syntax;
import Checker;
import analysis::typepal::TypePal;

PathConfig pcfg = getProjectPathConfig(|project://rascaldsl|);

Language aluLang = language(pcfg, "ALU", "alu", "Plugin", "contribs");

set[LanguageService] contribs() = {
    parser(start[Program] (str program, loc src) {
        return parse(#start[Program], program, src);
    }),

    lenses(rel[loc, Command] (start[Program] input) {
        return {};
    }),
    
    analyzer(start[Program] (start[Program] input) {
        TModel tm = checkALU(input);
        return input[@messages=tm.messages];
    })
};

void main() {
    registerLanguage(aluLang);
    println("Lenguaje ALU registrado con TypePal");
}
