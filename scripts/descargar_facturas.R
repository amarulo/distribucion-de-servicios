# ==============================================================================
# descargar_facturas.R
# Propósito: Descargar las diferentes facturas de servicios de Google Drive
# Author: Dist_SS
# Date: 2026-05-07
# ==============================================================================
# SETUP: Authentication & Configuration
# ==============================================================================

# Regla Global: Nunca abra el navegador automáticamente
options(gargle_oauth_interactive = FALSE)
# En caso que este código arroje un error (debido a: interactive = FALSE),
# Comente (#) la línea de código anterior y descomente la que sigue (quite #):
# options(gargle_oauth_interactive = TRUE)

# Establezca el email desde las variables del sistema de R:
google_email <- Sys.getenv("GOOGLE_HM_EMAIL")

if (google_email == "") {
  stop("GOOGLE_HM_EMAIL not found in .Renviron. Please set it and restart R.")
}

cat("Authenticating with Google Account:", google_email, "\n")

# AUTENTICAR DRIVE (Permanente / Sin necesidad del navegador)
# Esta vía usa la llave del robot:
drive_auth(path = here::here(Sys.getenv("SECRETO_HM"), "llave-ss-hacienda.json"))

cat("✓ Authentication successful\n\n")

# ==============================================================================
# CONFIGURACIÓN: Carpetas, Etiquetas, and Fechas
# ==============================================================================

# Defina la carpeta de destino para descargar las facturas
download_dir <- here::here("input", "facturas_temp")
if (!dir.exists(download_dir)) {
  dir.create(download_dir, recursive = TRUE)
  cat("Carpeta creada:", download_dir, "\n")
}

# Determine el rango de fechas de facturas para descargar
# Lógica: 
# Antes de mayo de 2026 => baje todas las facturas disponibles;
# de mayo 2026 en adelante => baje solamente las facturas del último mes
current_date <- Sys.Date()
cutoff_date <- ymd("2026-05-15")

if (current_date < cutoff_date) {
  # Baje todas las facturas de enero 2025 en adelante
  start_date <- ymd("2025-01-01")
  cat("Modo: DESCARGA INICIAL (facturas desde enero de 2025 en adelante)\n")
} else {
  # Baje solamente las del último mes
  start_date <- fecha_ini
  cat("Modo: DESCARGA MENSUAL (", format(start_date, "%B %Y"), ")\n")
}

cat("Rango de fechas: desde ", format(start_date, "%Y-%m-%d"), " hasta ", 
    format(current_date, "%Y-%m-%d"), "\n\n")

# ==============================================================================
# FUNCIÓN: Descargar facturas de Google Drive
# ==============================================================================

download_from_drive <- function(folder_path, download_dir, start_date) {
  cat("Bajando facturas de Google Drive:", folder_path, "\n")
  
  # Navigate to folder
  folder <- drive_find(pattern = folder_path, type = "folder", n_max = 1)
  print(folder[[1]])
  if (nrow(folder) == 0) {
    warning("Folder not found: ", folder_path)
    return(NULL)
  }
  
  # List files in folder
  files <- drive_ls(folder$id)
     print(paste(files$drive_resource, collapse = ", "))

  if (nrow(files) == 0) {
    cat("  → No files found\n")
    return(NULL)
  }

  # Filter PDFs by modification date
  files_filtered <- files %>%
  mutate(mime_type = purrr::map_chr(drive_resource, "mimeType")) %>%
  filter(mime_type == "application/pdf") %>%
  mutate(modified_date = as.Date(purrr::map_chr(drive_resource, "modifiedTime"))) %>%
  filter(modified_date >= start_date)
  
  # Baje los documentos
  downloaded_files <- c()
  for (i in seq_len(nrow(files_filtered))) {
    file_name <- files_filtered$name[i]
    file_id <- files_filtered$id[i]
    local_path <- file.path(download_dir, file_name)
    
    # Skip if file already exists
    if (file.exists(local_path)) {
      cat("  ✓ El documento ya existe:", file_name, "- ignorado.\n")
      downloaded_files <- c(downloaded_files, local_path)
      next
    }
    
    # Download file
    drive_download(file = file_id, path = local_path, overwrite = FALSE)
    cat("  ✓ Documento descargado:", file_name, "\n")
    downloaded_files <- c(downloaded_files, local_path)
  }
  
  return(downloaded_files)
}

# ==============================================================================
# EXECUTE: Download from All Sources
# ==============================================================================

all_downloaded <- c()

# 1. Movistar
cat("\n--- Facturas de Movistar ---\n")
fact_web <- download_from_drive(
  folder_path = Sys.getenv("DRIVE_HM_WEB"),
  download_dir = download_dir,
  start_date = start_date
)
all_downloaded <- c(all_downloaded, fact_web)

# 2. Gas
cat("\n--- Gases del Caribe ---\n")
fact_gas <- download_from_drive(
  folder_path = Sys.getenv("DRIVE_HM_GAS"),
  download_dir = download_dir,
  start_date = start_date
)
all_downloaded <- c(all_downloaded, fact_gas)

# 3. AAA
cat("\n--- Triple A ---\n")
fact_aaa <- download_from_drive(
  folder_path = Sys.getenv("DRIVE_HM_AAA"),
  download_dir = download_dir,
  start_date = start_date
)
all_downloaded <- c(all_downloaded, fact_aaa)

# 4. EE
cat("\n--- Air-e ---\n")
fact_ee <- download_from_drive(
  folder_path = Sys.getenv("DRIVE_HM_EE"),
  download_dir = download_dir,
  start_date = start_date
)
all_downloaded <- c(all_downloaded, fact_ee)

# ==============================================================================
# SUMMARY
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("RESUMEN DE DESCARGAS:\n")
cat(strrep("=", 70), "\n")
cat("Total de documentos descargados:", length(unique(all_downloaded)), "\n")
cat("Ubicación:", normalizePath(download_dir), "\n")
cat(strrep("=", 70), "\n")
