# ==============================================================================
# Función para analizar el formato PDF de las facturas del agua.
# ============================================================================== 

# carpeta_facts <- "input/facturas_temp/"
# aaa_pdf <- paste0(carpeta_facts, facturas_aaa[1])
# fact_aaa <- parse_aaa(aaa_pdf)
# unlist(fact_aaa)

parse_aaa <- function(pdf_path) {

  # --- Read & split text ---
  lines <- pdftools::pdf_text(pdf_path) |>
    paste(collapse = "\n") |>
    stringr::str_split("\n") |>
    purrr::pluck(1)
  # print(str_squish(lines[47]))
  
  p_total <- regex("^\\s+TOTAL\\s+\\$\\s?(\\d{1,3}(?:,\\d{3}))\\s+.{12,25}$")
  total_a_pagar <- parse_number(str_match(lines[which(str_detect(lines, p_total))], p_total)[2])
  p_per_y_fecha <- regex("^\\s+MULTIUSUARIO\\s+-\\s?Residencial")
  per_y_fecha <- lines[which(str_detect(lines, p_per_y_fecha))]
  match_pyf <- str_match(per_y_fecha, "(\\S+-\\d{4})\\s+(\\w{3}\\s+\\d{1,2}-\\d{2})$")
  periodo <- match_pyf[2]
  edit_felim <- unlist(str_split(match_pyf[3], "-"))
  fecha_lim <- gsub(" ", "-", paste(edit_felim[2], edit_felim[1]))
  p_cargo <- regex("^\\s+\\$\\d{1,3}(?:,\\d{3})$")
  l_cargo <- sort(parse_number(str_squish(lines[which(str_detect(lines, p_cargo))])))
  cargo_del_mes <- l_cargo[length(l_cargo)]
  saldo_anterior <- total_a_pagar - cargo_del_mes
  p_f_lect <- regex("^MES\\s+FECHA\\s?DE\\s?LECTURA\\s+LECTURA\\s?\\(m3\\)\\s+PROMEDIO\\s?\\(m3\\)")
  tabla_lect <- which(str_detect(lines, p_f_lect))
  f_lect_ant <- dmy(str_extract(lines[tabla_lect + 2], "\\d{2}-\\d{2}-\\d{4}"))
  lect_ant <- str_extract(lines[tabla_lect + 2], "\\d{1,2},\\d{3}")
  f_lect_act <- dmy(str_extract(lines[tabla_lect + 3], "\\d{2}-\\d{2}-\\d{4}")) 
  lect_act <- str_extract(lines[tabla_lect + 3], "\\d{1,2},\\d{3}")

  factura_aaa <- list(
    proveedor = "Triple A",
    total_a_pagar = total_a_pagar,
    periodo = periodo,                # Texto en español
    cargo_del_mes = cargo_del_mes,
    saldo_anterior = saldo_anterior,
    fecha_lim = ymd(fecha_lim),
    No_contrato = Sys.getenv("AAAID"),
    f_lect_ant = f_lect_ant,
    lect_ant = parse_number(lect_ant),
    f_lect_act = f_lect_act,
    lect_act = parse_number(lect_act),
    cargo_AMP = NA_real_
  )  
}

