# Casa: ----

## Lista de integrantes por habitación tomada de googlesheets:
  googlesheets4::gs4_auth(path = here::here(".entradas", "llave-ss-hacienda.json"))
url_ss <- Sys.getenv("URL_TABLAS_HACIENDA")
habitantes_casa_gsh4 <- googlesheets4::read_sheet(
    ss = url_ss,
    sheet = "habitantes"
  )
habitantes_casa_gsh4 <- habitantes_casa_gsh4 |>
  mutate(
    entrada = as.Date(entrada),
    salida = as.Date(salida)
  )

## Lista de integrantes por habitación salvada en input:
habitantes_casa_input <- readRDS("input/habitantes_casa.rds")

if(identical(habitantes_casa_input, habitantes_casa_gsh4)) {
  cat("La tabla guardada en input sigue estando vigente.")
} else {
  cat("La tabla guardada en input es diferente de la de Googlesheets, revise y si es necesario guarde la nueva version.")
}

# Antes de salvar la nueva version revise que toda la info esté correcta:
# saveRDS(habitantes_casa_gsh4, "input/habitantes_casa.rds")

# Esta tabla también se cambió a partir de el 20 de mayo de 2026, la idea es mantener la vigencia mientras perdure, e ir introduciendo los cambios a través de Googlesheets a medida que ocurran para que no haya que recuperar información de períodos anteriores.

# 2026-05-20 Cambio del sistema de archivo de info de listas a tabla, 
# para los inquilinos utilizo la información a partir de este año,
# para Luis dejé la fecha de nuestro matrimonio y para mi la fecha en que me mudé a esta casa.
# habitantes_casa <- tibble(
#   habitacion = c("Hab. 1", "Hab. 1", "Hab. 2", "Hab. 3", "Hab. 4", "Hab. 5", "Apt.", "Apt."),
#   nombre     = c("Andresito", "Kevin", "Jorge", "Gary", NA_character_, NA_character_, "Luis", "Andrés"), 
#   entrada    = c("2025-08-01", "2025-08-01", "2025_08_01", "2025_08_01", NA_Date_, NA_Date_, "2023-03-14", "2016-05-01"),
#   salida     = c(NA_Date_, NA_Date_, NA_Date_, "2026-03-25", NA_Date_, NA_Date_, NA_Date_, NA_Date_) 
# )

## Lista Casa anterior: ----
# Casa <- list(Habitantes = list(
#                             "Hab. 1" = c("Andresito", "Kevin"), 
#                             "Hab. 2" = c("Jorge"),
#                             "Hab. 3" = c("Gary"), 
#                             "Apt."   = c("Luis", "Andrés")),
#              Ocupa = c(1, 1/6, 1/6, 1)
# )
# Casa$Habitación <- names(Casa$Habitantes)
# Casa$`Integrante(s)` <- unlist(lapply(Casa$Habitantes, 
#                                       \(Hab) if (length(Hab) > 1) {
#                                         paste0(Hab, collapse = " y ")
#                                       } else {
#                                         Hab
#                                       }))
# Casa$Personas <- unlist(lapply(Casa$Habitantes, length))

