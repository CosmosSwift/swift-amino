//
//  Varint.swift
//  swift-amino
//


import Foundation


// ZigZag encoding
internal func zigZagEncode<T: SignedInteger>(_ n: T) -> UInt {
    let num = Int64(n) // FIX: there is a problem here, needs to be checked
    let size = MemoryLayout<UInt>.size
    return UInt((num << 1) ^ (num >> (size * 8 - 1)))
}

// ZigZag decoding
internal func zigZagDecode<T: UnsignedInteger>(_ n: T) -> Int {
    switch n % 2 {
    case 0:
        return Int(n >> 1)
    default:
        return -Int((n + 1) >> 1)
    }
}


// VarintEncode
internal func varintEncode<T: FixedWidthInteger>(_ n: T) -> [UInt8] {
    var u = UInt64(n)
    var a = [UInt8]()
    while (u != 0) {
        a.append(UInt8(u % 128))
        u = u >> 7
    }
    if (a.count == 0) { a.append(0x0) }
    for i in 0..<a.count - 1 {
        a[i] = a[i] ^ (1 << 7)
    }
    return a
}

// VarintDecode
internal func varintDecode(_ array: [UInt8]) -> UInt64 {
    assert(array.count < 11)
    var res: UInt64 = 0
    for i in 0..<array.count {
        res = res << 7  + UInt64(array[array.count-i-1] & 127)
    }
    return res
}


