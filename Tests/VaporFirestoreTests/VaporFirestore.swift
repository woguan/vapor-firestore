import Vapor
@testable import VaporFirestore
import XCTest
import Nimble

final class VaporFirestoreTests: XCTestCase {
    var app: Application!

    override func setUp() {
        super.setUp()
        self.app = Application(.testing)
        guard let thekey = Environment.get("FS_PK") else {
            XCTFail("Private key not available")
            return
        }

        self.app.storage[FirestoreConfig.FirestoreConfigKey.self] = FirestoreConfig(
            projectId: "dwg-server",
            email: "firebase-adminsdk-lwfhe@dwg-server.iam.gserviceaccount.com",
            privateKey: thekey
        )
    }

    func testAuthToken() throws {
        do {
            let apiClient = FirestoreAPIClient(app: app)
            let result = try apiClient.getToken().wait()
            
            expect(result).toNot(beEmpty())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testCreateDoc() throws {
        do {
            let client = app.firestoreService.firestore
            let testObject = TestFields(title: "A title", subTitle: "A subtitle")

            let result = try client.createDocument(path: "test", fields: testObject).wait()
            expect(result).toNot(beNil())

            print("Test object-id: \( (result.name as NSString).lastPathComponent)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGeoCreate() throws {
        do {
            let client = app.firestoreService.firestore
            let testObject = GeoFieldTest(somegeoPoint: Firestore.GeoPoint(latitude: 15.03, longitude: 15.03))
            let result = try client.createDocument(path: "test", fields: testObject).wait()
            expect(result).toNot(beNil())

            print("Test object-id: \( (result.name as NSString).lastPathComponent)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGeoRead() throws {
        do {
            var objectId = "<object-id>"
            objectId = "uIrxY3fapSXfiIELVKSd" // uncomment this string a and set it to some real id from testDatabbase
            let client = app.firestoreService.firestore

            let result: Firestore.Document<GeoFieldTest> = try client.getDocument(path: "test/\(objectId)").wait()

            expect(result).toNot(beNil())
            expect(result.fields?.somegeoPoint.latitude).toNot(beNil())
            expect(result.fields?.somegeoPoint.longitude).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testNullableCreate() throws {
        do {
            let client = app.firestoreService.firestore
            let testObject = NullValueTest(title: nil, number: 120)
            let result = try client.createDocument(path: "test", fields: testObject).wait()
            expect(result).toNot(beNil())

            print("Test object-id: \( (result.name as NSString).lastPathComponent)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testNullRead() throws {
        do {
            var objectId = "<object-id>"
            objectId = "bGxv5lBmZrlWZQWyyGS6" // uncomment this string a and set it to some real id from testDatabbase
            let client = app.firestoreService.firestore

            let result: Firestore.Document<NullValueTest> = try client.getDocument(path: "test/\(objectId)").wait()

            expect(result).toNot(beNil())
            expect(result.fields?.title).to(beNil())
            expect(result.fields?.number).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUpdateDoc() throws {
        do {
            var objectId = "<object-id>"
            objectId = "oomlgfl9uWovPVKikBFB" // uncomment this string a and set it to some real id from testDatabbase
            let client = app.firestoreService.firestore
            let testObject = TestFields(title: "An updated title again", subTitle: "expecting to ignore this text")
            let result = try client.updateDocument(path: "test/\(objectId)", fields: testObject, updateMask: ["title"]).wait()

            expect(result).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testListDocs() throws {
        do {
            let client = app.firestoreService.firestore
            let result: [Firestore.Document<TestFields>] = try client.listDocuments(path: "test").wait()

            print(result.count)
            expect(result).toNot(beNil())
            expect(result[0].fields?.title).toNot(beNil())
            expect(result[0].fields?.subTitle).toNot(beNil())
        } catch {
           XCTFail(error.localizedDescription)
        }
    }
    
    func testListDocsUnlimited() throws {
        do {
            let client = app.firestoreService.firestore
            let result: [Firestore.Document<TestFields>] = try client.listDocumentsUnlimited(path: "test").wait()

            print(result.count)
            expect(result).toNot(beNil())
            expect(result[0].fields?.title).toNot(beNil())
            expect(result[0].fields?.subTitle).toNot(beNil())
        } catch {
           XCTFail(error.localizedDescription)
        }
    }

    func testGetDoc() throws {
        do {
            var objectId = "<object-id>"
            objectId = "oomlgfl9uWovPVKikBFB" // uncomment this string a and set it to some real id from testDatabbase
            let client = app.firestoreService.firestore

            let result: Firestore.Document<TestFields> = try client.getDocument(path: "test/\(objectId)").wait()

            expect(result).toNot(beNil())
            expect(result.fields?.title).toNot(beNil())
            expect(result.fields?.subTitle).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testGetHiltonDoc() throws {
        do {
            let objectId = "hilton/canopy-brazil"
            let client = app.firestoreService.firestore
            let result: Firestore.Document<Hilton> = try client.getDocument(path: objectId).wait()
            expect(result).toNot(beNil())
            expect(result.fields?.records).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAllTypesCreate() throws {
        do {
            let client = app.firestoreService.firestore
            let testObject = AllTypesModelTest(someStringValue: "demoString",
                                               someBoolValue: true,
                                               someIntValue: 42,
                                               someDoubleValue: 3.14159265359,
                                               someGeoPoint: Firestore.GeoPoint(latitude: 15, longitude: 10),
                                               someTimestamp: Date(),
                                               someReference: Firestore.ReferenceValue(projectId: app.firebaseConfig!.projectId, documentPath: "test/tester"),
                                               someMapValue: AllTypesModelTest.NestedType(nestedString: "nestedStringDemo"),
                                               someArray: ["lemon", "banana", "apple", "grapes"]
            )
            let result = try client.createDocument(path: "test", fields: testObject).wait()
            expect(result).toNot(beNil())

            print("Test object-id: \( (result.name as NSString).lastPathComponent)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAllTypesRead() throws {
        do {
            var objectId = "<object-id>"
            objectId = "0z3IKmbPuzd212wlhH6u" // uncomment this string a and set it to some real id from testDatabbase
            let client = app.firestoreService.firestore

            let result: Firestore.Document<AllTypesModelTest> = try client.getDocument(path: "test/\(objectId)").wait()

            expect(result.fields).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testWriteWithName() throws {
        do {
            let client = app.firestoreService.firestore
            let testObject = TestFields(title: "A title", subTitle: "A subtitle")

            let result = try client.createDocument(path: "test2", name: "demoName", fields: testObject).wait()
            expect(result).toNot(beNil())
            expect(result.id).to(be("demoName"))

            print("Test object-id: \( (result.name as NSString).lastPathComponent)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCreateDocWithMessageFields() throws {
        do {
            let client = app.firestoreService.firestore
            for id in 0...100 {
                let testObject = MessageFields(id: id, title: "The title", subTitle: "The id is \(id)")
                let result = try client.createDocument(path: "message", fields: testObject).wait()
                expect(result).toNot(beNil())
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetAllMessageFields() throws {
        do {
            let client = app.firestoreService.firestore
            let result: [Firestore.Document<MessageFields>] = try client.listDocumentsUnlimited(path: "message").wait()
            print(result.count)
            expect(result).toNot(beNil())
            expect(result[0].fields?.title).toNot(beNil())
            expect(result[0].fields?.id).toNot(beNil())
        } catch {
           XCTFail(error.localizedDescription)
        }
    }
    
    func testFilterMessageField() throws {
        do {
            let client = app.firestoreService.firestore
            let result: [Firestore.ListDocument<MessageFields>] = try client.getFilteredDocuments(collectionId: "message", fieldName: "id", op: .greaterThan, value: 50).wait()
            
            if let firstId = result.first?.document?.fields?.id {
                XCTAssertTrue(firstId > 50, "Unexpected")
            } else {
                XCTFail("Unexpected")
            }
            
            if let lastId = result.last?.document?.fields?.id {
                XCTAssertTrue(lastId > 50, "Unexpected")
            } else {
                XCTFail("Unexpected")
            }
            print(result)
        } catch {
           XCTFail(error.localizedDescription)
        }
    }
}
