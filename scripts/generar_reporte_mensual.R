# ==============================================================================
# Script para generar el reporte mensual sobre la distribución de los servicios
# ==============================================================================

# Ajuste el año (AAAA) y el mes (mm) para generar el reporte correspondiente
# una vez lo tenga configurado salve este documento y copie y pegue el siguiente
# comando en la consola inferior: source("scripts/generar_reporte_mensual.R")
# una vez copiado presione Enter

# --- INGRESE EL AÑO Y MES PARA GENERAR EL REPORTE ---
# Por defecto se utilizan el mes y año actuales
AAAA <- as.numeric(format(Sys.Date(), "%Y"))
mm <- as.numeric(format(Sys.Date(), "%m"))

 
# --- Nombre-base para el archivo de salida ---
output_file <- paste0(
  AAAA, "_", sprintf("%02d", mm),
  "_Dist_SS"
)

# --- Generar el nuevo reporte estableciendo el año y mes ingresados ---
quarto::quarto_render(
  input = "Dist_SS.qmd",
  execute_params = list(
    year = AAAA,
    month = mm
  ),
  output_file = output_file
)

# --- Mueva el reporte al folder 'reports' ---
current_path <- here::here("docs", paste0(output_file, ".html"))
new_path     <- here::here("docs", "reports", paste0(output_file, ".html"))

file.rename(from = current_path, to = new_path)


# --- ACTUALICE LA PÁGINA DE ENTRADA, EL ÍNDICE ---

# 1. Define paths safely from the project root
index_qmd_path <- here::here("index.qmd")
reports_dir  <- here::here("docs", "reports")
previous_dir <- here::here("docs", "reports", "previous_reports")

# 2. List all HTML files inside those folders
report_files <- list.files(reports_dir,  pattern = "\\.html$", full.names = FALSE)
old_reports  <- list.files(previous_dir, pattern = "\\.html$", full.names = FALSE)

# 3. Base content (YAML)
index_content <- c(
  "---",
  "title: \"Hacienda +\"",
  "---",
  "",
  "# Distribución de servicios",
  "",
  "## Reportes mensuales",
  ""
)

# 4. Function to write the index lines for each group
write_indx_lines <- function(files_ls, destino) {
  lines <- ""
  for (file in files_ls) {
    # Extract year and month to make a clean name (e.g., "Abril 2026")
    year_part <- gsub("^(\\d{4})_.*", "\\1", file)
    month_part <- gsub("^\\d{4}_(\\d{2})_.*", "\\1", file)
    
    # Quick translation mapping for a polished look
    mes_nombre <- switch(month_part,
                         "01" = "Enero", "02" = "Febrero", "03" = "Marzo", 
                         "04" = "Abril", "05" = "Mayo", "06" = "Junio", 
                         "07" = "Julio", "08" = "Agosto", "09" = "Septiembre", 
                         "10" = "Octubre", "11" = "Noviembre", "12" = "Diciembre",
                         paste("Mes", month_part))
    
    report_name <- paste(mes_nombre, year_part)
    
    # Create the link pointing inside the reports/ subfolder for the browser
    link_line <- paste0("- [", report_name, "](", destino, "/", file, ")")
    lines <- c(lines, link_line)
  }
  lines[1] <- if (destino == "reports") {"#### Formato actual"} else {"#### Formato anterior"}
  return(lines)
}

# 4A. Sort the each group of reports
if (length(report_files) == 0 && length(old_reports) == 0) {
  index_content <- c(index_content, "*No se han encontrado reportes todavía.*")
} else {
  # Sort files in reverse order (newest month first)
  report_files <- sort(report_files, decreasing = TRUE)
  old_reports  <- sort(old_reports,  decreasing = TRUE)
}

# 4B. Write the link lines for the reports
# Keep the string "reports" or "reports/previous_reports" as argument destino 
# because this is for the web browser URL (not R's file system)
new_links <- write_indx_lines(report_files, "reports")
old_links <- write_indx_lines(old_reports, "reports/previous_reports")

index_content <- c(index_content, new_links, " ",old_links)


# 5. Save and overwrite index.qmd safely using the absolute root path
writeLines(index_content, index_qmd_path)

# 6. Render to docs/index.html using absolute pathing
quarto::quarto_render(
  input = index_qmd_path, 
  output_file = "index.html"
)

message("¡index.html actualizado!")


  