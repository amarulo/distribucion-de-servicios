input_fls <- list.files(here::here("input"))
  if ("cons_SS.rds" %in% input_fls) {
    cons_SS <- readRDS(here::here("input", "cons_SS.rds"))
  } else {
    stop(
      "No se encontró input/cons_SS.rds. ",
      "El archivo es requerido para continuar. ",
      "Revise el estado del archivo antes de ejecutar nuevamente el pipeline."
    )
  #  cons_SS <- tibble::tibble()
  #  fecha_ini <- as.Date("2025-01-01")
  }

cat("\n", nrow(cons_SS), " registros en cons_SS.\n")