
web <- list(
  proveedor = "Movistar",
  fecha_lim = ceiling_date(Sys.Date(), unit = "month") + 9,
  pago_mensual = 94990,
  ref_pago = 60512751061
)

carpeta_facts <- "input/facturas_temp/"

source("scripts/parse_gas.R")
facturas_gas <- list.files(path = "input/facturas_temp/", pattern = "^\\d{4}_\\d{2}_gas")
gas_pdf <- paste0(carpeta_facts, facturas_gas)
fact_gas <- parse_gas(gas_pdf)

source("scripts/parse_aaa.R")
facturas_aaa <- list.files(path = "input/facturas_temp/", pattern = "^\\d{4}_\\d{2}_aaa")
aaa_pdf <- paste0(carpeta_facts, facturas_aaa)

source("scripts/parse_ee.R")
facturas_ee <- list.files(path = "input/facturas_temp/", pattern = "^\\d{4}_\\d{2}_ee")
ee_pdf <- paste0(carpeta_facts, facturas_ee)


