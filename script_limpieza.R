######################
## Limpieza de datos 
#####################
#
#Objetivo: tabla por departamento_dia número de casos positivos
#
# Pasos: 
# Levantar la data
#Trabajr las fechas. Todas en el mismo formato
#Cambiar nombres de columnas: minusculas sin espacio, etc
#Limpiar nombres de provincia y distrito. 
#Limpiar otros campos
#Ubicar duplicados
#Merge con Ubigeo
#Calapse table

####################### DATA POSITIVOS POR COVID
# Levantar la data

positivos <- read.csv("data/positivos_covid_0602.csv", header = T, sep = ",")

#Aseguramos la fecha
str(positivos$FECHA_RESULTADO)

positivos$FECHA_RESULTADO <- as.Date(positivos$FECHA_RESULTADO, "%d/%m/%Y")

str(positivos$FECHA_RESULTADO)

#Cambiar el nombre de las variables
names (positivos)[1] = "uuid"
names (positivos)[2] = "region"
names (positivos)[3] = "provincia"
names (positivos)[4] = "distrito"
names (positivos)[5] = "metododx"
names (positivos)[6] = "edad"
names (positivos)[7] = "sexo"
names (positivos)[8] = "fecharesultado"

names (positivos)

#Limpiar nombre de provincia y distrito
#Tenemos problemas con Ñ y tildes

str(positivos$provincia)

table(positivos$provincia)

positivos$provincia<-gsub("Ñ","N",positivos$provincia)
positivos$provincia<-gsub("Ó","O",positivos$provincia)

table(positivos$provincia)

#Limpiar distritos

table(positivos$distrito)
positivos$distrito<-gsub("Ñ","N",positivos$distrito)
positivos$distrito<-gsub("Ó","O",positivos$distrito)
table(positivos$distrito)  

#Creamos variable concatenada para poder unir con la base de datos del INEI
library(tidyr)
positivos <- unite(positivos, nombrecompleto, c(2:4), sep = "-", remove = F)

#Extraer base de datos de ubigeo INEI
library(readr)
ubigeo <- read_csv("~/GitHub/Datos-Abiertos-COVID-19/extras/ubigeos.csv",skip = 0,col_names = TRUE)

#Limpiamos las provincias de ubigeo
str(ubigeo$desc_prov_inei)
table(ubigeo$desc_prov_inei)

ubigeo$desc_prov_inei<-gsub("Ã\u0091","N",ubigeo$desc_prov_inei) #PARA LAS EÑES
ubigeo$desc_prov_inei<-gsub("Ã\u0080","A",ubigeo$desc_prov_inei) #PARA LAS A CON TILDE
ubigeo$desc_prov_inei<-gsub("Ã\u0092","O",ubigeo$desc_prov_inei) #PARA LAS O CON TILDE

table(ubigeo$desc_prov_inei)

#Limpiamos los distritos del ubigeo
str(ubigeo$desc_ubigeo_inei)

ubigeo$desc_ubigeo_inei<-gsub("Ã\u0091","N",ubigeo$desc_ubigeo_inei) #PARA LAS EÑES

table(ubigeo$desc_ubigeo_inei)

# Corregimos los nombres para que coincidan con la bd de positivos

library("forcats") #trabajar variables categoricas
#Provincias
ubigeo$desc_prov_inei <- fct_recode(ubigeo$desc_prov_inei,
                                    "CALLAO" = "PROV. CONST. DEL CALLAO")

ubigeo$desc_prov_inei <- fct_recode(ubigeo$desc_prov_inei,
                                    "ANTONIO RAIMONDI" = "ANTONIO RAYMONDI")

ubigeo$desc_prov_inei <- fct_recode(ubigeo$desc_prov_inei,
                                    "NAZCA" = "NASCA")

#Distritos
ubigeo$desc_ubigeo_inei <- fct_recode(ubigeo$desc_ubigeo_inei,                                  
                                      "ANDRES AVELINO CACERES D." = "ANDRES AVELINO CACERES DORREGARAY")

ubigeo$desc_ubigeo_inei <- fct_recode(ubigeo$desc_ubigeo_inei,                                  
                                      "SAN PEDRO DE PUTINA PUNCU" = "SAN PEDRO DE PUTINA PUNCO")

ubigeo$desc_ubigeo_inei <- fct_recode(ubigeo$desc_ubigeo_inei,                                  
                                      "CORONEL GREGORIO ALBARRACIN L." = "CORONEL GREGORIO ALBARRACIN LANCHIPA")

##El distrito de salcabamba no tiene ubigeo

table(ubigeo$desc_prov_inei)

library(tidyr)
ubigeo_inei <- unite(ubigeo, variables, c(2,4,6), sep = "-")

library(dplyr)
ubigeo_inei2 <- select(ubigeo_inei, variables, cod_ubigeo_inei)


#Unimos información de datos positivos con ubigeo de INEI
positivos1 <- merge(positivos, ubigeo_inei2, by.x = "nombrecompleto", by.y = "variables", all.x = T, all.y = T)

#Exportamos como csv para observar las inconsistencias
write.csv(positivos1,"data\\positivosR.csv", row.names = FALSE)