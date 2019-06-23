
# Este es el manejador de casos de prueba. Para probar un caso, 
# se modifica el segundo .include para poner el caso de prueba probar.
# Luego se ensambla y corre este archivo.

.include "myexceptions.s"  # No modificar, importa el manejador de excepciones.
.include "Caso1.s"     # Modificar: poner aquí el nombre del archivo con el caso de prueba
			 # que se desea probar.
