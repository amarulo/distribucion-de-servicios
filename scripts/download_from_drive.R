# ==============================================================================
# FUNCIÓN: Descargar facturas de Google Drive
# ==============================================================================

download_from_drive <- function(folder_path, download_dir, fecha_ini) {
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
  filter(modified_date >= fecha_ini)
  
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
