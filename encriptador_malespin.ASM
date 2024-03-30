;--------------------------------------------Portada------------------------------------------------------------------------------------
; Tarea corta de ASM: Encriptador Malespin-Numerico
; Curso: Fundamentos de Organizacion de Computadores
; Grupo: 3
; Escuela de Computacion
; Instituto Tecnologico de Costa Rica
; Fecha de entrega: Miercoles 29 de julio del 2020
; Estudiante: Alejandro Castro Araya
; Carne: 2020034944
; Profesor: Kirstein Gatjens
;--------------------------------------------Manual de Usuario-------------------------------------------------------------------------
; Este programa convierte lo que el usuario escribe en la linea de comandos luego de la opcion escogida. La codifiacion a la que se convierte depende de la opcion. La opcion es escogida con un guion y luego una letra especifica pegados.
; -M Traduce al Malespin o de el, porque es bidireccional
; -E Traduce de codificacion numerica a espanol
; -N Traduce del espanol a codificacion numerica
; -H Despliega la ayuda del programa con las opciones usadas para convertir y la descripcion del programa
;--------------------------------------------Analisis de resultados--------------------------------------------------------------------
;+---------------------------------------------------------------------------------------------+------+------------------------+
;|                                            Parte                                            | Nota | Explicacion Adicional  |
;+---------------------------------------------------------------------------------------------+------+------------------------+
;| Mini acerca de                                                                              | A    | Funciona correctamente |
;| Recibir las 4 posibles opciones y lo que se quiere convertir en la linea de comandos        | A    | Funciona correctamente |
;| -H despliega ayuda cuando es solicitada y cuando no se escribe nada                         | A    | Funciona correctamente |
;| -M traduce a malespin y de malespin correctamente                                           | A    | Funciona correctamente |
;| -E traduce de la codificacion numerica al espanol correctamente                             | A    | Funciona correctamente |
;| -N traduce del espanol a la codificacion numerica correctamente                             | A    | Funciona correctamente |
;| Desplegar a la salida solamente la tira codificada a como se solicitó                       | A    | Funciona correctamente |
;| Documentación (Portada, manual de usuario y analisis de resultados con ABCDE) y comentarios | A    | Escrita correctamente  |
;+---------------------------------------------------------------------------------------------+------+------------------------+
;--------------------------------------------Conclusiones-----------------------------------------------------------------------------
;1. Al iniciar con esta tarea, yo creia que ensamblador era imposible de entender para una persona normal y que era demasiado avanzado. Sin embargo, luego de investigar extensivamente sobre como funciona TASM y ensamblador en si,
;me di cuenta de que en realidad es cuestion de entender como funciona el codigo maquina y de no ser intimidado por todos los numeros e interrupts que se ven.
;
;2. Los labels, interrupts, jumps, y compares son esenciales para intentar hacer un programa que realice conversiones, ya que me permitieron programar todas las codificaciones necesarias para que el programa funcione, por medio de usar
;estos elementos mencionados extensivamente.
;
;3. Al querer obtener lo que se escribe en la linea de comandos, en mi experiencia personal, lo que se tuvo que hacer fue: primero mover 82h al source index. Luego de eso, para la opcion con guion, se agarra el byte que esta en
;si+1, ya que en si esta el guion, lo que no sirve para determinar la opcion. Luego, para obtener lo que se escribio que se desea convertir, se debe crear un ciclo que obtenga el primer byte luego del espacio que va despues de la opcion
;elegida, y luego se le va incrementando por medio de inc (use bx+si y luego inc bx para hacer esto) para obtener los siguientes bytes de la palabra. Luego, simplemente use un compare con el valor del espacio en hexadecimal, el cual es
;20h, y si el valor del byte es menor eso significa que ya se acabo la palabra, por lo que ya se puede parar el ciclo.
;
;4. Conclui personalmente que ensamblador es un lenguaje que honestamente primero me daba mucho miedo y me confundia, pero cuando lo entendi mas, la verdad me intereso mucho, se sintio muy satisfactorio hacer assemble sin que tuviera
;errores en el TASM o en el linker, y ya cuando uno entiende que hacen los interrupts y los registers, uno se da cuenta de que si es posible programar en ensamblador aunque se vea muy dificil. Por ende, me gusto mucho esta tarea y espero
;pasar a Arqui para poder aprender mas sobre ensamblador y aprender a hacer programas mas complicados en el, aunque estoy seguro que van a ser mucho mas complicados que este.
;-----------------------------------------------------------------------------------------------------------------------------------


data segment

	acercade db 'FOC Grupo 3 Alejandro Castro Araya Tarea ASM' ,13, 10, 'Carne 2020034944 Ver. 0.74-3 23/07/2020', 13, 10, ' ', 13, 10, '$'
	letra db 80, 0, 80 dup('$')
	ayuda db 'Convierte lo que escribe luego de la opcion escogida. -E convierte numeros a espanol, -N convierte espanol a numeros, -M convierte de y hacia malespin, -H da ayuda.$'
	output db 81 dup('$')
	

