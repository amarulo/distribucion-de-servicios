# ==============================================================================
# Filtro de seguridad para comparar la tabla de Googlesheets y la tabla contenida 
# en este repositorio: input/cont_int.rds
# ============================================================================== 

## Revisar conexión: ----
if (!googlesheets4::gs4_has_token()) {
  googlesheets4::gs4_auth(path = here::here(Sys.getenv("SECRETO_HM"), Sys.getenv("SHA256_HMT")))
}


## Tablas a comparar: ----
# Tabla de notas de Googlesheets:
tbl_ss <- Sys.getenv("TABLAS_HM")
cont_int_gsh4 <- googlesheets4::read_sheet(
    ss = tbl_ss,
    sheet = "lect_contadores"
  )
names(cont_int_gsh4) <- names(cont_int_gsh4) |>
  tolower() |>
  (\(x) { ifelse(grepl("^\\d", x), paste0("cont_", x), x) })()
cont_int_gsh4 <- cont_int_gsh4 |> mutate(fecha = as.Date(fecha))

## Tabla de lectura de Contadores Internos anterior:
cont_int_input <- readRDS(here::here("input", "cont_int.rds"))


## Punto de comparación de cambios, interactivo: ----
if (identical(cont_int_gsh4, cont_int_input)) {
  cat("La tabla guardada en input sigue estando vigente.\n")
} else {
  cat("\nSe detectaron diferencias:\n\n")
  waldo::compare(cont_int_input, cont_int_gsh4)

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
    } else {
      stop("Proceso cancelado por el usuario.")
    }
  } else {
    stop("Se detectaron cambios en la tabla de lectura de los contadores internos. Revise manualmente antes de continuar.")
  }
}

  
