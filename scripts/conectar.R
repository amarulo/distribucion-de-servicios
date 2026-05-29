## Establecer conexión con Google Drive: ----
if (!googledrive::drive_has_token()) {
  googledrive::drive_auth()
  cat("Conexión con Google Drive establecida.\n")
}


## Establecer conexión con Google Sheets: ----
if (!googlesheets4::gs4_has_token()) {
  googlesheets4::gs4_auth(
    path = here::here(
      Sys.getenv("SECRETO_HM"),
      Sys.getenv("SHA256_HMT")
    )
  )
  cat("Conexión con Google Sheets establecida.\n")
}