# Estructura para el proyecto:
Data tables
    ↓
R functions/calculations
    ↓
Parameterized Rmd template
    ↓
Monthly HTML reports

Inputs
utility bills,
occupancy,
events/notes.
↓
Calculations
allocations,
weighted shares,
adjustments.
↓
Outputs
monthly reports,
searchable history,
interactive inspection.

Current Architecture:
Data layer
  utilities
  occupancy
  notes/events
↓
Rendering layer
  HTML placeholders
  dynamic insertion
  monthly reports
↓
Historical archive
  generated documents
  source tracking


# Your best path right now: ----
Step 1
  Build a clean single-report workflow.

Step 2
  Publish via GitHub Pages.

Step 3
  Once stable, evolve into:
    multi-page site,
    monthly archives,
    automatic indexes,
    blog-style structure.

At that point, migrating to a Quarto Website project becomes trivial because:
your infrastructure,
rendering,
CSS,
deployment,
GitHub Pages


==============================================================================
# Corte para la automatización de la lectura de las facturas ----
Fecha: 2026-05-15
Inicio la utilización de las funciones para automatizar la lectura de las facturas. Creé la tabla inicial de "Cons_SS" (consumo de servicios), con las facturas que  pude encontrar desde 2025-01-01 hasta la fecha (2026-05-15).

Antes de esta fecha se creaban los documentos ("Dist_SS.nb.html") sobre distribución de servicios ("Dist_SS.Rmd") mes a mes con los datos de las facturas de ese mes solamente. Se conservan los históricos de esos documentos hasta poder rescatar las notas y otros datos desde esos documentos. Para la elaboración de dichos documentos se ingresaban los valores y situaciones cambiantes (número de habitantes, por ejemplo) en el archivo "Casa_SS.R" y se leían como código para actualizar el documento mes a mes. Una vez listo el documento actualizado se actualizaba la publicación en https://rpubs.com/amarulo/1341684 para informar a todos los residentes de la Hacienda.


==============================================================================
# Notas tomadas de Casa_SS.R 
Fecha: 2026-05-15

En este script se encuentran los datos de las facturas que cambian mes a mes.

SIEMPRE RECUERDE:
- SALVAR EL DOCUMENTO HTML en el folder de output/Histórico antes de
  cambiar los datos de este documento: Noviembre 2025 ya está salvado
- Tomar la imagen de la tabla con la distribución a fin de mes con el total 
  de los servicios: La tabla de noviembre 2025 ya está salvada.
- Actualizar la información de los servicio en este archivo:
  "input/Casa_SS.R"
- Una vez actualizado este script, correr TODOS los chunks en el archivo
  "output/Dist_SS.Rmd" para evitar errores.

## Casa: ----
Lista de habitaciones, integrantes y otros datos 
para tener en cuenta para el consumo:

## SS: ----

### Gas ----

### AAA ----

### EE ----
#### Factura EE ----
#### Contadores Internos ----

### Switch Actual ----
Lista con los datos de las facturas de los servicios actualizadas,
Estas se agregan automaticamente al siguiente vector de acuerdo a la fecha
límite de pago de la factura cada mes:
#### Convenciones para los datos que ingresan en este vector: ----
       "Gas" = Gases del Caribe
       "Web" = Movistar
       "AAA" = Triple A
       "CI"  = Consumo registrado por los contadores internos
       "EE"  = Air-e


==============================================================================
# Notas tomadas de Dist_SS.Rmd ----
Fecha: 2026-05-15

## Comentario inicial ----
<!-- 
Preliminares (README): 
Convertí a proyecto este documento el 2025-07-04, en el directorio:
    "C:/Users/Mono/Documents/Hacienda +/Dist_SS/"
En este directorio creé 3 carpetas: input, output y scripts.
Este documento está en la carpeta: "output"
2026-01-15 
  Migré el proyecto a Ubuntu, 
  Estoy utilizando Git para el control de versiones y Positron como IDE.

SIEMPRE RECUERDE:
- SALVAR EL DOCUMENTO HTML en el folder de output/Histórico antes de cambiarlo.
- Tomar la imagen de la tabla con la distribución a fin de mes de todos los servicios.
- Actualizar la info de los servicios en el archivo "input/Casa_SS.R"
- Una vez actualizado ese archivo, correr TODOS los chunks después de este comentario para evitar errores.
-->

NOTA 2026-05-15: Antes de la fecha mencionada en el comentario anterior, solo realizaba un promedio ponderado para la distribución del servicio de energía, utilizaba para dicho fin las hojas de cálculo de Google (Google Sheets) y llevaba registro del consumo en el contador externo para, asi mismo, vigilar el consumo reportado por la empresa de energía. Se realizó el cambio en esa fecha pues entraron en funcionamiento los contadores internos de energía eléctrica.


## Secciones del documento: ----

### Notas Preliminares
### 1. Gases del Caribe
### 2. AAA
#### 2.1. Datos de la factura
#### 2.2. Total pago por habitación
### 3. Air-e
#### 3.1. Datos de la factura:
#### 3.2. Datos para tener en cuenta
##### 3.2.1. Diferencias sobre datos de consumo
##### 3.2.2. Valor de corte
##### 3.2.3. Lectura de contadores internos
##### 3.2.4. Consumo area común
#### 3.3. Total a pagar por habitación
### 4. Movistar
### 5. Total Servicios 
