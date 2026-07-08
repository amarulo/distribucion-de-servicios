# ==============================================================================
# Filtro de seguridad para comparar la tabla de Googlesheets y la tabla contenida 
# en este repositorio: input/cont_int.rds
# ============================================================================== 

## Revisar conexión: ----
if (!googlesheets4::gs4_has_token()) {
  googlesheets4::gs4_auth(path = here::here(Sys.getenv("SECRETO_HM"), Sys.getenv("SHA256_HMT")))
}


## Tablas a comparar: ----
# Tabla de contadores internos de Googlesheets: cont_int_gsh4 (bajada con bajar_tablas_gsh4.R)

## Tabla de lectura de Contadores Internos anterior:
cont_int_input <- readRDS(here::here("input", "cont_int.rds"))


## Punto de comparación de cambios, interactivo: ----
difcontint <- waldo::compare(cont_int_input, cont_int_gsh4)
if (length(difcontint) == 0) {
  cat("La tabla de lecturas de los contadores internos guardada en input sigue estando vigente.\n")
  cat(rep("=", 30), "\n")
} else {
  cat("\nSe detectaron diferencias:\n\n")
  print(difcontint)
  ## Modo interactivo:
  if (interactive()) {
    respuesta <- readline(
      prompt = "\n¿Aceptar cambios y actualizar cont_int.rds? (y/n): "
    ) |>
      trimws() |>
      stringr::str_sub(1, 1) |>
      tolower()
    if (respuesta %in% c("y", "s")) {
      saveRDS(cont_int_gsh4, here::here("input", "cont_int.rds"))
      cat("\nNueva versión guardada.\n")
      rm(cont_int_gsh4)
      cat(rep("=", 30), "\n")
    } else {
      stop("Proceso cancelado por el usuario.")
    }
  } else {
    stop("Se detectaron cambios en la tabla de lectura de los contadores internos. Revise manualmente antes de continuar.")
  }
}

  
