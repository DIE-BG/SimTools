# SimTools
 
 Paquete para la simulación de modelos DSGE en MATLAB a través del paquete IRIS.
 
 Para agregar en MATLAB debe seguir los suguientes pasos:
 
 1. Clonar el repositorio y guardarlo en una carpeta con acceso.
 2. En la cinta de opciones de MATLAB ir a la sección `ENVIRONMENT` y seleccionar `Set Path`.
 3. En la ventana emergente buscar el directorio donde está guardado el repositorio clonado en el paso 1, aceptar los cambios.
 
 Para utiliar el paquete debe escribir el nombre del paquete seguido de `.`  y el nombre del módulo.
 
 Ejemplo:
 ```
 SimTools.sim.read_model
 ```
 La instrucción indica que se está llamando la función `read_model` del módulo `sim` del paquete `SimTools`.
 
 Para acceder a la ayuda de las funciones se puede utiliar el comando `help`. 
 
 Ejemplo:
 ```
 help SimTools.sim.read_model
 ```
 La instrucción mostrará la ayuda de la función `read_model`.
