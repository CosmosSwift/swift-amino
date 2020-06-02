//
//  ConcreteTypeRegistry.swift
//  swift-amino
//


import Foundation



// Registers concrete type.
// Also registers disambiguations



// String: 4bytes or String: 7 bytes

import Crypto

public protocol AminoCodableInterface: AminoInterface, AminoCodable {}

public class ConcreteTypeRegistry {
    
    
    enum Error: Swift.Error {
        case duplicateTypeRegistration(String)
    }
    
    static var hashToType: [Data: AminoCodableInterface.Type] = [:]
    static var typeToHash: [String: Data] = [:]
    static var typeToIndentifier: [String: String] = [:]

    static public func registerInterface<T: AminoCodableInterface>(_ type: T.Type) {
        // TODO: register interface
        
    }

    
    static public func registerConcrete<T: AminoCodableInterface>(_ type: T.Type, _ identifier: String = String(describing: T.self)) throws {
        guard typeToIndentifier[String(describing: type)] == nil else {
            throw Error.duplicateTypeRegistration(identifier)
        }
        let (disamb, prefix) = getFullPrefix(identifier)
        hashToType[Data(disamb + prefix)] = type
        typeToIndentifier[String(describing: type)] = identifier
        if let h = hashToType[Data(prefix)] {
            // update typeToHash to hold disambiguated hash
            let (d, _) = getFullPrefix(typeToIndentifier[String(describing: h)]!)
            typeToHash[String(describing: h)] = Data(d + prefix)
            typeToHash[String(describing: type)] = Data(disamb + prefix)
            hashToType[Data(prefix)] = nil
        } else {
            hashToType[Data(prefix)] = type
            typeToHash[String(describing: type)] = Data(prefix)
        }
    }
    
    static private func getFullPrefix(_ identifier: String) -> ([UInt8], [UInt8]) {
        let a = [UInt8](Crypto.SHA256.hash(data: [UInt8](identifier.utf8)))
        var idx = 0
        while (a[idx] == 0) { idx += 1 }
        let disamb: [UInt8] = [0x0, a[idx], a[idx+1], a[idx+2]]
        idx += 3
        while (a[idx] == 0) { idx += 1 }
        let prefix: [UInt8] = [a[idx], a[idx+1], a[idx+2],  a[idx+3]]
        return (disamb, prefix)
    }
    
    
    static public func getHash(_ type: AminoCodableInterface.Type) -> [UInt8]? {
        guard let a = typeToHash[String(describing: type)] else { return nil }
        return [UInt8](a)
    }
    
    static public func getType(_ hash: [UInt8]) -> AminoCodableInterface .Type? {
        return hashToType[Data(hash)]
    }
}


