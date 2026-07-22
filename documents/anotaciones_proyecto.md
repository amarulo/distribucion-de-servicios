# Sistema de Distribución de Costos de Servicios Públicos

Un sistema automatizado para analizar las facturas de servicios públicos y distribuir los costos compartidos entre los habitantes de la casa. El proyecto utiliza R y Quarto para generar informes mensuales que se publican en línea.

Características del proyecto:
  - Análisis y procesamiento automatizados de facturas de servicios públicos de múltiples proveedores   
    (electricidad, agua, internet, gas natural)
  - Asignación dinámica de costos basada en métricas de consumo y datos de ocupación
  - Informes reproducibles con control de versiones mediante Git
  - Informes mensuales en HTML para una distribución transparente de costos



==============================================================================
## Estructura de los scripts del proyecto:
actualizar_datos.R
│
├╴cargar_librerias.R:                    carga todas las librerías necesarias para los scripts
│
├╴conectar.R:                            establece las conexiones con las fuentes en la nube
│
├╴bajar_tablas_gsh4.R:                   baja las tablas actualizadas desde google sheets
│
├╴revisa_nueva_factura.R:                parada para revisar la nueva información de facturas recientes
│  │
│  ├╴agregar_facturas.R:                 chequea la tabla existente, revisa si hay nuevas facturas y, si
│  │                                     las hay, agrega la nueva información a la tabla: input/cons_SS.rds
│  │ 
│  ├╴descargar_facturas.R:               descarga las diferentes facturas de servicios desde Google 
│  │  │                                  Drive a una misma carpeta
│  │  └╴download_from_drive.R:           downloads the PDFs from Drive
│  │
│  ├╴parse_aaa.R:                        analiza el formato PDF de las facturas del agua
│  │
│  ├╴generar_imagenes_ee:                genera las  imágenes de las facturas de EE a partir de los PDF's
│  │
│  ├╴parse_ee.R:                         analiza la imagen generada a de las facturas de energía eléctrica
│  │
│  └╴parse_gas.R:                        analiza el formato PDF de las facturas del gas
│
├╴revisa_hist_habs.R:                    filtro de seguridad para comparar la tabla de Googlesheets y la  │                                        tabla de habitantes contenida en este repositorio
│
├╴revisa_nts_evnts.R:                    filtro de seguridad para comparar la tabla de Googlesheets y la  
│                                        tabla de notas preliminares contenida en este repositorio
│
├╴revisa_ajustes.R:                      filtro de seguridad para comparar la tabla de Googlesheets y la
│                                        tabla de ajustes de consumo contenida en este repositorio
│
├╴revisa_cont_int.R:                     filtro de seguridad para comparar la tabla de Googlesheets y la  
│                                        tabla de lecturas de los contadores internos de este repositorio
│
├╴distro_mes_SS.R:                       produce las listas utilizadas en la preparación del informe mensual
│  │
│  ├╴ajustes_aaa.R:                      ajusta el consumo del agua acorde a los ajustes reportados
│  │
│  └╴ajustes_web.R:                      ajusta el consumo del internet acorde a los ajustes reportados
│
└╴generar_reporte_mensual.R:             genera el reporte mensual
   │
   ├╴Dist_SS.qmd:                        estandariza la plantilla para la generación del reporte mensual
   │  │
   │  ├╴cargar_librerias.R:              carga las librerías necesarias para los scripts
   │  │
   │  ├╴cargar_info.R:                   carga la información en una lista para los calculos del consumo
   │  │                                  mensual
   │  └╴distro_mes_SS.R:                 produce las listas ajustadas para el informe mensual
   │
   └╴index.qmd:                          actualiza la página de entrada del proyecto index.html



==============================================================================
## Justificación: 

Vivo en una casa con varias personas a quienes les alquilo habitaciones, y necesito repartir los gastos de los servicios públicos entre todos. La idea es organizar la información de forma que cada uno esté al tanto de su parte de cada servicio y del costo total. Hay cuatro servicios que debemos cubrir: gas natural (que no comparto con los demás inquilinos, ya que mi apartamento tiene su propia instalación de gas y recibo mi propia factura), internet (suministrado por Movistar), agua (suministrada por AAA - Triple A) y electricidad (suministrada por Air-e). Publico los resultados de la división de estos servicios en línea para que los inquilinos puedan consultar la información.

Llevo haciendo esto bastante tiempo, pero ya he cambiado mi método varias veces, porque siempre encuentro una forma mejor, más rápida y sencilla de hacerlo. Ahora mismo, genero un documento Dist_SS.nb.html cada mes en RStudio y luego actualizo el documento publicado a la nueva versión, que sería la distribución de servicios para el mes correspondiente. Lo que he notado en este caso concreto es que, aunque me resulta bastante fácil tener el nuevo documento listo: simplemente cambio los valores en el archivo Casa_SS.R (manualmente), ejecuto el script en Dist_SS.Rmd y hago clic en vista previa, ¡y listo! 

Mi principal preocupación para replantearme este proyecto en este momento (2026-01-15) es que no guardo un registro histórico de los cambios y que alguna información utilizada anteriormente va a ser difícil de reconstruir (en caso necesario y si es del todo posible). Me motiva también ser capaz de construir un sistema automatizado de procesamiento de los datos que haga la labor completa de actualización, verificación y almacenamiento mensual de los datos que permanezca disponible para los habitantes de la casa.

