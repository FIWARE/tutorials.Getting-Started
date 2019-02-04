[![FIWARE Banner](https://fiware.github.io/tutorials.Getting-Started/img/Fiware.png)](https://www.fiware.org/developers)

[![FIWARE Core Context Management](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/core.svg)](https://www.fiware.org/developers/catalogue/)
[![License: MIT](https://img.shields.io/github/license/fiware/tutorials.Getting-Started.svg)](https://opensource.org/licenses/MIT)
[![Support badge](https://nexus.lab.fiware.org/repository/raw/public/badges/stackoverflow/fiware.svg)](https://stackoverflow.com/questions/tagged/fiware)
[![NGSI v2](https://img.shields.io/badge/NGSI-v2-blue.svg)](https://fiware-ges.github.io/core.Orion/api/v2/stable/)
<br/>
[![Documentation](https://img.shields.io/readthedocs/fiware-tutorials.svg)](https://fiware-tutorials.rtfd.io)

<!-- prettier-ignore -->
これは、FIWARE Platform のチュートリアルです。スーパーマーケット・チェーンのスト
ア・ファインダのデータから始め、コンテキスト・データとして各ストアの住所と場所を
FIWARE context broker に渡して、非常に単純な _"Powered by FIWARE"_ アプリケーシ
ョンを作成します。

このチュートリアルでは、全体で [cUrl](https://ec.haxx.se/) コマンドを使用してい
ますが
、[Postman documentation](https://fiware.github.io/tutorials.Getting-Started/)
も利用できます。

[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/d6671a59a7e892629d2b)

# コンテンツ

<details>
<summary>詳細 <b>(クリックして拡大)</b></summary>

-   [アーキテクチャ](#architecture)
-   [前提条件](#prerequisites)
    -   [Docker](#docker)
    -   [Docker Compose (オプション)](#docker-compose-optional)
-   [コンテナの起動](#starting-the-containers)
    -   [オプション 1) Docker コマンドを直接使用](#option-1-using-docker-commands-directly)
    -   [オプション 2) Docker Compose を使用](#option-2-using-docker-compose)
-   [最初の "Powered by FIWARE" アプリを作成](#creating-your-first-powered-by-fiware-app)
    -   [サービスの状態を確認](#checking-the-service-health)
    -   [コンテキスト・データの作成](#creating-context-data)
        -   [データモデルのガイドライン](#data-model-guidelines)
    -   [コンテキスト・データのクエリ](#querying-context-data)
        -   [id でエンティティ・データを取得](#obtain-entity-data-by-id)
        -   [タイプ別にエンティティ・データを取得](#obtain-entity-data-by-type)
        -   [属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-an-attribute)
        -   [geo:json 属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-a-geojson-attribute)
-   [次のステップ](#next-steps)
    -   [反復型開発](#iterative-development)

</details>

<a name="architecture"></a>

# アーキテクチャ

デモアプリケーションでは
、[Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/) という
1 つの FIWARE コンポーネントしか使用しません。アプリケーションが _"Powered by
FIWARE"_ と認定するには、Orion Context Broker を使用するだけで十分です。

現在、Orion Context Broker はオープンソースの
[MongoDB](https://www.mongodb.com/) 技術を利用して、コンテキスト・データの永続性
を維持しています。したがって、アーキテクチャは 2 つの要素で構成されます :

-   [NGSI](https://fiware.github.io/specifications/OpenAPI/ngsiv2) を使用してリ
    クエストを受信する
    [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/)
-   バックエンドの [MongoDB](https://www.mongodb.com/) データベース
    -   Orion Context Broker が、データ・エンティティなどのコンテキスト・データ
        情報、サブスクリプション、登録などを保持するために使用します

2 つの要素間のすべての対話は HTTP リクエストによって開始されるため、エンティティ
はコンテナ化され、公開されたポートから実行されます。

![](https://fiware.github.io/tutorials.Getting-Started/img//architecture.png)

<a name="prerequisites"></a>

# 前提条件

<a name="docker"></a>

## Docker

物事を単純にするために、両方のコンポーネントが [Docker](https://www.docker.com)
を使用して実行されます。**Docker** は、さまざまコンポーネントをそれぞれの環境に
分離することを可能にするコンテナ・テクノロジです。

-   Docker を Windows にインストールするには
    、[こちら](https://docs.docker.com/docker-for-windows/)の手順に従ってくださ
    い
-   Docker を Mac にインストールするには
    、[こちら](https://docs.docker.com/docker-for-mac/)の手順に従ってください
-   Docker を Linux にインストールするには
    、[こちら](https://docs.docker.com/install/)の手順に従ってください

<a name="docker-compose-optional"></a>

## Docker Compose (オプション)

**Docker Compose** は、マルチコンテナ Docker アプリケーションを定義して実行する
ためのツールです
。[YAML file](https://raw.githubusercontent.com/Fiware/tutorials.Getting-Started/master/docker-compose.yml)
ファイルは、アプリケーションのために必要なサービスを構成するために使用します。つ
まり、すべてのコンテナ・サービスは 1 つのコマンドで呼び出すことができます
。Docker Compose は、デフォルトで Docker for Windows と Docker for Mac の一部と
してインストールされますが、Linux ユーザ
は[ここ](https://docs.docker.com/compose/install/)に記載されている手順に従う必要
があります

次のコマンドを使用して、現在の **Docker** バージョンと **Docker Compose** バージ
ョンを確認できます :

```console
docker-compose -v
docker version
```

Docker バージョン 18.03 以降と Docker Compose 1.21 以上を使用していることを確認
し、必要に応じてアップグレードしてください。

<a name="starting-the-containers"></a>

# コンテナの起動

<a name="option-1-using-docker-commands-directly"></a>

## オプション 1) Docker コマンドを直接使用

まず、Docker Hub から必要な Docker イメージを取得し、コンテナが接続するネットワ
ークを作成します :

```console
docker pull mongo:3.6
docker pull fiware/orion
docker network create fiware_default
```

[MongoDB](https://www.mongodb.com/) データベースを実行している Docker コンテナを
起動し、ネットワークに接続するには、次のコマンドを実行します :

```console
docker run -d --name=mongo-db --network=fiware_default \
  --expose=27017 mongo:3.6 --bind_ip_all --smallfiles
```

Orion Context Broker は、次のコマンドを使用して起動し、ネットワークに接続できま
す :

```console
docker run -d --name fiware-orion  --network=fiware_default \
  -p 1026:1026  fiware/orion -dbhost mongo-db
```

> **注** : クリーンアップして再び開始したい場合は、以下のコマンドを使用して行う
> ことができます

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

すべてのサービスは、 `docker-compose` コマンドを使ってコマンドラインから初期化す
ることができます。リポジトリを複製し、以下のコマンドを実行して必要なイメージを作
成してください :

```console
git clone git@github.com:Fiware/tutorials.Getting-Started.git
cd tutorials.Getting-Started

docker-compose -p fiware up -d
```

> **注** : クリーンアップして再起動する場合は、次のコマンドを使用して再起動でき
> ます :

```bash
docker-compose -p fiware down
```

>

<a name="creating-your-first-powered-by-fiware-app"></a>

# 最初の "Powered by FIWARE" アプリを作成

<a name="checking-the-service-health"></a>

## サービスの状態を確認

公開されたポートに対して HTTP リクエストを行うことで、Orion Context Broker が実
行されているかどうかを確認できます :

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

> **`Failed to connect to localhost port 1026: Connection refused` のレスポンス
> を受け取った時の対応は?**
>
> `Connection refused` のレスポンスを受け取った場合、Orion Content Broker はこの
> チュートリアルで期待される場所には見つかりません。各 cUrl コマンドの URL とポ
> ートを修正した IP アドレスで置き換える必要があります。すべての cUrl コマンドの
> チュートリアルでは、`localhost:1026` で orion を使用できると仮定しています。
>
> 次の対策を試してください :
>
> -   Docker コンテナが動作していることを確認するには、以下を試してください :

```console
docker ps
```

> 実行中の 2 つのコンテナが表示されます。orion が実行されていない場合は、必要に
> 応じてコンテナを再起動できます。このコマンドは、開いているポート情報も表示しま
> す。
>
> -   [Virtual Box](https://www.virtualbox.org/) と
>     [`docker-machine`](https://docs.docker.com/machine/) をインストールしてい
>     る場合は、orion docker コンテナが別の IP アドレスから実行されている可能性
>     があります。次のように仮想ホスト IP を取得する必要があります :
>
> ```console
> curl -X GET \
>  'http://$(docker-machine ip default):1026/version'
> ```
>
> または、コンテナネットワーク内からすべての cUrl コマンドを実行します :
>
> ```console
> docker run --network fiware_default --rm appropriate/curl -s \
>  -X GET http://orion:1026/version
> ```

<a name="creating-context-data"></a>

## コンテキスト・データの作成

FIWARE はコンテキスト情報を管理するシステムなので、2 つの新しいエンティティ
(**Berlin** のストア) を作成することによって、コンテキスト・データをシステムに追
加することができます。どんなエンティティも `id` と `type` 属性を持たなければなら
ず、追加の属性はオプションであり、記述されているシステムに依存します。それぞれの
追加属性も `type`と `value` 属性を定義しなければなりません。

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

コンテキスト内の各データ・エンティティは、ユースケースによって異なりますが、各デ
ータ・エンティティ内の共通構造は、再利用を促進するために標準化された順序にする必
要があります。完全な FIWARE データモデルのガイドラインは
、[ここ](https://fiware-datamodels.readthedocs.io/en/latest/guidelines/index.html)に
あります。このチュートリアルでは、次の推奨事項の使用方法を示します :

#### すべての用語はアメリカ英語で定義されています

コンテキスト・データの `value` フィールドは任意の言語であってもよく、すべての属
性およびタイプは英語を使用して書かれています。

#### エンティティ・タイプの名前は大文字で始まる必要があります

この場合、1 つエンティティ・タイプしか持っていません - **Store**

#### エンティティ ID は、NGSI-LD のガイドラインに従った URN でなければなりません

NGSI-LD は現時点で
は[ドラフトの勧告](https://www.etsi.org/deliver/etsi_gs/CIM/001_099/009/01.01.01_60/gs_CIM009v010101p.pdf)で
すが、各 `id` は 標準フォーマットに従った URN という提案があります :
`urn:ngsi-ld:<entity-type>:<entity-id>`。これは、システム内のすべての `id` がユ
ニークであることを意味します。

#### データ・タイプ名は、可能であれば schema.org データ・タイプを再利用する必要があります

[Schema.org](http://schema.org/) は、共通の構造化データ・スキーマを作成するイニ
シアチブです。再利用を促進するために、Store エンティティ内 で
[`Text`](http://schema.org/PostalAddress) と
[`PostalAddress`](http://schema.org/PostalAddress) タイプ名を意図的に使用してい
ます。[Open311](http://www.open311.org/) (市政問題追跡用) や
[Datex II](http://www.datex2.eu/) (輸送システム用) などの既存の標準も使用できま
すが、既存のデータモデルに同じ属性が存在するかどうかを確認して再利用することが重
要です。

#### 属性名にはキャメルケースの構文を使用します

`streetAddress`、`addressRegion`、`addressLocality` および `postalCode` 属性のす
べての例は、キャメルケースを使用しています。

#### 位置情報は `address` および `location` 属性を使用して定義する必要があります

-   [schema.org](http://schema.org/) のように、市政の位置に `address` 属性を使用
    しています
-   地理座標には `location` 属性を使用しています

#### GeoJSON を使用して地理空間プロパティをコード化

[GeoJSON](http://geojson.org) は、単純な地理的特徴を表現するためのオープンな標準
フォーマットです。`location` 属性が GeoJSON `Point` location としてエンコードさ
れています。

<a name="querying-context-data"></a>

## コンテキスト・データのクエリ

コンシューマ向けアプリケーションは、Orion Context Broker への HTTP リクエストを
作成することにより、コンテキスト・データをリクエストできるようになりました。既存
の NGSI インタフェースにより、複雑なクエリを作成し、結果をフィルタリングすること
ができます。

現時点では、ストア・ファインダのデモでは、すべてのコンテキスト・データが HTTP リ
クエストを介して直接追加されていますが、より複雑なスマートなソリューションでは
、Orion Context Broker は各エンティティに関連付けられたセンサーからコンテキスト
を直接取得します。

いくつかの例を示します。それぞれの場合、`options=keyValues` クエリ・パラメータは
、各属性からタイプ要素を取り除いてレスポンスを短縮するために使用されています。

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
        "coordinates": [13.3986, 52.5547]
    },
    "name": "Bösebrücke Einkauf"
}
```

<a name="obtain-entity-data-by-type"></a>

### タイプ別にエンティティ・データを取得

この例では、コンテキスト・データ内のすべての `Store` エンティティのデータを返し
ます

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
            "coordinates": [13.3903, 52.5075]
        },
        "name": "Checkpoint Markt"
    }
]
```

<a name="filter-context-data-by-comparing-the-values-of-a-geojson-attribute"></a>

### geo:json 属性の値を比較してコンテキスト・データをフィルタリング

この例 では、ベルリンの**ブランデンブルク門**から 1.5km 以内のすべてのストアを返
却します (_52.5162N 13.3777W_)

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
            "coordinates": [13.3903, 52.5075]
        },
        "name": "Checkpoint Markt"
    }
]
```

<a name="next-steps"></a>

# 次のステップ

アドバンス機能を追加するアプリをもっと複雑にする方法を知りたいですか？ このシリ
ーズの他のチュートリアルを読むことで、学ぶことができます。

&nbsp; 101.
[Getting Started](https://github.com/Fiware/tutorials.Getting-Started)<br/>
&nbsp; 102.
[Entity Relationships](https://github.com/Fiware/tutorials.Entity-Relationships)<br/>
&nbsp; 103.
[CRUD Operations](https://github.com/Fiware/tutorials.CRUD-Operations)<br/>
&nbsp; 104.
[Context Providers](https://github.com/Fiware/tutorials.Context-Providers)<br/>
&nbsp; 105.
[Altering the Context Programmatically](https://github.com/Fiware/tutorials.Accessing-Context)<br/>
&nbsp; 106.
[Subscribing to Changes in Context](https://github.com/Fiware/tutorials.Subscriptions)<br/>

&nbsp; 201.
[Introduction to IoT Sensors](https://github.com/Fiware/tutorials.IoT-Sensors)<br/>
&nbsp; 202.
[Provisioning an IoT Agent](https://github.com/Fiware/tutorials.IoT-Agent)<br/>
&nbsp; 203.
[IoT over MQTT](https://github.com/Fiware/tutorials.IoT-over-MQTT)<br/>
&nbsp; 250.
[Introduction to Fast-RTPS and Micro-RTPS ](https://github.com/Fiware/tutorials.Fast-RTPS-Micro-RTPS)<br/>

&nbsp; 301.
[Persisting Context Data (MongoDB, MySQL, PostgreSQL)](https://github.com/Fiware/tutorials.Historic-Context)<br/>
&nbsp; 302.
[Querying Time Series Data (MongoDB)](https://github.com/Fiware/tutorials.Short-Term-History)<br/>
&nbsp; 303.
[Querying Time Series Data (CrateDB)](https://github.com/Fiware/tutorials.Time-Series-Data)<br/>

&nbsp; 401.
[Managing Users and Organizations](https://github.com/Fiware/tutorials.Identity-Management)<br/>
&nbsp; 402.
[Roles and Permissions](https://github.com/Fiware/tutorials.Roles-Permissions)<br/>
&nbsp; 403.
[Securing Application Access](https://github.com/Fiware/tutorials.Securing-Access)<br/>
&nbsp; 404.
[Securing Microservices with a PEP Proxy](https://github.com/Fiware/tutorials.PEP-Proxy)<br/>
&nbsp; 405. [XACML Rules-based Permissions](https://github.com/Fiware/tutorials.XACML-Access-Rules)<br/>
&nbsp; 406.
[Administrating XACML via a PAP](https://github.com/Fiware/tutorials.Administrating-XACML)<br/>

&nbsp; 503.
[Introduction to Media Streams](https://github.com/Fiware/tutorials.Media-Streams)<br/>

全てのドキュメントは[ここ](https://www.letsfiware.jp/fiware-tutorials)にあります
。

<a name="iterative-development"></a>

# 反復型開発

ストア・ファインダ・デモのコンテキストは非常にシンプルです。各ストアの現在の在庫
数をコンテキスト・データとして
[Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/) に渡すこ
とで、在庫管理システム全体を簡単に拡張することができます。

これまでのところ単純ですが、このスマート・アプリケーションをどのように反復できる
かを考えてみましょう :

-   ビジュアライゼーション・コンポーネントを使用して各ストアの在庫状態を監視する
    リアルタイム・ダッシュボードを作成することができます
    。\[[Wirecloud](https://github.com/Fiware/catalogue/blob/master/processing/README.md#Wirecloud)\]
-   倉庫とストアの現在のレイアウトを Context Broker に渡すことができるので、在庫
    の場所を地図上に表示することができます
    。\[[Wirecloud](https://github.com/Fiware/catalogue/blob/master/processing/README.md#Wirecloud)\]
-   ストア管理者のみがアイテムの価格を変更できるように、ユーザ管理コンポーネント
    \[[Wilma](https://github.com/Fiware/catalogue/blob/master/security/README.md#Wilma),
    [AuthZForce](https://github.com/Fiware/catalogue/blob/master/security/README.md#Authzforce),
    [Keyrock](https://github.com/Fiware/catalogue/blob/master/security/README.md#Keyrock)\]
    を追加することができます
-   棚が空でないことを保証して商品が販売するので、倉庫内で閾値警報を発生させるこ
    とができます。[publish/subscribe function of
    [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/)]
-   倉庫から積み込まれるアイテムの生成された各リストは、補充の効率を最大にするた
    めに計算することができます
    。\[[Complex Event Processing - CEP](https://github.com/Fiware/catalogue/blob/master/security/README.md#new-perseo-incubated)\]
-   入り口にモーション・センサーを追加して顧客数をカウントすることもできます
    。\[[IDAS](https://github.com/Fiware/catalogue/blob/master/iot-agents/README.md)\]
-   顧客がと入店するたびに、モーション・センサーがベルを鳴らすことができます
    。\[[IDAS](https://github.com/Fiware/catalogue/blob/master/iot-agents/README.md)\]
-   各ストアにビデオ・フィードを導入するための一連のビデオカメラを追加することが
    できます
    。\[[Kurento](https://github.com/Fiware/catalogue/blob/master/processing/README.md#Kurento)\]
-   ビデオ画像を顧客が店内に立っている場所を認識するために処理することができます
    。\[[Kurento](https://github.com/Fiware/catalogue/blob/master/processing/README.md#Kurento)\]
-   システム内の履歴データを維持し、処理することによって、顧客の足跡と滞留時間を
    計算することができます。ストアのどの領域が最も関心を集めているかを確認するこ
    とができます。\[connection through
    [Cygnus](https://github.com/Fiware/catalogue/blob/master/core/README.md#Cygnus)
    to Apache Flink\]
-   異常な行動を認識したパターンは、盗難を避けるために警告を発するのに使用するこ
    とができます
    。\[[Kurento](https://github.com/Fiware/catalogue/blob/master/processing/README.md#Kurento)\]
-   群衆の移動に関するデータは、科学的研究に有用です。ストアの状態に関するデータ
    は、外部に公開することができます
    。\[[extensions to CKAN](https://github.com/Fiware/catalogue/tree/master/data-publication#extensions-to-ckan)\]

## 各反復は、標準インタフェースを備えた既存のコンポーネントを介してソリューションに付加価値を与え、開発時間を最小限に抑えます。

## License

[MIT](LICENSE) © 2018-2019 FIWARE Foundation e.V.
