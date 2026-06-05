# ==============================================================================
# Función para producir las listas utilizadas en la preparación del informe mensual
# sobre la distribución de los servicios.
# ==============================================================================

source(here::here("scripts", "ajustes_aaa.R"))
source(here::here("scripts", "ajustes_web.R"))

distro_mes <- function(datos = NULL, yyyy = NULL, mm = NULL) {

  # Si no hay datos:
  if (is.null(datos)) {
    listablas <- cargar_info()
  } else {
    listablas <- datos
  }

  # Si no hay año ni mes:
  if(is.null(yyyy) && is.null(mm)) {
    f_ini_per <- as.Date(floor_date(Sys.Date(), unit = "months"))
  }

  # Si solo hay uno de año o mes:
  if(xor(is.null(yyyy), is.null(mm))) {
    stop("yyyy y mm deben suministrarse juntos.")
  }

  # Ajuste la fecha inicial del período:
  f_ini_per <- ymd(paste0(yyyy, "-", mm, "-01"))

  # Vector Actual: ----
  # Las facturas actualizadas se agregan de acuerdo a la fecha_lim
  # Convenciones para los datos que ingresan en este vector:
  # "Gas" = Gases del Caribe ; "Web" = Movistar ; "AAA" = Triple A ;
  # "CI"  = Consumo registrado por los contadores internos ; "EE"  = Air-e
  Actual <- c(
    Gas = FALSE,
    AAA = FALSE,
    EE  = FALSE,
    CI  = FALSE,
    Web = TRUE
  )

  # Habitaciones activas:
  hab_activa <- listablas$habitantes_casa |>
    filter(!is.na(nombre) & entrada < f_ini_per & (is.na(salida) | salida > f_ini_per)) |>
    pluck(1)|>
    unique()|>
    tolower() |>
    str_replace("\\.\\s?", "")
    
  ## Gas: ---- 
  # --- Tabla con los datos del mes ---
  gas_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < ceiling_date(f_ini_per + 28) & 
      str_detect(proveedor, "^Gases")
    )
  # --- Cambiar valor en el vector Actual si ya hay factura ---
  Actual["Gas"] <- nrow(gas_fm) > 0
  # --- Reunir los datos del gas en una Lista ---- 
  if (Actual["Gas"]) {
    Gas <- list(
            periodo = f_ini_per,
            perio_f = gas_fm$periodo,
            total_a_pagar = gas_fm$total_a_pagar,
            cargo_del_mes = gas_fm$cargo_del_mes,
            saldo_anterior = gas_fm$saldo_anterior,
            fecha = gas_fm$fecha_lim,
            f_lect_ant = gas_fm$f_lect_ant,
            lect_ant = gas_fm$lect_ant,
            f_lect_act = gas_fm$f_lect_act,
            lect_act = gas_fm$lect_act,
            cargo_andres = gas_fm$cargo_AMP,
            No_contrato = gas_fm$No_contrato
    )
  } else {
    Gas <- list()
  }

  ## Agua (AAA): ----
  # --- Tabla con los datos del mes ---
  aaa_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < as.Date(ceiling_date(f_ini_per + 28)) & 
      str_detect(proveedor, "^Triple")
    )
  # --- Cambiar valor en el vector Actual si ya hay factura ---
  Actual["AAA"] <- nrow(aaa_fm) > 0
  # --- Realize los ajustes pertinentes al agua ---
  if (Actual["AAA"]) {
    ajust_hab_aaa <- ajustes_aaa(aaa_fm, listablas)
  }
  # --- Reunir los datos del agua en una Lista ---- 
  if (Actual["AAA"] && nrow(ajust_hab_aaa) > 0) {
    AAA <- list(
              habitacion = ajust_hab_aaa$habitacion, 
              ocupantes = ajust_hab_aaa$ocupantes,
              ocupa = ajust_hab_aaa$pers_dia_aaa/sum(ajust_hab_aaa$pers_dia_aaa),
              periodo = aaa_fm$periodo,
              fecha = aaa_fm$fecha_lim,
              total_pago_aaa = aaa_fm$total_a_pagar,
              fecha_lect_act = aaa_fm$f_lect_act,
              lect_act = aaa_fm$lect_act,
              fecha_lect_ant = aaa_fm$f_lect_ant,
              lect_ant = aaa_fm$lect_ant,
              No_poliza = aaa_fm$No_contrato,
              subtotal_AAA = ajust_hab_aaa$pers_dia_aaa * (aaa_fm$total_a_pagar - sum(ajust_hab_aaa$pago_dir_aaa))
    )
    AAA$total_AAA  =  100 * round(AAA$subtotal_AAA/(sum(ajust_hab_aaa$pers_dia_aaa) * 100)) +
                      ajust_hab_aaa$pago_dir_aaa
  } else {
    AAA <- list()
  }

  ## Energía Eléctrica (EE): ----
  ee_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < ceiling_date(f_ini_per + 28) & 
      str_detect(proveedor, "^Air")
    )
  Actual["EE"] <- nrow(ee_fm) > 0
  ### EE ----
  if (Actual["EE"]) {
    EE <- list(
                periodoEE = ee_fm$periodo,
                vr_fact = ee_fm$total_a_pagar,
                f_venc = ee_fm$fecha_lim,
                f_lect_act = ee_fm$f_lect_act,
                f_lect_ant = ee_fm$f_lect_ant,
                lect_actual = ee_fm$lect_act,
                lect_anterior = ee_fm$lect_ant,
                NIC = ee_fm$No_contrato,
                kwh_f = ee_fm$lect_act - ee_fm$lect_ant
    )
  } else { 
    EE <- list() 
  }
  ### --- Ajustes por ocupación: ---
  # En el caso de la EE la ponderación del consumo del área común se hace en proporción al consumo
  # reportado por los contadores internos, se asume que las lecturas inician cuando haya ocupantes.
  ### --- Ajustes por uso de habitación desocupada: ---
  extra_ee <- listablas$ajustes_cons |>
    filter(
      servicio == "EE",
      tipo == "Uso Hab. 4"      # Hab. 3 está cubierta por el contador
    )
  ## Contadores Internos (CI):
  ci_fm <- listablas$cont_int |>
    filter(
      fecha >= floor_date(f_ini_per - 28) & 
      fecha < ceiling_date(f_ini_per + 28)
    )
  Actual["CI"] <- nrow(ci_fm) > 0
  ### CI (contadores internos) ----
  if (Actual["CI"]) {
    EE$CI <- list(
                hab_activa = hab_activa,
                fecha_lect_anter = first(ci_fm$fecha),
                fecha_lect_actual = last(ci_fm$fecha),
                lect_ini = ci_fm |> summarise(across(matches("\\d{8}$"), ~ first(.))) |> unlist(),
                lect_fin = ci_fm |> summarise(across(matches("\\d{8}$"), ~ last(.))) |> unlist(),
                contador = names(ci_fm)[str_detect(names(ci_fm), "\\d{8}$")]
    )
    EE$CI$consumo <- EE$CI$lect_fin - EE$CI$lect_ini
    consumo_habs_vacias <- 0
    if (length(hab_activa) != length(EE$CI$consumo)) {
      codigos_medidores <- sub("_.*", "", names(EE$CI$consumo))
      es_activa <- codigos_medidores %in% hab_activa
      consumo_habs_vacias <- sum(EE$CI$consumo[!es_activa])
      EE$CI$consumo <- EE$CI$consumo[es_activa]
    }
    if (nrow(extra_ee) > 0) {
      EE$CI$por_repartir <- extra_ee$valor + consumo_habs_vacias
      EE$CI$ee_de_mas <- EE$kwh_f - extra_ee$valor - sum(EE$CI$consumo)
      EE$CI$direct_ee <- rep(0, length(EE$CI$consumo))
      names(EE$CI$direct_ee) <- names(EE$CI$consumo)
      room <- gsub("\\. ", "", tolower(extra_ee$habitacion))
      EE$CI$direct_ee[str_detect(names(EE$CI$direct_ee), room)] <- EE$CI$ee_de_mas
      EE$CI$cons_per_hab <- (EE$CI$por_repartir * EE$CI$consumo / 
                                  sum(EE$CI$consumo)) + EE$CI$direct_ee
    } else {
      EE$CI$por_repartir <- EE$kwh_f - sum(EE$CI$consumo) + consumo_habs_vacias
      EE$CI$cons_per_hab <- EE$CI$por_repartir * EE$CI$consumo / 
                                  sum(EE$CI$consumo)
    }
    EE$total_EE <- 100 * round(EE$vr_fact * (EE$CI$consumo + EE$CI$cons_per_hab) / 
                                 (100 * EE$kwh_f))
  } else {
    EE$CI <- list()
  }

  ## Web - Servicio de Internet: ----
  web_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < ceiling_date(f_ini_per + 28) & 
      str_detect(proveedor, "^Movistar")
    )
  # --- Realize los ajustes pertinentes al internet ---
  ajust_hab_web <- ajustes_web(f_ini_per, listablas)
  # --- Reunir los datos del internet en una Lista ---- 
  Web <- list(
      habitacion = ajust_hab_web$habitacion,
      ocupantes = ajust_hab_web$ocupantes,
      valor_pago = web_fm$total_a_pagar,
      fecha_lim = web_fm$fecha_lim,
      ref_pago = web_fm$No_contrato
  )
  Web$vr_per_dia <- 100 * round(Web$valor_pago / (100 * sum(ajust_hab_web$pers_dia_web)))
  Web$total_Web <- Web$vr_per_dia * ajust_hab_web$pers_dia_web

  ## Fechas para seleccionar notas preliminares:
  fechas_per <- list(
    fIni_per = f_ini_per, 
    fecha_min = min(f_ini_per, gas_fm$f_lect_ant, aaa_fm$f_lect_ant, ee_fm$f_lect_ant)
  )
  
  list(
    "Actual" = Actual, 
    "Gas" = Gas, 
    "AAA" = AAA, 
    "EE" = EE, 
    "Web" = Web,
    "fechas_per" = fechas_per
  )
}

# SS <- list(fIni_per = f_ini_per, "Actual" = Actual, "Web" = Web, "Gas" = Gas, "AAA" = AAA, "EE" = EE)