Si es posible, me gustaría que el proyecto residiera en la misma cuenta de Google Drive y poder leerlo a través del IDE. Esto, aunque no he encontrado una forma fiable de actualizar el documento Rpub directamente desde el IDE; normalmente, una vez que tengo el documento listo, abro RStudio y lo actualizo desde allí. Dado que tengo limitaciones de espacio, me gustaría tener una forma muy compacta de almacenar la información que irá creciendo mes a mes. Me gustaría guardar las copias de los recibos, las imágenes con las lecturas de los contadores de electricidad internos, las notas que tomo (estas se pueden guardar en formato R, por ejemplo) y el historial de cuántas personas y quiénes vivieron en la casa (con las fechas de mudanzas: entrada y salida). Además de los registros históricos que proceso para poder crear gráficos que me permitan comprobar tendencias o problemas con los servicios públicos (por ejemplo, un alto caudal de agua debido a un grifo que gotea o algo similar). 
Actualización sobre este último párrafo: Con la implementación del control de versiones el proyecto pasó a residir en Github, ya no en Drive como aparece planteado, y las publicaciones actualizadas en Github Pages (https://amarulo.github.io/distribucion-de-servicios/), ya no en Rpubs (https://rpubs.com/amarulo/1341684), donde todavía se encuentra el último reporte de la versión anterior.


==============================================================================
## Pasos realizados: 

Ya creé una cuenta independiente para guardar todos los registros de este proyecto. Lo ideal sería crear un script para leer la información directamente desde allí, así no tendría que ingresarla manualmente. Una limitación que tengo en esta cuenta es el espacio de almacenamiento. 

Este proyecto lo inicié usando Google Sheets, luego lo migré a RStudio, y actualmente me encuentro usando Posit's IDE. Cada vez que he cambiado de aplicación, también he cambiado la forma de procesar y entregar la información. Los siguientes apuntes son notas tomadas de los estadíos previos en la evolución de este proyecto:

### Corte para la automatización de la lectura de las facturas
Fecha: 2026-05-15
Inicio la utilización de las funciones para automatizar la lectura de las facturas. Creé la tabla inicial de "Cons_SS" (consumo de servicios), con las facturas que  pude encontrar desde 2025-01-01 hasta la fecha (2026-05-15).

Desde mediados de 2025 y antes de esta fecha se creaban los documentos "Año_Mes_Dist_SS.nb.html", basados en el formato de distribución de servicios "Dist_SS.Rmd", mes a mes con los datos de las facturas de ese mes solamente. Se conservan los históricos de esos documentos hasta poder rescatar las notas y otros datos desde esos documentos. Para la elaboración de dichos documentos se ingresaban manualmente los valores y situaciones cambiantes (por ejemplo: número de habitantes, ajustes de consumo, etc.) en el archivo "Casa_SS.R" y se leían como código para actualizar el documento mes a mes. Una vez listo el documento actualizado se actualizaba la publicación en https://rpubs.com/amarulo/1341684 para informar a todos los residentes.


### Notas de documentos anteriores:
En las siguientes copias de las notas de los documentos, usados en versiones anteriores de este proyecto, los indentificadores de títulos originales han sido colocados entre paréntesis, por ejemplo: (##), para indicar la sección en el documento original sin afectar el presente documento. Similarmente, se agregaron espacios extra al inicio y final de un comentario en formato HTML para evitar su comportamiento habitual.

#### Notas tomadas del script Casa_SS.R
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

(##) Casa: 
Lista de habitaciones, integrantes y otros datos 
para tener en cuenta para el consumo:
(##) SS: 
(###) Gas 
(###) AAA 
(###) EE 
(####) Factura EE 
(####) Contadores Internos 
(###) Switch Actual 
Lista con los datos de las facturas de los servicios actualizadas,
Estas se agregan automaticamente al siguiente vector de acuerdo a la fecha
límite de pago de la factura cada mes:
(####) Convenciones para los datos que ingresan en este vector: 
       "Gas" = Gases del Caribe
       "Web" = Movistar
       "AAA" = Triple A
       "CI"  = Consumo registrado por los contadores internos
       "EE"  = Air-e


#### Notas tomadas de Dist_SS.Rmd 
Fecha: 2026-05-15
(##) Comentario inicial 
< ! - - 
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
- - >

NOTA 2026-05-15: Antes de la fecha mencionada en el comentario anterior, solo realizaba un promedio ponderado para la distribución del servicio de energía, utilizaba para dicho fin las hojas de cálculo de Google (Google Sheets) y llevaba registro del consumo del contador externo para, asi mismo, vigilar el consumo reportado por la empresa de energía. Se realizó el cambio en esa fecha pues entraron en funcionamiento los contadores internos de energía eléctrica.

(##) Secciones del documento: 
(###) Notas Preliminares
(###) 1. Gases del Caribe
(###) 2. AAA
(####) 2.1. Datos de la factura
(#### 2.2. Total pago por habitación
(###) 3. Air-e
(####) 3.1. Datos de la factura:
(####) 3.2. Datos para tener en cuenta
(#####) 3.2.1. Diferencias sobre datos de consumo
(#####) 3.2.2. Valor de corte
(#####) 3.2.3. Lectura de contadores internos
(#####) 3.2.4. Consumo area común
(####) 3.3. Total a pagar por habitación
(###) 4. Movistar
(###) 5. Total Servicios 




