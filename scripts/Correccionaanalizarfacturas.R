# R
# Itera PDFs reales, valida existencia, crea carpeta de salida y convierte la 1ª página
pdfs <- list.files(carpeta_facts, pattern = "\\.pdf$", full.names = TRUE)
dir.create(carpeta_imgs, recursive = TRUE, showWarnings = FALSE)

purrr::walk(pdfs, function(pdf_in) {
  if (!file.exists(pdf_in)) {
    warning("No existe el PDF de entrada: ", pdf_in)
    return(invisible(NULL))
  }
  out_png <- file.path(
    carpeta_imgs,
    paste0(tools::file_path_sans_ext(basename(pdf_in)), "_p1.png")
  )
  pdftools::pdf_convert(pdf = pdf_in, dpi = 300, pages = 1, filenames = out_png)
})