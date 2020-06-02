//
//  AminoCodableExtensions.swift
//  swift-amino
//

// Implementations of AminoCodable for built-in types.
import Foundation


// Optional:
// when nil, the field is not encoded
extension Optional: AminoCodable where Wrapped: AminoCodable {
    public init(fromAmino aminoDecoder: AminoDecoder) throws { // this is only valid with lists
        var v: UInt8 = 0
        try aminoDecoder.read(into: &v)
        if (v == 1) {
            self = .none
        } else {
            let decoded = try Wrapped(fromAmino: aminoDecoder)
            self = .some(decoded)
        }
    }
}

extension Optional: AminoType where Wrapped: AminoType {
    public static var typ3: AminoWireType {
        return Wrapped.typ3
    }
}


protocol AminoOptional   {
    var isNil: Bool {get}
}

extension Optional: AminoOptional {
    public var isNil: Bool {
        get {
            switch self {
            case .none:
                return true
            default:
                return false
            }
        }
    }
}



extension Array: AminoList {}


// length as varint
// position << 3 + type byte of bytes
// length of elt encoded as proto3
// elt encoded as proto3
// for all repeated elt, the position is the same


// when elements are scalar numeric types, they are packed
// if empty, then it doesn't appear -> how to differentiate from a nil array elt? nil will take precedence.
// if not empty, it will be


/*
 extension AminoInterfaceEncodable {
 func aminoEncode(to encoder: AminoEncoder) throws {
 guard let hash = ConcreteTypeRegistry.getHash(type(of: self)) else { throw Error.unregisteredConcreteType(type(of: self))}
 encoder.appendBytes(of:hash)
 try self.encode(to: encoder)
 }
 }
 */


extension Array: AminoCodable where Array.Element: Codable & AminoCodable & AminoType {
    public func aminoEncode(to encoder: AminoEncoder, _ position: UInt8?) throws{
        // Packed arrays only appear when not empty
        switch Array.Element.self {
        case _ as AminoScalar.Type: // Packed arrays only appear when not empty
            if let p = position {
                encoder.appendBytes(of: [p])
            }
            if self.count > 0 {
                let enc = AminoEncoder()
                for element in self {
                    try element.aminoEncode(to: enc)
                }
                enc.prependSize()
                encoder.appendBytes(of: enc.bytes)
            }
            
        default:
            if self.count > 0 {
                for element in self {
                    // put key in front of elt
                    if let p = position {
                        encoder.appendBytes(of: [p])
                    }
                    try element.aminoEncode(to: encoder)
                }
            }
        }
    }
    public init(fromAmino aminoDecoder: AminoDecoder, _ position: UInt8?) throws {
        let typ3: UInt8 = UInt8(Element.self.typ3)
        // remove first bytes (0x6 & field_number << 3)
        //let (_, list_typ3) = try aminoDecoder.readPrefix()
        //assert(list_typ3 == 0x6)
        // decode typ3 of element on 1 byte
        //let elt_typ3 = try aminoDecoder.readListType()
        //assert(elt_typ3 == typ3)
        // TODO: this works for packed arrays (ie scalar types). for non packed arrays, every element has the prefix, and the elements may not come in the proper order.
        self.init()
        if Element.self is AminoScalar.Type {
            
            // decode length as varint
            var length: UInt = 0
            try aminoDecoder.readUnsignedVarint(into: &length)

            //self.reserveCapacity(Int(length))
            let start = aminoDecoder.cursor
            while aminoDecoder.cursor < start + Int(length) {
                let decoded = try Element(fromAmino: aminoDecoder)
                self.append(decoded)
            }
        } else if let position = position {
            // TODO: iterate over the decoder to get all elements of the array
            // TODO: need to provide a way to go back for cases where the elements are not contiguous
            var pos = position
            while pos == position {
            // TODO: peek if next one is same position
                //let decoded = try Element(fromAmino: aminoDecoder) // TODO: should use decode<T> form decoder
                let decoded = try aminoDecoder.decode(Element.self)
            // TODO: element decoding expects the pos/type prefix in front so off by 1
            // TODO: the problem is that the struct starts with a length, and then the type. that needs to be handled properly.
            // TODO: element being a struct, it should decode the struct type first instead of going in directly in the content of the struct
            self.append(decoded)
            aminoDecoder.rePin()
            (pos,_) = try aminoDecoder.readPrefix()
            }
            aminoDecoder.reset()
            // TODO: here, go through all remaining aminoDecoder (using a separate cursor) to find all elements
            // TODO: maybe, the aminoDecoder should also reorder the elts such that the keys are in order?
        } else {
            // throw
        }
        
    }
}



extension Bool: AminoCodable {
    public func aminoEncode(to encoder: AminoEncoder) {
        encoder.appendBytes(of: varintEncode(self ? 1 : 0))
    }
    
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        var v: UInt8 = 0
        try aminoDecoder.readUnsignedVarint(into: &v)
        self.init(v != 0)
    }
}