data ends


pila segment stack 'stack'
   dw 256 dup(?)

pila ends


code segment
.model small
.386

        assume  cs:code, ds:data, ss:pila

start:

	mov ax,ds ; Se mueve ds a es
	mov es,ax

	mov ax,data ; Inicializa el data segment mandandolo al ds register
	mov ds,ax

	mov ax,pila ; Inicializa la pila mandandola al ss register
	mov ss,ax

	mov si,82h ; Se mueve lo que se puso en la command line al source index empezando por el guion
	mov bl,byte ptr es:[si+1] ; Se mueve la letra que se escribio luego del guion a bl
	mov letra,bl ; Se mueve la letra que se escribio luego del guion a la variable letra por medio de mover bl a letra

	lea dx,acercade ; Asigna la address del acerca de al registro dx
	mov ah,9h ; Hace un DOS interrupt y hace display del mini acerca de que tiene la address cargada en DX
	int 21h

	mov bx,2 ; Le pongo 2 a bx para poder luego enciclarlo para conseguir todos los bytes de lo que se desea convertir
	mov cx,2

esVacio:

	cmp letra,20h ; Reviso si no se puso nada en la linea de comandos comparandolo con un caracter de espacio
	jl darAyuda ; Si es menor que un espacio no se puso nada, y en ese caso se despliega la ayuda

esH:

	cmp letra,48h ; Comparo el valor de la letra escogida como opcion con el valor hexadecimal de H mayuscula
	jne esE ; Si es igual significa que la letra es una H mayuscula, por lo que voy al label de dar ayuda ya que la H es para desplegar la ayuda
	je darAyuda ; Hago el jump al label de desplegar la ayuda

darAyuda:

	lea dx,ayuda ; Asigna la address de la variable con la ayuda del programa a dx
	mov ah,9h ; Hace el interrupt para hacer display a la ayuda del programa
	int 21h
	jmp terminar ; Luego de desplegar la ayuda, termina el programa

esE:

	cmp letra,45h ; Revisa si la letra luego del guion es una E por medio de comparar con el valor hexadecimal de E mayuscula
	jne esN ; Si no es E, salta al label que hice para revisar si es N
	je EspanolLuegoDeGuion ; Si es E, salta al label que hice para el procedimiento que deberia seguir si escogio E
	int 21h

esN:

	cmp letra,4Eh ; Revisa si la letra luego del guion es una N por medio de comparar con el valor hexadecimal de N mayuscula
	jne esM ; Si no es N, salta al label que hice para revisar si es M
	je NumeroLuegoDeGuion ; Si es N, salta al label que hice para el procedimiento que deberia seguir si escogio N
	int 21h

esM:

	cmp letra,4Dh ; Revisa si la letra luego del guion es una M comparandola con el valor hexadecimal de M mayuscula
	jne terminar ; Si no es M, se termina el programa porque no se puso ninguna opcion aceptada
	je MalespinluegoDeGuion ; Si si es M, se salta al label del procedimiento que deberia seguir si se escogio M
	int 21h

MalespinluegoDeGuion:

	dec cx
	inc bx ; Le incremento 1 al register bx cada ciclo para moverme un byte para adelante cada ciclo, lo que permite al programa obtener todos los caracteres de lo que desea convertir
	mov al,byte ptr es:[si+bx] ; Muevo un byte de lo que se escribio en la linea de comandos a al, y cada vez voy avanzando un espacio ya que le incremento 1 a bx cada ciclo
	cmp al,20h ; Comparo lo que se escribio en la linea de comandos con el valor hexadecimal de un espacio, si es menor a eso entonces ya no hay nada mas que obtener, y se termina el ciclo
	jl terminar ; Si se cumplio esa condicion se salta al label terminar para poder ya terminar el programa ya que ya se convirtio lo que se deseaba convertir
	cmp al,41h ; Si no es menor de 20h significa que todavia hay caracteres que leer, entonces comparo con 41h que es la A en hexadecimal
	je MalespinAaE ; Si es A, entonces hace jump al proceso para convertir A a E
	cmp al,45h ; Si no era A, lo comparo con el valor hexadecimal de E mayuscula
	je MalespinEaA ; Si es E, hace jump al proceso para convertir E a A
	cmp al,49h ;  Se va a repetir este mismo proceso con la I, O, B, T, F, G, P, y M, para conver desde y hacia ellas para evitar comentarios redundantes y sobresaturacion de texto no voy a comentar esas pero es el mismo proceso
	je MalespinIaO 
	cmp al,4Fh
	je MalespinOaI
	cmp al,42h
	je MalespinBaT
	cmp al,54h
	je MalespinTaB
	cmp al,46h
	je MalespinFaG
	cmp al,47h
	je MalespinGaF
	cmp al,50h
	je MalespinPaM
	cmp al,4Dh
	je MalespinMaP
	jmp MalespinNoCambiar ; Si no era ninguna de esas letras y no era menor a 20h significa que era una letra que no tiene codificacion, entonces hago jump a la label que hice para printearla sin modificarla
	jmp MalespinluegoDeGuion ; Hago jump a este mismo label para enciclarlo hasta que se cumpla que se leyeron todos los characters que no eran menores del valor hexadecimal de un espacio
	int 21h

