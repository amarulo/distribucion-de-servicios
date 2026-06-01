# ==============================================================================
# Función para producir las listas utilizadas en la preparación del informe mensual
# sobre la distribución de los servicios
# ==============================================================================

preparar_mes <- function(datos = NULL, yyyy = NULL, mm = NULL) {

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

  # Tablas con los datos del mes por servicio:
  aaa_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < as.Date(ceiling_date(f_ini_per + 28)) & 
      str_detect(proveedor, "^Triple")
    )
  ci_fm <- listablas$cont_int |>
    filter(
      fecha >= floor_date(f_ini_per - 28) & 
      fecha < ceiling_date(f_ini_per + 28)
    )
  ee_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < ceiling_date(f_ini_per + 28) & 
      str_detect(proveedor, "^Air")
    )
  gas_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < ceiling_date(f_ini_per + 28) & 
      str_detect(proveedor, "^Gases")
    )
  web_fm <- listablas$cons_SS |> 
    filter(
      fecha_lim >= f_ini_per & 
      fecha_lim < ceiling_date(f_ini_per + 28) & 
      str_detect(proveedor, "^Movistar")
    )

  ## Ajustes para los servicios: ----
  ### AAA ----
  ini_fact_aaa <- aaa_fm$f_lect_ant
  fin_fact_aaa <- aaa_fm$f_lect_act
  ocup_aaa <- listablas$habitantes_casa |>
    filter(!is.na(nombre)) |>                            # Quite habitaciones vacías
    mutate(salida = coalesce(salida, fin_fact_aaa)) |>   # Deje el final facturado si salida = NA
    filter(                                              # Deje solo ocupantes durante el periodo
      entrada <= fin_fact_aaa,
      salida >= ini_fact_aaa
    ) |>
    mutate(                                              # Compute el intervalo que se sobrepone 
      inicio_cobro = pmax(entrada, ini_fact_aaa),
      fin_cobro    = pmin(salida, fin_fact_aaa)
    ) |>
    mutate(                                              # Compute los días incluidos
      dias_pres_aaa =
        as.integer(fin_cobro - inicio_cobro)
    ) |>  
    select(
      habitacion,
      nombre,
      inicio_cobro,
      fin_cobro,
      dias_pres_aaa
    )
  
  ausenci_aaa <- listablas$ajustes_cons |>
    filter(
      tipo == "Ausencia"
    ) |>    
    mutate(                                               # overlap against bill interval
      inicio_aus = pmax(fecha_ini, ini_fact_aaa),
      fin_aus = pmin(fecha_fin, fin_fact_aaa)
    ) |>
    filter(                                               # keep only real overlaps
      inicio_aus <= fin_aus
    ) |>
    mutate(
      ajus_ausen_aaa = as.integer(fin_aus - inicio_aus)
    ) |>
    select(
      habitacion,
      nombre,
      ajus_ausen_aaa
    )

  factor_aaa <- listablas$ajustes_cons |>  
    filter(
      servicio == "AAA",
      tipo == "Factor"
    ) |>
    select(
      habitacion,
      nombre,
      factor_aaa = valor
    )

  pago_direct_aaa <- listablas$ajustes_cons |>
    filter(
      servicio == "AAA",
      tipo == "Pago"
    ) |>
    select(
      habitacion,
      nombre,
      pago_dir_aaa = valor
    )

  ### EE ----
  extra_ee <- listablas$ajustes_cons |>
    filter(
      servicio == "EE",
      tipo == "Extra_EE_use"
    )
  
  ### Web ----
  ini_fact_web <- f_ini_per
  fin_fact_web <- ceiling_date(f_ini_per + 28, unit = "month")
  ocup_web <- listablas$habitantes_casa |>
    filter(!is.na(nombre)) |>                            # Quite habitaciones vacías
    mutate(salida = coalesce(salida, fin_fact_web)) |>   # Deje el final facturado si salida = NA
    filter(                                              # Deje solo ocupantes durante el periodo
      entrada < fin_fact_web,
      salida >= ini_fact_web
    ) |>
    mutate(                                              # Compute el intervalo que se sobrepone 
      inicio_cobro = as.Date(pmax(entrada, ini_fact_web)),
      fin_cobro    = as.Date(pmin(salida, fin_fact_web))
    ) |>
    mutate(                                              # Compute los días incluidos
      dias_pres_web =
        as.integer(fin_cobro - inicio_cobro)
    ) |>  
    select(
      habitacion,
      nombre,
      inicio_cobro,
      fin_cobro,
      dias_pres_web
    )

  ausenci_web <- listablas$ajustes_cons |>
    filter(
      tipo == "Ausencia"
    ) |>    
    mutate(                                               # overlap against bill interval
      inicio_aus = pmax(fecha_ini, ini_fact_web),
      fin_aus = pmin(fecha_fin, fin_fact_web)
    ) |>
    filter(                                               # keep only real overlaps
      inicio_aus <= fin_aus
    ) |>
    mutate(
      ajus_ausen_web = as.integer(fin_aus - inicio_aus)
    ) |>
    select(
      habitacion,
      nombre,
      ajus_ausen_web
    )
  
  factor_web <- listablas$ajustes_cons |>  
    filter(
      servicio == "Web",
      tipo == "Factor"
    ) |>
    select(
      habitacion,
      nombre,
      factor_web = valor
    )

  ## Tablas de ajustes: ----
  # Individuales:
  ajustes_indiv <- ocup_aaa |>
    select(habitacion, nombre, dias_pres_aaa) |>
    left_join(
      ocup_web |>
        select(habitacion, nombre, dias_pres_web),
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      ausenci_aaa,
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      ausenci_web,
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      factor_aaa,
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      factor_web,
      by = c("habitacion", "nombre")
    ) |>
    left_join(
      pago_direct_aaa,
      by = c("habitacion", "nombre")
    ) |>
    mutate(
      dias_pres_web = coalesce(dias_pres_web, 0),
      ajus_ausen_aaa = coalesce(ajus_ausen_aaa, 0),
      ajus_ausen_web = coalesce(ajus_ausen_web, 0),
      factor_aaa = coalesce(factor_aaa, 1),
      factor_web = coalesce(factor_web, 1),
      pago_dir_aaa = coalesce(pago_dir_aaa, 0),
      pers_dia_aaa = (dias_pres_aaa - ajus_ausen_aaa) * factor_aaa,
      pers_dia_web = (dias_pres_web - ajus_ausen_web) * factor_web
    )

  ### Por habitación: ----
  ajustes_casa <- ajustes_indiv |>
      group_by(habitacion) |>
      summarise(
        ocupantes = paste(nombre, collapse = " y "),
        personas = n(),
        pago_dir_aaa = sum(pago_dir_aaa),
        pers_dia_aaa = sum(pers_dia_aaa),
        pers_dia_web = sum(pers_dia_web)
      )

  ## Lista con los datos por habitación:
  Casa <- list(
    Habitacion = ajustes_casa$habitacion,
    Ocupantes = ajustes_casa$ocupantes,
    Personas = ajustes_casa$personas,
    Ocupa_aaa = ajustes_casa$pers_dia_aaa/sum(ajustes_casa$pers_dia_aaa),
    Pago_Dir_AAA = ajustes_casa$pago_dir_aaa,
    Pers_Dia_Web = ajustes_casa$pers_dia_web
  )

  ## Lista de SS: ----
  SS <- list()
  # Vector Actual:
  # Las facturas actualizadas se agregan de acuerdo a la fecha_lim
  # Convenciones para los datos que ingresan en este vector:
  # "Gas" = Gases del Caribe ; "Web" = Movistar ; "AAA" = Triple A ;
  # "CI"  = Consumo registrado por los contadores internos ; "EE"  = Air-e
  SS$Actual <- c(
    Gas = nrow(gas_fm) > 0,
    AAA = nrow(aaa_fm) > 0,
    EE  = nrow(ee_fm) > 0,
    CI  = nrow(ci_fm) > 0,
    Web = TRUE
  )

  ### Gas ----
  if (SS$Actual["Gas"]) {
    SS$Gas <- list(
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
  }

  ### AAA ----
  if (SS$Actual["AAA"]) {
    SS$AAA <- list(
              periodo = aaa_fm$periodo,
              fecha = aaa_fm$fecha_lim,
              total_pago_aaa = aaa_fm$total_a_pagar,
              fecha_lect_act = fin_fact_aaa,
              lect_act = aaa_fm$lect_act,
              fecha_lect_ant = ini_fact_aaa,
              lect_ant = aaa_fm$lect_ant,
              No_poliza = aaa_fm$No_contrato,
              subtotal_AAA = Casa$Ocupa_aaa * (aaa_fm$total_a_pagar - sum(Casa$Pago_Dir_AAA))
    )
    SS$AAA$total_AAA  =  100 * round(SS$AAA$subtotal_AAA/100) + Casa$Pago_Dir_AAA
  }

  ### EE ----
  if (SS$Actual["EE"]) {
    SS$EE <- list(
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
  }

  ### CI (contadores internos) ----
  if (SS$Actual["CI"]) {
    SS$EE$ConsInt <- list(
                fecha_lect_anter = first(ci_fm$fecha),
                fecha_lect_actual = last(ci_fm$fecha),
                lect_ini = ci_fm |> summarise(across(matches("\\d{8}$"), ~ first(.))) |> unlist(),
                lect_fin = ci_fm |> summarise(across(matches("\\d{8}$"), ~ last(.))) |> unlist(),
                contador = names(ci_fm)[str_detect(names(ci_fm), "\\d{8}$")]
    )
    SS$EE$ConsInt$consumo <- SS$EE$ConsInt$lect_fin - SS$EE$ConsInt$lect_ini
    consumo_habs_vacias <- 0
    if (length(Casa$Habitacion) != length(SS$EE$ConsInt$consumo)) {
      habitaciones_activas <- tolower(gsub("\\.\\s?", "", Casa$Habitacion))
      codigos_medidores <- sub("_.*", "", names(SS$EE$ConsInt$consumo))
      es_activa <- codigos_medidores %in% habitaciones_activas
      consumo_habs_vacias <- sum(SS$EE$ConsInt$consumo[!es_activa])
      SS$EE$ConsInt$consumo <- SS$EE$ConsInt$consumo[es_activa]
    }
    if (nrow(extra_ee) > 0) {
      SS$EE$ConsInt$por_repartir <- extra_ee$valor + consumo_habs_vacias
      SS$EE$ConsInt$ee_de_mas <- SS$EE$kwh_f - extra_ee$valor - sum(SS$EE$ConsInt$consumo)
      SS$EE$ConsInt$direct_ee <- rep(0, length(SS$EE$ConsInt$consumo))
      names(SS$EE$ConsInt$direct_ee) <- names(SS$EE$ConsInt$consumo)
      room <- gsub("\\. ", "", tolower(extra_ee$habitacion))
      SS$EE$ConsInt$direct_ee[str_detect(names(SS$EE$ConsInt$direct_ee), room)] <- SS$EE$ConsInt$ee_de_mas
      SS$EE$ConsInt$cons_per_hab <- (SS$EE$ConsInt$por_repartir * SS$EE$ConsInt$consumo / 
                                  sum(SS$EE$ConsInt$consumo)) + SS$EE$ConsInt$direct_ee
    } else {
      SS$EE$ConsInt$por_repartir <- SS$EE$kwh_f - sum(SS$EE$ConsInt$consumo) + consumo_habs_vacias
      SS$EE$ConsInt$cons_per_hab <- SS$EE$ConsInt$por_repartir * SS$EE$ConsInt$consumo / 
                                  sum(SS$EE$ConsInt$consumo)
    }
    SS$EE$total_EE <- 100 * round(SS$EE$vr_fact * (SS$EE$ConsInt$consumo + SS$EE$ConsInt$cons_per_hab) / 
                                 (100 * SS$EE$kwh_f))
  }
  
  ### Web ----
  if (SS$Actual["Web"]) {
    SS$Web <- list(
      valor_pago = web_fm$total_a_pagar,
      fecha_lim = web_fm$fecha_lim,
      ref_pago = web_fm$No_contrato
      )
    SS$Web$vr_per_dia <- 100 * round(SS$Web$valor_pago / (100 * sum(Casa$Pers_Dia_Web)))
    SS$Web$total_Web <- SS$Web$vr_per_dia * Casa$Pers_Dia_Web
  }

  list(
    fIni_per = f_ini_per,
    SS = SS,
    Casa = Casa
  )
}

# mes_actual <- preparar_mes(
#   yyyy = 2026,
#   mm = 4
# )

# SS <- mes_actual$SS
# Casa <- mes_actual$Casa

# # DONE: ----
# ## docu Gas ----
# if (SS$Actual["Gas"]){
#   writeLines(paste0("La factura de la casa grande (contrato No.",
#                   SS$Gas$No_contrato,
#                   "), por un valor total de $",
#                   format(SS$Gas$total_a_pagar, big.mark=".", decimal.mark=","),
#                   if (SS$Gas$saldo_anterior != 0){
#                     paste0(" correspondiente a los períodos ", 
#                            format(my(SS$Gas$periodo) - days(30), "%b"),
#                            " y ",
#                            format(my(SS$Gas$periodo), "%b de %Y"))
#                   } else {
#                     paste0(" correspondiente al período ", SS$Gas$periodo)
#                   },
#                   ", está para pagar antes del ",
#                   format(SS$Gas$fecha, "%d de %B de %Y"),
#                   ".\n", "\n",
#            "NOTA: Del valor total de este mes me corresponde pagar: $",
#                   format(100 * round((SS$Gas$cargo_andres) / 100),
#                          big.mark=".",decimal.mark=","), ".\n"))
# } else {
#   writeLines("Factura no disponible todavía.")
# }

# ## docu AAA: ----
# writeLines(if (SS$Actual["AAA"]) {
#     paste0("La factura del agua (póliza No.", SS$AAA$No_poliza,
#            "), por un valor total de $",
#            format(SS$AAA$total_pago_aaa, big.mark = ".",
#                   decimal.mark = ","),
#            ", correspondiente al período: ", SS$AAA$periodo,
#            ", está para pagar antes del ",
#            format(ymd(SS$AAA$fecha), "%d de %B de %Y"),
#            ".\n\nSegún la factura, la fecha de la lectura anterior fue el ",
#            format(SS$AAA$fecha_lect_ant, "%d de %B de %Y"),
#            " y la fecha de la lectura actual el ",
#            format(SS$AAA$fecha_lect_act, "%d de %B de %Y"),
#            " (consumo: ", SS$AAA$lect_act - SS$AAA$lect_ant, " m³)", ".\n")
#   } else {
#     "Todavía no hay factura disponible para este período."
# })

# ### 2.2. Total pago por habitación
# if (SS$Actual["AAA"]) {
#   data.table(Habitación = Casa$Habitacion, `Integrante(s)` = Casa$Ocupantes,
#              Ocupación = label_percent(accuracy = 0.01)(Casa$Ocupa_aaa),
#              `Total AAA` = label_currency(prefix = "$", big.mark = ".",
#                                           decimal.mark = ",")(SS$AAA$total_AAA))
# } else {
#     writeLines("La factura de este período no está disponible todavía.")
# }

# ## docu EE ----
# ### 3.1. Datos de la factura:
# writeLines(if (SS$Actual["EE"]) {
#            paste0("Para el período ", SS$EE$periodoEE, 
#                   ", el valor total a pagar por la factura de energía eléctrica del NIC: ",
#                   SS$EE$NIC, " es de $",
#                   format(SS$EE$vr_fact, big.mark = ".", decimal.mark = ","),
#                   ".\nEste valor corresponde a un consumo de ", SS$EE$kwh_f, " Kws en ",
#                   SS$EE$f_lect_act - SS$EE$f_lect_ant, " días ",
#                   if (SS$EE$f_lect_ant) { paste0("desde el ",
#                                             format(SS$EE$f_lect_ant+1, format = "%d de %B"),
#                                             " ") },
#                   if (SS$EE$f_lect_act) { paste0("hasta el ",
#                                              format(SS$EE$f_lect_act, format = "%d de %B de %Y"))
#                   } else {
#                     ", pero sin lectura actual (consumo estimado)" 
#                   }, ".\n\nLa factura tiene fecha de vencimiento para pagar hasta el ", 
#                   format(SS$EE$f_venc, format = "%d de %B de %Y"),".\n")
#   } else {
#     "La factura del período actual todavía no está disponible.\n"
#   })

# #### 3.2.1. Diferencias sobre datos de consumo
# writeLines(if (SS$Actual["CI"]) {
#   paste0("La suma total de los consumos internos para este período es de ",
#          sum(SS$EE$ConsInt$consumo), if ("EE" %in% SS$Actual) {
#                     paste0(" Kw. Quedando un consumo a repartir de ",
#                            SS$EE$kwh_f - sum(SS$EE$ConsInt$consumo),
#                            " Kw respecto al consumo reportado por air-e.")
#                     } else {" Kw.\n"})
#   } else {"Consumo no disponible todavía."})

# writeLines(if (SS$Actual["CI"]) {
#   paste0("La última lectura de los contadores internos se realizó el ",
#          format(SS$EE$ConsInt$fecha_lect_actual, "%d de %B de %Y"),
#          " y la lectura anterior se hizo el ",
#          format(SS$EE$ConsInt$fecha_lect_anter, "%d de %B de %Y"),
#          ".\nEn cuanto a Air-e, ", if (SS$Actual["EE"]) {
#            paste0("la lectura actual la realizó el ", format(SS$EE$f_lect_act, "%d de %B de %Y"),
#            " y la lectura anterior el ", format(SS$EE$f_lect_ant, "%d de %B de %Y"), ".\n")
#          } else {
#            "la factura no está disponible todavía.\n"
#          })
#   } else {
#     "No hay datos disponibles todavía.\n"
#   })

# if (SS$Actual["EE"]) {
#   tibble(`Factura air-e` = paste(SS$EE$kwh_f,"Kw"),
#        `Lectura contadores` = paste(round(sum(SS$EE$ConsInt$lect_fin) - 
#                                           sum(SS$EE$ConsInt$lect_ini),
#                                           digits=2),"Kw"),
#        Diferencia = paste0(abs(round(SS$EE$kwh_f - (sum(SS$EE$ConsInt$lect_fin) -
#                                        sum(SS$EE$ConsInt$lect_ini)), digits = 2)),
#                            " Kw"),
#        `Número de días factura` = paste0(SS$EE$f_lect_act - SS$EE$f_lect_ant," días"),
#        `Número de días interno` = paste0(SS$EE$ConsInt$fecha_lect_actual - 
#                                            SS$EE$ConsInt$fecha_lect_anter," días"),
#        )
# } else {writeLines("Factura no disponible todavía.\n")}

# #### 3.2.2. Valor de corte
# if (SS$Actual["EE"]) {
#   writeLines(paste0("Este mes hemos ",if (round(10 - SS$EE$kwh_f/as.numeric(SS$EE$f_lect_act - SS$EE$f_lect_ant), digits=3) <0) {"aumentado "} else {"disminuido "},"el promedio de consumo diario en ",
#   abs(round(10 - SS$EE$kwh_f/as.numeric(SS$EE$f_lect_act - SS$EE$f_lect_ant), digits=3))," Kw con respecto al corte.\n"))
# } else {writeLines("Factura no disponible todavía.\n")}

# #### 3.2.3. Lectura de contadores internos
# if (SS$Actual["CI"]) {
#   data.table(Habitación = Casa$Habitacion,
#            `Contador` = gsub("^.{3,4}_", "No.", str_to_title(SS$EE$ConsInt$contador)),
#            `Lectura final` = SS$EE$ConsInt$lect_fin,
#            `Lectura inicial` = SS$EE$ConsInt$lect_ini,
#            `Consumo Kw` = SS$EE$ConsInt$consumo)
# } else {writeLines("Consumo no disponible todavía.\n")}

# #### 3.2.4. Consumo area común
# if (SS$Actual["EE"]) {
#   data.table(`Habitación` = Casa$Habitacion,
#            `Consumo Contador` = SS$EE$ConsInt$consumo,
#            `Asignado Area Común` = round(SS$EE$ConsInt$cons_per_hab,2)) %>%
#   mutate(`Consumo Total por Hab.` = `Consumo Contador` + `Asignado Area Común`)
# } else {
#   writeLines("No hay datos de la factura todavía.\n")
# }

# ### 3.3. Total a pagar por habitación
# if (SS$Actual["EE"]) {
#   data.table(Habitación = Casa$Habitacion,
#            `Integrante(s)` = Casa$Ocupantes,
#            `Costo Energía` = label_currency(prefix = "$", big.mark = ".",
#                           decimal.mark = ",")(SS$EE$total_EE))
# } else {
#   writeLines("Factura no disponible todavía.\n")
# }

# ## docu Web: ----
# writeLines(paste0("El valor total de la factura del Internet por $",
#                   format(SS$Web$valor_pago, big.mark=".", decimal.mark=","),
#                   ", con referencia de pago ", SS$Web$ref_pago, ", está para pagar antes del ",
#                   format(SS$Web$fecha_lim, "%d de %B de %Y"), ".\n"))
# data.table(Habitación = Casa$Habitacion,
#       `Integrante(s)` = Casa$Ocupantes,
#       `Costo Internet` = label_currency(prefix = "$", big.mark = ".", decimal.mark = ",")(SS$Web$total_Web)
