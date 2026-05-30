# ==============================================================================
# Función para analizar el formato PDF de las facturas del gas.
# ============================================================================== 

# source("scripts/cargar_librerias.R")
# gas_pdf <- paste0(carpeta_facts,facturas_gas[4])
# fact_gas <- parse_gas(gas_pdf)
# unlist(fact_gas)

parse_gas <- function(pdf_path) {

  # --- Read & split text ---
  lines <- pdftools::pdf_text(pdf_path) |>
    paste(collapse = "\n") |>
    stringr::str_split("\n") |>
    purrr::pluck(1)
  # print(str_squish(lines[70:104]))

  primera_l <- str_squish(lines[1])
  # print(primera_l)
  if (primera_l == Sys.getenv("GASID")) {
    add1 <- 0
  } else if (primera_l == "Rojo") {
    add1 <- 1
  } else {
    print("Esta factura no tiene formato conocido!")
    return(NULL)
  }

  # --- Seleccione las primeras lineas ---
  total_a_pagar <- parse_number(str_squish(lines[9 + add1]))
  periodo <- str_squish(lines[18 + add1])

  # --- Establezca la fecha límite de pago ---
  lin_fecha <- lines[which(stringr::str_detect(lines, "^\\s+\\d{2}/\\d{2}/\\d{4}\\s+\\$\\s+\\d{1,3}(?:,\\d{1,3})\\s*$"))]
  fecha_lim <- as.Date(dmy(str_extract(str_squish(lin_fecha), "^\\d{2}/\\d{2}/\\d{4}")))

  # --- Localice el identificador del contador ---
  ind <- which(str_detect(lines, "^\\s+U-570346-X"))
  fechas <- str_split(str_squish(lines[which(str_detect(lines, "^\\s+U-570346-X"))+1]), " ")[[1]]
  f_lect_ant <- paste0(fechas[1], "/", year(fecha_lim - 30))
  f_lect_act <- paste0(fechas[3], "/", year(fecha_lim - 30))
  lecturas <- str_split(str_squish(lines[which(str_detect(lines, "^\\s+U-570346-X"))+2]), " ")[[1]]
  lect_ant <- lecturas[4]
  lect_act <- lecturas[3]

  # --- Localice la sección de la tabla ---
  indx <- which(stringr::str_detect(lines, "^\\s*SERV\\.GAS\\s*\\(Serv\\.Susc\\.1020307\\)"))

  MODIF_marzo <- unlist(str_split(str_squish(lines[indx + 3 + add1]), " "))
  Financ_mayo <- unlist(str_split(str_squish(lines[indx + 4 + add1]), " "))
  MODIF_mayo <- unlist(str_split(str_squish(lines[indx + 5 + add1]), " "))
  Financ_agos <- unlist(str_split(str_squish(lines[indx + 6 + add1]), " "))
  INTERESES <- unlist(str_split(str_squish(lines[indx + 8 + add1]), " "))
  cargo_AMP <- sum(parse_number(MODIF_marzo[10]), parse_number(MODIF_marzo[11]),
      parse_number(Financ_mayo[2]), parse_number(MODIF_mayo[10]), parse_number(MODIF_mayo[11]), 
      parse_number(Financ_agos[8]), parse_number(Financ_agos[9]), 
      parse_number(INTERESES[10]), parse_number(INTERESES[11]))

  pattern <- regex("
      ^\\s+.+?\\s+\\$\\s?
        (\\d{1,3}(?:,\\d{3})*)\\s+\\$\\s?  # Saldo anterior
        (\\d{1,3}(?:,\\d{3})*)\\s+\\$\\s?  # Cargo del mes
        (\\d{1,3}(?:,\\d{3})*)\\s+.{17}$   # Valor total
      ", comments = TRUE)
  cargos <- str_match(lines[which(str_detect(lines, pattern))], pattern)
  # print(cargos)
  cargo_del_mes <- parse_number(cargos[3])
  saldo_anterior <- parse_number(cargos[2])

  # print(writeLines(paste("total_a_pagar:", total_a_pagar, "\nperiodo:", periodo, "\ncargo_del_mes:", cargo_del_mes,
  #       "\nsaldo_anterior:", saldo_anterior, "\nfecha_lim:", fecha_lim, 
  #       "\nModif_marzo:", paste(MODIF_marzo, collapse = "; "), "\nFinanc_mayo:", paste(Financ_mayo, collapse = "; "),
  #       "\nMODIF_mayo:", paste(MODIF_mayo, collapse = "; "), "\nFinanc_agos:", paste(Financ_agos, collapse = "; "),
  #       "\nINTERESES", paste(INTERESES, collapse = "; "), "\ncargo_AMP:", cargo_AMP)))

  factura_gas <- list(
    proveedor = "Gases del Caribe",
    total_a_pagar = total_a_pagar,
    periodo = periodo,                # Texto en español
    cargo_del_mes = cargo_del_mes,
    saldo_anterior = saldo_anterior,
    fecha_lim = fecha_lim,
    No_contrato = Sys.getenv("GASID"),
    f_lect_ant = dmy(f_lect_ant),
    lect_ant = parse_number(lect_ant),
    f_lect_act = dmy(f_lect_act),
    lect_act = parse_number(lect_act),
    cargo_AMP = cargo_AMP
  )
}




