[![FIWARE Banner](https://fiware.github.io/tutorials.Getting-Started/img/Fiware.png)](https://www.fiware.org/developers)

[![FIWARE Core Context Management](https://img.shields.io/badge/FIWARE-Core-233c68.svg?label=FIWARE&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABsAAAAVCAYAAAC33pUlAAAABHNCSVQICAgIfAhkiAAAA8NJREFUSEuVlUtIFlEUx+eO+j3Uz8wSLLJ3pBiBUljRu1WLCAKXbXpQEUFERSQF0aKVFAUVrSJalNXGgmphFEhQiZEIPQwKLbEUK7VvZrRvbr8zzjfNl4/swplz7rn/8z/33HtmRhn/MWzbXmloHVeG0a+VSmAXorXS+oehVD9+0zDN9mgk8n0sWtYnHo5tT9daH4BsM+THQC8naK02jCZ83/HlKaVSzBey1sm8BP9nnUpdjOfl/Qyzj5ust6cnO5FItJLoJqB6yJ4QuNcjVOohegpihshS4F6S7DTVVlNtFFxzNBa7kcaEwUGcbVnH8xOJD67WG9n1NILuKtOsQG9FngOc+lciic1iQ8uQGhJ1kVAKKXUs60RoQ5km93IfaREvuoFj7PZsy9rGXE9G/NhBsDOJ63Acp1J82eFU7OIVO1OxWGwpSU5hb0GqfMydMHYSdiMVnncNY5Vy3VbwRUEydvEaRxmAOSSqJMlJISTxS9YWTYLcg3B253xsPkc5lXk3XLlwrPLuDPKDqDIutzYaj3eweMkPeCCahO3+fEIF8SfLtg/5oI3Mh0ylKM4YRBaYzuBgPuRnBYD3mmhA1X5Aka8NKl4nNz7BaKTzSgsLCzWbvyo4eK9r15WwLKRAmmCXXDoA1kaG2F4jWFbgkxUnlcrB/xj5iHxFPiBN4JekY4nZ6ccOiQ87hgwhe+TOdogT1nfpgEDTvYAucIwHxBfNyhpGrR+F8x00WD33VCNTOr/Wd+9C51Ben7S0ZJUq3qZJ2OkZz+cL87ZfWuePlwRcHZjeUMxFwTrJZAJfSvyWZc1VgORTY8rBcubetdiOk+CO+jPOcCRTF+oZ0okUIyuQeSNL/lPrulg8flhmJHmE2gBpE9xrJNkwpN4rQIIyujGoELCQz8ggG38iGzjKkXufJ2Klun1iu65bnJub2yut3xbEK3UvsDEInCmvA6YjMeE1bCn8F9JBe1eAnS2JksmkIlEDfi8R46kkEkMWdqOv+AvS9rcp2bvk8OAESvgox7h4aWNMLd32jSMLvuwDAwORSE7Oe3ZRKrFwvYGrPOBJ2nZ20Op/mqKNzgraOTPt6Bnx5citUINIczX/jUw3xGL2+ia8KAvsvp0ePoL5hXkXO5YvQYSFAiqcJX8E/gyX8QUvv8eh9XUq3h7mE9tLJoNKqnhHXmCO+dtJ4ybSkH1jc9XRaHTMz1tATBe2UEkeAdKu/zWIkUbZxD+veLxEQhhUFmbnvOezsJrk+zmqMo6vIL2OXzPvQ8v7dgtpoQnkF/LP8Ruu9zXdJHg4igAAAABJRU5ErkJgggA=)](https://www.fiware.org/developers/catalogue/)
[![License: MIT](https://img.shields.io/github/license/fiware/tutorials.Getting-Started.svg)](https://opensource.org/licenses/MIT)
[![Documentation](https://img.shields.io/readthedocs/fiware-tutorials.svg)](https://fiware-tutorials.rtfd.io)
[![NGSI v2](https://img.shields.io/badge/NGSI-v2-blue.svg)](http://fiware.github.io/context.Orion/api/v2/stable/)

これは、FIWARE Platform のチュートリアルです。スーパーマーケット・チェーンのストア・ファインダのデータから始め、コンテキスト・データとして各ストアの住所と場所を FIWARE context broker に渡して、非常に単純な *"Powered by FIWARE"* アプリケーションを作成します。

このチュートリアルでは、全体で [cUrl](https://ec.haxx.se/) コマンドを使用していますが、[Postman documentation](http://fiware.github.io/tutorials.Getting-Started/) も利用できます。

[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/d6671a59a7e892629d2b)


#  コンテンツ

- [アーキテクチャ](#architecture)
- [前提条件](#prerequisites)
  * [Docker](#docker)
  * [Docker Compose (オプション)](#docker-compose-optional)
- [コンテナの起動](#starting-the-containers)
  * [オプション 1) Docker コマンドを直接使用](#option-1-using-docker-commands-directly)
  * [オプション 2) Docker Compose を使用](#option-2-using-docker-compose)
- [最初の "Powered by FIWARE" アプリを作成](#creating-your-first-powered-by-fiware-app)
  * [サービスの状態を確認](#checking-the-service-health)
  * [コンテキスト・データの作成](#creating-context-data)
    + [データモデルのガイドライン](#data-model-guidelines)
  * [コンテキスト・データのクエリ](#querying-context-data)
    + [idでエンティティ・データを取得](#obtain-entity-data-by-id)
    + [タイプ別にエンティティ・データを取得](#obtain-entity-data-by-type)
    + [属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-an-attribute)
    + [geo:json 属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-a-geojson-attribute)
- [次のステップ](#next-steps)
  * [反復型開発](#iterative-development)

<a name="architecture"></a>
# アーキテクチャ

デモアプリケーションでは、[Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/) という1つの FIWARE コンポーネントしか使用しません。アプリケーションが *"Powered by FIWARE"* と認定するには、Orion Context Broker を使用するだけで十分です。

現在、Orion Context Broker はオープンソースの [MongoDB](https://www.mongodb.com/) 技術を利用して、コンテキスト・データの永続性を維持しています。したがって、アーキテクチャは2つの要素で構成されます :

* [NGSI](https://fiware.github.io/specifications/OpenAPI/ngsiv2) を使用してリクエストを受信する [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/)
* バックエンドの [MongoDB](https://www.mongodb.com/) データベース
  + Orion Context Broker が、データ・エンティティなどのコンテキスト・データ情報、サブスクリプション、登録などを保持するために使用します

2つの要素間のすべての対話は HTTP リクエストによって開始されるため、エンティティはコンテナ化され、公開されたポートから実行されます。

![](https://fiware.github.io/tutorials.Getting-Started/img//architecture.png)

<a name="prerequisites"></a>
# 前提条件

<a name="docker"></a>
## Docker

物事を単純にするために、両方のコンポーネントが [Docker](https://www.docker.com) を使用して実行されます。**Docker** は、さまざまコンポーネントをそれぞれの環境に分離することを可能にするコンテナ・テクノロジです。

* Docker を Windows にインストールするには、[こちら](https://docs.docker.com/docker-for-windows/)の手順に従ってください
* Docker を Mac にインストールするには、[こちら](https://docs.docker.com/docker-for-mac/)の手順に従ってください
* Docker を Linux にインストールするには、[こちら](https://docs.docker.com/install/)の手順に従ってください

<a name="docker-compose-optional"></a>
## Docker Compose (オプション)

**Docker Compose** は、マルチコンテナ Docker アプリケーションを定義して実行するためのツールです。[YAML file](https://raw.githubusercontent.com/Fiware/tutorials.Getting-Started/master/docker-compose.yml) ファイルは、アプリケーションのために必要なサービスを構成するために使用します。つまり、すべてのコンテナ・サービスは1つのコマンドで呼び出すことができます。Docker Compose は、デフォルトで Docker for Windows と Docker for Mac の一部としてインストールされますが、Linux ユーザは[ここ](https://docs.docker.com/compose/install/)に記載されている手順に従う必要があります


次のコマンドを使用して、現在の **Docker** バージョンと **Docker Compose** バージョンを確認できます :

```console
docker-compose -v
docker version
```

Docker バージョン 18.03 以降と Docker Compose 1.21 以上を使用していることを確認し、必要に応じてアップグレードしてください。

<a name="starting-the-containers"></a>
# コンテナの起動

<a name="option-1-using-docker-commands-directly"></a>
## オプション 1) Docker コマンドを直接使用

まず、Docker Hub から必要な Docker イメージを取得し、コンテナが接続するネットワークを作成します :

```console
docker pull mongo:3.6
docker pull fiware/orion
docker network create fiware_default
```

[MongoDB](https://www.mongodb.com/) データベースを実行している Docker コンテナを起動し、ネットワークに接続するには、次のコマンドを実行します :

```console
docker run -d --name=mongo-db --network=fiware_default \
  --expose=27017 mongo:3.6 --bind_ip_all --smallfiles
```

Orion Context Broker は、次のコマンドを使用して起動し、ネットワークに接続できます :

```console
docker run -d --name fiware-orion  --network=fiware_default \
  -p 1026:1026  fiware/orion -dbhost mongo-db
```


>**注** : クリーンアップして再び開始したい場合は、以下のコマンドを使用して行うことができます
>
```console
docker stop fiware-orion
docker rm fiware-orion
docker stop mongo-db
docker rm mongo-db
docker network rm fiware_default
```
>

<a name="option-2-using-docker-compose"></a>
## オプション 2) Docker Compose を使用

すべてのサービスは、 `docker-compose` コマンドを使ってコマンドラインから初期化することができます。リポジトリを複製し、以下のコマンドを実行して必要なイメージを作成してください :


```console
git clone git@github.com:Fiware/tutorials.Getting-Started.git
cd tutorials.Getting-Started

docker-compose -p fiware up -d
```

>**注** : クリーンアップして再起動する場合は、次のコマンドを使用して再起動できます :
>
```bash
docker-compose -p fiware down
```
>

<a name="creating-your-first-powered-by-fiware-app"></a>
# 最初の "Powered by FIWARE" アプリを作成

<a name="checking-the-service-health"></a>
## サービスの状態を確認

公開されたポートに対して HTTP リクエストを行うことで、Orion Context Broker が実行されているかどうかを確認できます :

#### :one: リクエスト :

```console
curl -X GET \
  'http://localhost:1026/version'
```

#### レスポンス :

レスポンスは次のようになります :

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

>**`Failed to connect to localhost port 1026: Connection refused` のレスポンスを受け取った時の対応は?**
>
> `Connection refused` のレスポンスを受け取った場合、Orion Content Broker はこのチュートリアルで期待される場所には見つかりません。各 cUrl コマンドの URL とポートを修正した IP アドレスで置き換える必要があります。すべての cUrl コマンドのチュートリアルでは、`localhost:1026` でorion を使用できると仮定しています。
>
>次の対策を試してください :
>
> * Docker コンテナが動作していることを確認するには、以下を試してください :
>
```console
docker ps
```
>
>実行中の2つのコンテナが表示されます。orion が実行されていない場合は、必要に応じてコンテナを再起動できます。このコマンドは、開いているポート情報も表示します。
>
> * [Virtual Box](https://www.virtualbox.org/) と [`docker-machine`](https://docs.docker.com/machine/) をインストールしている場合は、orion docker コンテナが別の IP アドレスから実行されている可能性があります。次のように仮想ホスト IP を取得する必要があります :
>
>```console
>curl -X GET \
>  'http://$(docker-machine ip default):1026/version'
>```
>
>または、コンテナネットワーク内からすべての cUrl コマンドを実行します :
>
>```console
>docker run --network fiware_default --rm appropriate/curl -s \
>  -X GET http://orion:1026/version
>```

<a name="creating-context-data"></a>
## コンテキスト・データの作成

FIWARE はコンテキスト情報を管理するシステムなので、2つの新しいエンティティ (**Berlin** のストア) を作成することによって、コンテキスト・データをシステムに追加することができます。どんなエンティティも `id` と `type` 属性を持たなければならず、追加の属性はオプションであり、記述されているシステムに依存します。それぞれの追加属性も `type`と `value` 属性を定義しなければなりません。

#### :two: リクエスト :

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

#### :three: リクエスト :

後続の各エンティティには、指定された `type` の一意の `id` が必要です。

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

<a name="data-model-guidelines"></a>
### データモデルのガイドライン

コンテキスト内の各データ・エンティティは、ユースケースによって異なりますが、各データ・エンティティ内の共通構造は、再利用を促進するために標準化された順序にする必要があります。完全な FIWARE データモデルのガイドラインは、[ここ](http://fiware-datamodels.readthedocs.io/en/latest/guidelines/index.html)にあります。このチュートリアルでは、次の推奨事項の使用方法を示します :

#### すべての用語はアメリカ英語で定義されています
コンテキスト・データの `value` フィールドは任意の言語であってもよく、すべての属性およびタイプは英語を使用して書かれています。

#### エンティティ・タイプの名前は大文字で始まる必要があります

この場合、1つエンティティ・タイプしか持っていません - **Store**

#### エンティティ ID は、NGSI-LD のガイドラインに従った URN でなければなりません

NGSI-LD は現時点では[ドラフトの勧告](https://docbox.etsi.org/ISG/CIM/Open/ISG_CIM_NGSI-LD_API_Draft_for_public_review.pdf)ですが、各 `id` は 標準フォーマットに従った URN という提案があります : `urn:ngsi-ld:<entity-type>:<entity-id>`。これは、システム内のすべての `id` がユニークであることを意味します。

#### データ・タイプ名は、可能であれば schema.org データ・タイプを再利用する必要があります

[Schema.org](http://schema.org/) は、共通の構造化データ・スキーマを作成するイニシアチブです。再利用を促進するために、Store エンティティ内 で [`Text`](http://schema.org/PostalAddress) と [`PostalAddress`](http://schema.org/PostalAddress) タイプ名を意図的に使用しています。[Open311](http://www.open311.org/) (市政問題追跡用) や [Datex II](http://www.datex2.eu/) (輸送システム用) などの既存の標準も使用できますが、既存のデータモデルに同じ属性が存在するかどうかを確認して再利用することが重要です。

#### 属性名にはキャメルケースの構文を使用します

`streetAddress`、`addressRegion`、`addressLocality` および `postalCode` 属性のすべての例は、キャメルケースを使用しています。

#### 位置情報は `address` および `location` 属性を使用して定義する必要があります

* [schema.org](http://schema.org/) のように、市政の位置に `address` 属性を使用しています
* 地理座標には `location` 属性を使用しています

####  GeoJSON を使用して地理空間プロパティをコード化

[GeoJSON](http://geojson.org) は、単純な地理的特徴を表現するためのオープンな標準フォーマットです。`location` 属性が GeoJSON `Point` location としてエンコードされています。

<a name="querying-context-data"></a>
## コンテキスト・データのクエリ

コンシューマ向けアプリケーションは、Orion Context Broker への HTTP リクエストを作成することにより、コンテキスト・データをリクエストできるようになりました。既存の NGSI インタフェースにより、複雑なクエリを作成し、結果をフィルタリングすることができます。

現時点では、ストア・ファインダのデモでは、すべてのコンテキスト・データが HTTP リクエストを介して直接追加されていますが、より複雑なスマートなソリューションでは、Orion Context Broker は各エンティティに関連付けられたセンサーからコンテキストを直接取得します。

いくつかの例を示します。それぞれの場合、`options=keyValues` クエリ・パラメータは、各属性からタイプ要素を取り除いてレスポンスを短縮するために使用されています。

<a name="obtain-entity-data-by-id"></a>
### id でエンティティ・データを取得

この例では、 `urn:ngsi-ld:Store:001` のデータを返します

#### :four: リクエスト :

```console
curl -X GET \
   'http://localhost:1026/v2/entities/urn:ngsi-ld:Store:001?options=keyValues'
 ```

#### レスポンス :

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
        "coordinates": [
            13.3986,
            52.5547
        ]
    },
    "name": "Bösebrücke Einkauf"
}
```

<a name="obtain-entity-data-by-type"></a>
### タイプ別にエンティティ・データを取得

この例では、コンテキスト・データ内のすべての `Store` エンティティのデータを返します

#### :five: リクエスト :

```console
curl -X GET \
    'http://localhost:1026/v2/entities?type=Store&options=keyValues'
```

#### レスポンス :

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
            "coordinates": [
                13.3986,
                52.5547
            ]
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
            "coordinates": [
                13.3903,
                52.5075
            ]
        },
        "name": "Checkpoint Markt"
    }
]
```

<a name="filter-context-data-by-comparing-the-values-of-an-attribute"></a>
### 属性の値を比較してコンテキスト・データをフィルタリング

この例では、Kreuzberg 地区にあるすべてのストアを返します

#### :six: リクエスト :

```console
curl -X GET \
http://localhost:1026/v2/entities?type=Store&q=address.addressLocality==Kreuzberg&options=keyValues
```

#### レスポンス :

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
            "coordinates": [
                13.3903,
                52.5075
            ]
        },
        "name": "Checkpoint Markt"
    }
]
```

<a name="filter-context-data-by-comparing-the-values-of-a-geojson-attribute"></a>
### geo:json 属性の値を比較してコンテキスト・データをフィルタリング

この例 では、ベルリンの**ブランデンブルク門**から 1.5km 以内のすべてのストアを返却します (*52.5162N 13.3777W*)

#### :seven: リクエスト :

```console
curl -X GET \
  'http://localhost:1026/v2/entities?type=Store&georel=near;maxDistance:1500&geometry=point&coords=52.5162,13.3777'
```

#### レスポンス :

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
            "coordinates": [
                13.3903,
                52.5075
            ]
        },
        "name": "Checkpoint Markt"
    }
]
```

<a name="next-steps"></a>
# 次のステップ

アドバンス機能を追加するアプリをもっと複雑にする方法を知りたいですか？ このシリーズの他のチュートリアルを読むことで、学ぶことができます。

&nbsp; 101. [Getting Started](https://github.com/Fiware/tutorials.Getting-Started)<br/>
&nbsp; 102. [Entity Relationships](https://github.com/Fiware/tutorials.Entity-Relationships)<br/>
&nbsp; 103. [CRUD Operations](https://github.com/Fiware/tutorials.CRUD-Operations)<br/>
&nbsp; 104. [Context Providers](https://github.com/Fiware/tutorials.Context-Providers)<br/>
&nbsp; 105. [Altering the Context Programmatically](https://github.com/Fiware/tutorials.Accessing-Context)<br/>
&nbsp; 106. [Subscribing to Changes in Context](https://github.com/Fiware/tutorials.Subscriptions)<br/>

&nbsp; 201. [Introduction to IoT Sensors](https://github.com/Fiware/tutorials.IoT-Sensors)<br/>
&nbsp; 202. [Provisioning an IoT Agent](https://github.com/Fiware/tutorials.IoT-Agent)<br/>
&nbsp; 203. [IoT over MQTT](https://github.com/Fiware/tutorials.IoT-over-MQTT)<br/>
&nbsp; 250. [Introduction to Fast-RTPS and Micro-RTPS ](https://github.com/Fiware/tutorials.Fast-RTPS-Micro-RTPS)<br/>

&nbsp; 301. [Persisting Context Data (Mongo-DB, MySQL, PostgreSQL)](https://github.com/Fiware/tutorials.Historic-Context)<br/>
&nbsp; 302. [Querying Time Series Data (Mongo-DB)](https://github.com/Fiware/tutorials.Short-Term-History)<br/>
&nbsp; 303. [Querying Time Series Data (Crate-DB)](https://github.com/Fiware/tutorials.Time-Series-Data)<br/>

&nbsp; 401. [Managing Users and Organizations](https://github.com/Fiware/tutorials.Identity-Management)<br/>
&nbsp; 402. [Roles and Permissions](https://github.com/Fiware/tutorials.Roles-Permissions)<br/>
&nbsp; 403. [Securing Application Access](https://github.com/Fiware/tutorials.Securing-Access)<br/>
&nbsp; 404. [Securing Microservices with a PEP Proxy](https://github.com/Fiware/tutorials.PEP-Proxy)<br/>

&nbsp; 503. [Introduction to Media Streams](https://github.com/Fiware/tutorials.Media-Streams)<br/>

全てのドキュメントは[ここ](https://www.letsfiware.jp/fiware-tutorials)にあります。

<a name="iterative-development"></a>
# 反復型開発
ストア・ファインダ・デモのコンテキストは非常にシンプルです。各ストアの現在の在庫数をコンテキスト・データとして [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/) に渡すことで、在庫管理システム全体を簡単に拡張することができます。

これまでのところ単純ですが、このスマート・アプリケーションをどのように反復できるかを考えてみましょう :

* ビジュアライゼーション・コンポーネントを使用して各ストアの在庫状態を監視するリアルタイム・ダッシュボードを作成することができます。\[[Wirecloud](https://catalogue.fiware.org/enablers/application-mashup-wirecloud)\]
* 倉庫とストアの現在のレイアウトを Context Broker に渡すことができるので、在庫の場所を地図上に表示することができます。\[[Wirecloud](https://catalogue.fiware.org/enablers/application-mashup-wirecloud)\]
* ストア管理者のみがアイテムの価格を変更できるように、ユーザ管理コンポーネント \[[Wilma](https://catalogue.fiware.org/enablers/pep-proxy-wilma), [AuthZForce](https://catalogue.fiware.org/enablers/authorization-pdp-authzforce), [Keyrock](https://catalogue.fiware.org/enablers/identity-management-keyrock)\] を追加することができます
* 棚が空でないことを保証して商品が販売するので、倉庫内で閾値警報を発生させることができます。[publish/subscribe function of [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/)]
* 倉庫から積み込まれるアイテムの生成された各リストは、補充の効率を最大にするために計算することができます。\[[Complex Event Processing -  CEP](https://catalogue.fiware.org/enablers/complex-event-processing-cep-proactive-technology-online)\]
* 入り口にモーション・センサーを追加して顧客数をカウントすることもできます。\[[IDAS](https://catalogue.fiware.org/enablers/backend-device-management-idas)\]
* 顧客がと入店するたびに、モーション・センサーがベルを鳴らすことができます。\[[IDAS](https://catalogue.fiware.org/enablers/backend-device-management-idas)\]
* 各ストアにビデオ・フィードを導入するための一連のビデオカメラを追加することができます。\[[Kurento](https://catalogue.fiware.org/enablers/stream-oriented-kurento)\]
* ビデオ画像を顧客が店内に立っている場所を認識するために処理することができます。\[[Kurento](https://catalogue.fiware.org/enablers/stream-oriented-kurento)\]
* システム内の履歴データを維持し、処理することによって、顧客の足跡と滞留時間を計算することができます。ストアのどの領域が最も関心を集めているかを確認することができます。\[connection through [Cygnus](https://catalogue.fiware.org/enablers/cygnus) to Apache Flink\]
* 異常な行動を認識したパターンは、盗難を避けるために警告を発するのに使用することができます。\[[Kurento](https://catalogue.fiware.org/enablers/stream-oriented-kurento)\]
* 群衆の移動に関するデータは、科学的研究に有用です。ストアの状態に関するデータは、外部に公開することができます。\[[extensions to CKAN](https://catalogue.fiware.org/enablers/fiware-ckan-extensions)\]

各反復は、標準インタフェースを備えた既存のコンポーネントを介してソリューションに付加価値を与え、開発時間を最小限に抑えます。
---

## License

[MIT](LICENSE) © FIWARE Foundation e.V.
