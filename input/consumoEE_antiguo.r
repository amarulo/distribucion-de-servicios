# Librerias:----
load_libs <- function(){
  # Declare a vector with the names of the libraries to upload:
  librerias <- c("tidyverse","data.table","magrittr","hms","scales",
                 "rlang")
  
  # Set up a variable to check the number of libraries loaded:
  ctrl <- length(librerias)
  # Load the librerias silently:
  librerias <- suppressMessages(lapply(librerias,library,
                                       character.only=TRUE))
  if (ctrl == length(librerias)){ # Checking the number of loaded libs
    libs <- unlist(librerias[[2]])
    libs <- paste0(sort(libs), collapse = "\n\t + ")
    salida <- paste0("The following libraries were installed:\n\t + ",libs)
  } else {
    salida <- "Algo pasó, ¡hay que revisar!"
  }
  return(writeLines(salida))
}
load_libs()




# Directorio de almacenamiento:----
setwd("C:/Users/Mono/Documents/Hacienda +/Air-e")




# Notas:----
# El día que CAMA y KAHY regresaron del dpto. del Magdalena hice 
# doble lectura antes y después de que arribaran, en uso dejé el 
# de antes que llegaran y este es el de después:
# fecha[10] <- "2024-10-14 22:58:00"
# datos[10] <- 31759.1
# El 28-10-2024 cambió el contador Air-e
# Cambió del contador: 28 de octubre 2024.
# La lectura del nuevo contador arranca en 2.5 kW
# El domingo 24/11/2024 olvidé tomar los datos, los datos 
# ingresados corresponden al promedio de los datos tomados el 23
# y el 25 del mismo mes. 
# 6/12/2024: no tomé el dato sino hasta las 2:50 AM del 7/12/2024,
# entonces interpolé para las 11:40 PM del 6/12/2024.
# 7/12/2024: no tomé el dato, promedié con el siguiente día.
# 10/12/2024: murió Rachel y no tomé dato, adicional CAMA me informó
# que esa noche prendieron el aire, promedié y ajusté con respecto
# al promedio entre 22/10/2024 a 12/12/2024 (13.328) para reflejar
# la situación.
# Con las celebraciones y los viajes a Bogotá y al Rodadero, no tomé
# varios datos, todos los que faltan y falten de ahí en adelante, son
# interpolaciones promedio de los que hay.
# Para febrero 2025 Jorge compró nevera y el promedio aumentó en 1.88 kWh




# Históricos de fechas y datos:----
# _Antiguo contador:----
# fecha1 <- c(
#            "2024-10-5 02:20:18", "2024-10-06 03:44:10", 
#            "2024-10-07 02:18:30", "2024-10-08 23:04:00", 
#            "2024-10-09 21:36:00", "2024-10-10 23:18:00", 
#            "2024-10-11 23:47:00", "2024-10-12 23:56:00", 
#            "2024-10-13 22:41:00", "2024-10-14 13:00:16",
#            "2024-10-15 17:28:41", "2024-10-16 21:53:00",
#            "2024-10-17 22:06:00", "2024-10-18 20:30:00",
#            "2024-10-19 23:59:00", "2024-10-20 21:59:00",
#            "2024-10-21 21:35:00", "2024-10-22 21:47:00",
#            "2024-10-23 21:04:00", "2024-10-24 22:37:00",
#            "2024-10-25 23:35:00", "2024-10-26 23:02:00",
#            "2024-10-27 21:31:00", "2024-10-28 11:17:00"
# )

# datos1 <- c(
#            31589.2, 31608.7, 31621.5, 31656.3, 31674.9, 31689.8, 
#            31707.5, 31724.7, 31742.7, 31750.9, 31772.4, 31794.1,
#            31810.9, 31827.5, 31845.2569, 31865.0, 31881.0, 31899.3,
#            31917.5, 31937.2, 31953.6, 31968.5, 31981.5, 31991.3
# )
# Contador_Antiguo <- data.table(Fecha = fecha1, Datos = datos1)
# write.csv(Contador_Antiguo, file = "Contador_Antiguo.csv", append = FALSE, 
#           quote = TRUE,row.names = F)

