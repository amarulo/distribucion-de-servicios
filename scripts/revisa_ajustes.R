# ==============================================================================
# Filtro de seguridad para comparar la tabla de Googlesheets y la tabla contenida 
# en este repositorio: input/ajustes.rds
# ============================================================================== 


## Tablas a comparar: ----
#  de Googlesheets: ajustes_cons_gsh4 (obtenida con bajar_tablas_gsh4.R)


# Tabla de ajustes de consumo actual:
ajustes_cons_input <- readRDS(here::here("input", "ajustes.rds"))


## Punto de comparación de cambios, interactivo: ----
difajus <- waldo::compare(ajustes_cons_input, ajustes_cons_gsh4)
if (length(difajus) == 0) {
  cat("La tabla de ajustes guardada en input sigue estando vigente.\n")
  cat(rep("=", 30), "\n")
} else {
  cat("\nSe detectaron diferencias:\n\n")
  print(difajus)
  ## Modo interactivo:
  if (interactive()) {
    respuesta <- readline(
      prompt = "\n¿Aceptar cambios y actualizar ajustes.rds? (y/n): "
    ) |>
      trimws() |>
      stringr::str_sub(1, 1) |>
      tolower()
    if (respuesta %in% c("y", "s")) {
      saveRDS(ajustes_cons_gsh4, here::here("input", "ajustes.rds"))
      cat("\nNueva versión guardada.\n")
      rm(ajustes_cons_gsh4)
      cat(rep("=", 30), "\n")
    } else {
      stop("Proceso cancelado por el usuario.")
    }
  } else {
    stop("Se detectaron cambios en la tabla de ajustes de consumo. Revise manualmente antes de continuar.")
  }
}
