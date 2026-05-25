cargar_info <- function() {

  # Cargue la información disponible:
  cons_SS <- readRDS(here::here("input", "cons_SS.rds"))
  habitantes_casa <- readRDS(here::here("input", "habitantes_casa.rds"))
  tabla_notas <- readRDS(here::here("input", "tabla_notas.rds"))

  # Autorice el uso de Googlesheets:
  googlesheets4::gs4_auth(path = here::here(".entradas", "llave-ss-hacienda.json"))
  url_ss <- Sys.getenv("URL_TABLAS_HACIENDA")
  
  # Baje la información de Googlesheets:
  cont_int <- googlesheets4::read_sheet(
    ss = url_ss,
    sheet = "lect_contadores"
  )
  names(cont_int) <- names(cont_int) |>
    tolower() |>
    (\(x) { ifelse(grepl("^\\d", x), paste0("cont_", x), x) })()
  cont_int <- cont_int |> mutate(fecha = as.Date(fecha))
  
  ajustes_cons <- read_sheet(
    ss = url_ss,
    sheet = "ajustes_cons"
  )
  names(ajustes_cons) <- names(ajustes_cons) |> tolower()
  ajustes_cons <- ajustes_cons |> 
    mutate(
      fecha_ini = as.Date(fecha_ini),
      fecha_fin = as.Date(fecha_fin),
    )

  # Return everything together:
  list(
    cons_SS = cons_SS,
    habitantes_casa = habitantes_casa,
    tabla_notas = tabla_notas,
    cont_int = cont_int,
    ajustes_cons = ajustes_cons
  )
}

# listablas <- cargar_info()
