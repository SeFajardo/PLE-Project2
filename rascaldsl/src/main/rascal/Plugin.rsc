module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;
import Syntax;

PathConfig pcfg = getProjectPathConfig(|project://rascaldsl|);

Language aluLang = language(pcfg, "ALU", "alu", "Plugin", "contribs");

set[LanguageService] contribs() = {
    parser(start[Program] (str program, loc src) {
        return parse(#start[Program], program, src);
    })
};

void main() {
    registerLanguage(aluLang);
    println("Lenguaje ALU creado");
}