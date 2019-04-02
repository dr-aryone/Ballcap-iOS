//
//  Document.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol Documentable {
    init()
}

public enum DocumentError: Error {
    case invalidReference
    case invalidData
    case timeout

    public var description: String {
        switch self {
        case .invalidReference: return "The value you are trying to reference is invalid."
        case .invalidData: return "Invalid data."
        case .timeout: return "DataSource fetch timed out."
        }
    }
}

public protocol Modelable: class, Referencable {

    associatedtype Model: Codable & Documentable = Void

    var data: Model? { get set }
}

public extension Modelable where Self: Document {

    init(id: String, from data: Model) {
        self.init(id: id)
        self.data = data
    }

    init?(id: String, from data: [String: Any]) {
        self.init(id: id)
        do {
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
        } catch (let error) {
            print(error)
            return nil
        }
    }

    init?(snapshot: DocumentSnapshot) {
        guard let data: [String: Any] = snapshot.data() else {
            self.init(id: snapshot.documentID)
            self.snapshot = snapshot
            return
        }
        do {
            self.init(id: snapshot.documentID)
            self.snapshot = snapshot
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
        } catch (let error) {
            print(error)
            return nil
        }
    }
}

//public extension Document {
//
//    static var modelVersion: String {
//        return "1"
//    }
//
//    static var modelName: String {
//        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
//    }
//
//    static var path: String {
//        return "version/\(self.modelVersion)/\(self.modelName)"
//    }
//
//    static var collectionReference: CollectionReference {
//        return Firestore.firestore().collection(self.path)
//    }
//
//    var storageReference: StorageReference {
//        return Storage.storage().reference().child(self.path)
//    }
//
//    var path: String {
//        return self.documentReference.path
//    }
//
//    var id: String {
//        return self.documentReference.documentID
//    }
//
//    init() {
//        self.init()
//        self.data = Model()
////        self.documentReference = type(of: self).collectionReference.document()
//    }
//
//    init(id: String) {
//        self.init()
////        self.documentReference = type(of: self).collectionReference.document(id)
//    }
//
//    init(id: String, from data: Model) {
//        self.init()
//        self.data = data
////        self.documentReference = type(of: self).collectionReference.document(id)
//    }
//}

public class Document: NSObject, Referencable {

    public enum SourceType {
        case `default`
        case cacheOnly
        case networkOnly
    }

    open class var modelVersion: String {
        return "1"
    }

    open class var modelName: String {
        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
    }

    open class var path: String {
        return "version/\(self.modelVersion)/\(self.modelName)"
    }

    open class var collectionReference: CollectionReference {
        return Firestore.firestore().collection(self.path)
    }

    open var id: String {
        return self.documentReference.documentID
    }

    open var path: String {
        return self.documentReference.path
    }

    public fileprivate(set) var snapshot: DocumentSnapshot?

    public private(set) var documentReference: DocumentReference!

    open var storageReference: StorageReference {
        return Storage.storage().reference().child(self.path)
    }

    public override init() {
        super.init()
        self.documentReference = type(of: self).collectionReference.document()
    }

    public required init(id: String) {
        super.init()
        self.documentReference = type(of: self).collectionReference.document(id)
    }
}


//public class Document<Model: Codable & Documentable>: NSObject, Referencable {
//
//    public enum SourceType {
//        case `default`
//        case cacheOnly
//        case networkOnly
//    }
//
//    open class var modelVersion: String {
//        return "1"
//    }
//
//    open class var modelName: String {
//        return String(describing: Mirror(reflecting: Model.self).subjectType).components(separatedBy: ".").first!.lowercased()
//    }
//
//    open class var path: String {
//        return "version/\(self.modelVersion)/\(self.modelName)"
//    }
//
//    open class var collectionReference: CollectionReference {
//        return Firestore.firestore().collection(self.path)
//    }
//
//    open var id: String {
//        return self.documentReference.documentID
//    }
//
//    open var path: String {
//        return self.documentReference.path
//    }
//
//    public private(set) var snapshot: DocumentSnapshot?
//
//    public private(set) var documentReference: DocumentReference!
//
//    open var storageReference: StorageReference {
//        return Storage.storage().reference().child(self.path)
//    }
//
//    public var data: Model?
//
//    public override init() {
//        self.data = Model()
//        super.init()
//        self.documentReference = type(of: self).collectionReference.document()
//    }
//
//    public init(id: String) {
//        self.data = Model()
//        super.init()
//        self.documentReference = type(of: self).collectionReference.document(id)
//    }
//
//    public init(id: String, from data: Model) {
//        self.data = data
//        super.init()
//        self.documentReference = type(of: self).collectionReference.document(id)
//    }
//
//    public required init?(id: String, from data: [String: Any]) {
//        do {
//            self.data = try Firestore.Decoder().decode(Model.self, from: data)
//        } catch (let error) {
//            print(error)
//            return nil
//        }
//        super.init()
//        self.documentReference = type(of: self).collectionReference.document(id)
//    }
//
//    public init?(snapshot: DocumentSnapshot) {
//        guard let data: [String: Any] = snapshot.data() else {
//            super.init()
//            self.snapshot = snapshot
//            self.documentReference = type(of: self).collectionReference.document(snapshot.documentID)
//            return
//        }
//        do {
//            self.data = try Firestore.Decoder().decode(Model.self, from: data)
//        } catch (let error) {
//            print(error)
//            return nil
//        }
//        super.init()
//        self.documentReference = type(of: self).collectionReference.document(id)
//    }
//}
/*
// MARK: -

public extension Document {

    func save(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        Store.shared.set(self, reference: reference, completion: completion)
    }
}

// MARK: -

public extension Document {

    class func get(id: String, sourceType: SourceType = .default, completion: @escaping ((Document?, Error?) -> Void)) {

        switch sourceType {
        case .default:
            if let document: Document = self.get(id: id) {
                completion(document, nil)
            }
            self.reference.document(id).getDocument { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot!) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        case .cacheOnly:
            if let document: Document = self.get(id: id) {
                completion(document, nil)
            }
            self.reference.document(id).getDocument(source: FirestoreSource.cache) { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot!) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        case .networkOnly:
            if let document: Document = self.get(id: id) {
                completion(document, nil)
            }
            self.reference.document(id).getDocument { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot!) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        }
    }

    class func get(id: String) -> Document? {
        return Store.shared.get(documentType: self, id: id)
    }

    class func listen(id: String, includeMetadataChanges: Bool = true, completion: @escaping ((Document?, Error?) -> Void)) -> Disposer {
        let listenr: ListenerRegistration = self.reference.document(id).addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let document: Document = Document(snapshot: snapshot!) else {
                completion(nil, DocumentError.invalidData)
                return
            }
            completion(document, nil)
        }
        return Disposer(.value(listenr))
    }
}
*/
