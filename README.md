# Tableize

Build and prints tabular data on a terminal screen.

Exposes ```Tableize.print/1``` that takes a list of keyword lists. Output can not be customize for now.

## Usage

```
> data = [
  [city: "Paris", country: "France", planet: "Earth"],
  [city: "San Francisco", country: "United States of America", planet: "Earth"],
  [city: "Arcadia", country: "N/A", planet: "Gallifrey"]
]

> Tableize.print(data)
CITY            COUNTRY                    PLANET   
Paris           France                     Earth    
San Francisco   United States of America   Earth    
Arcadia         N/A                        Gallifrey
:ok
```

The function returns ```:ok``` if the table was properly parsed or ```{:error, "message d'erreur"}```.