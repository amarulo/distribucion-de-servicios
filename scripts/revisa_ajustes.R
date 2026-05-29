# ==============================================================================
# Filtro de seguridad para comparar la tabla de Googlesheets y la tabla contenida 
# en este repositorio: input/ajustes.rds
# ============================================================================== 

## Revisar conexión: ----
if (!googlesheets4::gs4_has_token()) {
  googlesheets4::gs4_auth(path = here::here(Sys.getenv("SECRETO_HM"), Sys.getenv("SHA256_HMT")))
}


## Tablas a comparar: ----
# Tabla de ajustes de consumo de Googlesheets:
tbl_ss <- Sys.getenv("TABLAS_HM")
ajustes_cons_gsh4 <- googlesheets4::read_sheet(
    ss = tbl_ss,
    sheet = "ajustes_cons"
  )
names(ajustes_cons_gsh4) <- names(ajustes_cons_gsh4) |> tolower()
ajustes_cons_gsh4 <- ajustes_cons_gsh4 |> 
    mutate(
      fecha_ini = as.Date(fecha_ini),
      fecha_fin = as.Date(fecha_fin),
    )

# Tabla de ajustes de consumo anteriores:
ajustes_cons_input <- readRDS(here::here("input", "ajustes.rds"))


## Punto de comparación de cambios, interactivo: ----
if (identical(ajustes_cons_gsh4, ajustes_cons_input)) {
  cat("La tabla guardada en input sigue estando vigente.\n")
} else {
  cat("\nSe detectaron diferencias:\n\n")
  waldo::compare(ajustes_cons_input, ajustes_cons_gsh4)

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
    } else {
      stop("Proceso cancelado por el usuario.")
    }
  } else {
    stop("Se detectaron cambios en la tabla de ajustes de consumo. Revise manualmente antes de continuar.")
  }
}
