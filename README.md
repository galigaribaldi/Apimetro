# API Metro DEV

Servicio Web encargado de dar información relevante sobre el Sistema de Transporte de Pasajeros (STP) de la ciudad de México.



## Objetivo

Dicho servicio tiene como propósito principal, ofrecer una información detallada, precisa y comprobable del transporte colectivo en la ciudad de México. Mayormente y haciendo énfasis en 3 transportes:



- **Metro de la Ciudad de México**: Sistema de transporte de tipo masivo; del cual se desprenden las 12 líneas existentes
- **Metrobús de la Ciudad de México**: Sistema de transporte másivo-auxiliar; del cual se desprenden las 7 líneas existentes
- **Cablebús de la Ciudad de México**: Sistema de transporte auxiliar; del cual se desprenden las 2 líneas existentes.



Para cada sistema se concretan dos estructuras (una dependiendo de la otra): líneas y estaciones.



## Metas y Alcance

El presente proyecto surge con la necesidad de crear un motor que alimente la representación gráfica (mapas) de las estructuras de transporte existentes en la Ciudad de México y el área metropolitana (EdoMex).

Otra necesidad (un tanto olvidada) de dichas medios de transporte, es la de salvaguardar un conocimiento histórico/político de la creación, inauguración, geografía e historia de los mismos. Ya que este punto es, a menudo, olvidado.



### Alcances esperados

La implementación de un servicio que brinde soporte, no solo estadístico, si no también geográfico, permitirá a proyectos de terceros poder ubicar de mejor manera la localización, tamaño e historia de cada una de las estaciones.

Ejemplo: ¿Dónde queda la estación 

Actualmente no existe una API oficial de los medios de transporte anteriormente mencionados, por lo que este proyecto no pretende reemplazar la información oficial dada por la [Secretaría de Movilidad y Transporte](https://www.semovi.cdmx.gob.mx). 

Sin embargo (y dado a este aspecto), si se pretende proporcionar una base de datos de acceso libre, gratuito y seguro de las ubicaciones e información relevante conforme al transporte de la Ciudad de México. De esta forma, cualquier persona interesada en obtener información sobre los medios de transporte, podrá hacer uso de esta API.



### Proyectos a Futuro

Aunque la idea principal de dicho repositorio es proporcionar una base de datos de libre acceso sobre los medios de transporte, se tiene el proyecto de trazar nuevas rutas a otros lugares que no se contemplan actualemente; mayormente a las periferias de la Ciudad de México que colindan con el Estado de México. Dicho proyecto no se engloba como *público*, siendo más una teoría personal.

La información puede encontrarse en: https://github.com/galigaribaldi/TrainMap

## *Stack* Tecnológico

Python

Golang

Fly.io

## Información de ejemplo



## Referencias



## Notas
Instalar los siguientes paquetes: psycopg2, psycopg-binary, sudo apt-get install libpq-dev python3-dev