MalespinNoCambiar:

	mov output,al ; Muevo el character que no se debe modificar al output y le hace display, luego salta al ciclo de nuevo para seguir printeado los caracteres
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinAaE:

	add al,4h ; Le sumo 4 hexadecimal a A para moverla 4 espacios adelante para que llegue a hacerse E, luego lo muevo a output y le hago display, por ultimo se devuelve al ciclo
	mov output,al ; Aqui como se dijo, muevo lo que acabo de convertir al output para poder hacerle display
	lea dx,output ; Le hago display usando un interrupt
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion ; Luego me devuelvo al ciclo principal para seguir haciendo conversiones y printeando caracteres convertidos


MalespinEaA:

	sub al,4h ; Le resto 4 hexadecimal a E para moverla 4 espacios atras para convertir la E en un A, luego la muevo a output y le hago display, por ultimo se devuelve al ciclo para seguir haciendo lo mismo con otras letras
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinIaO:

	add al,6h ; Se sigue el mismo proceso que con la A y la E pero con la I y la O, solo cambian los valores numericos para restar o sumar. Se le suma 6h a la I para hacerla convertirse en O, luego le hago display pasandola a output
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion ; Luego se devuelve al ciclo principal

MalespinOaI:

	sub al,6h ; Se hace el mismo proceso que se ha estado comentando, por ende voy a abstenerme de repetirme para evitar la redundancia
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinBaT:

	add al,12h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinTaB:

	sub al,12h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinFaG:

	add al,1h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinGaF:

	sub al,1h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinPaM:

	sub al,3h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion

MalespinMaP:

	add al,3h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp MalespinluegoDeGuion ; Este es el final de las operaciones para Malespin

NumeroLuegoDeGuion:

	dec cx
	inc bx ; Se usa la misma logica que con el malespin, aqui le incremento 1 a bx cada ciclo para obtener el primer caracter y luego el siguiente cada ciclo, hasta obtener todo lo que se deseaba convertir
	mov al,byte ptr es:[si+bx] ; Como le estoy sumando bx a si y se le suma 1 a bx cada ciclo, se movera la posicion de si por 1 cada ciclo, permitiendome obtener todos los caracteres que se desean convertir
	cmp al,20h ; Se usa la misma logica que el malespin, si el caracter actual tiene valor hexadecimal de menor que 20, eso significa que ya se acabo lo que se queria convertir, y se detiene el ciclo
	jl terminar ; Si ya no hay mas caracteres se termina el programa porque ya se printeo la conversion final
	cmp al,41h ; Aqui empieza el mismo ciclo que con el malespin solo que con diferentes valores y letras que convertir, primero comparo si es una A mayuscula
	je NumeroAa4 ; Si es A, entonces salto al proceso para convertirlo a 4
	cmp al,42h ; Si no era A se sigue a revisar si era B con su valor hexadecimal que es 42h
	je NumeroBa8 ; Si es B, hago jump al proceso de conversion de B a 8
	cmp al,45h ; Se sigue asi sucesivamente usando la misma logica con E, G, I, O, P, S, y T, convirtiendolos a su numero respectivo
	je NumeroEa3
	cmp al,47h
	je NumeroGa6
	cmp al,49h
	je NumeroIa1
	cmp al,4Fh
	je NumeroOa0
	cmp al,50h
	je NumeroPa9
	cmp al,53h
	je NumeroSa5
	cmp al,54h
	je NumeroTa7
	jmp NumeroNoCambiar ; Igual que con el malespin, si no cumplio ninguna de esas condiciones pero el valor es 20h mas, solo se reprintea el caracter sin cambiarle nada porque es una letra que no se codifica
	jmp NumeroLuegoDeGuion ; Se encicla hasta que se cumpla la condicion de tener un valor menor a 20h
	int 21h

NumeroNoCambiar:

	mov output,al ; Se mueve el caracter que no se modificara al output
	lea dx,output ; Se usa un interrupt para printear el caracter sin modificar
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion ; Luego se devuelve al ciclo principal de codificacion numerica

