//
//  FirestoreRequest.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//

import Vapor
import JWT

protocol FirestoreClient {
    func getToken() -> EventLoopFuture<String>
    func send<F: Decodable>(method: HTTPMethod, path: String, query: String, body: ByteBuffer, headers: HTTPHeaders) -> EventLoopFuture<F>
}

class FirestoreAPIClient: FirestoreClient {
    private let decoder = JSONDecoder.firestore
    private let encoder = JSONEncoder.firestore
    private weak var app: Application!
    private let basePath: String
    private let baseUrl: URL
    private let email: String
    private let privateKey: String
    private var authTokenExpireAt: Date
    private var authToken: String
    private var signer: JWTSigner?

    init(app: Application) {
        self.basePath = "projects/\(app.firebaseConfig!.projectId)/databases/(default)/documents/"
        self.baseUrl = URL(string: "https://firestore.googleapis.com/v1/")!
        self.app = app
        self.email = app.firebaseConfig!.email
        self.privateKey = app.firebaseConfig!.privateKey.replacingOccurrences(of: "\\n", with: "\n")
        self.authTokenExpireAt = Date.distantPast
        self.authToken = ""

        do {
            signer = try JWTSigner.rs256(key: .private(pem: self.privateKey))
        } catch {
            print("JWT error: \(error)")
        }
    }

    func getToken() -> EventLoopFuture<String> {
        guard let signer = signer else {
            return app.client.eventLoop.future(error: FirestoreError.signing)
        }

        if (authTokenExpireAt > Date() ) {
            return app.client.eventLoop.future(authToken)
        }
        
        var req = ClientRequest()
        
        do {
            let payload = Firestore.Auth.Payload(iss: IssuerClaim(value: self.email))
            let jwtString = try signer.sign(payload)

            var headers = HTTPHeaders([])
            headers.add(name: HTTPHeaders.Name.contentType, value: "application/x-www-form-urlencoded")

            let body = Firestore.Auth.Request(grantType: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: jwtString)
            
            
            try req.content.encode(body, as: .urlEncodedForm)
            req.url = URI(string: "https://www.googleapis.com/oauth2/v4/token")
            req.method = .POST
        } catch {
            return app.client.eventLoop.future(error: error)
        }

        return app.client.send(req).flatMapThrowing { response -> Firestore.Auth.Response in
            return try response.content.decode(Firestore.Auth.Response.self)
        }.map { authResponse -> String in
            self.authToken = authResponse.accessToken
            self.authTokenExpireAt = Date().addingTimeInterval(TimeInterval(authResponse.expiresIn - 10))
            return authResponse.accessToken
        }
    }

    func send<F: Decodable>(method: HTTPMethod, path: String, query:String, body: ByteBuffer, headers: HTTPHeaders) -> EventLoopFuture<F> {
        return getToken()
            .flatMap { accessToken in
                return self.send(method: method, path: path, query: query, body: body, headers: headers, accessToken: accessToken)
                    .flatMapThrowing { response -> F in
                        let body = response.body ?? ByteBuffer()
                        return try self.decoder.decode(F.self, from: body)
                    }
            }
    }

    private func send(method: HTTPMethod, path: String, query:String, body: ByteBuffer, headers: HTTPHeaders, accessToken: String) -> EventLoopFuture<ClientResponse> {
        let url = (path.hasPrefix(basePath)) ? baseUrl : baseUrl.appendingPathComponent(basePath)
        let uri = url.appendingPathComponent(path).absoluteString

        var finalHeaders: HTTPHeaders = [:]
        
        finalHeaders.add(name: .contentType, value: HTTPMediaType.json.description)
        finalHeaders.add(name: .authorization, value: "Bearer \(accessToken)")
        headers.forEach { finalHeaders.replaceOrAdd(name: $0.name, value: $0.value) }

        return app.client
            .send(method, headers: finalHeaders, to: "\(uri)?\(query)") { $0.body = body }
            .flatMap { response -> EventLoopFuture<ClientResponse> in
                guard (200...299).contains(response.status.code) else {
                    do {
                        let decodedError = try self.decoder.decode(FirestoreErrorResponse.self, from: response.body!)
                        return self.app.client.eventLoop.makeFailedFuture(decodedError)
                    } catch {
                        return self.app.client.eventLoop.makeFailedFuture(error)
                    }
                }
                return self.app.client.eventLoop.future(response)
            }
    }
}

