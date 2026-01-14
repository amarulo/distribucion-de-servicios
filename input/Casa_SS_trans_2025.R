# Casa: ----
# Lista de habitaciones, integrantes y otros datos a tener en cuenta para el consumo

Casa <- list(Habitantes = list("Hab. 1"=c("Andresito", "Kevin"), "Hab. 2"=c("Jorge"),
                               "Hab. 3"=c("Gary"), "Apt."=c("Luis", "Andrés")),
             Ocupa = c(1,1,1/3,1)
)
Casa$Habitación <- names(Casa$Habitantes)
Casa$`Integrante(s)` <- unlist(lapply(Casa$Habitantes, \(Hab) if (length(Hab) > 1) {
  paste0(Hab, collapse = " y ") 
} else { Hab }))
Casa$Personas <- unlist(lapply(Casa$Habitantes, length))
# Para la tabla de ponderación de EE:
Casa$En_casa <- as.numeric(c(1+0,1,0,1+0))
Casa$Aparatos <- as.numeric(c(3+1+0.5+0.5,1+0.5,0.5,3+1+0.5+0.5))

# SS: ----
# Lista con los datos de las facturas de los servicios,
# organizadas por fecha de arrivo de las facturas

# Sept-2025
SS <- list(Actual = c("Gas", "Web", "AAA", "EE"))

## Gas ----
SS$Gas <- list(
               periodo = "09/2025",
               total_pago = 94027,
               consumo_mes = 53766,
               fecha_lim = unlist(str_split("20/10/2025","/")),
               cargo_fijo_mes = 5134,
               revision_periodica = 1441,
               No_contrato = 1020307
)
SS$Gas$fecha <- ymd(paste(SS$Gas$fecha_lim[3], SS$Gas$fecha_lim[2], SS$Gas$fecha_lim[1],
                         sep = "-"))

## AAA ----
SS$AAA <- list(periodo = "Octubre-2025",
               # ¡Ojo! la abreviatura del mes debe ir en inglés:
               fecha_lim = unlist(str_split("Oct 15-25","-")),
               total_pago_a = 339660,
               No_poliza = 121497
)
SS$AAA$total_AAA <- 100 * round((Casa$Personas * Casa$Ocupa /100) * SS$AAA$total_pago_a / 
                                  (sum((Casa$Personas * Casa$Ocupa /100)*100)))

## EE ----
SS$EE <- list(periodoEE = "Oct. - 2025",
              vr_fact = 246220,
              f_venc = as.Date("2025-10-27"),
              f_lect = as.Date("2025-10-19"),
              f_ant = as.Date("2025-09-20"),
              kwh_f = 296,
              NIC = 2345873
)
SS$EE$CoeficientEE <- (Casa$Personas + Casa$En_casa + Casa$Aparatos) * Casa$Ocupa
SS$EE$ConsInt <- list(fecha_lect_anter = "19 de septiembre de 2025",
                      fecha_lect_actual = "19 de octubre de 2025",
                      lect_ini = c(171.68, 75.61, 3.82, 157.85),
                      lect_fin = c(300.35, 121.47, 4.57, 246.63),
                      contador = c(24177828, 24178030, 24176587, 24178159)
)
SS$EE$ConsInt$consumo <- SS$EE$ConsInt$lect_fin - SS$EE$ConsInt$lect_ini
SS$EE$ConsInt$por_repartir <- SS$EE$kwh_f - sum(SS$EE$ConsInt$consumo)
SS$EE$ConsInt$cons_per_hab <- SS$EE$ConsInt$por_repartir * SS$EE$ConsInt$consumo / 
  (sum(SS$EE$ConsInt$lect_fin) - sum(SS$EE$ConsInt$lect_ini))
SS$EE$total_EE <- 100 * round(SS$EE$vr_fact *
                                  (SS$EE$ConsInt$consumo + SS$EE$ConsInt$cons_per_hab)
                                / (100 * SS$EE$kwh_f))

## Web ----
SS$Web <- list(valor_pago = 94990,
               webCon = c(2,1,0,2),
               fecha_lim = ymd(paste0("2025-",format(Sys.Date()+30,"%m"),"-10")),
               ref_pago = 60512751061)
SS$Web$per_Per <- 100*round(SS$Web$valor_pago/(100*sum(SS$Web$webCon)))
SS$Web$total_Web <- SS$Web$per_Per * SS$Web$webCon

