# ======================================================================
# Función para ajustar los valores de la factura del agua de acuerdo a 
# los ajustes anotados en la hoja de cálculo de Google.
# ======================================================================

ajustes_aaa <- function(aaa_fm, listablas) {

  ini_fact_aaa <- aaa_fm$f_lect_ant
  fin_fact_aaa <- aaa_fm$f_lect_act
  ### --- Ajustes por ocupación: ---
  ocup_aaa <- listablas$habitantes_casa |>
    filter(!is.na(nombre)) |>                            # Quite habitaciones vacías
    mutate(salida = coalesce(salida, fin_fact_aaa)) |>   # Deje el final facturado si salida = NA
    filter(                                              # Deje solo ocupantes durante el periodo
      entrada <= fin_fact_aaa,
      salida >= ini_fact_aaa
    ) |>
    mutate(                                              # Compute el intervalo que se sobrepone 
      inicio_cobro = pmax(entrada, ini_fact_aaa),
      fin_cobro    = pmin(salida, fin_fact_aaa)
    ) |>
    mutate(                                              # Compute los días incluidos
      dias_pres_aaa =
        as.integer(fin_cobro - inicio_cobro)
    ) |>  
    select(
      habitacion,
      nombre,
      inicio_cobro,
      fin_cobro,
      dias_pres_aaa
    )
  ### --- Ajustes por ausencias: ---
  ausenci_aaa <- listablas$ajustes_cons |>
    filter(
      tipo == "Ausencia"
    ) |>    
    mutate(                                               # overlap against bill interval
      inicio_aus = pmax(fecha_ini, ini_fact_aaa),
      fin_aus = pmin(fecha_fin, fin_fact_aaa)
    ) |>
    filter(                                               # keep only real overlaps
      inicio_aus <= fin_aus
    ) |>
    mutate(
      ajus_ausen_aaa = as.integer(fin_aus - inicio_aus)
    ) |>
    select(
      habitacion,
      nombre,
      ajus_ausen_aaa
    )
  ### --- Ajustes por permanencia en la casa: ---
  factor_aaa <- listablas$ajustes_cons |>  
    filter(
      servicio == "AAA",
      tipo == "Factor"
    ) |>
    select(
      habitacion,
      nombre,
      factor_aaa = valor
    )
  ### --- Ajustes por pagos directos: ---
  pago_direct_aaa <- listablas$ajustes_cons |>
    filter(
      servicio == "AAA",
      tipo == "Pago"
    ) |>
    select(
      habitacion,
      nombre,
      pago_dir_aaa = valor
    )
  ### --- Tabla de ajustes por ocupante: ---
  ajust_indv_aaa <- ocup_aaa |>
    select(habitacion, nombre, dias_pres_aaa) |>
    left_join(
      ausenci_aaa,
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      factor_aaa,
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      pago_direct_aaa,
      by = c("habitacion", "nombre")
    ) |>
    mutate(
      ajus_ausen_aaa = coalesce(ajus_ausen_aaa, 0),
      factor_aaa = coalesce(factor_aaa, 1),
      pago_dir_aaa = coalesce(pago_dir_aaa, 0),
      pers_dia_aaa = (dias_pres_aaa - ajus_ausen_aaa) * factor_aaa
    )
  ### --- Tabla de ajustes por habitación: ---
  ajust_hab_aaa <- ajust_indv_aaa |>
      group_by(habitacion) |>
      summarise(
        ocupantes = paste(nombre, collapse = " y "),
        personas = n(),
        pers_dia_aaa = sum(pers_dia_aaa),
        pago_dir_aaa = sum(pago_dir_aaa)
      )
}