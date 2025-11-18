module Parser

import Syntax;
import ParseTree;
import IO;

public start[Program] parseALU(str src, loc origin) {
    return parse(#start[Program], src, origin);
}

public start[Program] parseALU(loc file) {
    return parse(#start[Program], file);
}