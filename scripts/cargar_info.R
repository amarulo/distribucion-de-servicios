# ==============================================================================
# Función para cargar la información de los contadores internos y los ajustes al
# consumo para generar la lista de tablas para la preparación del reporte mensual
# ==============================================================================

cargar_info <- function() {

  # Cargue la información disponible:
  cons_SS <- readRDS(here::here("input", "cons_SS.rds"))
  habitantes_casa <- readRDS(here::here("input", "habitantes_casa.rds"))
  tabla_notas <- readRDS(here::here("input", "tabla_notas.rds"))
  cont_int <- readRDS(here::here("input", "cont_int.rds"))
  ajustes_cons <- readRDS(here::here("input", "ajustes.rds"))

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
