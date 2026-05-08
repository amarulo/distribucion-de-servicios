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


# NOTAS: ----
nt_2026_04_27 <- "Jorge trajo su computador nuevamente y está trabajando acá desde casa."
nt_2026_03_27 <- "Richard se llevó la llave de Gary y dijo que iba a tomar el cuarto de Jorge, que venía el 31 de marzo, pero nunca vino."
nt_2026_03_25 <- "Gary ntregó su habitación, estoy pendiente de sacar los totales de los servicios."
nt_2026_03_20 <- "Jorge se llevó sus cosas y se fue a vivir a casa de su mamá."


