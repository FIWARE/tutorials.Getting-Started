[![FIWARE Banner](https://fiware.github.io/tutorials.Getting-Started/img/Fiware.png)](https://www.fiware.org/developers)
[![NGSI v2](https://img.shields.io/badge/NGSI-v2-5dc0cf.svg)](https://fiware-ges.github.io/orion/api/v2/stable/)

[![FIWARE Core Context Management](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/core.svg)](https://github.com/FIWARE/catalogue/blob/master/core/README.md)
[![License: MIT](https://img.shields.io/github/license/fiware/tutorials.Getting-Started.svg)](https://opensource.org/licenses/MIT)
[![Support badge](https://img.shields.io/badge/tag-fiware-orange.svg?logo=stackoverflow)](https://stackoverflow.com/questions/tagged/fiware)

<br/> [![Documentation](https://img.shields.io/readthedocs/fiware-tutorials.svg)](https://fiware-tutorials.rtfd.io)

Este é um Tutorial Introdutório à Plataforma FIWARE. Começaremos com os dados de uma loja de uma cadeia de supermercados
Localizador e criar um simples _"Powered by FIWARE"_ aplicativo passando no endereço e localização de cada loja como
dados de contexto para o corretor de contexto FIWARE.

O tutorial usa comandos [cUrl](https://ec.haxx.se/), mas também está disponível como
[Postman Documentação](https://fiware.github.io/tutorials.Getting-Started/)

[![executar em Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/d6671a59a7e892629d2b)

## Conteúdos

<details>
<summary><strong>Detalhes</strong></summary>

-   [Arquitetura](#arquitetura)
-   [Pré-requisitos](#pre-requisitos)
    -   [Docker](#docker)
    -   [Docker Compose (Opcional)](#docker-compose-opcional)
-   [Iniciando os contentores](#iniciando-os-contentores)
    -   [Opção 1) Usando comandos Docker diretamente](#opcao-1-usando-comandos-docker-diretamente)
    -   [Opção 2) Usando Docker Compose](#opcao-2-usando-docker-compose)
-   [Criando seu primeiro aplicativo "Powered by FIWARE"](#criando-seu-primeiro-aplicativo-powered-by-fiware)
    -   [Verificar a saúde do serviço](#verificar-a-saude-do-servico)
    -   [Criando Dados de Contexto](#criando-dados-de-contexto)
        -   [Diretrizes do modelo de dados](#diretrizes-do-modelo-de-dados)
    -   [Consulta de dados de contexto](#consulta-de-dados-de-contexto)
        -   [Obter dados de entidade por ID](#obter-dados-de-entidade-por-id)
        -   [Obter dados de entidade por tipo](#obter-dados-de-entidade-por-tipo)
        -   [Filtrar dados de contexto comparando os valores de um atributo](#filtrar-dados-de-contexto-comparando-os-valores-de-um-atributo)
        -   [Filtrar dados de contexto comparando os valores de um atributo geo:json](#filtrar-dados-de-contexto-comparando-os-valores-de-um-atributo-geojson)
-   [Próximos passos](#proximos-passos)
    -   [Desenvolvimento Iterativo](#desenvolvimento-iterativo)
    -   [License](#license)

</details>

# Arquitetura

Nosso aplicativo de demonstração só fará uso de um componente FIWARE - o
[Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/). A utilização do Orion Context Broker é
suficiente para que uma aplicação se qualifique como _"Powered by FIWARE"_.

Atualmente, o Orion Context Broker conta com tecnologia open source [MongoDB](https://www.mongodb.com/) para manter
persistência dos dados de contexto que contém. Portanto, a arquitetura consistirá em dois elementos:

-   O [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/) que receberá solicitações usando
    [NGSI-v2](https://fiware.github.io/specifications/OpenAPI/ngsiv2)
-   A base de dados subjacente [MongoDB](https://www.mongodb.com/) :
    -   Usado pelo Orion Context Broker para guardar informações de dados de contexto, tais como entidades de dados,
        subscrições e inscrições

Como todas as interações entre os dois elementos são iniciadas por solicitações HTTP, as entidades podem ser
contêinerizadas e a partir de portas expostas.

![](https://fiware.github.io/tutorials.Getting-Started/img/architecture.png)

# Pré-requisitos

## Docker

Para manter as coisas simples, ambos os componentes serão executados usando [Docker](https://www.docker.com). **Docker**
é um container que permite a diferentes componentes isolados em seus respectivos ambientes.

-   Para instalar o Docker no Windows siga as instruções [aqui](https://docs.docker.com/docker-for-windows/)
-   Para instalar o Docker no Mac, siga as instruções [aqui](https://docs.docker.com/docker-for-mac/)
-   Para instalar o Docker no Linux siga as instruções [aqui](https://docs.docker.com/install/)

## Docker Compose (Opcional)

**O Docker Compose** é uma ferramenta para definir e executar aplicações Docker multi-container. A
[Arquivo YAML](https://raw.githubusercontent.com/Fiware/tutorials.Getting-Started/master/docker-compose.yml) é usado
configurar os serviços necessários para a aplicação. Isso significa que todos os serviços de contêineres podem ser
criados em um único comando. Docker Compose é instalado por padrão como parte do Docker para Windows e Docker para Mac,
porém usuários de Linux terá de seguir as instruções encontradas [aqui](https://docs.docker.com/compose/install/)

Você pode verificar suas versões atuais **Docker** e **Docker Compose** usando os seguintes comandos:

```console
docker-compose -v
docker version
```

Certifique-se de estar usando Docker versão 18.03 ou superior e Docker Compose 1.29 ou superior e atualize se
necessário.

# Iniciando os contentores

## Opção 1) Usando comandos Docker diretamente

Primeiro puxe as imagens Docker necessárias do Docker Hub e crie uma rede para nossos containers se conectarem:

```console
docker pull mongo:4.4
docker pull fiware/orion
docker network create fiware_default
```

Um container Docker rodando um banco de dados [MongoDB](https://www.mongodb.com/) pode ser iniciado e conectado à rede
com o seguinte comando:

```console
docker run -d --name=mongo-db --network=fiware_default \
  --expose=27017 mongo:4.4 --bind_ip_all
```

O Orion Context Broker pode ser iniciado e ligado à rede com o seguinte comando:

```console
docker run -d --name fiware-orion -h orion --network=fiware_default \
  -p 1026:1026  fiware/orion -dbhost mongo-db
```

> **Nota**: Se quiseres limpar e recomeçar, podes fazê-lo com os seguintes comandos
>
> ```
> docker stop fiware-orion
> docker rm fiware-orion
> docker stop mongo-db
> docker rm mongo-db
> docker network rm fiware_default
> ```

## Opção 2) Usando Docker Compose

Todos os serviços podem ser inicializados a partir da linha de comando usando o comando `docker-compose`. Por favor,
clone o repositório e crie as imagens necessárias executando os comandos como mostrado:

```console
git clone https://github.com/FIWARE/tutorials.Getting-Started.git
cd tutorials.Getting-Started
git checkout NGSI-v2

docker-compose -p fiware up -d
```

> **Nota:** Se quiseres limpar e começar de novo, podes fazê-lo com o seguinte comando:
>
> ```
> docker-compose -p fiware down
> ```

# Criando seu primeiro aplicativo "Powered by FIWARE"

## Verificar a saúde do serviço

Você pode verificar se o Orion Context Broker está rodando fazendo uma requisição HTTP para a porta exposta:

#### :one: Pedido:

```console
curl -X GET \
  'http://localhost:1026/version'
```

#### Resposta:

A resposta será semelhante à seguinte:

```json
"orion" : {
  "version" : "3.0.0",
  "uptime" : "0 d, 0 h, 17 m, 19 s",
  "git_hash" : "d6f8f4c6c766a9093527027f0a4b3f906e7f04c4",
  "compile_time" : "Mon Apr 12 14:48:44 UTC 2021",
  "compiled_by" : "root",
  "compiled_in" : "f307ca0746f5",
  "release_date" : "Mon Apr 12 14:48:44 UTC 2021",
  "machine" : "x86_64",
  "doc" : "https://fiware-orion.rtfd.io/en/3.0.0/",
  "libversions": {
     "boost": "1_66",
     "libcurl": "libcurl/7.61.1 OpenSSL/1.1.1g zlib/1.2.11 nghttp2/1.33.0",
     "libmicrohttpd": "0.9.70",
     "openssl": "1.1",
     "rapidjson": "1.1.0",
     "mongoc": "1.17.4",
     "bson": "1.17.4"
  }
}
```

> **Que se eu começar um `Failed para conectar ao porto 1026 do localhost: Conexão recusada` Resposta?**
>
> Se você receber uma resposta "Conexão recusada", o Orion Content Broker não pode ser encontrado onde esperado para
> isso tutorial - você precisará substituir a URL e a porta em cada comando cUrl pelo endereço IP corrigido. Todos os
> cUrl commands tutorial assume que o orion está disponível em `localhost:1026`.
>
> Tente as seguintes soluções:
>
> Para verificar se os contêineres da janela de encaixe estão em execução, tente o seguinte:
>
> ```console
> docker ps
> ```
>
> Devias ver dois contentores a correr. Se o orion não estiver a funcionar, pode reiniciar os contentores conforme
> necessário. Este também exibirá informações sobre a porta aberta.
>
> -   Se você tiver instalado [`docker-machine`](https://docs.docker.com/machine/) e
>     [Virtual Box](https://www.virtualbox.org/), o contentor da janela de encaixe orion pode estar a correr a partir de
>     outro endereço IP. você precisará recuperar o IP do host virtual como mostrado:>
>
> ```console
> curl -X GET \
>  'http://$(docker-machine ip default):1026/version'
> ```
>
> Em alternativa, execute todos os comandos do seu cUrl a partir da rede de contentores:
>
> ```console
> docker run --network fiware_default --rm appropriate/curl -s \
>  -X GET 'http://orion:1026/version'
> ```

## Criando Dados de Contexto

No seu cerne, o FIWARE é um sistema de gestão de informação de contexto, pelo que permite adicionar alguns dados de
contexto ao sistema através de criar duas novas entidades (lojas em **Berlim**). Qualquer entidade deve ter atributos
`id` e `type`, adicionais são opcionais e dependem do sistema que está sendo descrito. Cada atributo adicional também
deve ter um definido `type` e um atributo `value`.

#### :two: Pedido:

```console
curl -iX POST \
  'http://localhost:1026/v2/entities' \
  -H 'Content-Type: application/json' \
  -d '
{
    "id": "urn:ngsi-ld:Store:001",
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
        "value": "Bösebrücke Einkauf"
    }
}'
```

#### :three: Pedido:

Cada entidade subseqüente deve ter um `id` exclusivo para o `type` dado.

```console
curl -iX POST \
  'http://localhost:1026/v2/entities' \
  -H 'Content-Type: application/json' \
  -d '
{
    "type": "Store",
    "id": "urn:ngsi-ld:Store:002",
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

### Diretrizes do modelo de dados

Embora cada entidade de dados dentro do contexto do usuário varie de acordo com o caso de uso, a estrutura comum dentro
de cada A entidade de dados deve ser padronizada para promover a reutilização. As diretrizes completas do modelo de
dados FIWARE podem ser encontradas [aqui](https://smartdatamodels.org/).
Este tutorial demonstra o uso de das seguintes recomendações:

#### Todos os termos são definidos em Inglês Americano

Embora os campos `value` dos dados de contexto possam estar em qualquer idioma, todos os atributos e tipos são escritos
usando o comando Língua inglesa.

#### Os nomes dos tipos de entidades devem começar com uma letra maiúscula

Neste caso só temos um tipo de entidade - **Loja**

#### As identificações de entidades devem ser um URN seguindo as diretrizes NGSI-LD

NGSI-LD é atualmente um
[especificação](https://www.etsi.org/deliver/etsi_gs/CIM/001_099/009/01.04.02_60/gs_cim009v010402p.pdf), porém o é
que cada `id` é um URN segue um formato padrão: turn:ngsi-ld:<entity-type>:<entity-id>`. Isto significará que cada`id`
no sistema será único

#### Os nomes dos tipos de dados devem reutilizar os tipos de dados schema.org sempre que possível

[Schema.org](http://schema.org/) é uma iniciativa para criar esquemas de dados estruturados comuns. A fim de promover a
reutilização, nós usaram deliberadamente o [`Text`](http://schema.org/PostalAddress) e o [Endereço Postal]
(http://schema.org/PostalAddress) digite nomes dentro da nossa entidade **Loja**. Outras normas existentes, tais como as
[Open311](http://www.open311.org/) (para rastreio de questões cívicas) ou [Datex II](https://datex2.eu/) (para
transporte ) também pode ser usado, mas o objetivo é verificar a existência do mesmo atributo em modelos de dados
existentes e reutilizá-lo.

#### Use a sintaxe da caixa de camelo para nomes de atributos

O `streetAddress`, `addressRegion`, `addressLocality` e `postalCode` são todos exemplos de atributos usando camel
invólucro

#### As informações de localização devem ser definidas usando os atributos `endereço` e `localização`.

-   Nós usamos um atributo `address` para localizações cívicas como por [schema.org](http://schema.org/)
-   Nós usamos um atributo `location` para coordenadas geográficas.

#### Use GeoJSON para codificar propriedades geoespaciais

O [GeoJSON](http://geojson.org) é um formato aberto normalizado concebido para representar características geográficas
simples. O O atributo `location` foi codificado como uma localização `Point` do geoJSON.

## Consulta de dados de contexto

Um aplicativo em consumo agora pode requisitar dados de contexto fazendo solicitações HTTP para o Orion Context Broker.
O atual A interface NGSI nos permite fazer consultas complexas e filtrar resultados.

No momento, para a demonstração do localizador de lojas, todos os dados de contexto estão sendo adicionados diretamente
via requisições HTTP, porém em um arquivo solução inteligente mais complexa, o Orion Context Broker também recuperará o
contexto diretamente dos sensores conectados associados a cada entidade.

Aqui estão alguns exemplos, em cada caso o parâmetro de consulta `options=keyValues` foi usado para encurtar as
respostas por despojando os elementos de tipo de cada atributo

### Obter dados de entidade por ID

Este exemplo retorna os dados de `urn:ngsi-ld:Store:001`

#### :four: Pedido:

```console
curl -X GET \
   'http://localhost:1026/v2/entities/urn:ngsi-ld:Store:001?options=keyValues'
```

#### Resposta:

```json
{
    "id": "urn:ngsi-ld:Store:001",
    "type": "Store",
    "address": {
        "streetAddress": "Bornholmer Straße 65",
        "addressRegion": "Berlin",
        "addressLocality": "Prenzlauer Berg",
        "postalCode": "10439"
    },
    "location": {
        "type": "Point",
        "coordinates": [13.3986, 52.5547]
    },
    "name": "Bösebrücke Einkauf"
}
```

### Obter dados de entidade por tipo

Este exemplo retorna os dados de todas as entidades `Store` dentro dos dados de contexto.

#### :five: Pedido:

```console
curl -X GET \
    'http://localhost:1026/v2/entities?type=Store&options=keyValues'
```

#### Resposta:

```json
[
    {
        "id": "urn:ngsi-ld:Store:001",
        "type": "Store",
        "address": {
            "streetAddress": "Bornholmer Straße 65",
            "addressRegion": "Berlin",
            "addressLocality": "Prenzlauer Berg",
            "postalCode": "10439"
        },
        "location": {
            "type": "Point",
            "coordinates": [13.3986, 52.5547]
        },
        "name": "Bose Brucke Einkauf"
    },
    {
        "id": "urn:ngsi-ld:Store:002",
        "type": "Store",
        "address": {
            "streetAddress": "Friedrichstraße 44",
            "addressRegion": "Berlin",
            "addressLocality": "Kreuzberg",
            "postalCode": "10969"
        },
        "location": {
            "type": "Point",
            "coordinates": [13.3903, 52.5075]
        },
        "name": "Checkpoint Markt"
    }
]
```

### Filtrar dados de contexto comparando os valores de um atributo

Este exemplo devolve todas as lojas encontradas no distrito de Kreuzberg

#### :six: Pedido:

```console
curl -X GET \
http://localhost:1026/v2/entities?type=Store&q=address.addressLocality==Kreuzberg&options=keyValues
```

#### Resposta:

```json
[
    {
        "id": "urn:ngsi-ld:Store:002",
        "type": "Store",
        "address": {
            "streetAddress": "Friedrichstraße 44",
            "addressRegion": "Berlin",
            "addressLocality": "Kreuzberg",
            "postalCode": "10969"
        },
        "location": {
            "type": "Point",
            "coordinates": [13.3903, 52.5075]
        },
        "name": "Checkpoint Markt"
    }
]
```

### Filtrar dados de contexto comparando os valores de um atributo geo:json

Este exemplo devolve todas as lojas num raio de 1,5 km do **Portão de Brandemburgo** em **Berlim** (_52.5162N 13.3777W_)

#### :seven: Pedido:

```console
curl -X GET \
  'http://localhost:1026/v2/entities?type=Store&georel=near;maxDistance:1500&geometry=point&coords=52.5162,13.3777'
```

#### Resposta:

```json
[
    {
        "id": "urn:ngsi-ld:Store:002",
        "type": "Store",
        "address": {
            "streetAddress": "Friedrichstraße 44",
            "addressRegion": "Berlin",
            "addressLocality": "Kreuzberg",
            "postalCode": "10969"
        },
        "location": {
            "type": "Point",
            "coordinates": [13.3903, 52.5075]
        },
        "name": "Checkpoint Markt"
    }
]
```

# Próximos passos

Quer aprender como adicionar mais complexidade ao seu aplicativo adicionando recursos avançados? Você pode descobrir
lendo os outros tutoriais desta série:

&nbsp; 101. [Getting Started](https://github.com/FIWARE/tutorials.Getting-Started)<br/> &nbsp; 102.
[Entity Relationships](https://github.com/FIWARE/tutorials.Entity-Relationships)<br/> &nbsp; 103.
[CRUD Operations](https://github.com/FIWARE/tutorials.CRUD-Operations)<br/> &nbsp; 104.
[Context Providers](https://github.com/FIWARE/tutorials.Context-Providers)<br/> &nbsp; 105.
[Altering the Context Programmatically](https://github.com/FIWARE/tutorials.Accessing-Context)<br/> &nbsp; 106.
[Subscribing to Changes in Context](https://github.com/FIWARE/tutorials.Subscriptions)<br/>

&nbsp; 201. [Introduction to IoT Sensors](https://github.com/FIWARE/tutorials.IoT-Sensors/tree/NGSI-v2)<br/> &nbsp; 202.
[Provisioning an IoT Agent](https://github.com/FIWARE/tutorials.IoT-Agent)<br/> &nbsp; 203. [IoT over MQTT](https://github.com/FIWARE/tutorials.IoT-over-MQTT)<br/>
&nbsp; 204. [Using an alternative IoT Agent](https://github.com/FIWARE/tutorials.IoT-Agent-JSON)<br/>
&nbsp; 205. [Creating a Custom IoT Agent](https://github.com/FIWARE/tutorials.Custom-IoT-Agent)<br/>
&nbsp; 250. [Introduction to Fast-RTPS and Micro-RTPS](https://github.com/FIWARE/tutorials.Fast-RTPS-Micro-RTPS)<br/>

&nbsp; 301.
[Persisting Context Data using Apache Flume (MongoDB, MySQL, PostgreSQL)](https://github.com/FIWARE/tutorials.Historic-Context-Flume)<br/>
&nbsp; 302.
[Persisting Context Data using Apache NIFI (MongoDB, MySQL, PostgreSQL)](https://github.com/FIWARE/tutorials.Historic-Context-NIFI)<br/>
&nbsp; 303. [Querying Time Series Data (MongoDB)](https://github.com/FIWARE/tutorials.Short-Term-History)<br/>
&nbsp; 304. [Querying Time Series Data (CrateDB)](https://github.com/FIWARE/tutorials.Time-Series-Data)<br/>
&nbsp; 305.
[Big Data Analysis (Flink)](https://github.com/FIWARE/tutorials.Big-Data-Analysis)<br/>

&nbsp; 401. [Managing Users and Organizations](https://github.com/FIWARE/tutorials.Identity-Management)<br/> &nbsp; 402.
[Roles and Permissions](https://github.com/FIWARE/tutorials.Roles-Permissions)<br/> &nbsp; 403.
[Securing Application Access](https://github.com/FIWARE/tutorials.Securing-Access)<br/> &nbsp; 404.
[Securing Microservices with a PEP Proxy](https://github.com/FIWARE/tutorials.PEP-Proxy)<br/> &nbsp; 405.
[XACML Rules-based Permissions](https://github.com/FIWARE/tutorials.XACML-Access-Rules)<br/> &nbsp; 406.
[Administrating XACML via a PAP](https://github.com/FIWARE/tutorials.Administrating-XACML)<br/>

&nbsp; 501. [Creating Application Mashups](https://github.com/FIWARE/tutorials.Application-Mashup)<br/> &nbsp; 503.
[Introduction to Media Streams](https://github.com/FIWARE/tutorials.Media-Streams)<br/>
&nbsp; 507. [Cloud-Edge Computing](https://github.com/FIWARE/tutorials.Edge-Computing)<br/>

&nbsp; 601. [Introduction to Linked Data](https://github.com/FIWARE/tutorials.Linked-Data)<br/>
&nbsp; 602. [Linked Data Relationships and Data Models](https://github.com/FIWARE/tutorials.Relationships-Linked-Data)<br/>
&nbsp; 603. [Traversing Linked Data Programmatically](https://github.com/FIWARE/tutorials.Accessing-Linked-Data)<br/>
&nbsp; 604. [Linked Data Subscriptions and Registrations](https://github.com/FIWARE/tutorials.LD-Subscriptions-Registrations)<br/>

A documentação completa pode ser encontrada [aqui](https://fiware-tutorials.rtfd.io).

## Desenvolvimento Iterativo

O contexto da demonstração do localizador de lojas é muito simples, poderia ser facilmente expandido para abranger a
totalidade de uma gestão de stocks passando a contagem de estoque atual de cada filial como dados de contexto para o
[Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/).

Até agora, tão simples, mas considere como essa aplicação Smart poderia ser iterada:

-   Dashboards em tempo real podem ser criados para monitorar o estado do estoque em cada loja usando uma visualização
    componente. \[[Wirecloud](https://github.com/FIWARE/catalogue/blob/master/processing/README.md#Wirecloud)\]
-   O layout atual do depósito e da loja pode ser passado para o corretor de contexto para que a localização do o
    estoque pode ser exibido em um mapa
    \[[Wirecloud](https://github.com/FIWARE/catalogue/blob/master/processing/README.md#Wirecloud)\]
-   Os componentes da Administração de usuários
    \[[Wilma](https://github.com/FIWARE/catalogue/blob/master/security/README.md#Wilma),
    [AuthZForce](https://github.com/FIWARE/catalogue/blob/master/security/README.md#Authzforce),
    [Keyrock](https://github.com/FIWARE/catalogue/blob/master/security/README.md#Keyrock)\] podem ser adicionados de
    modo que somente os gerentes de loja podem modificar o preço dos itens
-   Um alerta de limite pode ser aumentado no depósito à medida que as mercadorias são vendidas para garantir que as
    prateleiras não fiquem vazias. \[função de publicação/assinatura do
    [corretor de contexto Orion](https://fiware-orion.readthedocs.io/en/latest/)]\]
-   Cada lista gerada de itens a serem carregados do armazém pode ser calculada para maximizar a eficiência de
    reabastecimento
    \[[Complex Event Processing - CEP](https://github.com/FIWARE/catalogue/blob/master/processing/README.md#new-perseo-incubated)\]
-   Um sensor de movimento poderia ser adicionado na entrada para contar o número de clientes
    \[[IDAS](https://github.com/FIWARE/catalogue/blob/master/iot-agents/README.md)\]
-   O sensor de movimento pode tocar um sino sempre que um cliente entra
    \[[IDAS](https://github.com/FIWARE/catalogue/blob/master/iot-agents/README.md)\]
-   Uma série de câmeras de vídeo poderia ser adicionada para introduzir um feed de vídeo em cada loja
    \[[Kurento](https://github.com/FIWARE/catalogue/blob/master/processing/README.md#Kurento)\]
-   As imagens de vídeo podem ser processadas para reconhecer onde os clientes estão dentro de uma loja
    \[[Kurento](https://github.com/FIWARE/catalogue/blob/master/processing/README.md#Kurento)\]
-   Ao manter e processar dados históricos dentro do sistema, pode-se calcular o número de pessoas e o tempo de
    permanência... estabelecendo quais as áreas da loja que atraem mais interesse \[através de
    [Cygnus](https://github.com/FIWARE/catalogue/blob/master/core/README.md#Cygnus) to Apache Nifi\]
-   Padrões de reconhecimento de comportamento incomum podem ser usados para levantar um alerta para evitar roubo
    \[[Kurento](https://github.com/FIWARE/catalogue/blob/master/processing/README.md#Kurento)\]
-   Os dados sobre a circulação de multidões seriam úteis para a investigação científica - os dados sobre o estado do
    armazém poderiam ser publicado externamente.
    \[[extensões para CKAN](https://github.com/FIWARE/catalogue/tree/master/data-publication#extensions-to-ckan)\]

Cada iteração agrega valor à solução através de componentes existentes com interfaces padrão e, portanto, minimiza tempo
de desenvolvimento.

---

## License

[MIT](LICENSE) © 2018-2021 FIWARE Foundation e.V.
