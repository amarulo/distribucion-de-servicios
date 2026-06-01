# --- Filtro para analizar únicamente facturas que no estén en cons_SS ---

filtre_fact_nuevas <- function(file_paths, existing_df) {
  
  tibble(file_path = file_paths) %>%
    mutate(
      file_name = basename(file_path),
      # Extract YYYY and MM
      year = as.integer(str_extract(file_name, "^\\d{4}")),
      month = as.integer(str_extract(file_name, "(?<=^\\d{4}_)\\d{2}")),
      # Identify the provider code from the filename
      code = str_extract(file_name, "(gas|aaa|NIC)")
    ) %>%
    filter(year >=2026) %>%
    # Map filename codes to actual database 'proveedor' names
    mutate(proveedor_clean = case_when(
      code == "gas" ~ "Gases del Caribe", # Update if different in your DB
      code == "aaa" ~ "Triple A",          # Update if different in your DB
      code == "NIC"  ~ "Air-e",
      TRUE ~ NA_character_)
    ) %>%
    # Filter out files where provider AND month/year match fecha_lim
    anti_join(
      existing_df %>% 
        mutate(
          year = year(fecha_lim), 
          month = month(fecha_lim)
        ),
      by = c("proveedor_clean" = "proveedor", "year", "month")
    ) %>%
    pull(file_path)
}