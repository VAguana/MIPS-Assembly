
# Este es el manejador de casos de prueba. Para probar un caso, 
# se modifica el segundo .include para poner el caso de prueba probar.
# Luego se ensambla y corre este archivo.

.include "testExcp.asm"  # No modificar, importa el manejador de excepciones.
.include "myprogs.s"     # Modificar: poner aquí el nombre del archivo con el caso de prueba
			 # que se desea probar.