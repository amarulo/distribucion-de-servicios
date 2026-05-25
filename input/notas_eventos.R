# NOTAS PRELIMINARES: ----

## Tabla de notas actualizada:
gs4_auth(path = "scripts/llave-ss-hacienda.json")
url_ss <- "https://docs.google.com/spreadsheets/d/1duuIfdB2F50626T8v9UL5Nrrk_-K-XyDhNHln24H3_0/edit?usp=sharing"
tabla_notas_gsh4 <- googlesheets4::read_sheet(
    ss = url_ss,
    sheet = "notas"
  )
tabla_notas_gsh4 <- tabla_notas_gsh4 |>
  mutate(fecha = as.Date(fecha))

## Notas Preliminares anteriores: ----
tabla_notas_input <- readRDS("input/tabla_notas.rds")

if(identical(tabla_notas_gsh4, tabla_notas_input)) {
  cat("La tabla guardada en input sigue estando vigente.")
} else {
  cat("La tabla guardada en input es diferente de la de Googlesheets, revise y si es necesario guarde la nueva version.")
}

## Salvar la tabla, REVISE la información antes de guardar
# saveRDS(tabla_notas_gsh4, "input/tabla_notas.rds")

## Preliminares 2026_05: ----
# nueva_nota <- tibble(
#   fecha = as.Date("2026-05-20"),
#   nota = "Cambié el sistema de listas a tabla, para los inquilinos utilizé como fecha de entrada el inicio de este año, para Luis dejé la fecha de nuestro matrimonio y para mi la fecha en que me mudé a esta casa.",
#   documento = "Por producir.")

## Preliminares 2026_04: ----
# nt_2026-04-27 <- "Jorge trajo su computador nuevamente y está trabajando acá desde la casa."

## Preliminares 2026_03: ----
# nt_2026-03-27 <- "Richard se llevó la llave de Gary y dijo que iba a tomar el cuarto de Jorge, que venía el 31 de marzo, pero nunca vino." # Esta nota no se incluye en la tabla.
# nt_2026-03-25 <- "Gary entregó su habitación." # Estoy pendiente de sacar los totales de los servicios.
# nt_2026-03-20 <- "Jorge se llevó sus cosas de la habitación, fue a pasar un tiempo a casa de su mamá."

### Nota sobre notas preliminares, 2026 05 20: ----
# Creé la tabla con las notas preliminares a partir de los archivos html en histórico. Falta el archivo de julio 2025, no está tampoco en Win11. Antes de junio, las notas se encuentran dispersas en los textos de las diferentes secciones de la distro de ee (los demás SS se dividían entre todos por igual). Recuerdo que hubo también distribuciones de servicios que no re registraron dentro de la tabla de habitantes en Casa_SS.R sino que se agregaron directamente a las ecuaciones de calculo de las distribuciones, por ende no hay registro de estas mas allá de la división final de los valores.

### Código para obtener la tabla con las notas preliminares de los documentos publicados
# # La tabla ya está salvada en esa misma carpeta: tabla_notas.rds
# historico <- list.files("output/Histórico/", full.names = TRUE)
# htmls <- grep(".html$", historico, value = TRUE)
# tabla_notas <- map_dfr(htmls, function(f) {
#   page <- read_html(f)
#   # locate the div with id="Notas"
#   notas_div <- xml_find_first(
#     page,
#     "//div[@id='Notas']"
#   )
#   # all elements AFTER that div
#   nodes <- xml_find_all(
#     notas_div,
#     "./following-sibling::*"
#   )
#   # Keep only <p> before the first <hr>
#   notes <- c()
#   for(node in nodes) {
#     if(xml_name(node) == "hr") {
#       break
#     }
#     if(xml_name(node) == "p") {
#       notes <- c(
#         notes,
#         html_text(node, trim = TRUE)
#       )
#     }
#   }
#   file_name <- basename(f)

#   tibble(
#     year = str_extract(file_name, "^\\d{4}"),
#     month = str_extract(file_name, "(?<=_)\\d{2}"),
#     note = notes,
#     file = file_name
#   )
# })