extension Data: AminoCodable, AminoBytes {
    public func aminoEncode(to encoder: AminoEncoder) throws {
        // encode length as varint
        let varint = varintEncode(self.count)
        encoder.appendBytes(of: varint)
        encoder.appendBytes(of: [UInt8](self))
    }
    
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        var length: UInt = 0
        try aminoDecoder.readUnsignedVarint(into: &length)
        // get length bytes from decoder
        var utf8: [UInt8] = []
        for _ in 0..<length {
            var u: UInt8 = 0
            try aminoDecoder.read(into: &u)
            utf8.append(u)
        }
        self = Data(utf8)
    }
}

extension String: AminoCodable, AminoBytes {
    public func aminoEncode(to encoder: AminoEncoder) throws {
        // encode length as varint
        let a = Array(self.utf8)
        let varint = varintEncode(a.count)
        encoder.appendBytes(of: varint)
        encoder.appendBytes(of: a)
        
    }
    
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        // decode length as varint
        var length: UInt = 0
        try aminoDecoder.readUnsignedVarint(into: &length)
        // get length bytes from decoder
        var utf8: [UInt8] = []
        for _ in 0..<length {
            var u: UInt8 = 0
            try aminoDecoder.read(into: &u)
            utf8.append(u)
        }
        if let str = String(bytes: utf8, encoding: .utf8) {
            self = str
        } else {
            throw AminoDecoder.Error.invalidUTF8(utf8)
        }
    }
}

extension FixedWidthInteger where Self: AminoEncodable & SignedInteger & AminoSignedVarint {
    public func aminoEncode(to encoder: AminoEncoder) {
        let a = varintEncode(zigZagEncode(self))
        encoder.appendBytes(of: a)
    }
}

extension FixedWidthInteger where Self: AminoDecodable & SignedInteger & AminoSignedVarint {
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        // process varint (zigZag)
        var v = Self.init()
        try aminoDecoder.readSignedVarint(into: &v)
        self.init(v)
    }
}

extension FixedWidthInteger where Self: AminoEncodable & SignedInteger & AminoVarint {
    public func aminoEncode(to encoder: AminoEncoder) {
        // if negative, convert first to uint{x}
        let u = UInt64(bitPattern: Int64(self))
        let a = varintEncode(u)
        encoder.appendBytes(of: a)
    }
}

extension FixedWidthInteger where Self: AminoDecodable & SignedInteger & AminoVarint {
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        // process varint, but not as zig-zag
        var v = UInt64(0)
        try aminoDecoder.readUnsignedVarint(into: &v)
        // TODO: make sure that the value fits in the type, else throw?
        self.init(truncatingIfNeeded: v)
    }
}

extension FixedWidthInteger where Self: AminoEncodable & UnsignedInteger & AminoVarint {
    public func aminoEncode(to encoder: AminoEncoder) {
        encoder.appendBytes(of: varintEncode(self))
    }
}

extension FixedWidthInteger where Self: AminoDecodable & UnsignedInteger & AminoVarint {
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        // process varint (non zigZag)
        var v = Self.init()
        try aminoDecoder.readUnsignedVarint(into: &v)
        self.init(v)
    }
}

extension FixedWidthInteger where Self: AminoEncodable & Amino4Bytes {
    public func aminoEncode(to encoder: AminoEncoder) {
        encoder.appendBytes(of: self.bigEndian) // TODO: should this not be stored little endian? (https://developers.google.com/protocol-buffers/docs/encoding)
    }
}

extension FixedWidthInteger where Self: AminoDecodable & Amino4Bytes {
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        var v = Self.init()
        try aminoDecoder.read(into: &v)
        self.init(bigEndian: v)
    }
}

extension FixedWidthInteger where Self: AminoEncodable & Amino8Bytes {
    public func aminoEncode(to encoder: AminoEncoder) {
        encoder.appendBytes(of: self.bigEndian) // TODO: should this not be stored little endian? (https://developers.google.com/protocol-buffers/docs/encoding)
    }
}

extension FixedWidthInteger where Self: AminoDecodable & Amino8Bytes {
    public init(fromAmino aminoDecoder: AminoDecoder) throws {
        var v = Self.init()
        try aminoDecoder.read(into: &v)
        self.init(bigEndian: v)
    }
}


extension Int8: AminoSignedVarint & AminoCodable {}
extension UInt8: AminoVarint & AminoCodable {}
extension Int16: AminoSignedVarint & AminoCodable {}
extension UInt16: AminoVarint & AminoCodable {}

extension Int32: AminoVarint & AminoCodable {}
extension UInt32: AminoVarint & AminoCodable {}
extension Int64: AminoVarint & AminoCodable {}
extension UInt64: AminoVarint & AminoCodable {}
extension Int: AminoVarint & AminoCodable {}
extension UInt: AminoVarint & AminoCodable {}

extension Date: AminoTime & AminoCodable {}
