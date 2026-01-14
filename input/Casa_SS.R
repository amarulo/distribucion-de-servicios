# En este script se encuentran los datos de las facturas que cambian mes a mes.

# SIEMPRE RECUERDE:
# - SALVAR EL DOCUMENTO HTML en el folder de output/Histórico antes de
#   cambiar los datos de este documento: Noviembre 2025 ya está salvado
# - Tomar la imagen de la tabla con la distribución a fin de mes con el total 
#   de los servicios: La tabla de noviembre 2025 ya está salvada.
# - Actualizar la información de los servicio en este archivo:
#   "input/Casa_SS.R"
# - Ajustar el valor del vector SS$Actual de acuerdo a la info disponible.
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
             Ocupa = c(1, 1/3, 1/3, 1)
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
               periodo = "11/2025",
               cargo_del_mes = 85507,
               saldo_anterior = 0,
               fecha_lim = unlist(str_split("20/01/2026","/")),
               cargo_fijo_mes    =  5147,
               consumo_mes       = 26649 + 12000,
               revision_periodica = 1636,
               No_contrato = 1020307
)
SS$Gas$fecha <- ymd(paste(SS$Gas$fecha_lim[3], SS$Gas$fecha_lim[2],
                          SS$Gas$fecha_lim[1], sep = "-"))
SS$Gas$total_a_pagar <- SS$Gas$cargo_del_mes + SS$Gas$saldo_anterior
SS$Gas$cargo_andres <- SS$Gas$cargo_del_mes - SS$Gas$consumo_mes - 
  SS$Gas$cargo_fijo_mes - SS$Gas$revision_periodica


## AAA ----
SS$AAA <- list(periodo = "Enero-2026",
               # ¡Ojo! la abreviatura del mes debe ir en inglés:
               fecha_lim = unlist(str_split("Jan 19-26","-")),
               total_pago_aaa = 274020,
               fecha_lect_act = dmy("29-12-2025"),
               fecha_lect_ant = dmy("28-11-2025"),
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
SS$EE <- list(periodoEE = "Dic. - 2025",
              vr_fact = 183820,
              f_venc = as.Date("2025-12-24"),
              f_lect = as.Date("2025-12-18"),
              f_ant = as.Date("2025-11-20"),
              lect_actual = 5182,
              lect_anterior = 4947,
              NIC = 2345873
)
SS$EE$kwh_f <- SS$EE$lect_actual - SS$EE$lect_anterior

### Contadores Internos ----
SS$EE$ConsInt <- list(fecha_lect_anter = as.Date("2025-11-20"),
                      fecha_lect_actual = as.Date("2025-12-19"),
                      lect_ini = c(413.01, 164.73, 5.06, 335.04),
                      lect_fin = c(523.04, 166.63, 5.37, 421.63),
                      contador = c(24177828, 24178030, 24176587, 24178159)
)
SS$EE$ConsInt$consumo <- SS$EE$ConsInt$lect_fin - SS$EE$ConsInt$lect_ini
SS$EE$ConsInt$por_repartir <- SS$EE$kwh_f - sum(SS$EE$ConsInt$consumo)
SS$EE$ConsInt$cons_per_hab <- SS$EE$ConsInt$por_repartir * 
  SS$EE$ConsInt$consumo / (sum(SS$EE$ConsInt$lect_fin) - 
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