NumeroAa4:

	sub al,0Dh ; Usando el mismo proceso aritmetico que el malespin, le resta el valor hexadecimal 0D a al, para asi convertir a A en 4
	mov output,al ; Se mueve el 4 al output
	lea dx,output ; Se le hace display usando un interrupt
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion ; Se devuelve al ciclo principal de codificacion numerica

NumeroBa8:

	sub al,0Ah ; Convierte la B en un 8 por medio de agregarle el valor hexadecimal 0A, lo que lo hace avanzar hasta convertirse en 8
	mov output,al ; Se mueve el 8 al output
	lea dx,output ; Se hace display al 8
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion ; Se devuelve al ciclo principal de codificacion numerica

NumeroEa3:

	sub al,12h ; En todos estos procesos de la codificacion numerica se siguen los mismos pasos pero con diferentes valores
	mov output,al ; Para evitar la redundancia y sobresaturacion de texto no voy a comentarlo en todos
	lea dx,output
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion

NumeroGa6:

	sub al,11h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion

NumeroIa1:

	sub al,18h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion

NumeroOa0:

	sub al,1Fh
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion

NumeroPa9:

	sub al,17h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion

NumeroSa5:

	sub al,1Eh
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion

NumeroTa7:

	sub al,1Dh
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp NumeroLuegoDeGuion

EspanolLuegoDeGuion:

	dec cx
	inc bx ; Se incrementa el bx por 1 cada ciclo, para poder luego sumarlo al si y asi mover la posicion del character actual por 1 cada ciclo
	mov al,byte ptr es:[si+bx] ; Se mueve el character actual que se obtuvo de la linea de comandos al si, y luego se le va sumando 1 cada ciclo para obtener todos los characters de lo que se desea convertir
	cmp al,20h ; Se compara el character que se obtuvo con el valor hexadecimal del espacio que es 20h
	jl terminar ; Si es menos que el valor del espacio, entonces ya no hay mas characters que convertir o printear y se termina el programa
	cmp al,34h ; Se empieza a comparar para convertir de numeros a espanol, primero revisa si el character es un 4 con su valor hexadecimal que es 34h
	je Espanol4aA ; Si es 4, hace jump hasta el label de convertir 4 a A
	cmp al,38h ; Si no era 4 entonces comparo con el valor hexadecimal de 8 que es 38h
	je Espanol8aB ; Si es 8, se hace jump para ir a convertirlo a B en el label adecuado
	cmp al,33h ; Se sigue este mismo proceso con 3, 6, 1, 0, 9, 5, y 7
	je Espanol3aE
	cmp al,36h
	je Espanol6aG
	cmp al,31h
	je Espanol1aI
	cmp al,30h
	je Espanol0aO
	cmp al,39h
	je Espanol9aP
	cmp al,35h
	je Espanol5aS
	cmp al,37h
	je Espanol7aT
	jmp EspanolNoCambiar ; Si el character es espacio o mayor, entonces es una letra que no se codifica pero igual se debe printear, entonces se hace jump al label para printearlo sin modificarlo
	jmp EspanolLuegoDeGuion ; Se encicla para hacer esto con todos los characters hasta que ya no haya mas characters, es decir, hasta que el character actual sea menor que el valor hexadecimal del espacio o sea 20h
	int 21h

EspanolNoCambiar:

	mov output,al ; Si detecta que es una letra que no se debe codificar pero si debe reprintearse, se mueve al output
	lea dx,output ; Se le hace display sin hacer una operacion aritmetica para que no cambie
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion ; Se devuelve al ciclo principal de la opcion Espanol

Espanol4aA:

	add al,0Dh ; Le suma 0Dh hexadecimal al 4 para hacerlo avanzar hasta convertirse en A
	mov output,al ; Mueve la A al output y luego le hace display
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion ; Se devuelve al ciclo principal de convertir a Espanol

Espanol8aB:

	add al,0Ah ; Le suma 0Ah hexadecimal al 8 para hacer que este avance hasta convertirse en B
	mov output,al ; Mueve la B al output para luego hacerle display
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion ; Se devuelve al ciclo principal de convertir a Espanol

Espanol3aE:

	add al,12h ; Sigue el mismo proceso y la misma logica aritmetica solo que con los valores 3, 6, 1, 0, 9, 5 y 7, por lo que evitare comentar lo mismo en estos para evitar la redundancia
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion

Espanol6aG:

	add al,11h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion

Espanol1aI:

	add al,18h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion

Espanol0aO:

	add al,1Fh
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion

Espanol9aP:

	add al,17h
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion

Espanol5aS:

	add al,1Eh
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion

Espanol7aT:

	add al,1Dh
	mov output,al
	lea dx,output
	mov ah,9h
	int 21h
	jmp EspanolLuegoDeGuion

terminar:

	mov ah,4ch ; Hace interrupt para hacer exit hacia DOS para terminar el programa
	int 21h

code ends

end start