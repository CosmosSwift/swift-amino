//
//  AminoTypes.swift
//  swift-amino
//

import Foundation


// reference : https://developers.google.com/protocol-buffers/docs/encoding
public enum AminoWireType: UInt8 {
    case varint = 0x0 // int32, int64, uint32, uint64, sint32, sint64, bool, enum
    case bytes8 = 0x1 // fixed64, sfixed64, double
    case bytes = 0x2 // string, bytes, embedded messages, packed repeated fields
    case bytes4 = 0x5 // fixed32, sfixed32, float
}

extension UInt8 {
    public init(_ wireType: AminoWireType) {
        self = wireType.rawValue
    }
}

public protocol AminoType {
    static var typ3: AminoWireType { get }
    var typ3: AminoWireType { get }
}

public extension AminoType {
    var typ3: AminoWireType {
        get {
            return Self.typ3
        }
    }
    static var typ3: AminoWireType {
        get {
            return .varint
        }
    }
}

public protocol AminoScalar: AminoType {}
public protocol AminoComplex: AminoType {}

public protocol AminoVarint: AminoScalar {}
public protocol AminoSignedVarint: AminoScalar {}
public protocol AminoTime: AminoScalar {}

public protocol Amino8Bytes: AminoScalar {}

public extension Amino8Bytes {
    static var typ3: AminoWireType {
        get {
            return .bytes8
        }
    }
}

public protocol AminoBytes: AminoComplex {}

public extension AminoBytes {
    static var typ3: AminoWireType {
        get {
            return .bytes
        }
    }
}

/*
public protocol AminoStruct: AminoType {}

public extension AminoStruct {
    static var typ3: AminoWireType {
        get {
            return .bytes
        }
    }
    
    // TODO: Add static item to register the Struct
}
*/

public protocol Amino4Bytes: AminoScalar {}

public extension Amino4Bytes {
    static var typ3: AminoWireType {
        get {
            return .bytes4
        }
    }
}

public protocol AminoList: AminoComplex {}

public extension AminoList {
    static var typ3: AminoWireType {
        get {
            return .bytes
        }
    }
}

public protocol AminoInterface: AminoComplex {}

public extension AminoInterface {
    static var typ3: AminoWireType {
        get {
            return .bytes
        }
    }
}






