# --- Generar las imágenes de las facturas de energía eléctrica ---

generar_imgs_ee <- function() {

  carpeta_facts <- here::here("input", "facturas_temp")
  carpeta_imgs  <- here::here("input", "facturas_temp", "ee_imgs")

  facturas_ee <- list.files(
  carpeta_facts,
  pattern = "NIC2345873",
  full.names = TRUE
  )
  imagenes_ee <- list.files(
    carpeta_imgs,
    pattern = "NIC2345873",
    full.names = TRUE
  )
  get_key <- function(ee_file) {
    stringr::str_extract(
      basename(ee_file),
      "^\\d{4}_\\d{2}"
    )
  }
  pdf_keys <- get_key(facturas_ee)
  png_keys <- get_key(imagenes_ee)
  pdf_lookup <- setNames(
    facturas_ee,
    pdf_keys
  )
  faltantes <- setdiff(pdf_keys, png_keys)
  if (length(faltantes) == 0) {
    cat("No hay nuevas facturas de energía para generar imagen.\n")
    return(character())
  }
  purrr::walk(
    faltantes,
    \(key) {
      pdf_file <- pdf_lookup[[key]]
      cat("Generando imagen de:", basename(pdf_file), "\n")
      pdf_convert(
        pdf_file,
        dpi = 300,
        pages = 1,
        filenames = file.path(
          carpeta_imgs,
          paste0(
            tools::file_path_sans_ext(basename(pdf_file)),
            "_1.png"
          )
        )
      )
    }
  )
  imagenes_ee <- list.files(
    carpeta_imgs,
    pattern = "NIC2345873",
    full.names = TRUE
  )
  new_imgs_ee <- imagenes_ee[
    get_key(imagenes_ee) %in% faltantes
  ]

  return(new_imgs_ee)
}
  
