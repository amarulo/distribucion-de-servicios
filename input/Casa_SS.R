# En este script se encuentran los datos de las facturas que cambian mes a mes.

# SIEMPRE RECUERDE:
# - SALVAR EL DOCUMENTO HTML en el folder de output/Histórico antes de
#   cambiar los datos de este documento: Noviembre 2025 ya está salvado
# - Tomar la imagen de la tabla con la distribución a fin de mes con el total 
#   de los servicios: La tabla de noviembre 2025 ya está salvada.
# - Actualizar la información de los servicio en este archivo:
#   "input/Casa_SS.R"
# - Una vez actualizado este script, correr TODOS los chunks en el archivo
#   "output/Dist_SS.Rmd" para evitar errores.


# Casa: ----
# Lista de habitaciones, integrantes y otros datos 
# para tener en cuenta para el consumo:

Casa <- list(Habitantes = list(
                            "Hab. 1" = c("Andresito", "Kevin"), 
                            "Hab. 2" = c("Jorge"),
                            "Hab. 3" = c("Gary"), 
                            "Apt."   = c("Luis", "Andrés")),
             Ocupa = c(1, 1/6, 1/6, 1)
)
Casa$Habitación <- names(Casa$Habitantes)
Casa$`Integrante(s)` <- unlist(lapply(Casa$Habitantes, 
                                      \(Hab) if (length(Hab) > 1) {
                                        paste0(Hab, collapse = " y ")
                                      } else {
                                        Hab
                                      }))
Casa$Personas <- unlist(lapply(Casa$Habitantes, length))

# SS: ----
hoy <- Sys.Date()
SS <- list()

## Gas ----
SS$Gas <- list(
               periodo = "02/2026",
               cargo_del_mes = 77284,
               saldo_anterior = 0,
               fecha_lim = unlist(str_split("18/03/2026","/")),
               cargo_fijo_mes    =  5206,
               consumo_mes       = 35916, # Consumo de Gas Natural
               revision_periodica = 1798,
               No_contrato = 1020307
)
SS$Gas$fecha <- ymd(paste(SS$Gas$fecha_lim[3], SS$Gas$fecha_lim[2],
                          SS$Gas$fecha_lim[1], sep = "-"))
SS$Gas$total_a_pagar <- SS$Gas$cargo_del_mes + SS$Gas$saldo_anterior
SS$Gas$cargo_andres <- SS$Gas$cargo_del_mes - SS$Gas$consumo_mes - 
  SS$Gas$cargo_fijo_mes - SS$Gas$revision_periodica


## AAA ----
SS$AAA <- list(periodo = "Marzo-2026",
               # ¡Ojo! el mes debe ir en formato de número mm:
               fecha_lim = unlist(str_split("03 16-26","-")),
               total_pago_aaa = 264804,
               fecha_lect_act = dmy("28-02-2026"),
               fecha_lect_ant = dmy("29-01-2026"),
               No_poliza = 121497
)
SS$AAA$fecha <- format(ymd(paste(paste0("20", SS$AAA$fecha_lim[2]),
                                 SS$AAA$fecha_lim[1])), "%Y-%m-%d")
SS$AAA$subtotal_AAA <- 100 * round((Casa$Personas * Casa$Ocupa /100) * 
                                     SS$AAA$total_pago_aaa / 
                                  (sum((Casa$Personas * Casa$Ocupa /100)*100)))
SS$AAA$total_AAA <- SS$AAA$subtotal_AAA # + c(50000,0,0,0)


## EE ----
### Factura EE ----
SS$EE <- list(periodoEE = "Mar. - 2026",
              vr_fact = 183820,
              f_venc = as.Date("2026-03-25"),
              f_lect = as.Date("2026-03-18"),
              f_ant = as.Date("2026-02-18"),
              lect_actual = 5932,
              lect_anterior = 5697,
              NIC = 2345873
)
SS$EE$kwh_f <- SS$EE$lect_actual - SS$EE$lect_anterior

### Contadores Internos ----
SS$EE$ConsInt <- list(fecha_lect_anter = as.Date("2026-02-19"),
                      fecha_lect_actual = as.Date("2026-03-19"),
                      lect_ini = c(751.60, 176.09, 6.59, 591.89),
                      lect_fin = c(847.93, 181.14, 6.86, 679.85),
                      contador = c(24177828, 24178030, 24176587, 24178159)
)
SS$EE$ConsInt$consumo <- SS$EE$ConsInt$lect_fin - SS$EE$ConsInt$lect_ini # + c(0, 9.32, 0, 0)
SS$EE$ConsInt$por_repartir <- SS$EE$kwh_f - sum(SS$EE$ConsInt$consumo)
SS$EE$ConsInt$cons_per_hab <- SS$EE$ConsInt$por_repartir * 
  SS$EE$ConsInt$consumo / (sum(SS$EE$ConsInt$lect_fin) - # + 9.32 - 
                             sum(SS$EE$ConsInt$lect_ini))
SS$EE$total_EE <- 100 * round(SS$EE$vr_fact *
                                (SS$EE$ConsInt$consumo + 
                                   SS$EE$ConsInt$cons_per_hab) / 
                                (100 * SS$EE$kwh_f))


## Web ----
SS$Web <- list(
  valor_pago = 94990,
  webCon = c(2, 1/2, 0, 2),
  fecha_lim = ymd(paste0(str_sub(as.character(hoy + 30), 1, 8), "10")),
  ref_pago = 60512751061
  )
SS$Web$per_Per <- 100 * round(SS$Web$valor_pago / (100 * sum(SS$Web$webCon)))
SS$Web$total_Web <- SS$Web$per_Per * SS$Web$webCon


## Switch Actual ----
# Lista con los datos de las facturas de los servicios actualizadas,
# Estas se agregan automaticamente al siguiente vector de acuerdo a la fecha
# límite de pago de la factura cada mes:
SS$Actual <- c(NA, NA, NA, NA, "Web")
# Convenciones para los datos que ingresan en este vector:
#       "Gas" = Gases del Caribe
#       "Web" = Movistar
#       "AAA" = Triple A
#       "CI"  = Consumo registrado por los contadores internos
#       "EE"  = Air-e
if(month(hoy) == month(SS$Gas$fecha) & year(hoy) == year(SS$Gas$fecha)){
  SS$Actual[[1]] <- "Gas"
}
if(month(hoy) == month(SS$AAA$fecha) & year(hoy) == year(SS$AAA$fecha)){
  SS$Actual[[2]] <- "AAA"
}
if(month(hoy) == month(SS$EE$f_venc) & year(hoy) == year(SS$EE$f_venc)){
  SS$Actual[[3]] <- "EE"
}
if(month(hoy) == month(SS$EE$ConsInt$fecha_lect_actual) & 
   year(hoy) == year(SS$EE$ConsInt$fecha_lect_actual)){
  SS$Actual[[4]] <- "CI"
}