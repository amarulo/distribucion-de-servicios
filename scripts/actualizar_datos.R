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
 
# Analizar las facturas y agregar la información requerida a la tabla de SS:
source(here::here("scripts", "analizar_facturas.R"))

# ==============================================================================

# Compara la tabla de habitantes de la casa del repositorio y de Googlesheets
source(here::here("scripts", "revisa_hist_habs.R"))

# ==============================================================================

# Compara la tabla de notas preliminares del repositorio y de Googlesheets
source(here::here("scripts", "revisa_nts_evnts.R"))

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
