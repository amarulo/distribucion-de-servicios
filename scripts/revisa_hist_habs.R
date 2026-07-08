# ==============================================================================
# Filtro de seguridad para comparar la tabla de Googlesheets y la tabla contenida 
# en este repositorio: input/habitantes_casa.rds
# ============================================================================== 


## Tablas a comparar:
# Lista de integrantes por habitación tomada de googlesheets: habitantes_casa_gsh4 (bajada con bajar_tablas_gsh4.R)


# Lista de integrantes por habitación actual:
habitantes_casa_input <- readRDS(here::here("input", "habitantes_casa.rds"))

## Punto de comparación de cambios, interactivo: ----
difhabs <-  waldo::compare(habitantes_casa_input, habitantes_casa_gsh4)
if (length(difhabs) == 0) {
  cat("La tabla sobre los habitantes de la casa guardada en input sigue estando vigente.\n")
  cat(rep("=",30), "\n")
} else {
  cat("\nSe detectaron diferencias:\n\n")
  print(difhabs)
  ## Modo interactivo:
  if (interactive()) {
    respuesta <- readline(
      prompt = "\n¿Aceptar cambios y actualizar habitantes_casa.rds? (y/n): "
    ) |>
      trimws() |>
      stringr::str_sub(1, 1) |>
      tolower()
    if (respuesta %in% c("y", "s")) {
      saveRDS(habitantes_casa_gsh4, here::here("input", "habitantes_casa.rds"))
      cat("\nNueva versión guardada.\n")
      rm(habitantes_casa_gsh4)
      cat(rep("=", 30), "\n")
    } else {
      stop("Proceso cancelado por el usuario.")
    }
  } else {
    stop("Se detectaron cambios en la tabla de habitantes de la casa. Revise manualmente antes de continuar.")
  }
}

