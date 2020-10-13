# qronavirus
## q library for connecting to PHE 'Coronavirus (COVID-19) in the UK' API

This is a kdb+/q library for the COVID-19 API, as published by Public Health England on [Coronavirus (COVID-19) in the UK.](https://coronavirus.data.gov.uk/).

Details of the API can be found [here](https://coronavirus.data.gov.uk/developers-guide).
This library handles necessary requests, pagination, and parsing, meaning that
only "filters" and "structure" need to be provided ("structure" can be derived
from a config file, see below).

**Note**: the library does not contain any error handling or sanity checking
of arguments etc., so is very likely to break given invalid args.

## Usage

Example of usage shown below:

```q
q)\l covid.q
q).phe.cfgreq`areaType`areaName!("nation";"northern ireland")
date       cases cumcases admissions cumadmissions
--------------------------------------------------
2020.10.12 877   21035                            
2020.10.11 1066  20158                            
2020.10.10 902   19092                            
2020.10.09 1080  18190                            
2020.10.08 923   17110    6          1959         
2020.10.07 828   16187    14         1953         
..
```

Here, the function `.phe.cfgreq` is used to perform a request using the config
read from `cfg.csv` (more details below). The dictionary passed should contain
the "filters" to be used as per [API docs](https://coronavirus.data.gov.uk/developers-guide).

Alternatively, the function `.phe.req` can be used passing a dictionary with
both "fiters" and "structure" e.g.

```q
q)s:`date`areaname`areacode`cases`cumcases`deaths`cumdeaths!`date`areaName`areaCode`newCasesByPublishDate`cumCasesByPublishDate`newDeathsByDeathDate`cumDeathsByDeathDate
q).phe.req`filters`structure!(`areaType`areaName!("nation";"northern ireland");s)
date         areaname           areacode    cases cumcases deaths cumdeaths
---------------------------------------------------------------------------
"2020-10-12" "Northern Ireland" "N92000002" 877   21035                    
"2020-10-11" "Northern Ireland" "N92000002" 1066  20158                    
"2020-10-10" "Northern Ireland" "N92000002" 902   19092                    
"2020-10-09" "Northern Ireland" "N92000002" 1080  18190  
```

## Config

For the `.phe.cfgreq` function, config is used. By default, this is read from
`cfg.csv` - if config needs sourced in a different manner, this behaviour
should be edited on line 42 of `covid.q`.

The config is read into the table `.phe.cfg` within the q session.

The config contains the PHE API name for each metric (`phename`), an `enabled`
flag to determine which fields should be requested, a `name` to use locally
(defaults to `phename` if not provided) and a `cast` that will be applied to
data after retrieval (e.g. to cast the string provided for `date` into a date).

The provided `cfg.csv` contains all PHE published fields at time of writing,
along with descriptions (not loaded in q) and a sample set of enabled &
renamed fields.