# _Nuevo contador:----
# Fechas:
# fechasCSV <- c(
#       Oct    "2024-10-28 12:14:00", "2024-10-28 23:08:00",
#            "2024-10-29 22:59:00", "2024-10-30 22:09:00",
#       [5]  "2024-10-31 21:50:00", 
#       Nov  "2024-11-01 22:20:00",
#            "2024-11-02 23:14:00", "2024-11-03 21:14:00",
#            "2024-11-04 22:47:00", "2024-11-05 21:51:00",
#            "2024-11-06 22:15:00", "2024-11-07 21:43:00",
#            "2024-11-08 19:50:00", "2024-11-09 22:16:00",
#            "2024-11-10 19:59:00", "2024-11-11 22:45:00",
#            "2024-11-12 22:12:00", "2024-11-13 22:03:00",
#            "2024-11-14 22:41:00", "2024-11-15 20:52:00",
#            "2024-11-16 22:53:00", "2024-11-17 21:34:00",
#            "2024-11-18 22:38:00", "2024-11-19 22:30:00",
#            "2024-11-20 21:52:00", "2024-11-21 21:46:00",
#            "2024-11-22 22:11:00", "2024-11-23 22:38:50",
#            "2024-11-24 23:06:00", "2024-11-25 23:30:00",
#            "2024-11-26 22:09:00", "2024-11-27 20:57:00",
#            "2024-11-28 22:01:00", "2024-11-29 23:39:00",
#       [30] "2024-11-30 23:41:00", 
#       Dic  "2024-12-01 22:35:00",
#            "2024-12-02 22:10:00", "2024-12-03 21:03:00",
#            "2024-12-04 20:03:00", "2024-12-05 21:00:00",
#            "2024-12-06 23:40:00", "2024-12-07 23:40:00",
#            "2024-12-08 23:40:00", "2024-12-09 22:25:00",
#            "2024-12-10 22:22:30", "2024-12-11 22:20:00",
#            "2024-12-12 23:19:00", "2024-12-14 21:08:00", 
#            "2024-12-15 23:44:00", "2024-12-16 21:35:00", 
#            "2024-12-18 23:59:00", "2024-12-27 23:41:00",
#       [18] "2024-12-29 23:58:00", 
#       Ene  "2025-01-02 22:00:00", "2025-01-03 23:30:00",
#            "2025-01-04 22:36:00", "2025-01-05 22:06:00",
#            "2025-01-06 22:04:00", "2025-01-07 20:52:00",
#            "2025-01-08 22:53:00", "2025-01-10 23:32:00",
#            "2025-01-11 22:03:00", "2025-01-12 22:56:00",
#            "2025-01-13 22:50:00", "2025-01-14 23:06:00",
#            "2025-01-16 23:58:00", "2025-01-19 23:21:00",
#            "2025-01-20 22:53:00", "2025-01-21 22:41:00",
#            "2025-01-23 23:05:00", "2025-01-26 22:34:00",
#       [19] "2025-01-30 23:05:00", "2025-01-31 21:03:00",
#
#       Feb  "2025-02-01 23:54:00", "2025-02-02 22:08:00",
#            "2025-02-04 22:05:00", "2025-02-05 22:15:00",
#            "2025-02-09 23:37:00", "2025-02-10 22:19:00",
#            "2025-02-12 22:38:00", "2025-02-13 22:06:00",
#            "2025-02-16 23:11:00", "2025-02-17 22:47:00",
#            "2025-02-18 22:07:00", "2025-02-20 23:06:00",
#            "2025-02-21 23:17:00", "2025-02-23 22:48:00",
#            "2025-02-24 23:53:00", "2025-02-25 22:26:00",
#       [17] "2025-02-26 22:48:00",
#       Mar  "2025-03-04 21:52:00", "2025-03-06 21:11:00",
#            "2025-03-07 22:22:00", "2025-03-09 23:03:00" 
# )

