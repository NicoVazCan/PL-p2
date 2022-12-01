PRÁCTICAS BÁSICAS BLOQUE 1:

Autor: Nicolás Vázquez Cancela.

Desarrollo:
Para empezar, se formó la siguiente gramática que describe la estructura del archivo XML descrito en el enunciado:

S -> header opt OBJ opt
OBJ -> begtag COLECT endtag
COLECT -> COLECT OBJ | COLECT com | COLECT cont | COLECT opt | epsilon

Asumiendo; tags sin atributos, por lo que el comienzo y el fin de un tag pueden ser tratados directamente como tokens que contienen como valor el nombre del tag; no existen tags vacios (solo <...>, sin </...>) por simplicidad; los atributos de la cabecera no se tienen en cuenta, por lo que toda la cabecera será un solo token; no se comprueban el archivo frente a un DTB, por lo que no se incluirá el campo "standalone" en la cabecera.

Para detectar los tokens o símbolos terminales descritos en la anterior gramática, en la sección de declaraciones del archivo flex, se hicieron varias definiciones por cada token a modo de reglas para abreviar, estas "reglas" estan basadas en las de la especificación de XML de W3C.

Luego, en la sección de reglas, se creo una acción para cada token donde, aparte de devolver el identificador del token, se guarda la primera y última fila y columna, y a mayores en los tokens de comienzo y final de tag, se guardará el nombre. Estos datos se usarán para detectar e informar de fallos al parsear el fichero XML.

Finalmente, en fichero bison, se implementa cada regla de la gramática y a mayores, para cada una, se crean varias alternativas de encaje con el objetivo de detectar multiples fallos en la sintaxis del fichero XML y aportar en la acción, la información recogida en flex.
