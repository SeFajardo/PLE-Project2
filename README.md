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
✓ Código generado en: |project://rascaldsl/instance/output.py|
