# ==============================================================================
# actualizar_datos.R
# Propósito: Actualizar las tablas que contienen los datos de los servicios, los
# habitantes de la casa y las notas sobre los eventos que afectan su consumo.
# Author: Dist_SS
# Date: 2026-05-07
# ==============================================================================

# Cargar las librerias requeridas:
source(here::here("scripts", "cargar_librerias.R"))

# ==============================================================================

# Establecer la conexión:
source(here::here("scripts", "conectar.R"))

# ==============================================================================

# Bajar las tablas actualizadas de google sheets:
source(here::here("scripts", "bajar_tablas_gsh4.R"))

# ==============================================================================
 
# Chequear los datos provenientes de nuevas facturas y agregarlos a la tabla de SS
source(here::here("scripts", "revisa_nueva_factura.R"))

# ==============================================================================

# Compara la tabla de habitantes de la casa del repositorio y de Googlesheets
source(here::here("scripts", "revisa_hist_habs.R"))

# ==============================================================================

# Compara la tabla de notas preliminares del repositorio y de Googlesheets
source(here::here("scripts", "revisa_cont_int.R"))

# ==============================================================================

# Compara la tabla de ajustes al consumo del repositorio y de Googlesheets
source(here::here("scripts", "revisa_ajustes.R"))

# ==============================================================================

# Compara la tabla de lecturas de los contadores internos del repositorio y de 
# Googlesheets
source(here::here("scripts", "revisa_nts_evnts.R"))

# ==============================================================================

# Produce las listas utilizadas en la preparación del informe mensual
source(here::here("scripts", "distro_mes_SS.R"))

# ==============================================================================

# Genera el informe mensual
source(here::here("scripts", "generar_reporte_mensual.R"))

# ==============================================================================
