[![FIWARE Banner](https://fiware.github.io/tutorials.Getting-Started/img/fiware.png)](https://www.fiware.org/developers)
[![NGSI LD](https://img.shields.io/badge/NGSI-LD-d6604d.svg)](https://www.etsi.org/deliver/etsi_gs/CIM/001_099/009/01.04.01_60/gs_cim009v010401p.pdf)

[![FIWARE Core Context Management](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/core.svg)](https://github.com/FIWARE/catalogue/blob/master/core/README.md)
[![License: MIT](https://img.shields.io/github/license/FIWARE/tutorials.Getting-Started.svg)](https://opensource.org/licenses/MIT)
[![Support badge](https://img.shields.io/badge/tag-fiware-orange.svg?logo=stackoverflow)](https://stackoverflow.com/questions/tagged/fiware)
[![JSON LD](https://img.shields.io/badge/JSON--LD-1.1-f06f38.svg)](https://w3c.github.io/json-ld-syntax/) <br/>
[![Documentation](https://img.shields.io/readthedocs/ngsi-ld-tutorials.svg)](https://ngsi-ld-tutorials.rtfd.io)

このチュートリアルでは、**NGSI-LD** と **JSON-LD** の `@context` ファイル間の相互作用を調べます。
[以前のチュートリアル](https://github.com/FIWARE/tutorials.Understanding-At-Context)で生成された `@context` ファイルは、
コンテキスト・データを入力するための基になるデータモデルとして使用され、コンテキスト情報がクエリされ、さまざまな形式で
読み取られます。

このチュートリアルでは、全体で[cUrl](https://ec.haxx.se/) コマンドを使用していますが、
[Postman ドキュメント](https://fiware.github.io/tutorials.Getting-Started/ngsi-ld.html)としても利用できます。

[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/610b7cd32e4b07b8e9c9)

## コンテンツ

<details>
<summary><strong>詳細</strong></summary>

-   [`@context` ファイルの操作](#working-with-context-files)
    -   [NGSI-LD ルール](#ngsi-ld-rules)
    -   [コンテント・ネゴシエーションと `Content-Type` と `Accept` ヘッダ](#content-negotiation-and-the-content-type-and-accept-headers)
-   [前提条件](#prerequisites)
    -   [Docker](#docker)
    -   [Cygwin](#cygwin)
-   [アーキテクチャ](#architecture)
-   [起動](#start-up)
-   [NGSI-LD データ・エンティティの作成](#creating-ngsi-ld-data-entities)
    -   [前提条件](#prerequisites-1)
        -   [`@context` ファイルの読み取り](#reading-context-files)
        -   [サービス状態の確認](#checking-the-service-health)
        -   [データ・エンティティの作成](#creating-data-entities)
        -   [core `@context` の使用 - NGSI-LD エンティティの定義](#using-core-context---defining-ngsi-ld-entities)
        -   [NGSI-LD エンティティ定義内でのプロパティのプロパティの定義](#defining-properties-of-properties-within-the-ngsi-ld-entity-definition)
    -   [コンテキスト・データのクエリ](#querying-context-data)
        -   [FQN タイプによるエンティティ・データの取得](#obtain-entity-data-by-fqn-type)
        -   [ID によるエンティティ・データの取得](#obtain-entity-data-by-id)
        -   [タイプ別にエンティティ・データを取得](#obtain-entity-data-by-type)
        -   [属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-an-attribute)
        -   [代替の `@context` の使用](#using-an-alternative-context)
        -   [配列内の属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-an-attribute-in-an-array)
        -   [サブ属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-a-sub-attribute)
        -   [メタデータのクエリによりコンテキスト・データをフィルタリング](#filter-context-data-by-querying-metadata)
        -   [geo:json 属性の値を比較してコンテキスト・データをフィルタリング](#filter-context-data-by-comparing-the-values-of-a-geojson-attribute)

</details>

<a name="working-with-context-files"/>

# `@context` ファイルの操作

> “Some quotations are greatly improved by lack of context.”
>
> ― John Wyndham, The Midwich Cuckoos

[以前のチュートリアル](https://github.com/FIWARE/tutorials.Understanding-At-Context)から、シンプルなスマート農場管理
システムで提供されるコンテキスト・データ・エンティティを定義する2つの `@context` ファイルを生成しました。つまり、
他の外部アプリケーションが Broker 内に保持されているデータをプログラムで理解できるように、すべてのデータ・エンティティと
それらのエンティティ内のすべての属性に対して、合意された一意の ID (URNs または URLs) のセットを定義しました。

たとえば、`address` 属性はスマート・アプリケーション内にあり、次のように定義されています:

```jsonld
"@context": {
    "schema": "https://schema.org/",
    "address": "schema:address"
}
```

つまり、すべての `address` 属性は、`schema.org` で定義されている定義に従います:

`https://schema.org/address` :

![](https://fiware.github.io/tutorials.Getting-Started/img/address.png)

したがって、サードパーティによって作成されたプログラムは、完全な
[schema.org **JSON-LD** schema](https://schema.org/version/latest/schemaorg-current-http.jsonld) を参照することにより、
`address` 属性が `streetAddress` を含むサブ属性を持つ JSON オブジェクトを保持しているという情報を抽出できます。

```jsonld
{
  "@id": "http://schema.org/streetAddress",
  "@type": "rdf:Property",
  "http://schema.org/domainIncludes": {
    "@id": "http://schema.org/PostalAddress"
  },
  "http://schema.org/rangeIncludes": {
    "@id": "http://schema.org/Text"
  },
  "rdfs:comment": "The street address. For example, 1600 Amphitheatre Pkwy.",
  "rdfs:label": "streetAddress"
}
```

これは **JSON-LD** プログラムによる構文であり、コンピュータが意味のあるデータを抽出できるようにします。
属性 `address.streetAddress`は、人間の介入を必要とせずに直接、ストリート (_a street_) です

会社が農業労働者と契約しているケースを想像してみてください。農家は、行われた作業に対して請求される必要があります。
そのようなシステムが JSON-LD で構築されている場合、農家と請負業者が各属性の明確に定義された URNs に同意できる場合、
農家の農場管理情報システムが請求先住所の属性に異なる名前を割り当てても問題ありません。**JSON-LD** は、
一般的な拡張および圧縮アルゴリズムを使用して、2つの形式間で簡単に変換できます。

<a name="ngsi-ld-rules"/>

## NGSI-LD ルール

**NGSI-LD** は、**JSON-LD** の正式に構造化された拡張サブセットです。したがって、**NGSI-LD** は、**JSON-LD**
自体のすべての相互運用性と柔軟性を提供します。また、**NGSI-LD** の操作でオーバーライドできない独自の core `@context`
を定義します。つまり、**NGSI-LD** ユーザは、データを構造化するためのよく定義された共通のルールセットに同意し、これを
**JSON-LD** 仕様の残りの部分で補足します。

Context Broker の **NGSI-LD** インターフェースと直接やり取りしながら、追加の **NGSI-LD** ルールを尊重する必要があります。
ただし、データが抽出された後、この要件を緩め、結果を **JSON-LD** として第三者に渡すことができます。

このチュートリアルは、**NGSI-LD** の背後にあるルールと制限の簡単な紹介であり、いくつかの **NGSI-LD** エンティティを
作成してから、さまざまな形式でデータを抽出します。2つの主要なデータ形式は _normalized_ と _key-value-pairs_ です。
_normalised_ 形式で返されるデータは **NGSI-LD** ルールを尊重し、別の Context Broker または **NGSI-LD** インターフェースを
提供するその他のコンポーネントで直接使用できます。_key-value-pairs_ 形式で返されるデータは、定義により **NGSI-LD**
ではありません。

<a name="content-negotiation-and-the-content-type-and-accept-headers"/>

## コンテント・ネゴシエーションと `Content-Type` と `Accept` ヘッダ

コンテント・ネゴシエーション中、**NGSI-LD** は3つの形式のいずれかでデータを提供します。これらはペイロード本体の構造に
影響します。

-   `Accept: application/json` - レスポンスは **JSON** 形式です
-   `Accept: application/ld+json` - レスポンスは **JSON-LD** 形式です
-   `Accept: application/geo+json` - レスポンスは **GeoJSON** または **GeoJSON-LD** 形式です

**JSON** 形式と **JSON-LD** 形式の主な違いは、**JSON-LD** 形式が選択されている場合、`@context` はレスポンスのボディ内の
追加属性として見つかります。**JSON** のみの形式が使用されている場合、`@context` は追加の `Link` ヘッダ要素として渡され、
レスポンスのボディにはありません。

同様に、**NGSI-LD** データを Context Broker に送信するときに、アプリケーションは追加の `@context` 属性 (この場合は
`Content-Type: application/ld+json`) または、アプリケーションは、追加の `@context` 属性なしで NGSI-LD データを送信できます
(この場合、`Content-Type: application/json` と `Link` ヘッダ も存在する必要があります)。

**GeoJSON** 形式は、既存のデータについて Context Broker にクエリを実行し、GIS システムに適した形式でコンテキストを返す
場合にのみ使用されます。これは、**NGSI-LD** 仕様に最近追加されたものであるため、ここではこれ以上説明しません。

<a name="prerequisites"/>

# 前提条件

<a name="docker"/>

## Docker

シンプルにするために、すべてのコンポーネントは [Docker](https://www.docker.com) を使用して実行されます。 **Docker**
は、それぞれの環境に分離されたさまざまなコンポーネントを可能にするコンテナ・テクノロジです。

-   Windows に Docker をインストールするには、[こちら](https://docs.docker.com/docker-for-windows/)の指示に従ってください
-   Mac に Docker をインストールするには、[こちら](https://docs.docker.com/docker-for-mac/)の指示に従ってください
-   Linux に Docker をインストールするには、[こちら](https://docs.docker.com/install/)の手順に従ってください

**Docker Compose** は、マルチコンテナ Docker アプリケーションを定義して実行するためのツールです。
[YAMLファイル](https://raw.githubusercontent.com/Fiware/tutorials.Getting-Started/master/docker-compose/orion-ld.yml)
を使用して、アプリケーションに必要なサービスを設定します。これは、すべてのコンテナ・サービスを単一のコマンドで起動
できることを意味します。Docker Compose は、Docker for Windows および Docker for Mac の一部としてデフォルトでインストール
されますが、Linux ユーザは[こちら](https://docs.docker.com/compose/install/)にある手順に従う必要があります。

<a name="cygwin"/>

## Cygwin

簡単な bash スクリプトを使ってサービスを開始します。Windows ユーザは、Windows 上の Linux ディストリビューションに
似たコマンドライン機能を提供するために [cygwin](http://www.cygwin.com/) をダウンロードするべきです。

<a name="architecture"/>

# アーキテクチャ

デモ・アプリケーションは、準拠する Context Broker に対してNGSI-LD 呼び出しを送受信します。標準化された NGSI-LD
インターフェイスは複数の Context Broker で利用できるため、1つだけ選択する必要があります。たとえば、
[Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/) を選択するだけです。したがって、
アプリケーションは1つの FIWARE コンポーネントのみを使用します。

現在、Orion Context Broker は、保持しているコンテキスト・データの永続性を保つためにオープンソースの
[MongoDB](https://www.mongodb.com/) テクノロジに依存しています。

データ交換の相互運用性を促進するために、NGSI-LD Context Broker は
[JSON-LD `@context` file](https://json-ld.org/spec/latest/json-ld/#the-context) を明示的に公開して、コンテキスト・
エンティティ内に保持されるデータを定義します。これは、エンティティ・タイプと属性ごとに一意の URI を定義するため、
NGSI ドメイン外の他のサービスは、データ構造の名前を選択できるようになります。すべての `@context` ファイルは
ネットワーク上で利用できる必要があります。私たちの場合、チュートリアル・アプリケーションは一連の静的ファイルをホスト
するために使用されます。

したがって、アーキテクチャは3つの要素から構成されます:

-   [NGSI-LD](https://forge.etsi.org/swagger/ui/?url=https://forge.etsi.org/rep/NGSI-LD/NGSI-LD/raw/master/spec/updated/generated/full_api.json)
    を使ってリクエストを受け取る [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/)
-   基礎となる [MongoDB](https://www.mongodb.com/) データベース :
    -   データ・エンティティ、サブスクリプション、レジストレーションなどのコンテキスト・データ情報を保持するために
        Orion Context Broker によって使用されます
-   **チュートリアル・アプリケーション**は次のことを行います。
    -   システム内のコンテキスト・エンティティを定義する静的な `@context` ファイルを提供します

3つの要素間のすべての対話は HTTP リクエストによって開始されるため、要素をコンテナ化して、公開されたポートから
実行できます。

![](https://fiware.github.io/tutorials.Getting-Started/img/architecture-ld.png)

必要な設定情報は、関連する `orion-ld.yml` ファイルの services セクションで確認できます:

```yaml
orion:
    image: fiware/orion-ld
    hostname: orion
    container_name: fiware-orion
    depends_on:
        - mongo-db
    networks:
        - default
    ports:
        - "1026:1026"
    command: -dbhost mongo-db -logLevel DEBUG
    healthcheck:
        test: curl --fail -s http://orion:1026/version || exit 1
```

```yaml
mongo-db:
    image: mongo:4.2
    hostname: mongo-db
    container_name: db-mongo
    expose:
        - "27017"
    ports:
        - "27017:27017"
    networks:
        - default
```

```yaml
ld-context:
    image: httpd:alpine
    hostname: context
    container_name: fiware-ld-context
    ports:
        - "3004:80"
```

すべてのコンテナは同じネットワーク上にあります - Orion Context Broker はポート `1026` でリッスンし、MongoDB
はデフォルト・ポート `27017` でリッスンしており、チュートリアル・アプリはポート `3000` でリッスンしています。また、
すべてのコンテナは同じポートを外部に公開しています - これは純粋にチュートリアル・アクセス用です - cUrl または Postman
が同じネットワークの一部でなくてもアクセスできるようにします。コマンドラインの初期化は自明です。

<a name="start-up"/>

# 起動

すべてのサービスは、リポジトリ内で提供される
[services](https://github.com/FIWARE/tutorials.Getting-Started/blob/master/services) Bash スクリプトを実行して、
コマンドラインから初期化できます。以下のようにコマンドを実行して、リポジトリのクローンを作成して必要なイメージを
作成してください :

```bash
git clone https://github.com/FIWARE/tutorials.Getting-Started.git
cd tutorials.Getting-Started
git checkout NGSI-LD

./services orion|scorpio
```

> **注 :** クリーンアップして最初からやり直す場合は、次のコマンドで実行できます :
>
> ```
> ./services stop
> ```

---

<a name="creating-ngsi-ld-data-entities"/>

# NGSI-LD データ・エンティティの作成

このチュートリアルでは、農場管理システムで使用するいくつかの初期の農場ビルディング・エンティティを作成します。

<a name="prerequisites-1"/>

## 前提条件

サービスが起動したら、Context Broker 自体と対話する前に、必要な前提条件が整っていることを確認してください。

<a name="reading-context-files"/>

### `@context` ファイルの読み取り

3つの `@context` ファイルが生成され、チュートリアル・アプリケーションでホストされています。
それらは異なる役割を果たします。

-   [`ngsi-context.jsonld`](http://localhost:3000/data-models/ngsi-context.jsonld) - **NGSI-LD** `@context` は、
    データを Context Broker に送信するとき、または _normalized_ 形式でデータを取得するときに、すべての属性を
    定義するのに役立ちます。この `@context` は **NGSI-LD** から **NGSI-LD** へのすべての相互作用に使用する必要があります

-   **JSON-LD** `@context` は、データをクエリして _key-values_ データを返すときに使用できます。レスポンスは
    **JSON** または **JSON-LD** であり、データは受信アプリケーションによって簡単に取り込んでさらに処理できます

    -   [`json-context.jsonld`](http://localhost:3000/data-models/json-context.jsonld) は、データモデルの属性のより豊富な
        **JSON-LD** 定義です
    -   [`alternate-context.jsonld`](http://localhost:3000/data-models/alternate-context.jsonld) は、サードパーティ
        (農場労働者のドイツの下請業者) が使用するデータモデルの属性の代替 **JSON-LD** 定義です。 内部的に、彼らの
        請求アプリケーションは、属性に異なる短い名前を使用していました。 彼らの `@context` ファイルは属性名間の合意された
        マッピングを反映しています

このチュートリアルで使用されている **Building** エンティティの完全なデータモデルの説明は、
[こちら](https://ngsi-ld-tutorials.readthedocs.io/en/latest/datamodels.html#building)にあります。
標準のスマート・データモデル定義に基づいています。同じモデルの
[Swagger 仕様](https://petstore.swagger.io/?url=https://smart-data-models.github.io/dataModel.Building/Building/swagger.yaml)
も利用可能です、そして完全なアプリケーションでコード・スタブを生成するために使用されます。

<a name="checking-the-service-health"/>

### サービス状態の確認

通常どおり、公開されたポートに HTTP リクエストを送信することで、Orion Context Broker が実行されているかどうかを
確認できます:

#### :one: リクエスト:

```console
curl -X GET \
  'http://localhost:1026/version'
```

#### レスポンス:

レスポンスは次のようになります:

```json
{
    "orion": {
        "version": "1.15.0-next",
        "uptime": "0 d, 3 h, 1 m, 51 s",
        "git_hash": "af440c6e316075266094c2a5f3f4e4f8e3bb0668",
        "compile_time": "Tue Jul 16 15:46:18 UTC 2019",
        "compiled_by": "root",
        "compiled_in": "51b4d802385a",
        "release_date": "Tue Jul 16 15:46:18 UTC 2019",
        "doc": "https://fiware-orion.readthedocs.org/en/master/"
    }
}
```

バージョン・レスポンスのフォーマットは変更されていません。以下で定義するリクエストを処理するには、
`release_date` が2019年7月16日以降である必要があります。

<a name="creating-data-entities"/>

### データ・エンティティの作成

`/ngsi-ld/v1/entities` エンドポイントに POST リクエストを行い、構造化された **NGSI-LD** データとともに `@context`
を提供することで、新しいコンテキスト・データ・エンティティを作成できます。

#### :two: リクエスト:

```console
curl -iX POST 'http://localhost:1026/ngsi-ld/v1/entities/' \
-H 'Content-Type: application/ld+json' \
--data-raw '{
    "id": "urn:ngsi-ld:Building:farm001",
    "type": "Building",
    "category": {
        "type": "Property",
        "value": ["farm"]
    },
    "address": {
        "type": "Property",
        "value": {
            "streetAddress": "Großer Stern 1",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "verified": {
            "type": "Property",
            "value": true
        }
    },
    "location": {
        "type": "GeoProperty",
        "value": {
             "type": "Point",
             "coordinates": [13.3505, 52.5144]
        }
    },
    "name": {
        "type": "Property",
        "value": "Victory Farm"
    },
    "@context": "http://context/ngsi-context.jsonld"
}'
```

Context Broker は `@context` で示されているすべてのファイルをナビゲートしてロードする必要があるため、
最初のリクエストにはしばらく時間がかかります。

`Content-Type: application/ld+json` なので、`@context` はリクエストのボディで提供されます。すべての **NGSI-LD**
相互作用と同様に、core **NGSI-LD** `@context`
([`https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.3.jsonld`](https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.3.jsonld))
も暗黙的に含まれています。

つまり、実際の `@context` は次のとおりです:

```jsonld
{
    "@context": [
        "http://context/ngsi-context.jsonld",
        "https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.3.jsonld"
    ]
}
```

Core`@context`が**最後**に処理されるため、以前に同じ `@ id` で定義された用語を上書きします。

#### :three: リクエスト:

後続の各エンティティには、指定された `type` に対して一意の `id` が必要です。

```console
curl -iX POST 'http://localhost:1026/ngsi-ld/v1/entities/' \
-H 'Content-Type: application/json' \
-H 'Link: <http://context/ngsi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
--d '{
    "id": "urn:ngsi-ld:Building:barn002",
    "type": "Building",
    "category": {
        "type": "Property",
        "value": ["barn"]
    },
    "address": {
        "type": "Property",
        "value": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "verified": {
            "type": "Property",
            "value": true
        }
    },
     "location": {
        "type": "GeoProperty",
        "value": {
             "type": "Point",
              "coordinates": [13.3698, 52.5163]
        }
    },
    "name": {
        "type": "Property",
        "value": "Big Red Barn"
    }
}'
```

この2番目のケースでは、`Content-Type: application/json` であるため、`@context` は、ペイロード・ボディではなく、
リクエストの関連する `Link` ヘッダで提供されます。

<a name="using-core-context---defining-ngsi-ld-entities"/>

### core `@context` の使用 - NGSI-LD エンティティの定義

Core `@context` は、**NGSI-LD** データ・エンティティを作成するための語彙を提供します。`id` や `type ` (NGSI v2
を使用したことがある人なら誰でもおなじみのはずです) などの属性は、標準の **JSON-LD** `@id` および `@type`
[keywords](https://w3c.github.io/json-ld-syntax/#syntax-tokens-and-keywords) にマッピングされます。`type`
はインクルードされたデータモデルを参照する必要があります。この場合、`Building` はインクルードされた
URN `https://uri.fiware.org/ns/data-models#Building` の短い名前として使用されています。その後、各プロパティ
(_property_) は、`type` と `value` の2つの属性を含む JSON 要素として定義されます。

プロパティ (_property_) 属性の `type` は次のいずれかでなければなりません:

-   `"GeoProperty"`: ロケーション (locations) の場合は `"http://uri.etsi.org/ngsi-ld/GeoProperty"`。
    ロケーションは、[GeoJSON 形式](https://tools.ietf.org/html/rfc7946) で経度と緯度のペアとして指定する
    必要があります。プライマリ・ロケーション属性の推奨名は `location` です
-   `"Property"`: `"http://uri.etsi.org/ngsi-ld/Property"` -  その他すべて
-   時間ベースの値 (time-based values) の場合、`"Property"` も使用する必要がありますが、プロパティ値は、
    [ISO 8601 形式](https://en.wikipedia.org/wiki/ISO_8601)でエンコードされた日付、時刻、または日時の文字列である
    必要があります - 例: `YYYY-MM-DDThh:mm:ssZ`

> **注:** 簡単にするために、このデータ・エンティティにはリレーションシップ (relationships) が定義されていません。
> リレーションシップには `type=Relationship` を指定する必要があります。リレーションシップについては、
> 後続のチュートリアルで説明します。

<a name="defining-properties-of-properties-within-the-ngsi-ld-entity-definition"/>

### NGSI-LD エンティティ定義内でのプロパティのプロパティの定義

プロパティのプロパティ (_Properties-of-Properties_) は NGSI-LD のメタデータ (つまり、データに関するデータ,
_"data about data"_) に相当します。これは、使用される精度、プロバイダ、単位などの属性値自体のプロパティを
記述するために使用されます。一部の組み込みメタデータ属性がすでに存在し、これらの名前は予約されています。

-   `createdAt` (タイプ: DateTime): ISO 8601 文字列としての属性作成日
-   `modifiedAt` (タイプ: DateTime): ISO 8601 文字列としての属性変更日

さらに、`observedAt`, `datasetId` および `instanceId` はオプションで追加される場合があり、`location`,
`observationSpace` および `operationSpace` はジオ・プロパティ (Geoproperties) に対して特別な意味を持ちます。

上記の例では、メタデータの1つの要素 (つまり、_property-of-a-property_) が `address` 属性内にあります。`verified`
フラグはアドレスが確認されたかどうかを示します。最も一般的な _property-of-a-property_ は、
UN/CEFACT [Common Codes](http://wiki.goodrelations-vocabulary.org/Documentation/UN/CEFACT_Common_Codes)
の測定単位を保持するために使用する必要がある `unitCode`です。

<a name="querying-context-data"/>

## コンテキスト・データのクエリ

アプリケーションは、Orion Context Broker に **NGSI-LD** HTTP リクエストを行うことで、コンテキスト・データを
リクエストできるようになりました。既存の NGSI-LD インターフェースを使用すると、複雑なクエリを実行して結果を
フィルタリングし、FQN または短い名前でデータを取得できます。

<a name="obtain-entity-data-by-fqn-type"/>

### FQN タイプによるエンティティ・データの取得

この例は、コンテキスト・データ内のすべての `Building` エンティティのデータを返します。`type` パラメータは
NGSI-LD に必須であり、レスポンスのフィルタリングに使用されます。Accept HTTP ヘッダは、レスポンス・ボディの
JSON-LD コンテンツを取得するために必要です。

#### :four: リクエスト:

```console
curl -G -X GET \
  'http://localhost:1026/ngsi-ld/v1/entities' \
  -H 'Accept: application/ld+json' \
  -d 'type=https://uri.fiware.org/ns/data-models%23Building'
```

#### レスポンス:

リクエストで明示的な `@context` が送信されなかったため、レスポンスはデフォルト
(`https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.3.jsonld`) で core `@context` を返し、
すべての属性は可能な限り展開されます。

-   `id`, `type`, `location` および `name` は core context で定義され、展開されません
-   `address` は `http://schema.org/address` にマッピングされました
-   `category`は `https://uri.fiware.org/ns/data-models#category` にマッピングされました

エンティティの作成時に属性が FQN に関連付けられていない場合は、短い名前が**常に**表示されます。

```jsonld
[
    {
        "@context": "https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.3.jsonld",
        "id": "urn:ngsi-ld:Building:farm001",
        "type": "https://uri.fiware.org/ns/data-models#Building",
        "https://schema.org/address": {
            "type": "Property",
            "value": {
                "streetAddress": "Großer Stern 1",
                "addressRegion": "Berlin",
                "addressLocality": "Tiergarten",
                "postalCode": "10557"
            },
            "verified": {
                "type": "Property",
                "value": true
            }
        },
        "name": {
            "type": "Property",
            "value": "Victory Farm"
        },
        "https://uri.fiware.org/ns/data-models#category": {
            "type": "Property",
            "value": "farm"
        },
        "location": {
            "type": "GeoProperty",
            "value": {
                "type": "Point",
                "coordinates": [
                    13.3505,
                    52.5144
                ]
            }
        }
    },
    {
        "@context": "https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.3.jsonld",
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "https://uri.fiware.org/ns/data-models#Building",
        "https://schema.org/address": {
            "type": "Property",
            "value": {
                "streetAddress": "Straße des 17. Juni",
                "addressRegion": "Berlin",
                "addressLocality": "Tiergarten",
                "postalCode": "10557"
            },
            "verified": {
                "type": "Property",
                "value": true
            }
        },
        "name": {
            "type": "Property",
            "value": "Big Red Barn"
        },
        "https://uri.fiware.org/ns/data-models#category": {
            "type": "Property",
            "value": "barn"
        },
        "location": {
            "type": "GeoProperty",
            "value": {
                "type": "Point",
                "coordinates": [
                    13.3698,
                    52.5163
                ]
            }
        }
    }
]
```

<a name="obtain-entity-data-by-id"/>

### ID によるエンティティ・データの取得

この例では、`urn:ngsi-ld:Building:farm001` のデータを返します。NGSI-LD `@context` は、返されるエンティティを
定義するために [`Link` ヘッダ](https://www.w3.org/wiki/LinkHeader) として提供されます。`ngsi-context.jsonld`
`@context` ファイルはすべての属性に短い名前を提供しているだけです。

完全な Link ヘッダ構文は次のとおりです:

```text
Link: <https://fiware.github.io/data-models/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json
```

標準の HTTP `Link` ヘッダを使用すると、当のリソースに実際に触れることなくメタデータ (この場合は `@context`)
を渡すことができます。NGSI-LD の場合、メタデータは `application/ld+json` 形式のファイルです。

#### :five: リクエスト:

```console
curl -L -X GET 'http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Building:farm001' \
-H 'Accept: application/ld+json' \
-H 'Link: <http://context/ngsi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"'
```

#### レスポンス:

リクエストで `@context` ファイルが提供されたため、短い名前がレスポンス全体に返されるようになりました。これにより、
ペイロードのサイズが小さくなり、データの操作が容易になります。

Core `@context` が含まれることは常に暗示されることに注意してください。送信された `@context` の配列の要素として、
両方の `@context` ファイルを明示的に含めることもできます。レスポンスは正規化された **NGSI-LD** であり、
したがって有効な **JSON-LD** でもあり、`@context` は受信プログラムで **JSON-LD** 操作に使用できます。

```jsonld
{
    "@context": "http://context/ngsi-context.jsonld",
    "id": "urn:ngsi-ld:Building:farm001",
    "type": "Building",
    "address": {
        "type": "Property",
        "value": {
            "streetAddress": "Großer Stern 1",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "verified": {
            "type": "Property",
            "value": true
        }
    },
    "name": {
        "type": "Property",
        "value": "Victory Farm"
    },
    "category": {
        "type": "Property",
        "value": "farm"
    },
    "location": {
        "type": "GeoProperty",
        "value": {
            "type": "Point",
            "coordinates": [
                13.3505,
                52.5144
            ]
        }
    }
}
```

<a name="obtain-entity-data-by-type"/>

### タイプ別にエンティティ・データを取得

`type` でフィルタリングする場合、[`Link` ヘッダ](https://www.w3.org/wiki/LinkHeader) を指定して、短い形式の
`type="Building"` を FQN `https://uri.fiware.org/ns/data-models/Building` に関連付ける必要があります。

提供されたデータへの参照が提供された場合、短い名前のデータを返し、データの特定の `type` にレスポンスを制限する
ことが可能です。たとえば、以下のリクエストはコンテキスト・データ内のすべての `Building` エンティティのデータを
返します。`type` パラメータを使用すると、レスポンスが `Building` エンティティのみに制限されます。
`options=keyValues` クエリ・パラメータを使用すると、レスポンスが標準の JSON-LD になります。

#### :six: リクエスト:

```console
curl -G -X GET \
    'http://localhost:1026/ngsi-ld/v1/entities' \
-H 'Link: <http://context/ngsi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
    -d 'type=Building' \
    -d 'options=keyValues'
```

#### レスポンス:

`options=keyValues` を使用しているため、レスポンスは JSON のみで構成され、属性定義 `type="Property"`
やプロパティのプロパティ (_properties-of-properties_) 要素は含まれません。リクエストの `Link`
ヘッダがレスポンスで返される `@context` として使用されていることがわかります。

```jsonld
[
    {
        "@context": "http://context/ngsi-context.jsonld",
        "id": "urn:ngsi-ld:Building:farm001",
        "type": "Building",
        "address": {
            "streetAddress": "Großer Stern 1",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Victory Farm",
        "category": "farm",
        "location": {
            "type": "Point",
            "coordinates": [
                13.3505,
                52.5144
            ]
        }
    },
    {
        "@context": "http://context/ngsi-context.jsonld",
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "Building",
        "address": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Big Red Barn",
        "category": "barn",
        "location": {
            "type": "Point",
            "coordinates": [
                13.3698,
                52.5163
            ]
        }
    }
]
```

<a name="filter-context-data-by-comparing-the-values-of-an-attribute"/>

### 属性の値を比較してコンテキスト・データをフィルタリング

この例は、`name` 属性が _Big Red Barn_ のすべての `Building` エンティティを返します。フィルタリングは、
`q` パラメータを使用して実行できます。文字列にスペースが含まれている場合、URL エンコードして二重引用符文字
`"` = `%22` で保持できます。`options=keyValues` が送信されるため、これによりペイロードの構造に影響を与えるため、
別の `@context` ファイル - `json-context.jsonld` を提供する必要があります。

#### :seven: リクエスト:

```console
curl -G -X GET \
  'http://localhost:1026/ngsi-ld/v1/entities/' \
-H 'Link: <http://context/json-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
    -d 'type=Building' \
    -d 'q=name==%22Big%20Red%20Barn%22' \
    -d 'options=keyValues'
```

#### レスポンス:

`Link` ヘッダと `options=keyValues` パラメータを使用すると、次のように、短い形式の Key-Value **JSON-LD**
へのレスポンスが減少します:

```jsonld
[
    {
        "@context": "http://context/json-context.jsonld",
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "Building",
        "address": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Big Red Barn",
        "category": "barn",
        "location": {
            "type": "Point",
            "coordinates": [
                13.3698,
                52.5163
            ]
        }
    }
]
```

この **JSON-LD** はもはや **NGSI-LD** ではなく (`type` および `value` 要素が削除されているため)、使用される
`@context` はこれを反映しています。`json-context.jsonld` ファイルは属性名を定義するだけでなく、次のような追加の
**JSON-LD** 情報もその中に含みます:

```json-ld
{
    "barn": "https://wiki.openstreetmap.org/wiki/Tag:building%3Dbarn",
    "category": {
        "@id": "https://uri.fiware.org/ns/data-models#category",
        "@type": "@vocab"
    }
}
```

これは、この **JSON-LD** レスポンスの `category` が列挙値 (`@vocab`) を保持し、値 `barn` が完全な URL によって
定義されていることを示しています。これは、完全な URL `https://uri.fiware.org/ns/data-models#category` を持つ属性が
あるということしか言えない `ngsi-context.jsonld` `@context` ファイルとは異なります。正規化された **NGSI-LD**
レスポンスでは、`category` 属性は (`type` と `value` を持つ) 文字列ではなく 、JSONオブジェクトを保持するためです。

<a name="using-an-alternative-context"/>

### 代替 `@context` の使用

単純な **NGSI-LD** `@context` は、URN をマッピングするためのメカニズムにすぎません。したがって、異なる短い名前の
セットを使用して同じデータ (_the same data_) を取得することが可能です。

`alternate-context.jsonld` は、さまざまな属性の名前をドイツ語の対応する属性にマッピングします。リクエストで提供されている
場合、代替の短い名前を使用してクエリを作成できます (たとえば、`type=Building` は `type=Gebäude` になります)。

#### :eight: リクエスト:

```console
curl -G -X GET \
    'http://localhost:1026/ngsi-ld/v1/entities/' \
-H 'Link: <http://context/alternate-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
    -d 'type=Geb%C3%A4ude' \
    -d 'q=name==%22Big%20Red%20Barn%22' \
    -d 'options=keyValues'
```

#### レスポンス:

レスポンスは、代替コンテキストで提供される短い名前に対応する短い形式の属性名 (`addresse`, `kategorie`) を含む JSON-LD
形式で返されます。Core Context の用語 (`id`, `type` など) を直接上書きすることはできませんが、追加の **JSON-LD**
拡張/圧縮操作が必要になることに注意してください。

```jsonld
[
    {
        "@context": "http://context/alternate-context.jsonld",
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "Gebäude",
        "adresse": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Big Red Barn",
        "kategorie": "barn",
        "location": {
            "type": "Point",
            "coordinates": [
                13.3698,
                52.5163
            ]
        }
    }
]
```

また、`address` = `addresse` = `http://schema.org/address` であり、この定義がサブ属性を定義しているため、
`addresse` のサブ属性も修正されていないことに注意してください。

<a name="filter-context-data-by-comparing-the-values-of-an-attribute-in-an-array"/>

### 配列内の属性の値を比較してコンテキスト・データをフィルタリング

標準の `Building` モデル内で、`category` 属性は文字列の配列を参照します。この例では、`commercial` または `office`
文字列を含む `category` 属性を持つすべての `Building` エンティティを返します。フィルタリングは、`q`
パラメータを使用して、許容値をカンマで区切って行うことができます。

#### :nine: リクエスト:

```console
curl -G -X GET \
    'http://localhost:1026/ngsi-ld/v1/entities/' \
-H 'Link: <http://context/nsgi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
    -d 'type=Building' \
    -d 'q=category==%22barn%22,%22farm_auxiliary%22' \
    -d 'options=keyValues'
```

#### レスポンス:

レスポンスは JSON-LD 形式で返され、短い形式の属性名が含まれます:

```jsonld
[
    {
        "@context": "http://context/ngsi-context.jsonld",
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "Building",
        "address": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Big Red Barn",
        "category": "barn",
        "location": {
            "type": "Point",
            "coordinates": [
                13.3698,
                52.5163
            ]
        }
    }
]
```

<a name="filter-context-data-by-comparing-the-values-of-a-sub-attribute"/>

### サブ属性の値を比較してコンテキスト・データをフィルタリング

この例では、ティーアガルテン地区 (Tiergarten District) にあるすべての店舗を返します。

フィルタリングは `q` パラメータを使用して行うことができます - サブ属性は、`q=address[addressLocality]=="Tiergarten"`
などのブラケット構文を使用して注釈が付けられます。

#### :one::zero: リクエスト:

```console
curl -L -X GET 'http://localhost:1026/ngsi-ld/v1/entities/' \
-H 'Link: <http://context/json-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
    -d 'type=Building' \
    -d 'q=address%5BaddressLocality%5D==%22Tiergarten%22' \
    -d 'options=keyValues'
```

#### レスポンス:

`Link` ヘッダと `options=keyValues` パラメータを使用すると、JSON-LD へのレスポンスが減少します。

```jsonld
[
    {
        "@context": "http://context/json-context.jsonld",
        "id": "urn:ngsi-ld:Building:farm001",
        "type": "Building",
        "address": {
            "streetAddress": "Großer Stern 1",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Victory Farm",
        "category": "farm",
        "location": {
            "type": "Point",
            "coordinates": [
                13.3505,
                52.5144
            ]
        }
    },
    {
        "@context": "http://context/json-context.jsonld",
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "Building",
        "address": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Big Red Barn",
        "category": "barn",
        "location": {
            "type": "Point",
            "coordinates": [
                13.3698,
                52.5163
            ]
        }
    }
]
```

<a name="filter-context-data-by-querying-metadata"/>

### メタデータのクエリによりコンテキスト・データをフィルタリング

この例では、検証された住所を持つすべての `Building` エンティティのデータを返します。`verified` 属性は
プロパティのプロパティ (_Property-of-a-Property_) の例です。

メタデータ・クエリ (プロパティのプロパティなど) は、ドット構文を使用して注釈が付けられます
(例: `q=address.verified==true`)。

#### :one::one: リクエスト:

```console
curl -G -X GET \
    'http://localhost:1026/ngsi-ld/v1/entities' \
    -H 'Link: <http://context/json-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
    -H 'Accept: application/json' \
    -d 'type=Building' \
    -d 'q=address.verified==true' \
    -d 'options=keyValues'
```

#### レスポンス:

`options=keyValues` を Accept HTTP ヘッダ (`application/json`) と共に使用するため、レスポンスは属性 `type` と
`metadata` 要素を含まない JSON のみで構成されます。

```json
[
    {
        "id": "urn:ngsi-ld:Building:farm001",
        "type": "Building",
        "address": {
            "streetAddress": "Großer Stern 1",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Victory Farm",
        "category": "farm",
        "location": {
            "type": "Point",
            "coordinates": [13.3505, 52.5144]
        }
    },
    {
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "Building",
        "address": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Big Red Barn",
        "category": "barn",
        "location": {
            "type": "Point",
            "coordinates": [13.3698, 52.5163]
        }
    }
]
```

`@context` 要素は失われていないことに注意してください。それでも、レスポンスでは `Link` ヘッダの形式で返されます。

<a name="filter-context-data-by-comparing-the-values-of-a-geojson-attribute"/>

### geo:json 属性の値を比較してコンテキスト・データをフィルタリング

この例では、ベルリン (**Berlin**)の ブランデンブルク門 (**Brandenburg Gate**) (_52.5162N 13.3777W_) から
800m以内のすべての建物を返します。ジオ・クエリ・リクエストを行うには、3つのパラメータ、`geometry`, `coordinates`,
`georel` を指定する必要があります。

`coordinates` パラメータは、角かっこを含めて [geoJSON](https://tools.ietf.org/html/rfc7946) で表されます。

これはデフォルトで NGSI-LD に指定されているため、デフォルトではジオ・クエリが `location` 属性に適用されることに
注意してください。別の属性を使用する場合は、追加の `geoproperty` パラメーターが必要です。

#### :one::two: リクエスト:

```console
curl -G -X GET \
  'http://localhost:1026/ngsi-ld/v1/entities' \
  -H 'Link: <https://fiware.github.io/data-models/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
  -H 'Accept: application/json' \
  -d 'type=Building' \
  -d 'geometry=Point' \
  -d 'coordinates=%5B13.3777,52.5162%5D' \
  -d 'georel=near;maxDistance==800' \
  -d 'options=keyValues'
```

#### レスポンス:

`options=keyValues` を Accept HTTP ヘッダ (`application/json`) と共に使用するため、レスポンスは属性 `type` と `metadata`
要素を含まない JSON のみで構成されます。

```json
[
    {
        "id": "urn:ngsi-ld:Building:barn002",
        "type": "Building",
        "address": {
            "streetAddress": "Straße des 17. Juni",
            "addressRegion": "Berlin",
            "addressLocality": "Tiergarten",
            "postalCode": "10557"
        },
        "name": "Big Red Barn",
        "category": "barn",
        "location": {
            "type": "Point",
            "coordinates": [13.3698, 52.5163]
        }
    }
]
```

# 次のステップ

高度な機能を追加することで、アプリケーションに複雑さを加える方法を知りたいですか？ このシリーズの
[他のチュートリアル](https://www.letsfiware.jp/ngsi-ld-tutorials)を読むことで見つけることができます

---

## License

[MIT](LICENSE) © 2020 FIWARE Foundation e.V.
