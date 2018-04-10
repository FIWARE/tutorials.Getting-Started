
This is an Introductory Tutorial to the FIWARE Platform

#  Contents

- [Creating your first "Powered by FIWARE" app](#creating-your-first-powered-by-fiware-app)
  * [Architecture](#architecture)
  * [Prerequisites](#prerequisites)
    + [Docker](#docker)
    + [Docker Compose (Optional)](#docker-compose-optional)
    + [Postman (Optional)](#postman-optional)
  * [Starting the containers](#starting-the-containers)
    + [Option 1) Using Docker commands directly](#option-1-using-docker-commands-directly)
    + [Option 2) Using Docker Compose](#option-2-using-docker-compose)
    + [Checking the service health](#checking-the-service-health)
  * [Creating Context Data](#creating-context-data)
  * [Querying Context Data](#querying-context-data)
    + [Obtain entity data by id](#obtain-entity-data-by-id)
    + [Obtain entity data by type](#obtain-entity-data-by-type)
    + [Filter context data by comparing the values of an attribute](#filter-context-data-by-comparing-the-values-of-an-attribute)
    + [Filter context data by comparing the values of a geo:json attribute](#filter-context-data-by-comparing-the-values-of-a-geojson-attribute)
- [Iterative Development](#iterative-development)

# Creating your first "Powered by FIWARE" app

Let’s start with the data from a supermarket chain’s store finder and create a very simple “Powered by FIWARE” application by passing in the address and location of each store as context data to the FIWARE context broker.

## Architecture

Our demo application will only make use of one FIWARE component - the [Orion Context Broker](https://catalogue.fiware.org/enablers/publishsubscribe-context-broker-orion-context-broker) . Usage of the Orion Context Broker is sufficient for an application to qualify as “Powered by FIWARE”.

Currently, the Orion Context Broker  relies on open source [MongoDB](https://www.mongodb.com/) technology to keep persistence of the context data it holds. Therefore, the architecture will consist of two elements:

* The  Orion Context Broker server which will receive requests using NGSI
* The underlying MongoDB database associated to the Orion Context Broker server

Since all interactions between the two elements are initiated by HTTP requests, the entities can be containerized and run from exposed ports. 

## Prerequisites

### Docker

To keep things simple both components will be run using [Docker](https://www.docker.com). **Docker** is a container technology which allows to different components isolated into their respective environments. 

* To install Docker on Windows follow the instructions [here](https://docs.docker.com/docker-for-windows/)
* To install Docker on Mac follow the instructions [here](https://docs.docker.com/docker-for-mac/)
* To install Docker on Linux follow the instructions [here](https://docs.docker.com/install/)

### Docker Compose (Optional)

**Docker Compose** is a tool for defining and running multi-container Docker applications. A [YAML file](https://raw.githubusercontent.com/Fiware/tutorials.Getting-Started/master/docker-compose.yml) is used configure the required
services for the application. This means all container sevices can be brought up in a single commmand. Docker Compose is installed by default as part of Docker for Windows and  Docker for Mac, however Linux users will need to follow the instructions found [here](https://docs.docker.com/compose/install/)

### Postman (Optional)

 **Postman** is a testing framework for REST APIs. The tool can be downloaded from [here](www.getpostman.com). 
 
The text in this tutorial uses `cUrl` commands to interact with the Orion Context Broker server, however a [Postman collection](https://raw.githubusercontent.com/Fiware/tutorials.Getting-Started/master/FIWARE%20Getting%20Started.postman_collection.json)  of commands is also available within this GitHub repository. The entire tutorial is also available directly as [Postman documentation](https://documenter.getpostman.com/view/513743/fiware-getting-started/RVu5kp1c).

## Starting the containers

### Option 1) Using Docker commands directly

First  pull the necessary Docker images from Docker Hub and create a network for our containers to connect to:

```bash 
docker pull mongo:3.6
docker pull fiware/orion
docker network create my-net
```

A Docker container running a MongoDB database can be started and connected to the network with the following command:

```bash
docker run -d --name=context-db --network=my-net \
  --expose=27017 mongo:3.6 --bind_ip_all --smallfiles
``` 

The Orion Context Broker can be started and connected to the network with the following command:

```bash
docker run -d --name orion  --network=my-net \
  -p 1026:1026  fiware/orion -dbhost context-db
``` 

 
>**Note:**  If you want to clean up and start again you can do so with the following commands
>
>```bash
>docker stop orion
>docker rm orion
>docker stop context-db
>docker rm context-db
>docker network rm my-net
>``` 
>

### Option 2) Using Docker Compose

All services can be initialised from the command line using the following command:

```bash
docker-compose up -d
``` 

>**Note:** If you want to clean up and start again you can do so with the following command:
>
>```bash
>docker-compose down
>``` 
>

### Checking the service health
 
You can check if the Orion Context Broker is running by making an HTTP request to the exposed port:

```bash
curl -X GET http://localhost:1026/version
```

The response will look similar to the following:

```json
{
    "orion": {
        "version": "1.12.0-next",
        "uptime": "0 d, 0 h, 3 m, 21 s",
        "git_hash": "e2ff1a8d9515ade24cf8d4b90d27af7a616c7725",
        "compile_time": "Wed Apr 4 19:08:02 UTC 2018",
        "compiled_by": "root",
        "compiled_in": "2f4a69bdc191",
        "release_date": "Wed Apr 4 19:08:02 UTC 2018",
        "doc": "https://fiware-orion.readthedocs.org/en/master/"
    }
}
```


## Creating Context Data

At its heart, FIWARE is a system for managing context information, so lets add some context data into the system by creating two new entities (stores in **Berlin**). Any entity must have a `id` and `type` attributes, additional attributes are optional and will depend on the system being described. Each additional attribute should also have a defined `type` and a `value` attribute.

```bash
curl -X POST \
  http://localhost:1026/v2/entities/ \
  -H 'Content-Type: application/json' \
  -d '
{
    "id": "store1",
    "type": "Store",
   "address": {
        "type": "PostalAddress",
        "value": {
            "streetAddress": "Bornholmer Straße 65",
            "addressRegion": "Berlin",
            "addressLocality": "Prenzlauer Berg",
            "postalCode": "10439"
        }
    },
    "location": {
        "type": "geo:json",
        "value": {
           "type": "Point",
           "coordinates": [13.3986, 52.5547]
        }
    },
    "name": {
        "type": "Text",
        "value": "Bose Brucke Einkauf"
    }
}'
```
 
Each subsequent entity must have a unique `id` for the given `type`

```bash
curl -X POST \
  http://localhost:1026/v2/entities/ \
  -H 'Content-Type: application/json' \
  -d '
{
    "id": "store2",
    "type": "Store",
   "address": {
        "type": "PostalAddress",
        "value": {
            "streetAddress": "Friedrichstraße 44",
            "addressRegion": "Berlin",
            "addressLocality": "Kreuzberg",
            "postalCode": "10969"
        }
    },
    "location": {
        "type": "geo:json",
        "value": {
             "type": "Point",
             "coordinates": [13.3903, 52.5075]
        }
    },
    "name": {
        "type": "Text",
        "value": "Checkpoint Markt"
    }
}'
```
 
 
## Querying Context Data

A consuming application can now request context data by making HTTP requests to the Orion Context Broker. The existing NGSI interface enables us to make complex queries and filter results.

At the moment, for the store finder demo all the context data is being added directly via HTTP requests, however in a more complex smart solution, the Orion Context Broker will also retrieve context directly from attached sensors associated to each entity.

Here are a few examples, in each case the `options=keyValues` query parameter has been used shorten the responses by stripping out the type elements from each attribute

### Obtain entity data by id

This example returns the data of store1 

#### Request:

```bash
curl -X GET \
   http://localhost:1026/v2/entities/store1?options=keyValues
 ```
 
#### Response:

```json 
{
    "id": "store1",
    "type": "Store",
    "address": {
        "streetAddress": "Bornholmer Straße 65",
        "addressRegion": "Berlin",
        "addressLocality": "Prezlauer Berg",
        "postalCode": "10439"
    },
    "location": {
        "type": "Point",
        "coordinates": [
            52.5547,
            13.3986
        ]
    },
    "name": "Bose Brucke Einkauf"
}
```

### Obtain entity data by type

This example returns the data of all `Store` entities within the context data

#### Request:

```bash
curl -X GET \
    http://localhost:1026/v2/entities?type=Store&options=keyValues
```

#### Response:

```json
[
    {
        "id": "store1",
        "type": "Store",
        "address": {
            "streetAddress": "Bornholmer Straße 65",
            "addressRegion": "Berlin",
            "addressLocality": "Prenzlauer Berg",
            "postalCode": "10439"
        },
        "location": {
            "type": "Point",
            "coordinates": [
                13.3986,
                52.5547
            ]
        },
        "name": "Bose Brucke Einkauf"
    },
    {
        "id": "store2",
        "type": "Store",
        "address": {
            "streetAddress": "Friedrichstraße 44",
            "addressRegion": "Berlin",
            "addressLocality": "Kreuzberg",
            "postalCode": "10969"
        },
        "location": {
            "type": "Point",
            "coordinates": [
                13.3903,
                52.5075
            ]
        },
        "name": "Checkpoint Markt"
    }
]
```
 
### Filter context data by comparing the values of an attribute

This example returns all stores found in the Kreuzberg District

#### Request:

```bash
curl -X GET \    
http://localhost:1026/v2/entities?q=address.addressLocality==Kreuzberg&type=Store&options=keyValues 
```

#### Response:

```json 
[
    {
        "id": "store2",
        "type": "Store",
        "address": {
            "streetAddress": "Friedrichstraße 44",
            "addressRegion": "Berlin",
            "addressLocality": "Kreuzberg",
            "postalCode": "10969"
        },
        "location": {
            "type": "Point",
            "coordinates": [
                13.3903,
                52.5075
            ]
        },
        "name": "Checkpoint Markt"
    }
]
```

### Filter context data by comparing the values of a geo:json attribute

This example return all Stores within 1.5km the **Brandenburg Gate**  in **Berlin** (*52.5162N 13.3777W*) 

#### Request:

```bash
curl -X GET \
  http://localhost:1026/v2/entities?type=Store&georel=near;maxDistance:1500&geometry=point&coords=52.5162,13.3777
```
 
#### Response:

```json
[
    {
        "id": "store2",
        "type": "Store",
        "address": {
            "streetAddress": "Friedrichstraße 44",
            "addressRegion": "Berlin",
            "addressLocality": "Kreuzberg",
            "postalCode": "10969"
        },
        "location": {
            "type": "Point",
            "coordinates": [
                13.3903,
                52.5075
            ]
        },
        "name": "Checkpoint Markt"
    }
]
```

Want to learn how you can more complex app adding advance features? Learn how.

# Iterative Development
The context of the store finder demo is very simple, it could easily be expanded to hold the whole of a stock management system by passing in the current stock count of each store as context data to the [Orion Context Broker](https://catalogue.fiware.org/enablers/publishsubscribe-context-broker-orion-context-broker).

So far, so simple, but consider how this Smart application could be iterated:
* Real-time dashboards could be created to monitor the state of the stock across each store using a visualization component. \[[Wirecloud](https://catalogue.fiware.org/enablers/application-mashup-wirecloud)\]
* The current layout of both the warehouse and store could be passed to the context broker so the location of the stock could be displayed on a map \[[Wirecloud](https://catalogue.fiware.org/enablers/application-mashup-wirecloud)\]
* User Management components\[[Wilma](https://catalogue.fiware.org/enablers/pep-proxy-wilma), [AuthZForce](https://catalogue.fiware.org/enablers/authorization-pdp-authzforce), [Keyrock](https://catalogue.fiware.org/enablers/identity-management-keyrock)\] could be added so that only store managers are able to change the price of items
* A threshold alert could be raised in the warehouse as the goods are sold to ensure the shelves are not left empty [publish/subscribe function of [Orion Context Broker](https://catalogue.fiware.org/enablers/publishsubscribe-context-broker-orion-context-broker)]
* Each generated list of items to be loaded from the warehouse could be calculated to maximize the efficiency of replenishment \[[Complex Event Processing -  CEP](https://catalogue.fiware.org/enablers/complex-event-processing-cep-proactive-technology-online)\] 
* A motion sensor could be added at the entrance to count the number of customers \[[IDAS](https://catalogue.fiware.org/enablers/backend-device-management-idas)\]
* The motion sensor could ring a bell whenever a customer enters  \[[IDAS](https://catalogue.fiware.org/enablers/backend-device-management-idas)\]
* A series of video cameras could be added to introduce a video feed in each store \[[Kurento](https://catalogue.fiware.org/enablers/stream-oriented-kurento)\]
* The video images could be processed to recognize where customers are standing within a store \[[Kurento](https://catalogue.fiware.org/enablers/stream-oriented-kurento)\]
 * By maintaining and processing historical data within the system, footfall and dwell time can be calculated - establishing which areas of the store attract the most interest \[connection through [Cygnus](https://catalogue.fiware.org/enablers/cygnus) to Apache Flink\]
* Patterns recognizing unusual behaviour could be used to raise an alert to avoid theft \[[Kurento](https://catalogue.fiware.org/enablers/stream-oriented-kurento)\]
* Data on the movement of crowds would be useful for scientific research - data about the state of the store could be published externally. \[[extensions to CKAN](https://catalogue.fiware.org/enablers/fiware-ckan-extensions)\]

Each iteration adds value to the solution through existing components with standard interfaces and therefore minimizes development time.
