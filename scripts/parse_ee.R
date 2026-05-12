# carpeta_facts <- "input/facturas_temp/"
# facturas_ee <- list.files(path = carpeta_facts, pattern = "NIC2345873")
# purrr::map(
#   paste0(carpeta_facts, facturas_ee),
#   \(ee_pdf) pdf_convert(
#     ee_pdf,
#     dpi = 300,
#     pages = 1,
#     filenames = paste0(
#       "input/facturas_temp/ee_imgs/",
#       tools::file_path_sans_ext(basename(ee_pdf)),
#       "_1.png"
#     )
#   )
# )
# carpeta_imgs <- "input/facturas_temp/ee_imgs/"
# ee_pdf <- paste0(carpeta_facts,facturas_ee[6])
# imgs_ee <- list.files(path = carpeta_imgs, pattern = "NIC2345873")
# ee_img <- paste0(carpeta_imgs, imgs_ee[4])
# fact_ee <- parse_ee(ee_img)
# unlist(fact_ee)

parse_ee <- function(pdf_path) {

  # --- Convert pdf to img and get the text from there ---
  #  pdf_text() doesn't work here
  lines <- pdf_path |>
    ocr(engine = tesseract("spa")) |>
    stringr::str_split("\n") |>
    purrr::pluck(1)
  lines <- lines[lines != ""]
  # print(lines)
  
  ind1 <- which(str_detect(lines, "[Ii]mpuesto\\s*[so]?\\s+(?![Asd])"))
  total_a_pagar <- parse_number(gsub("\\.", "", str_extract(lines[ind1], "\\d{1,3}(?:\\.\\d{3})+")))
  fecha_lim <- dmy(str_extract(lines[which(str_detect(lines, "pago\\s+\\d{2}/\\d{2}/\\d{4}"))], "\\d{2}/\\d{2}/\\d{4}"))
  periodo <- sub("-", ".-", str_to_title(format(as.Date(fecha_lim), "%b-%y")))
  if (fecha_lim < as.Date("2025-08-01")) {
    pat_consm <- regex("
      (\\d{4})\\s+                # Lectura Actual
      (\\d{3,4})\\s+              # Lectura Anterior
      \\d{1}\\s+                  # Factor Multiplicador
      (\\d{3}),00\\s+\\d{1}$      # Consumo Mes
      ", comments = TRUE)
    ind2 <- which(str_detect(lines, "Energ[ií]a\\s?Mes"))
    ind3 <- which(str_detect(lines, "^\\$\\d{2}(?:\\.\\d{3})?"))
    ind4 <- which(str_detect(lines, "El\\s?no\\s?pago\\s?oportuno\\s?de\\s?la\\s?factura"))
    c_del_mes <- gsub("\\.", "", str_extract(lines[ind2], "\\$\\d{1,3}(?:\\.\\d{2,3})?$"))
    t_de_seg <- gsub("\\.", "", str_extract(lines[ind3], "^\\$\\d{2}(?:\\.\\d{3})?"))
    cargo_del_mes <- parse_number(c_del_mes) + parse_number(t_de_seg)
    lect_cons <- str_match(lines[ind4], pat_consm)
    lect_act <- parse_number(lect_cons[2])
    lect_ant <- parse_number(lect_cons[3])
    consumes <- parse_number(lect_cons[4])
  } else {
    pat_TotMes <- regex("
      ^(\\$\\d{1,3}(?:\\.\\d{3})?)\\s?    # Tasa de seguridad
      (\\$\\d{1,3}(?:\\.\\d{3})?)\\s?     # Cargo del mes
      (\\$\\d{1,3}(?:\\.\\d{3})?)\\s?     # Total mes sin tasa
      ", comments = TRUE)
    pat_consm <- regex("
      (\\d{4})\\s+.{1,3}\\s+          # Lectura Actual
      (\\d{3,4})\\s+.{1,2}\\s+        # Lectura Anterior
      \\d{1}\\s+.{2,3}\\s+            # Factor Multiplicador
      (\\d{3}),00$                    # Consumo Mes
      ", comments = TRUE)
    ind2 <- which(str_detect(lines, pat_TotMes))
    ind4 <- which(str_detect(lines, "FIU\\s?es\\s?la\\s?cantidad\\s?de\\s?veces\\s?sin\\s?energ"))
    vlrs <- str_match(lines[ind2], pat_TotMes)
    t_de_seg <- gsub("\\.", "", vlrs[2])
    c_del_mes <- gsub("\\.", "", vlrs[3])
    cargo_del_mes <- parse_number(c_del_mes)
    lect_cons <- str_match(lines[ind4], pat_consm)
    lect_act <- parse_number(lect_cons[2])
    lect_ant <- parse_number(lect_cons[3])
    consumes <- parse_number(lect_cons[4])
  }
  ind6 <- which(str_detect(lines, "Fecha\\s?Lectura\\s?Anterior:"))
  f_lect_ant <- dmy(str_extract(lines[ind6], "\\d{2}/\\d{2}/\\d{4}"))
  ind7 <- which(str_detect(lines, "Fecha\\s?Lectura\\s?Actual:"))
  f_lect_act <- dmy(str_extract(lines[ind7], "\\d{2}/\\d{2}/\\d{4}"))

  # --- Corrige errores de la imagen que afectan valores ---
  if (nchar(c_del_mes) < 7) {
    check <- total_a_pagar - parse_number(t_de_seg)
    if (adist(paste0("$", check), as.character(c_del_mes)) <= 1) {
      c_del_mes <- check 
      cargo_del_mes <- c_del_mes + parse_number(t_de_seg)
    } else if (adist(paste0("$",total_a_pagar), as.character(c_del_mes)) <= 1) {
      cargo_del_mes <- total_a_pagar
    }
  }

  if (lect_act - lect_ant != consumes) {
    check <- lect_act - consumes
    if (adist(as.character(check), as.character(lect_ant)) <= 1) {
      lect_ant <- check
    }
  }

  saldo_anterior <- total_a_pagar - cargo_del_mes

  factura_ee <- list(
    proveedor = "Air-e S.A.S. E.S.P.",
    total_a_pagar = total_a_pagar,
    periodo = periodo,                # Texto en español
    cargo_del_mes = cargo_del_mes,
    saldo_anterior = saldo_anterior,
    fecha_lim = fecha_lim,
    No_contrato = 2345873,
    f_lect_ant = f_lect_ant,
    lect_ant = lect_ant,
    f_lect_act = f_lect_act,
    lect_act = lect_act,
    cargo_AMP = NA_real_
  )
}


