# ==============================================================================
# Función para chequear la tabla existente, revisar si hay nuevas facturas y, 
# si las hay, agregar la nueva información a la tabla: input/cons_SS.rds
# ============================================================================== 


# Cargue las funciones requeridas: ----
source(here::here("scripts", "descargar_facturas.R"))
source(here::here("scripts", "filtre_fact_nuevas.R"))
source(here::here("scripts", "parse_aaa.R"))
source(here::here("scripts", "generar_imagenes_ee.R"))
source(here::here("scripts", "parse_ee.R"))
source(here::here("scripts", "parse_gas.R"))


# Función agregar_facturas ----
agregar_facturas <- function() {

  cat("\nBuscando nuevas facturas.\n")

  # --- Confirmación de los datos de la tabla de consumo de servicios ---
  input_fls <- list.files(here::here("input"))
  if ("cons_SS.rds" %in% input_fls) {
    cons_SS <- readRDS(here::here("input", "cons_SS.rds"))
    fecha_ini <- floor_date(max(cons_SS$fecha_lim) - 15, unit = "month")
  } else {
    cons_SS <- tibble::tibble()
    fecha_ini <- as.Date("2025-01-01")
  }
  fecha_fin <- ceiling_date(Sys.Date(), unit = "month")
  mes_a_mes <- seq.Date(fecha_ini, fecha_fin, by = "month")

  # --- Descargue nuevas facturas si existen ---
  descargar_facturas(fecha_ini)

  # --- Use las nuevas facturas para agregar los datos a la tabla ---
  tabla_web <- tabla_aaa <- tabla_ee <- tabla_gas <- tibble()

  # --- Generar la tabla con la información de la factura del internet ---
  # OJO: El valor era menor al inicio de 2025, hay que revisar si hace falta
  for (mes in mes_a_mes) {
    web <- list(
      proveedor = "Movistar",
      total_a_pagar = 94990,
      periodo = toupper(format(as.Date(mes), "%b.-%Y")),
      cargo_del_mes = 94990,
      saldo_anterior = 0,
      fecha_lim = floor_date(as.Date(mes), unit = "month") + 9,
      No_contrato = Sys.getenv("WEBID"),
      f_lect_ant = NA_Date_,
      lect_ant = NA_real_,
      f_lect_act = NA_Date_,
      lect_act = NA_real_,
      cargo_AMP = NA_real_
    )
    tabla_web <- bind_rows(tabla_web, web)
  }
  nuevos_registros <- tabla_web

  # --- Carpetas de archivos temporales ---
  carpeta_facts <- here::here("input", "facturas_temp")
  carpeta_imgs <- here::here("input", "facturas_temp", "ee_imgs")
  fact_todas <- list.files(carpeta_facts, pattern = "\\.pdf$", full.names = TRUE)
  f_para_analizar <- filtre_fact_nuevas(fact_todas, cons_SS)

  # --- Tabla del consumo de gas ---
  facturas_gas <- f_para_analizar[str_detect(basename(f_para_analizar), pattern = "^\\d{4}_\\d{2}_gas")]
  de_gas <- length(facturas_gas)

  for (gas_pdf in facturas_gas) {
    pdf_path <- file.path(carpeta_facts, gas_pdf)
    if (!file.exists(pdf_path)) {
      warning("No existe: ", pdf_path)
      next
    }
    cat("Analizando", gas_pdf, " : ", which(facturas_gas == gas_pdf), "de", de_gas, "\n")
    fact_gas <- parse_gas(pdf_path)
    tabla_gas <- bind_rows(tabla_gas, fact_gas)
  }
  nuevos_registros <- bind_rows(nuevos_registros, tabla_gas)

  # --- Tabla del consumo de agua ---
  facturas_aaa <- f_para_analizar[str_detect(basename(f_para_analizar), pattern = "^\\d{4}_\\d{2}_aaa")]
  de_agua <- length(facturas_aaa)

  for (aaa_pdf in facturas_aaa) {
    pdf_path <- file.path(carpeta_facts, aaa_pdf)
    if (!file.exists(pdf_path)) {
      warning("No existe: ", pdf_path)
      next
    }
    cat("Analizando", aaa_pdf, " : ", which(facturas_aaa == aaa_pdf), "de", de_agua, "\n")
    fact_aaa <- parse_aaa(pdf_path)
    tabla_aaa <- bind_rows(tabla_aaa, fact_aaa)
  }
  nuevos_registros <- bind_rows(nuevos_registros, tabla_aaa)
  
  # --- Tabla del consumo de energía eléctrica ---
  imagenes_ee <- generar_imgs_ee()
  if (length(imagenes_ee) == 0) {
    todas_imgs_ee <- list.files(here::here("input", "facturas_temp", "ee_imgs"),
      pattern = "^\\d{4}_\\d{2}_", full.names = TRUE)
    imagenes_ee <- filtre_fact_nuevas(todas_imgs_ee, cons_SS)
  }
  de_imgee <- length(imagenes_ee)
  for (ee_img in imagenes_ee) {
    if (!file.exists(ee_img)) {
      warning("No existe: ", ee_img)
      next
    }
    cat("Analizando", ee_img, " : ", which(imagenes_ee == ee_img), "de", de_imgee, "\n")
    fact_ee <- parse_ee(ee_img)
    tabla_ee <- bind_rows(tabla_ee, fact_ee)
  }
  nuevos_registros <- bind_rows(nuevos_registros, tabla_ee)
  nuevos_registros <- nuevos_registros |> arrange(fecha_lim) |> unique()

  return(nuevos_registros)
}


# para_imaginar <- ifelse(!(paste0(tools::file_path_sans_ext(facturas_ee), "_1.png") %in% imagenes_ee), 
  #                         facturas_ee, NA_character_)
  # para_imaginar <- para_imaginar[!is.na(para_imaginar)]
  # de_imaginar <- length(para_imaginar)
 # para_imaginar),



