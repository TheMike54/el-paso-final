# Si la copia de la sesión fallaba, Restaurar ofrecía la de una sesión anterior

**Síntoma.** Con la copia fallando al empezar una sesión (reproducido el 1-nov-2026 poniendo una carpeta en lugar de `<ruta>.bak.tmp`), `Guardado.respaldar` devolvía el error y la ficha seguía prometiendo volver «al inicio de la última sesión» con una copia más vieja.

**Causa.** El texto de la confirmación prometía más de lo que la copia garantiza.

**Arreglo.** La copia anterior se queda, porque una vieja rescata más que ninguna, y la confirmación dice «a su última copia». Una partida que no es válida sigue sin copiarse y conserva su copia buena.

**Guion.** `nucleo/ranuras`, caso «si la copia falla lo dice y conserva la anterior».