# Datos:
# datosCSV <- c(
#       Oct  2.50, 10.07, 26.12, 41.80, 55.23,
#       Nov  67.99, 80.34, 90.65, 102.75, 114.40, 126.75, 139.28, 150.77,
#            164.51, 175.26, 189.18, 202.24, 215.15, 228.15, 240.58, 254.32,
#            265.01, 276.23, 289.02, 300.93, 313.38, 324.72, 336.06, 347.86,
#       [25] 360.20, 371.27, 382.50, 397.18, 410.11, 422.47, 
#       Dic  435.46, 453.60, 467.94, 481.41, 494.35, 509.06, 520.28, 531.51,
#            543.78, 557.11, 573.23, 587.97, 612.73, 625.80, 638.13, 663.45, 
#       [17] 785.26, 811.89, 
#       Ene  853.07, 867.58, 880.42, 892.07, 904.27, 916.81, 931.43, 954.51, 
#            963.38, 975.74, 987.41, 999.70, 1022.26, 1056.89, 1068.69,
#       [16] 1081.21, 1106.90, 1145.25, 1213.68, 1226.88, 
#       Feb  1241.88, 1254.32, 1283.01, 1297.48, 1344.96, 1357.45, 1382.18, 
#            1394.70, 1440.10, 1454.73, 1468.77, 1498.98, 1513.87, 1541.75,
#       [15] 1557.60, 1571.10, 1586.73, 
#       Mar  1676.61, 1705.81, 1720.53, 1750.89
# )
# Nuevo_Contador <- data.table(Fecha=fechasCSV,Datos=datosCSV)
# write.csv(Nuevo_Contador, file = "Nuevo_Contador.csv", append = FALSE, 
#           quote = TRUE,row.names = F)


# Fechas y datos actuales:----
fecha2 <- c(
  "2025-03-20 22:09:00", "2025-03-27 22:14:00",
  "2025-03-30 23:09:00", "2025-03-31 23:33:00", 
  
  "2025-04-01 23:13:00",
  "2025-04-02 21:05:00", "2025-04-09 23:15:00",
  "2025-04-15 22:56:00", "2025-04-16 22:41:00",
  "2025-04-19 23:59:00", "2025-04-21 22:35:00",
  "2025-04-22 23:18:00", "2025-04-24 23:54:00",
  "2025-04-26 22:05:00", "2025-04-28 23:13:00",
  "2025-04-29 23:58:00", "2025-04-30 20:13:00"
)
datos2 <- c(
  1890.07, 1990.86, 2038.54, 2055.55, 
  2070.90, 2083.80, 2191.47, 2289.98, 2303.70, 2339.07, 2384.56,
  2399.95, 2430.87, 2459.15, 2490.22, 2505.96, 2519.20
)
f_y_d_actuales <- data.table(Fecha=fecha2,Datos=datos2)
write.csv(f_y_d_actuales, file = "Nuevo_Contador.csv", append = FALSE, 
          quote = TRUE,row.names = F)


# Fórmulas para el cálculo del consumo:----
# Definición de valores de medida de cada vector:
# hasta1 <- length(datos1) - 1
hasta2 <- length(datos2) - 1
hasta <- hasta2 # + hasta1 - 1


# Conversión de los vectores de fechas de char a POSIXlt:
# dates1 <- as.POSIXlt(1:hasta1+1)
# dates1[1] <- strptime(fecha1[1], "%Y-%m-%d %H:%M:%S")
# for (i in 1:hasta1+1) {
#  fech <- strptime(fecha1[i], "%Y-%m-%d %H:%M:%S")
#  dates1[i] <- fech
# }

dates2 <- as.POSIXlt(1:hasta2+1)
dates2[1] <- strptime(fecha2[1], "%Y-%m-%d %H:%M:%S")
for (i in 1:hasta2+1) {
  fech <- strptime(fecha2[i], "%Y-%m-%d %H:%M:%S")
  dates2[i] <- fech
}


