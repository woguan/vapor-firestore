# Vapor Firestore Provider

Vapor-firestore is a lightweight provider which allows you to easily connect your Vapor project to a Firestore database and perform basic crud operations via the Firebase REST API.

### Prerequisites
You will need:
- Vapor 4.0+

### Installing

In your Package.swift file, add the line

```swift
.package(url: "https://github.com/abesmon/vapor-firestore.git", from: "0.3.0")
```

Also add `VaporFirestore` as a dependency

```swift
dependencies: [
    .product(name: "Vapor", package: "vapor"),
    ...
    .product(name: "VaporFirestore", package: "vapor-firestore")
    ...
]
```

## Setup

1. To use the VaporFirestore, you'll need a Firebase project, a service account to communicate with the Firebase service, and a configuration file with your service account's credentials.

* If you don't already have a Firebase project, add one in the Firebase console.
* Navigate to the Service Accounts tab in your project's settings page.
* Click the Generate New Private Key button at the bottom of the Firebase Admin SDK section of the Service Accounts tab.
* After you click the button, a JSON file containing your service account's credentials will be downloaded. You'll need this to initialize VaporFirestore in the next step.

2. Setup `VaporFirestore` configuration. This must me done before any `firestore` call. Best way to make such setup is in `configure(_ app: Application)`
```swift
import VaporFirstore

public func configure(_ app: Application) throws {
    ...
    self.app.storage[FirestoreConfig.FirestoreConfigKey.self] = FirestoreConfig(
        projectId: Environment.get("FS_PRJ_KEY")!,
        email: Environment.get("FS_EMAIL_KEY")!,
        privateKey: Environment.get("FS_PRIVKEY_KEY")!
    )
    ...
}
```

as you can see, Environment storage is in use. It's highly recomended to pass your credentials this way. But if you have reasons to do other way, you can pass any string :)

## Usage

First setup a model for your document. The current implementation of Vapor-Firestore uses helper wrappers when defining documents for example:

```swift
struct AllTypesModel: Codable {
    struct NestedType: Codable {
        @Firestore.StringValue
        var nestedString: String
    }
    
    @Firestore.StringValue
    var someStringValue: String
    
    @Firestore.BoolValue
    var someBoolValue: Bool
    
    @Firestore.IntValue
    var someIntValue: Int
    
    @Firestore.DoubleValue
    var someDoubleValue: Double
    
    var someGeoPoint: Firestore.GeoPoint
    
    @Firestore.TimestampValue
    var someTimestamp: Date
    
    var someReference: Firestore.ReferenceValue
    
    @Firestore.MapValue
    var someMapValue: NestedType
    
    @Firestore.ArrayValue
    var someArray: [Firestore.StringValue]
}
```

To create a new document using this model:

```swift
let client = app.firestoreService.firestore
let testObject = ArticleFields(title: "A title", "A subtitle")
let result = try client.createDocument(path: "test", fields: testObject).wait()
```

To retrieve an array of all objects in this collection using this model:

```swift
let client = app.firestoreService.firestore
let result: [Firestore.Document<ArticleFields>] = try client.listDocuments(path: "test").wait()
```

To retrieve an individual object in this collection using this model:

```swift
let client = app.firestoreService.firestore
let result: Firestore.Document<ArticleFields> = try client.getDocument(path: "test/<object-id>").wait()
```

To update a document with all fields:

```swift
let client = app.firestoreService.firestore
let result = try client.updateDocument(path: "test/<object-id>", fields: testObject, updateMask: nil).wait()
```

To update specific fields of a document you must declare a new model with only those fields and pass a mask:

```swift

struct ArticleUpdateFields: Codable {
    var title: Firestore.StringValue
}

let client = app.firestoreService.firestore
let updateObject = ArticleUpdateFields(title: Firestore.StringValue("An updated title again"))
let result = try client.updateDocument(path: "test/<object-id>", fields: updateObject, updateMask: ["title"]).wait()
```


## Testing (outdated)

The Vapor-Firstore project contains some example simple unit tests. If you want to run these tests you will need to create a test Firestore database and add the service account credentials to `Application+Testing.swift`.
The testUpdateDoc and testGetDoc tests require a document to exist before they will pass. The easiest way to do this is to first run just the testCreateDoc test which will create a document of the test structure and output its object-id. Cut and paste this id into the update and get tests and then comment out testCreateDoc to avoid continually createing documents everytime you run the tests.


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Ferno, a similar project for connecting to Firebase realime database. [Ferno](https://github.com/vapor-community/ferno.git)
* Stripe Provider, a great template and example provider [stripe-provider](https://github.com/vapor-community/stripe-provider)
* Vapor Discord for answering all my questions


