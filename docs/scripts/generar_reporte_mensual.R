# Ajuste el año (AAAA) y el mes (mm) para generar el reporte correspondiente
# una vez lo tenga configurado salve este documento y copie y pegue el siguiente
# comando en la consola inferior: source("scripts/generar_reporte_mensual.R")
# una vez copiado presione Enter

AAAA <- 2026
mm <- 4

output_file <- paste0(
  AAAA, "_", sprintf("%02d", mm),
  "_Dist_SS"
)

quarto::quarto_render(
  input = "Dist_SS.qmd",
  execute_params = list(
    year = AAAA,
    month = mm
  ),
  output_file = output_file
)

current_path <- here::here("docs", paste0(output_file, ".html"))
new_path     <- here::here("docs", "reports", paste0(output_file, ".html"))

# Move the file safely
file.rename(from = current_path, to = new_path)