# Creación de los vectores de intervalos de tiempo y consumo por 
# intervalo
diftimeInSecs <- timeIntervUse <- (1:hasta)

# for (i in 1:hasta1-1) {
#   timeIntervUse[i] <- datos1[i+1] - datos1[i]
#   diftimeInSecs[i] <- as.numeric(difftime(dates1[i+1], dates1[i],
#                                           units="secs"))
# }
# timeIntervUse[hasta1] <- datos1[hasta1+1] - datos1[hasta1] + datos2[2] - 
#                          datos2[1]
# diftimeInSecs[hasta1] <- as.numeric(difftime(dates1[hasta1+1], 
#                                            dates1[hasta1], units="secs")) +
#                          as.numeric(difftime(dates2[2], dates2[1], 
#                                              units="secs"))

cont <- 1 # + hasta1 <<< La formula para el cambio de contador está
# comentada mas abajo, la que viene es solo con el contador nuevo, 
# para revisar todo habría que invertir los comentarios

for (i in 1:hasta){
  if (as.numeric(date(dates2[i+1])-date(dates2[i]))==1){
    diftimeInSecs[cont] <- as.numeric(difftime(dates2[i+1], dates2[i],
                                               units="secs"))
    timeIntervUse[cont] <- datos2[i+1] - datos2[i]
    cont <- cont+1
  } else {
      for (j in 1:as.numeric(date(dates2[i+1])-date(dates2[i]))){
        divisor <- as.numeric(date(dates2[i+1])-date(dates2[i]))
        diftimeInSecs[cont] <- as.numeric(difftime(dates2[i+1], dates2[i],
                                                   units="secs"))/divisor
        timeIntervUse[cont] <- (datos2[i+1] - datos2[i])/divisor
        cont <- cont+1
      }
  }
}

# for (i in (hasta1+1):hasta){
#  if (as.numeric(date(dates2[i+1-(hasta-hasta2)])-
#                 date(dates2[i-(hasta-hasta2)]))==1){
#    diftimeInSecs[cont] <- as.numeric(difftime(dates2[i+1-(hasta-hasta2)],
#                                   dates2[i-(hasta-hasta2)], units="secs"))
#    timeIntervUse[cont] <- datos2[i+1-(hasta-hasta2)] - 
#                           datos2[i-(hasta-hasta2)]
#    cont <- cont+1
#  } else {
#    for (j in 1:as.numeric(date(dates2[i+1-(hasta-hasta2)])-
#                           date(dates2[i-(hasta-hasta2)]))){
#      divisor <- as.numeric(date(dates2[i+1-(hasta-hasta2)])-
#                            date(dates2[i-(hasta-hasta2)]))
#      diftimeInSecs[cont] <- as.numeric(difftime(dates2[i+1-(hasta-hasta2)],
#                           dates2[i-(hasta-hasta2)], units="secs"))/divisor
#      timeIntervUse[cont] <- (datos2[i+1-(hasta-hasta2)] - 
#                              datos2[i-(hasta-hasta2)])/divisor
#      cont <- cont+1
#    }
#  }
#}

# Formulas para revisar el numero de elementos de los vectores
# date(dates2[length(dates2)])-date(dates1[1])
# length(diftimeInSecs)
numDatos <- length(timeIntervUse)


# Estandarización del consumo para intervalos de 24h y definición
# del vector de fechas:
datoEstand24h <- fecha <- c(1:numDatos)
fecha <- as.Date(fecha)
for (i in 1:numDatos) {
  datoEstand24h[i] <- 24*60*60*timeIntervUse[i]/diftimeInSecs[i]
# La fecha arranca desde la primera disponible de fechas 2  
  fecha[i] <- date(dates2[1]) + (i-1)
}




# Gráfica:----
# Creacion del data-frame a graficar:
# 01-05-25: Le cambié los nombres a las columnas de toPlot, los puse
# con mayúsculas para evitar confusiones con los vectores.

# OJO: está limitado a 31 obs.
toPlot <- data.frame(Fecha=fecha[1:31],Consumo=datoEstand24h[1:31])

