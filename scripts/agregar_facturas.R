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

  cat("\nBuscando nuevas facturas para agregar.\n")

  # --- Definición de los períodos a consultar por servicio ---
  fecha_fin <- floor_date(Sys.Date(), unit = "month")

  # Relación entre los nombres de proveedores en cons_SS
  # y los nombres utilizados para descargar las facturas.
  proveedores <- c(
    web = "Movistar",
    aaa = "Triple A",
    gas = "Gases del Caribe",
    ee  = "Air-e"
  )

  # Obtener el primer período que necesita cada servicio.
  fechas_inicio <- sapply(proveedores, function(proveedor) {
    fechas <- cons_SS$fecha_lim[cons_SS$proveedor == proveedor]

    if (length(fechas) == 0 || all(is.na(fechas))) {
      stop(
        "No hay fechas válidas en cons_SS para el proveedor: ",
        proveedor
      )
    }

    ceiling_date(max(fechas, na.rm = TRUE), unit = "month")
  })
  fechas_inicio <- as.Date(fechas_inicio)

  # Construir los prefijos de archivo para cada servicio.
  mes_a_mes <- lapply(fechas_inicio, function(fecha_ini) {
    if (fecha_ini > fecha_fin) {
      return(character(0))
    }

    fechas <- seq.Date(
      from = fecha_ini,
      to = fecha_fin,
      by = "month"
    )

    paste0(format(fechas, "%Y_%m"), "_")
  })

  # Mostrar los períodos que se consultarán.
  for (servicio in names(mes_a_mes)) {
    periodos <- mes_a_mes[[servicio]]

    if (length(periodos) > 0) {
      cat(
        proveedores[[servicio]], ": ",
        paste0('"', periodos, '"', collapse = "; "),
        "\n",
        sep = ""
      )
    }
  }
  cat("\n")

  # --- Descargue nuevas facturas si existen ---
  descargar_facturas(mes_a_mes)

  # --- Use las nuevas facturas para agregar los datos a la tabla ---
  tabla_web <- tabla_aaa <- tabla_ee <- tabla_gas <- tibble()

  # --- Generar la tabla vacia de nuevos registros ---
  nuevos_registros <- tibble(
      proveedor = character(),
      total_a_pagar = numeric(),
      periodo = character(),
      cargo_del_mes = numeric(),
      saldo_anterior = numeric(),
      fecha_lim = as.Date(character()),
      No_contrato = character(),
      f_lect_ant = as.Date(character()),
      lect_ant = numeric(),
      f_lect_act = as.Date(character()),
      lect_act = numeric(),
      cargo_AMP = numeric()
  )

  # --- Carpetas de archivos temporales ---
  carpeta_facts <- here::here("input", "privado_temp")
  carpeta_imgs <- here::here("input", "privado_temp", "ee_imgs")
  fact_todas <- list.files(carpeta_facts, pattern = "\\.pdf$", full.names = TRUE)
  f_para_analizar <- filtre_fact_nuevas(fact_todas, cons_SS)

  # --- Tabla del consumo del internet ---
  # OJO: El valor era menor al inicio de 2025, hay que revisar si hace falta
  if (length(mes_a_mes$web) > 0) {
    crear_registro_web <- function(prefijo) {
      filas <- !is.na(pago_web_gsh4$fecha) & format(pago_web_gsh4$fecha, "%Y_%m_") == prefijo

      if (!any(filas)) {
        warning(
          "No se encontró un registro de internet para el período ",
          prefijo,
          " en pago_web_gsh4."
        )
        return(NULL)
      }

      fecha_periodo <- as.Date(paste0(
        substr(prefijo, 1, 4), "-",
        substr(prefijo, 6, 7), "-01"
      ))

      pago <- pago_web_gsh4[filas, ]

      tibble(
        proveedor = pago$proveedor,
        total_a_pagar = pago$valor_internet,
        periodo = toupper(format(fecha_periodo, "%b.-%Y")),
        cargo_del_mes = pago$valor_internet,
        saldo_anterior = 0,
        fecha_lim = fecha_periodo + 9,
        No_contrato = Sys.getenv("WEBID"),
        f_lect_ant = NA_Date_,
        lect_ant = NA_real_,
        f_lect_act = NA_Date_,
        lect_act = NA_real_,
        cargo_AMP = NA_real_
      )
    }
    nuevos_registros <- bind_rows(nuevos_registros, tabla_web)
  }

  # --- Tabla del consumo de gas ---
  facturas_gas <- f_para_analizar[str_detect(basename(f_para_analizar), pattern = "^\\d{4}_\\d{2}_gas")]
  de_gas <- length(facturas_gas)

  if (de_gas == 0) {
      cat("No hay facturas del gas para analizar.\n")
  } else {
    for (gas_pdf in facturas_gas) {
      cat("Analizando", basename(gas_pdf), " : ", which(facturas_gas == gas_pdf), "de", de_gas, "\n")
      fact_gas <- parse_gas(gas_pdf)
      tabla_gas <- bind_rows(tabla_gas, fact_gas)
    }
  nuevos_registros <- bind_rows(nuevos_registros, tabla_gas)
  }

  # --- Tabla del consumo de agua ---
  facturas_aaa <- f_para_analizar[str_detect(basename(f_para_analizar), pattern = "^\\d{4}_\\d{2}_aaa")]
  de_agua <- length(facturas_aaa)

  if (de_agua == 0) {
      cat("No hay facturas de agua para analizar.\n")
  } else {
    for (aaa_pdf in facturas_aaa) {
      cat("Analizando", basename(aaa_pdf), " : ", which(facturas_aaa == aaa_pdf), "de", de_agua, "\n")
      fact_aaa <- parse_aaa(aaa_pdf)
      tabla_aaa <- bind_rows(tabla_aaa, fact_aaa)
    }
    nuevos_registros <- bind_rows(nuevos_registros, tabla_aaa)
  }
  
  # --- Tabla del consumo de energía eléctrica ---
  facturas_ee <- f_para_analizar[str_detect(basename(f_para_analizar), pattern = "NIC2345873")]
  if (length(facturas_ee) != 0){
    imagenes_ee <- generar_imgs_ee()
    if (length(imagenes_ee) == 0) {
      todas_imgs_ee <- list.files(carpeta_imgs, pattern = "^\\d{4}_\\d{2}_", full.names = TRUE)
      if (length(todas_imgs_ee) > 0){
        imagenes_ee <- filtre_fact_nuevas(todas_imgs_ee, cons_SS)
      }
    }
    de_imgee <- length(imagenes_ee)
    if (de_imgee == 0){
      cat("No hay imágenes de facturas de electricidad para analizar.\n")
    } else {
      for (ee_img in imagenes_ee){
        cat("Analizando", basename(ee_img), " : ", which(imagenes_ee == ee_img), "de", de_imgee, "\n")
        fact_ee <- parse_ee(ee_img)
        tabla_ee <- bind_rows(tabla_ee, fact_ee)
      }
      nuevos_registros <- bind_rows(nuevos_registros, tabla_ee)
    }
  } else {
      cat("No hay facturas de electricidad recientes.\n")
  }
  nuevos_registros <- nuevos_registros |> arrange(fecha_lim) |> unique()

  return(nuevos_registros)
}



