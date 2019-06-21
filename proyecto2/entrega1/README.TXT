Esta es una entrega provisional. El programa principal está listo, pero el informe
no lo está. 

<< Equipo >>

Luis Diaz: 15-10420.
Valentina Aguana: 15-10011.

<< Descripción de los archivos >>

	myexceptions.s: Archivo manejador de excepciones que contiene el planificador
	
	instrumentador.asm: Archivo con el código del instrumentador. Es independiente
del manejador de excepciones y el planificador, pero el planificador depende de él.

	testCasesHandler.asm: Un scrip auxiliar para probar casos de prueba. En él se 
encuentran instrucciones de cómo usarlo.

	myprogs.s: Un caso de prueba provisto y probado, completamente funcional.

<< Instrucciones de uso >>

	Para poder utilizar las funciones de next/prev program, será necesario activar 
el simulador MMIO de Mars y establecer el "delay" como "fixed" y fijarlo en el valor 
mínimo posible. Luego, se debe presionar s o p segun se desee procurando que el 
programa esté corriendo en el área de texto. Para esto es recomendable disminuir la 
velocidad de ejecución a 5 o 10 instr/s durante la ejecución de los programas de 
prueba. También es posible spammear uno de los botones, pero esto puede no ser efectivo.

	Para probar el programa, se debe correr el archivo "testCasesHandler.asm" segun
las instrucciones proporcionadas en el mismo.