# Definition of constants:
avgDaily <- mean(toPlot$Consumo)
# consMaxDiarioSinAire <- datoEstand24h[5]
# Tuve el valor de corte en 14kW, pero lo bajé al valor máximo de 
# diciembre 13.65647, ahora en feb/25 lo subo de acuerdo a la subida
# del promedio por cuenta de la nevera de Jorge, lo dejé en 15
# 01-05-25: avg mar+abr 14.810335
# avg 20-03 al 19-04: 15.204456

filas <- nrow(toPlot)-3
consumoEE <- ggplot(toPlot, aes(Fecha,Consumo)) + 
  geom_col(aes(fill=Consumo)) +
  scale_fill_gradient(low="forestgreen", high="red", name = "Kw/h por día") +
  labs(x = "Fecha", y = "Consumo en Kw/h",
       title ="Consumo de energía eléctrica diaria",
       subtitle = "(Estandarizado para períodos de 24h)") +
  geom_hline(aes(yintercept = avgDaily), color = "red") +
  annotate("text",x=toPlot$Fecha[filas], y=avgDaily+0.7, hjust=0,
           label="Promedio")+
  geom_hline(aes(yintercept = 15), color = "gray10") +
  annotate("text",x=toPlot$Fecha[filas], y=14.5, hjust=0, label="Corte") +
  scale_x_date(date_breaks="3 days",date_labels="%m-%d") +
  scale_y_continuous(breaks = seq(0, max(toPlot$Consumo), by = 2))

consumoEE

# Líneas sacadas, son de gráficas anteriores:
# geom_hline(aes(yintercept = consMaxDiarioSinAire), color = "green2") +
  # annotate(geom = "text", x = toPlot[numDatos,1]+1.1,
  #          y = datoEstand24h[5]-0.7, hjust= 0.4, label = "Sin aire") + 
# annotate(geom = "text", x = toPlot[hasta1,1], y = 1, 
#   label = "Cambio de contador", hjust= 0.075, vjust= 0.36, angle = 90) +
#  coord_cartesian(xlim = c(toPlot[1,1]-0.5,toPlot[numDatos,1]+1.5))




# Valores importantes:----
altoCons <- filter(toPlot, Consumo > avgDaily)
enExceso <- sum(altoCons$Consumo) - nrow(altoCons)*avgDaily

consTotalAbr25 <- subset(toPlot, Fecha>"2025-3-19" & Fecha<"2025-4-20")
kwAbr25 <- sum(consTotalAbr25$Consumo) ##[1] 471.3381
avgAbr25 <- kwAbr25/nrow(consTotalAbr25) ##[1] 15.20446 diff: +1.152196
consTotalMar25 <- subset(toPlot, fecha>"2025-2-16"&fecha<"2025-3-20")
kwMar25 <- sum(consTotalMar25$datoEstand24h) ##[1] 435.6201
avgMar25 <- kwMar25/nrow(consTotalMar25) ##[1] 14.05226 diff: +0.1967497
consTotalFeb25 <- subset(toPlot, fecha>"2025-1-20"&fecha<"2025-2-18")
kwFeb25 <- sum(consTotalFeb25$datoEstand24h)
avgFeb25 <- kwFeb25/nrow(consTotalFeb25) ##[1] 13.85551 diff: +1.878271
consTotalEne25 <- subset(toPlot, fecha>"2024-12-19"&fecha<"2025-1-21")
kwEne25 <- sum(consTotalEne25$datoEstand24h)
avgEne25 <- kwEne25/nrow(consTotalEne25) ##[1] 11.97724
consTotalDic24 <- subset(toPlot, fecha>"2024-11-19"&fecha<"2024-12-20")
kwDic24 <- sum(consTotalDic24$datoEstand24h)
consTotalNov24 <- subset(toPlot, fecha>"2024-10-20"&fecha<"2024-11-21")
kwNov24 <- sum(consTotalNov24$datoEstand24h)

