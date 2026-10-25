# Dos líneas `senal` de la misma señal rompían el guion

- **Síntoma:** un `.esperado` con dos líneas `senal` del mismo nodo y la misma señal (por ejemplo una línea `en` y la
  final) imprimía `ERROR: Signal '<señal>' is already connected to given callable 'Node(puerto_depuracion.gd)::_contar'`.
  Con el criterio del CI, esa línea `ERROR:` ya hace malo al guion. Ningún `.esperado` del repo repetía una señal;
  apareció al probar las líneas `en` en una copia del proyecto.
- **Causa:** `_conectar_senales()` de `herramientas/puerto_depuracion.gd` conectaba una vez por cada línea `senal`,
  con `_contar.bind(k)`. Godot toma la segunda conexión de la misma señal al mismo método como repetida y la rechaza.
- **Arreglo:** una conexión y una cuenta por cada señal distinta (nodo y nombre). Cada línea `senal` guarda el índice
  de su cuenta (`_cuenta_de`), y las líneas de la misma señal comparten la cuenta.
- **Lo cubre:** `nucleo/banco.esperado`, con `en 300 senal /root/Eventos jugador_muerto 0` y
  `en 300 senal /root/Eventos descanso_en_banco 1` junto a las líneas finales de las mismas señales. Con el código de
  antes, esas líneas hacen malo al guion. Con `en 300 senal /root/Eventos jugador_muerto 1` falla con
  `en 300 senal /root/Eventos jugador_muerto esperado=1 obtenido=0`.
