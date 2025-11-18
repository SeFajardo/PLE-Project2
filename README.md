## TUTO PROJECT 2
Acá explicamos como ejecutar nuestro proyecto
Descargar todo
Abrir una terminal de rascal
- import Parser;
- import Implode;
Estos 2 primeros imports deben mostrar ok

- cast = parseALU(|project://rascaldsl/instance/test.alu|);
Acá se guarda en cast el parseo del test.alu que tenemos en la carpeta instances

- ast = implodeAST(cast);
Este es el parseo

- ast
Acá se muestra de nuevo el parseo

Para crear un archivo con el Generator deben
- import Generator
Acá se importa la clase .rsc 

- generatePython(|project://rascaldsl/instance/test.alu|);
Con este se genera, va a quedar guardado en /rascaldsl/instance/output.py queda como un archivo py
Se debería ver lo siguiente:
- Código generado en: |project://rascaldsl/instance/output.py|

## TUTO PROJECT 3
- import Checker;
- checkAndReport(|project://rascaldsl/instance/test-typed.alu|);
- checkAndReport(|project://rascaldsl/instance/test-errors.alu|);

- El primero de test-typed es una gramática correcta, va a salir un error "Error durante la verificación: NoSuchAnnotation("src")", pero este no es relacionado a la syntaxis ni al parseo de los tipos de dato, sino que hubo un problema con algo del enrutamiento que no supimos resolver
- El segundo test es una gramática que no va a pasar, de una vez sale un error mostrando en que parte del archivo del test-errors.alu este esta fallando, es decir, donde la anotación de tipos no es correcta
