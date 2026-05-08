# Función para cargar las librerías:

load_libs <- function(){
  # Vector con los nombres de las librerias a cargar:
  librerias <- c("tidyverse", "data.table", "gargle", "googledrive", "hms", 
    "htmltools", "rio", "rlang", "rsconnect", "scales")
  
  # Variable para chequear el numero de librerias cargadas:
  ctrl <- length(librerias)
  # Cargue las librerias silenciosamente:
  librerias <- suppressMessages(lapply(librerias,library,
                                       character.only=TRUE))
  
  if (ctrl == length(librerias)){ # Chequee el numero de librerias cargadas
    base_libs <- sort(sessionInfo()$base)
    base_toP <- paste(base_libs[1:length(base_libs) - 1], collapse = ", ")
    libs <- sort(unlist(librerias[[length(librerias)]]))
    libs <- libs[!(libs %in% base_libs)]
    libs_toP <- paste0(libs[1:length(libs) - 1], collapse = ", ")
    salida <- paste0("Las siguientes librerías de base R fueron instaladas: ",
                     base_toP, " y ", base_libs[length(base_libs)], ".\n",
                     "Adicionalmente las siguientes librerias fueron cargadas: ",
                     libs_toP, " y ", libs[length(libs)], ".\n")
  } else {
    salida <- "Algo pasó, ¡hay que revisar!"
  }
  return(writeLines(salida))
}

load_libs()

# Borrar la función para cargar las librerías
rm(load_libs)
