# ==============================================================================
# Función para bajar todas las tablas desde Google Sheets
# ============================================================================== 

## Revisar conexión:
if (!googlesheets4::gs4_has_token()) {
  googlesheets4::gs4_auth(path = here::here(Sys.getenv("SECRETO_HM"), Sys.getenv("SHA256_HMT")))
}

## Tablas de Googlesheets:
tbl_ss <- Sys.getenv("TABLAS_HM")


## Tabla de ajustes de consumo ----
ajustes_cons_gsh4 <- googlesheets4::read_sheet(
    ss = tbl_ss,
    sheet = "ajustes_cons"
  ) |> 
    dplyr::mutate(
      Fecha_ini = as.Date(Fecha_ini),
      Fecha_fin = as.Date(Fecha_fin),
    )
names(ajustes_cons_gsh4) <- names(ajustes_cons_gsh4) |> tolower()


## Tabla de lecturas de contadores internos ----
cont_int_gsh4 <- googlesheets4::read_sheet(
    ss = tbl_ss,
    sheet = "lect_contadores"
  ) |> 
  dplyr::mutate(Fecha = as.Date(Fecha))
names(cont_int_gsh4) <- names(cont_int_gsh4) |>
  tolower() |>
  (\(x) { ifelse(grepl("^\\d", x), paste0("cont_", x), x) })()


## Tabla de integrantes por habitación ----
habitantes_casa_gsh4 <- googlesheets4::read_sheet(
    ss = tbl_ss,
    sheet = "habitantes"
  ) |>
    dplyr::mutate(
      entrada = as.Date(entrada),
      salida = as.Date(salida)
    )


## Tabla de notas preliminares ----
tabla_notas_gsh4 <- googlesheets4::read_sheet(
    ss = tbl_ss,
    sheet = "notas"
  ) |>
    dplyr::mutate(fecha = as.Date(fecha))


## Tabla de pago del internet ----
pago_web_gsh4 <- googlesheets4::read_sheet(
    ss = tbl_ss,
    sheet = "internet"
  ) |>
  dplyr::mutate(Fecha = as.Date(Fecha))
names(pago_web_gsh4) <- names(pago_web_gsh4) |>
  tolower()


rm(tbl_ss)

