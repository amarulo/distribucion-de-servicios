# ==============================================================================
# Función para chequear la tabla existente, revisar si hay nuevas facturas y, 
# si las hay, agregar la nueva información a la tabla.
# ============================================================================== 

 
agregar_facturas <- function() {

  # --- Confirmación de los datos de la tabla de consumo de servicios ---
  output_fls <- list.files("output/")
  if ("cons_SS.rds" %in% output_fls) {
    cons_SS <- readRDS("output/cons_SS.rds")
    fecha_ini <- floor_date(max(cons_SS$fecha_lim) - 30, unit = "month")
  } else {
    cons_SS <- tibble::tibble()
    fecha_ini <- as.Date("2025-01-01")
  }
  fecha_fin <- ceiling_date(Sys.Date(), unit = "month") + 9
  mes_a_mes <- seq.Date(fecha_ini, fecha_fin, by = "month")


  # --- Revisar y descargar nuevas facturas en caso que existan ---
  source("scripts/descargar_facturas.R")


  # --- Use las nuevas facturas para agregar los datos a la tabla ---
  tabla_web <- tabla_aaa <- tabla_ee <- tabla_gas <- tibble()

  # --- Generar la tabla con la información de la factura del internet ---
  # OJO: El valor era menor al inicio de 2025, hay que revisar si hace falta
  for (mes in mes_a_mes) {
    web <- list(
      proveedor = "Movistar Colombia Telecomunicaciones S.A. E.S.P.",
      total_a_pagar = 94990,
      periodo = toupper(format(as.Date(mes), "%b.-%Y")),
      cargo_del_mes = 94990,
      saldo_anterior = 0,
      fecha_lim = floor_date(as.Date(mes), unit = "month") + 9,
      No_contrato = "60512751061",
      f_lect_ant = NA_Date_,
      lect_ant = NA_real_,
      f_lect_act = NA_Date_,
      lect_act = NA_real_,
      cargo_AMP = NA_real_
    )
    tabla_web <- bind_rows(tabla_web, web)
  }
  cons_SS <- bind_rows(cons_SS, tabla_web)

  # --- Funciones para crear la tabla de consumo de servicios ---
  source("scripts/parse_aaa.R")
  source("scripts/parse_ee.R")
  source("scripts/parse_gas.R")

  # --- Carpetas de archivos temporales ---
  carpeta_facts <- "input/facturas_temp/"
  carpeta_imgs <- "input/facturas_temp/ee_imgs/"

  # --- Tabla del consumo de gas ---
  facturas_gas <- list.files(path = carpeta_facts, pattern = "^\\d{4}_\\d{2}_gas")
  de_gas <- length(facturas_gas)

  for (gas_pdf in facturas_gas) {
    cat(paste("Analizando", gas_pdf, " : ", which(facturas_gas == gas_pdf), "de", de_gas, "\n"))
    fact_gas <- parse_gas(paste0(carpeta_facts, gas_pdf))
    tabla_gas <- bind_rows(tabla_gas, fact_gas)
  }
  cons_SS <- bind_rows(cons_SS, tabla_gas)

  # --- Tabla del consumo de agua ---
  facturas_aaa <- list.files(path = carpeta_facts, pattern = "^\\d{4}_\\d{2}_aaa")
  de_agua <- length(facturas_aaa)

  for (aaa_pdf in facturas_aaa) {
    cat("Analizando", aaa_pdf, " : ", which(facturas_aaa == aaa_pdf), "de", de_agua, "\n")
    fact_aaa <- parse_aaa(paste0(carpeta_facts, aaa_pdf))
    tabla_aaa <- bind_rows(tabla_aaa, fact_aaa)
  }
  cons_SS <- bind_rows(cons_SS, tabla_aaa)

  # --- Generación de las imágenes de las facturas de energía eléctrica ---
  facturas_ee <- list.files(path = carpeta_facts, pattern = "NIC2345873")
  de_ee <- length(facturas_ee)
  imagenes_ee <- list.files(path = carpeta_imgs, pattern = "NIC2345873")
  de_imgee <- length(imagenes_ee)

  # para_imaginar <- ifelse(!(paste0(tools::file_path_sans_ext(facturas_ee), "_1.png") %in% imagenes_ee), 
  #                         facturas_ee, NA_character_)
  # para_imaginar <- para_imaginar[!is.na(para_imaginar)]
  # de_imaginar <- length(para_imaginar)

  purrr::map(
    paste0(carpeta_facts, imagenes_ee), # para_imaginar),
    \(ee_pdf) {
        cat("Generando imágen de: ", ee_pdf, ":", which(imagenes_ee == ee_pdf), "de", de_imgee, "\n") # which(para_imaginar == ee_pdf), "de", de_imaginar, "\n")
        pdf_convert(
        ee_pdf,
        dpi = 300,
        pages = 1,
        filenames = paste0(
          carpeta_imgs,
          tools::file_path_sans_ext(basename(ee_pdf)),
          "_p1.png"
        )
      )
    }
  )

  # --- Tabla del consumo de energía eléctrica ---
  for (ee_img in no_imagina) {
    cat("Analizando", ee_img, " : ", which(no_imagina == ee_img), "de", length(no_imagina), "\n")
    fact_ee <- parse_ee(paste0(carpeta_imgs, ee_img))
    tabla_ee <- bind_rows(tabla_ee, fact_ee)
  }
  cons_SS <- bind_rows(cons_SS, tabla_ee)
  cons_SS <- cons_SS |> arrange(fecha_lim) |> unique()

  saveRDS(cons_SS, "output/cons_SS.rds")

  return(cons_SS)
}






