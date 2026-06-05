# ==============================================================================
# Filtro de seguridad para revisar los nuevos registros de facturas recientes para
# añadirlos a la tabla: input/cons_SS.rds
# ============================================================================== 

## Revisar conexión: ----
if (!googledrive::drive_has_token()) {
  googledrive::drive_auth()
}


## Nuevos registros para revisar: ----
source(here::here("scripts", "agregar_facturas.R"))
nuevos_registros <- agregar_facturas()

if (nrow(nuevos_registros) == 0) {
  cat("No se detectaron nuevas facturas.\n")
} else {  
  ## Modo interactivo:
  if (interactive()) {
      print(nuevos_registros)
      respuesta <- readline(
        prompt = "\n¿Aceptar y agregar los nuevos registros a cons_SS.rds? (y/n): "
      ) |>
        trimws() |>
        stringr::str_sub(1, 1) |>
        tolower()
      if (respuesta %in% c("y", "s")) {
        cons_SS <- readRDS(here::here("input", "cons_SS.rds")) |>
          dplyr::bind_rows(nuevos_registros) |>
          unique() |>
          arrange(fecha_lim)
        saveRDS(cons_SS, here::here("input", "cons_SS.rds"))
        cat("\nNuevos registros añadidos.\n")
      } else {
        stop("Proceso cancelado por el usuario.")
      }
    } else {
      stop("Se detectaron nuevos registros de facturas. Revise manualmente antes de continuar.")
    }
}


