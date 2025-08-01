[![FIWARE Banner](https://fiware.github.io/tutorials.Getting-Started/img/Fiware.png)](https://www.fiware.org/developers)

[![FIWARE Core Context Management](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/core.svg)](https://github.com/FIWARE/catalogue/blob/master/core/README.md)
[![License: MIT](https://img.shields.io/github/license/fiware/tutorials.Getting-Started.svg)](https://opensource.org/licenses/MIT)
[![Support badge](https://img.shields.io/badge/tag-fiware-orange.svg?logo=stackoverflow)](https://stackoverflow.com/questions/tagged/fiware)

These are an Introductory Tutorials to the FIWARE NGSI interfaces. We will start with the data from a supermarket chain’s store
finder/Smart Farm and create a very simple _“Powered by FIWARE”_ application by passing in the address and location of each store
as context data to the FIWARE context broker.

The tutorial uses [cUrl](https://ec.haxx.se/) commands throughout, but is also available as
[Postman documentation](https://www.postman.com/downloads/).

# Start-Up

## NGSI-v2 Smart Supermarket

**NGSI-v2** offers JSON based interoperability used in individual Smart Systems. To run this tutorial with **NGSI-v2**, use the `NGSI-v2` branch.

```console
git clone https://github.com/FIWARE/tutorials.Getting-Started.git
cd tutorials.Getting-Started
git checkout NGSI-v2

./services create
./services start
```

| [![NGSI v2](https://img.shields.io/badge/NGSI-v2-5dc0cf.svg)](https://fiware-ges.github.io/orion/api/v2/stable/)<br>   | :books: [Documentation](https://github.com/FIWARE/tutorials.Getting-Started/tree/NGSI-v2) | <img src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/postman.svg" height="15" width="15"> [Postman Collection](https://fiware.github.io/tutorials.Getting-Started/) | ![](https://img.shields.io/github/last-commit/fiware/tutorials.Getting-Started/NGSI-v2)
| --- | --- | --- | --- |

## NGSI-LD Smart Farm

**NGSI-LD** offers JSON-LD based interoperability used for Federations and Data Spaces. To run this tutorial with **NGSI-LD**, use the `NGSI-LD` branch.

```console
git clone https://github.com/FIWARE/tutorials.Getting-Started.git
cd tutorials.Getting-Started
git checkout NGSI-LD

./services create
./services start
```

| [![NGSI LD](https://img.shields.io/badge/NGSI-LD-d6604d.svg)](https://cim.etsi.org/NGSI-LD/official/0--1.html) | :books: [Documentation](https://github.com/FIWARE/tutorials.Getting-Started/tree/NGSI-LD) | <img  src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/postman.svg" height="15" width="15"> [Postman Collection](https://fiware.github.io/tutorials.Getting-Started/ngsi-ld.html) | ![](https://img.shields.io/github/last-commit/fiware/tutorials.Getting-Started/NGSI-LD) |
| --- | --- | --- | --- |

---

## License

[MIT](LICENSE) © 2018-2024 FIWARE Foundation e.V.
