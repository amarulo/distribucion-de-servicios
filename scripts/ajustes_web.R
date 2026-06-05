# ======================================================================
# Función para ajustar los valores del servicio de internet de acuerdo a 
# los ajustes anotados en la hoja de cálculo de Google.
# ======================================================================

ajustes_web <- function(f_ini_per, listablas){
  ini_fact_web <- f_ini_per
  fin_fact_web <- ceiling_date(f_ini_per + 28, unit = "month")

    ### --- Ajustes por ocupación: ---
  ocup_web <- listablas$habitantes_casa |>
    filter(!is.na(nombre)) |>                            # Quite habitaciones vacías
    mutate(salida = coalesce(salida, fin_fact_web)) |>   # Deje el final facturado si salida = NA
    filter(                                              # Deje solo ocupantes durante el periodo
      entrada < fin_fact_web,
      salida >= ini_fact_web
    ) |>
    mutate(                                              # Compute el intervalo que se sobrepone 
      inicio_cobro = as.Date(pmax(entrada, ini_fact_web)),
      fin_cobro    = as.Date(pmin(salida, fin_fact_web))
    ) |>
    mutate(                                              # Compute los días incluidos
      dias_pres_web =
        as.integer(fin_cobro - inicio_cobro)
    ) |>  
    select(
      habitacion,
      nombre,
      inicio_cobro,
      fin_cobro,
      dias_pres_web
    )
  ### --- Ajustes por ausencias: ---
  ausenci_web <- listablas$ajustes_cons |>
    filter(
      tipo == "Ausencia"
    ) |>    
    mutate(                                               # overlap against bill interval
      inicio_aus = pmax(fecha_ini, ini_fact_web),
      fin_aus = pmin(fecha_fin, fin_fact_web)
    ) |>
    filter(                                               # keep only real overlaps
      inicio_aus <= fin_aus
    ) |>
    mutate(
      ajus_ausen_web = as.integer(fin_aus - inicio_aus)
    ) |>
    select(
      habitacion,
      nombre,
      ajus_ausen_web
    )
  ### --- Ajustes por utilización del servicio: ---
  factor_web <- listablas$ajustes_cons |>  
    filter(
      servicio == "Web",
      tipo == "Factor"
    ) |>
    select(
      habitacion,
      nombre,
      factor_web = valor
    )
  ### --- Tabla de ajustes por ocupante: ---
  ajust_indv_web <- ocup_web |>
    select(habitacion, nombre, dias_pres_web) |>
    left_join(
      ausenci_web,
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      factor_web,
      by = c("habitacion", "nombre")
    ) |>
    mutate(
      dias_pres_web = coalesce(dias_pres_web, 0),
      ajus_ausen_web = coalesce(ajus_ausen_web, 0),
      factor_web = coalesce(factor_web, 1),
      pers_dia_web = (dias_pres_web - ajus_ausen_web) * factor_web
    )
  ### --- Tabla de ajustes por habitación: ---
  ajust_hab_web <- ajust_indv_web |>
      group_by(habitacion) |>
      summarise(
        ocupantes = paste(nombre, collapse = " y "),
        personas = n(),
        pers_dia_web = sum(pers_dia_web)
      )
}
