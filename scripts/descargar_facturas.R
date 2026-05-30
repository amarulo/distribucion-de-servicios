# ==============================================================================
# descargar_facturas.R
# Propósito: Descargar las diferentes facturas de servicios de Google Drive
# Author: Dist_SS
# Date: 2026-05-07
# ==============================================================================
# SETUP: Authentication & Configuration
# ==============================================================================

if (!googledrive::drive_has_token()) {
  googledrive::drive_auth(
    path = here::here(Sys.getenv("SECRETO_HM"), Sys.getenv("SHA256_HMT"))
  )
}

source(here::here("scripts", "download_from_drive.R"))

# ==============================================================================
# FUNCIÓN: descargar_facturas.R
# ==============================================================================

descargar_facturas <- function(fecha_ini){
  # Defina la carpeta de destino para descargar las facturas
  download_dir <- here::here("input", "facturas_temp")
  if (!dir.exists(download_dir)) {
    dir.create(download_dir, recursive = TRUE)
    cat("Carpeta creada:", download_dir, "\n")
  }

  current_date <- Sys.Date()
  cat("Modo: DESCARGA MENSUAL (", format(fecha_ini, "%B %Y"), ")\n")
  cat("Rango de fechas: desde ", format(fecha_ini, "%Y-%m-%d"), " hasta ", 
    format(current_date, "%Y-%m-%d"), "\n\n")

  # ==============================================================================
  # EXECUTE: Download from All Sources
  # ==============================================================================

  all_downloaded <- c()

  # 1. Movistar
  cat("\n--- Facturas de Movistar ---\n")
  fact_web <- download_from_drive(
    folder_path = Sys.getenv("DRIVE_HM_WEB"),
    download_dir = download_dir,
    fecha_ini = fecha_ini
  )
  all_downloaded <- c(all_downloaded, fact_web)

  # 2. Gas
  cat("\n--- Gases del Caribe ---\n")
  fact_gas <- download_from_drive(
    folder_path = Sys.getenv("DRIVE_HM_GAS"),
    download_dir = download_dir,
    fecha_ini = fecha_ini
  )
  all_downloaded <- c(all_downloaded, fact_gas)

  # 3. AAA
  cat("\n--- Triple A ---\n")
  fact_aaa <- download_from_drive(
    folder_path = Sys.getenv("DRIVE_HM_AAA"),
    download_dir = download_dir,
    fecha_ini = fecha_ini
  )
  all_downloaded <- c(all_downloaded, fact_aaa)

  # 4. EE
  cat("\n--- Air-e ---\n")
  fact_ee <- download_from_drive(
    folder_path = Sys.getenv("DRIVE_HM_EE"),
    download_dir = download_dir,
    fecha_ini = fecha_ini
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
  invisible(NULL)
}