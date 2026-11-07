# Caso de prueba de ranuras colisionaba con zona raices

- Síntoma: `ranuras.guion` fallaba en `prueba_ranuras.gd:64`: «la ubicacion es la sala del banco esperado=Raices 1 obtenido=Las Raíces».
- Causa: La prueba usaba `raices_1` como ejemplo de sala sin zona registrada en `indice_salas.tres`. Al agregar la zona Las Raíces con su ficha, `raices_1` pasó a tener nombre de zona visible («Las Raíces»).
- Arreglo: Usar `sin_zona_1` como sala de prueba sin zona en `herramientas/pruebas/prueba_ranuras.gd`.
- Guion: `herramientas/guiones/nucleo/ranuras.guion`.
