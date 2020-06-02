import XCTest
@testable import Amino




protocol NumberItem: AminoCodable {
    var number: Int {get}
}

final class AminoTests: XCTestCase {

    // https://github.com/cybercongress/js-amino/tree/master/test
    /*
     Encode int8(123) 02f601
     Encode int16(12345) 03f2c001
     Encode int32(1234567) 03 87ad4b
     Encode int64(123456789) 04 959aef3a
     */
    /*
     FixedInt{
     Int32(fixed32): 1234567,
     Int64(fixed64):123456789,
     } 0e 0d 87d61200 11 15cd5b0700000000
     */
    /*
     Encode string(teststring유니코드) 17 16 74657374737472696e67ec9ca0eb8b88ecbd94eb939c
     */
    /*
     cdc.RegisterConcrete(SimpleStruct{}, "SimpleStruct", nil)
     SimpleStruct{
     Int8:  123,
     Int16: 12345,
     Int32: 1234567,
     Int64: 123456789,
     Str:   "teststring유니코드",
     } 2c 4a89c4bc 08f601 10f2c001 18 87ad4b   20 959aef3a           2a 16 74657374737472696e67ec9ca0eb8b88ecbd94eb939c

                  08f601 10f2c001 18 8eda9601 20 aab4de75 2a1674657374737472696e67ec9ca0eb8b88ecbd94eb939c

     */
    /*
     []Struct{
     SimpleStruct{
     Int8:  123,
     Int16: 12345,
     Int32: 1234567,
     Int64: 123456789,
     Str:   "teststring유니코드",
     },
     SimpleStruct2{
     Str:   "test",
     }
     } 3a // length of following message
         0a // embedded, field 1 (repeated elt, field 1)
          2c // length of SimpleStruct
           4a89c4bc // SimpleStruct
             08f60110f2c001
             1887ad4b 20959aef3a 2a1674657374737472696e67ec9ca0eb8b88ecbd94eb939c
         0a // embedded, field 1  (repeated elt, field 1)
           0a // length of SimpleStruct2
            d7618abe // SimpleStruct2
             0a0474657374
     */
    
    
    
    // TODO:
    /*
    
     X - test scalar individually (positive and negatives)
     X - test bytes/Data
     - test interfaces in structs
     - test structs in structs
     - test classes in structs
     X - test present optional in structs
     X - test nil optional in structs
     - test time // times seems to be a struct of seconds= Int64, nano=Int32
     X - test bool
     
     X - test Array of Scalars
     - test Array of Interfaces
     - test Array of Structs
     - test Array of Classes (= pointers)
     - test Array of Optionals // how do you represent nil?
     - test empty arrays
     - test decode out of order keys for structs
     - test decode out of order keys for non scalar arrays
     - test decode multiple same keys for strings (should concatenate)
     - test decode multiple same keys for data (should concatenate)
     - test decode override with last value with same key for scalars
     
     - implement test with go-amino
     - implement test from js-amino
    
    */
    
    struct SimpleStruct: AminoCodableInterface {
        let a: Int8
        let b: Int16
        let c: Int32
        let d: Int64
        let e: String
        
        enum CodingKeys: Int, CodingKey {
            case a, b, c, d, e
        }
    }
    
    struct Primitives: AminoCodableInterface {
        var a: Int8
        var b: UInt8
        var c: Int16
        var d: UInt16
        var e: Int32
        var f: UInt32
        var g: Int64
        var h: UInt64
        var i: Int
        var j: UInt
        var k: Bool
        var l: Bool
        
        enum CodingKeys: Int, CodingKey {
            case a, b, c, d, e, f, g, h, i, j, k, l
        }
    }

    class NumberItemClass: AminoCodableInterface {
        let number: Int
        
        enum CodingKeys: Int, CodingKey {
            case number
        }
        
        public init(number: Int) {
            self.number = number
        }
    }
    
    class Item: NumberItemClass {
        override init(number: Int) {
            super.init(number: number)
        }
        
        required init(from decoder: Decoder) throws {
            try super.init(from: decoder)
        }
    }
    
    struct List: AminoCodableInterface   {
        let MyList: [NumberItemClass]
        
        enum CodingKeys: Int, CodingKey {
            case MyList
        }
        
    }
    
    struct WithString: AminoCodableInterface {
        var a: String
        var b: String
        var c: Int
        
        enum CodingKeys: Int, CodingKey {
            case a, b, c
        }
    }
    
    struct WithList: AminoCodableInterface {
        var a: [Int32]
        var b: [String]
        var c: [UInt8]
        
        enum CodingKeys: Int, CodingKey {
            case a, b, c
        }
    }

    struct WithListNillable: AminoCodableInterface {
        var a: Int32
        var b: String?
        var c: UInt?
        
        enum CodingKeys: Int, CodingKey {
            case a, b, c
        }
    }
    struct Company: AminoCodableInterface {
        var name: String
        var employees: [Employee]
        var ceo: Employee
        var cto: Employee?
        
        enum CodingKeys: Int, CodingKey {
            case name, employees, ceo, cto
        }
    }
    
    struct Employee: AminoCodableInterface {
        var name: String
        var jobTitle: String
        var age: Int
        
        enum CodingKeys: Int, CodingKey {
            case name, jobTitle, age
        }
    }
    
    struct ItemStruct: AminoCodableInterface, NumberItem  {
        let number: Int
        
        enum CodingKeys: Int, CodingKey {
            case number
        }
    }
    
    struct ListProtocol: AminoCodableInterface   {
        let MyList: [ItemStruct] // TODO: should be a NumberItem
        
        enum CodingKeys: Int, CodingKey {
            case MyList
        }
        
    }
    
    override func setUp() {
        do {
            try ConcreteTypeRegistry.registerConcrete(SimpleStruct.self, "SimpleStruct")
            try ConcreteTypeRegistry.registerConcrete(Primitives.self)
            try ConcreteTypeRegistry.registerConcrete(NumberItemClass.self)
            try ConcreteTypeRegistry.registerConcrete(Item.self)
            try ConcreteTypeRegistry.registerConcrete(List.self)
            try ConcreteTypeRegistry.registerConcrete(WithString.self)
            try ConcreteTypeRegistry.registerConcrete(WithList.self)
            try ConcreteTypeRegistry.registerConcrete(WithListNillable.self)
            try ConcreteTypeRegistry.registerConcrete(Company.self)
            try ConcreteTypeRegistry.registerConcrete(Employee.self)
            try ConcreteTypeRegistry.registerConcrete(ItemStruct.self)
            try ConcreteTypeRegistry.registerConcrete(ListProtocol.self)

        } catch {
            
        }
        
    }
    
    
    
    
    
    func testSimpleStructEncoding() throws {

        
        
        let s = SimpleStruct(a: 123, b: 12345, c: 1234567, d: 123456789, e: "teststring유니코드")
        let data = try AminoEncoder.encode(s)
        print(data.reduce("", { $0 + String(format: "%02X", $1)}))
        XCTAssertEqual(data, [
            0x2c, 0x4a, 0x89, 0xc4, 0xbc,
            0x8, 0xf6, 0x01,
            0x10, 0xf2, 0xc0, 0x01,
            0x18, 0x87, 0xad, 0x4b,
            0x20, 0x95, 0x9a, 0xef, 0x3a,
            0x2a, 0x16, 0x74, 0x65, 0x73, 0x74, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0xec,0x9c, 0xa0, 0xeb, 0x8b,0x88, 0xec, 0xbd, 0x94, 0xeb, 0x93, 0x9c
            ])
    }
    
    func testStringEncoding() throws {
        let s = "teststring유니코드"
        let data = try AminoEncoder.encode(s)
        XCTAssertEqual(data, [
            0x16, 0x74, 0x65, 0x73, 0x74, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0xec, 0x9c, 0xa0, 0xeb, 0x8b, 0x88, 0xec, 0xbd, 0x94, 0xeb, 0x93, 0x9c
            ])
    }
    
    func testStringDecoding() throws {
        let s = "teststring유니코드"
        let data = try AminoEncoder.encode(s)
        var d: [UInt8] = [0x16, 0x74, 0x65, 0x73, 0x74, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0xec, 0x9c, 0xa0, 0xeb, 0x8b, 0x88, 0xec, 0xbd, 0x94, 0xeb, 0x93, 0x9c]
        d.append(contentsOf: data)
        let decoded = try AminoDecoder.decode(String.self, data: d)
        
        XCTAssertEqual(s, decoded)
    }
    
    func testDataEncoding() throws {
        let s = Data(Array("teststring유니코드".utf8))
        let data = try AminoEncoder.encode(s)
        XCTAssertEqual(data, [
            0x16, 0x74, 0x65, 0x73, 0x74, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0xec, 0x9c, 0xa0, 0xeb, 0x8b, 0x88, 0xec, 0xbd, 0x94, 0xeb, 0x93, 0x9c
            ])
    }
    
    func testDataDecoding() throws {
        let s = Data([UInt8]("teststring유니코드".utf8))
        let data = try AminoEncoder.encode(s)
        var d: [UInt8] = [0x16, 0x74, 0x65, 0x73, 0x74, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0xec, 0x9c, 0xa0, 0xeb, 0x8b, 0x88, 0xec, 0xbd, 0x94, 0xeb, 0x93, 0x9c]
        d.append(contentsOf: data)
        let decoded = try AminoDecoder.decode(Data.self, data: d)
        
        XCTAssertEqual(s, decoded)
    }
    
    func testPrimitiveEncoding() throws {
        let s = Primitives(a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: false, l: true)
        let data = try AminoEncoder.encode(s)
        XCTAssertEqual(data, [
            28,
            113, 193, 12, 131,
            8, 2,
            16, 2,
            24, 6,
            32, 4,
            40, 5,
            48, 6,
            56, 7,
            64, 8,
            72, 9,
            80, 10,
            88, 0, // false
            96, 1 // true
            
            ])
    }
    
    func testPrimitiveNegativeEncoding() throws {
        let s = Primitives(a: -1, b: 2, c: -3, d: 4, e: -5, f: 6, g: -7, h: 8, i: -9, j: 10, k: false, l: true)
        let data = try AminoEncoder.encode(s)
        XCTAssertEqual(data, [
            55,
            113, 193, 12, 131,
            8, 1,
            16, 2,
            24, 5,
            32, 4,
            40, 251, 255, 255, 255, 255, 255, 255, 255, 255, 1,
            48, 6, 56, 249, 255, 255, 255, 255, 255, 255, 255, 255, 1,
            64, 8, 72, 247, 255, 255, 255, 255, 255, 255, 255, 255, 1,
            80, 10,
            88, 0,
            96, 1
            ])
    }
    
    func testPrimitiveDecoding() throws {
        let data: [UInt8] = [
        28,
        113, 193, 12, 131,
        8, 2,
        16, 2,
        24, 6,
        32, 4,
        40, 5,
        48, 6,
        56, 7,
        64, 8,
        72, 9,
        80, 10,
        88, 0, // false
        96, 1 // true
        
        ]
        let s = try AminoDecoder.decode(Primitives.self, data: data)
        XCTAssertEqual(s.a, 1)
        XCTAssertEqual(s.b, 2)
        XCTAssertEqual(s.c, 3)
        XCTAssertEqual(s.d, 4)
        XCTAssertEqual(s.e, 5)
        XCTAssertEqual(s.f, 6)
        XCTAssertEqual(s.g, 7)
        XCTAssertEqual(s.h, 8)
        XCTAssertEqual(s.i, 9)
        XCTAssertEqual(s.j, 10)
        XCTAssertEqual(s.k, false)
        XCTAssertEqual(s.l, true)
    }
    
    func testPrimitiveNegativeDecoding() throws {
        let data: [UInt8] = [
        55,
        113, 193, 12, 131,
        8, 1,
        16, 2,
        24, 5,
        32, 4,
        40, 251, 255, 255, 255, 255, 255, 255, 255, 255, 1,
        48, 6, 56, 249, 255, 255, 255, 255, 255, 255, 255, 255, 1,
        64, 8, 72, 247, 255, 255, 255, 255, 255, 255, 255, 255, 1,
        80, 10,
        88, 0,
        96, 1
        ]
        
        let s = try AminoDecoder.decode(Primitives.self, data: data)
        XCTAssertEqual(s.a, -1)
        XCTAssertEqual(s.b, 2)
        XCTAssertEqual(s.c, -3)
        XCTAssertEqual(s.d, 4)
        XCTAssertEqual(s.e, -5)
        XCTAssertEqual(s.f, 6)
        XCTAssertEqual(s.g, -7)
        XCTAssertEqual(s.h, 8)
        XCTAssertEqual(s.i, -9)
        XCTAssertEqual(s.j, 10)
        XCTAssertEqual(s.k, false)
        XCTAssertEqual(s.l, true)
    }

    func testStringEncode() throws {
        let data = try AminoEncoder.encode(WithString(a: "hello", b: "world", c: 42))
        XCTAssertEqual(data, [
            20,
            174, 152, 148, 34,
            10, 5, 104, 101, 108, 108, 111,
            18, 5, 119, 111, 114, 108, 100,
            24, 42
        ])
    }

    
    func testStringDecode() throws {
        let data: [UInt8] = [
            20,
            174, 152, 148, 34,
            10, 5, 104, 101, 108, 108, 111,
            18, 5, 119, 111, 114, 108, 100,
            24, 42
        ]
        let s = try AminoDecoder.decode(WithString.self, data: data)
        XCTAssertEqual(s.a, "hello")
        XCTAssertEqual(s.b, "world")
        XCTAssertEqual(s.c, 42)
    }
    
    func testStringRoundTrip() throws {
        AssertRoundtrip(WithString(a: "hello", b: "world", c: 42))
    }
    
    func testArrayNoNillableEncode() throws {
        let data = try AminoEncoder.encode(WithList(a: [-1,0,1] , b: ["hello", "world"], c: [1,2,3]))
        XCTAssertEqual(data, [
            37, 43, 67, 21, 39,

            10, 12, // a
                255, 255, 255, 255, 255, 255, 255, 255, 255, 1,
                0,
                1,
            18, //b
                5, 104, 101, 108, 108, 111,
            18,
                5, 119, 111, 114, 108, 100,
            26, 3, // c
                1,
                2,
                3
        ])
    }
    
    func testArrayNoNillableDecode() throws {
        let data: [UInt8] = [
            37, 43, 67, 21, 39,

            10, 12, // a
                255, 255, 255, 255, 255, 255, 255, 255, 255, 1,
                0,
                1,
            18, //b
                5, 104, 101, 108, 108, 111,
            18,
                5, 119, 111, 114, 108, 100,
            26, 3, // c
                1,
                2,
                3
        ]
        let s = try AminoDecoder.decode(WithList.self, data: data)
        
        XCTAssertEqual(s.a[0], -1)
        XCTAssertEqual(s.a[1], 0)
        XCTAssertEqual(s.a[2], 1)
        XCTAssertEqual(s.b[0], "hello")
        XCTAssertEqual(s.b[1], "world")
        XCTAssertEqual(s.c[0], 1)
        XCTAssertEqual(s.c[1], 2)
        XCTAssertEqual(s.c[2], 3)
    }
    
    func testArrayNoNillableRoundTrip() throws {
        AssertRoundtrip(WithList(a: [-1,0,1], b: ["hello", "world"], c: [1,2,3]))
    }
    
    
    func testStructWithNillableEncode() throws {
        let data = try AminoEncoder.encode(WithListNillable(a: 1, b: nil, c: 1))
        XCTAssertEqual(data, [8, 150, 30, 210, 70,// 8 bytes length, struct hash
            8, 1, // Int32(1)
            // String at pos 2 is nil
            24, // Varint, pos 3
            1, // UInt(1)
            ])
    }
    
    func testStructWithNillableDecode() throws {
        let data: [UInt8] = [8, 150, 30, 210, 70,// 8 bytes length, struct hash
        8, 1, // Int32(1)
        // String at pos 2 is nil
        24, // Varint, pos 3
        1, // UInt(1)
        ]
        
        let s = try AminoDecoder.decode(WithListNillable.self, data: data)
        
        XCTAssertEqual(s.a, 1)
        XCTAssertEqual(s.b, nil)
        XCTAssertEqual(s.c, 1)

    }
    
    func testZigZagEncoding() {
        XCTAssertEqual(zigZagEncode(128), 256)
        XCTAssertEqual(zigZagEncode(-128), 255)
    }
    
    func testZigZagDecoding() {
        XCTAssertEqual(zigZagDecode(UInt(256)), 128)
        XCTAssertEqual(zigZagDecode(UInt(255)), -128)
    }
    
    func testZigZagRoundTrip() {
        XCTAssertEqual(zigZagDecode(zigZagEncode(128)), 128)
        XCTAssertEqual(zigZagDecode(zigZagEncode(-128)), -128)
        XCTAssertEqual(zigZagEncode(zigZagDecode(UInt(128))), 128)
        XCTAssertEqual(zigZagEncode(zigZagDecode(UInt(255))), 255)
    }
    
    func testVarintEncoding() {
        XCTAssertEqual(varintEncode(1), [0b00000001])
        XCTAssertEqual(varintEncode(UInt(18446744073709551611)), [251, 255, 255, 255, 255, 255, 255, 255, 255, 1])
        XCTAssertEqual(varintEncode(300), [0b10101100, 0b00000010])
    }
    
    func testVarintDecoding() {
        XCTAssertEqual(1, varintDecode([0b00000001]))
        XCTAssertEqual(UInt64(18446744073709551611), varintDecode([251, 255, 255, 255, 255, 255, 255, 255, 255, 1]))
        XCTAssertEqual(300, varintDecode([0b10101100, 0b00000010]))

    }
    
    func testVarintRoundTrip() {
        XCTAssertEqual([0b00000001], varintEncode(varintDecode([0b00000001])))
        XCTAssertEqual([0b10101100, 0b00000010], varintEncode(varintDecode([0b10101100, 0b00000010])))
        XCTAssertEqual(1, varintDecode(varintEncode(1)))
        XCTAssertEqual(300, varintDecode(varintEncode(300)))
        XCTAssertEqual(3000000000, varintDecode(varintEncode(3000000000)))
    }
    
    func testComplexStructEncode() throws {
        let company = Company(name: "a", employees: [
            Employee(name: "b", jobTitle: "c", age: 1),
            Employee(name: "d", jobTitle: "e", age: 1),
            Employee(name: "f", jobTitle: "g", age: 1),
            Employee(name: "g", jobTitle: "h", age: 1),
            ], ceo: Employee(name: "i", jobTitle: "j", age: 1),
               cto: nil
)
        let data = try AminoEncoder.encode(company)
        XCTAssertEqual(data, [77,
                                                            
                              200, 121, 115, 77, // Company struct hash
                              
                              10, 1, 97, // name
                              18, 12, 106, 87, 3, 39, // employees[0]
                                10, 1, 98,
                                18, 1, 99,
                                24, 1,
                              18, 12, 106, 87, 3, 39, // employees[1]
                                10, 1, 100,
                                18, 1, 101,
                                24, 1,
                              18, 12, 106, 87, 3, 39, // employees[2]
                                10, 1, 102,
                                18, 1, 103,
                                24, 1,
                              
                              18, 12, 106, 87, 3, 39, // employees[3]
                                10, 1, 103,
                                18, 1, 104,
                                24, 1,
                              26, 12, 106, 87, 3, 39, // ceo
                                10, 1, 105,
                                18, 1, 106,
                                24, 1
                                // cto is nil
                            ]
        )
    }
    
    func testComplexStructDecode() throws {
        XCTAssertTrue(false, "Not working")
        //return
        let data: [UInt8] = [77,
                                      
        200, 121, 115, 77, // Company struct hash
        
        10, 1, 97, // name
        18, 12, 106, 87, 3, 39, // employees[0]
          10, 1, 98,
          18, 1, 99,
          24, 1,
        18, 12, 106, 87, 3, 39, // employees[1]
          10, 1, 100,
          18, 1, 101,
          24, 1,
        18, 12, 106, 87, 3, 39, // employees[2]
          10, 1, 102,
          18, 1, 103,
          24, 1,
        
        18, 12, 106, 87, 3, 39, // employees[3]
          10, 1, 103,
          18, 1, 104,
          24, 1,
        26, 12, 106, 87, 3, 39, // ceo
          10, 1, 105,
          18, 1, 106,
          24, 1]
        
        let s = try AminoDecoder.decode(Company.self, data: data)
        
        XCTAssertEqual(s.name, "a")
        XCTAssertEqual(s.employees[0].name, "b")
        XCTAssertEqual(s.employees[0].jobTitle, "c")
        XCTAssertEqual(s.employees[0].age, 1)
        XCTAssertEqual(s.employees[1].name, "d")
        XCTAssertEqual(s.employees[1].jobTitle, "e")
        XCTAssertEqual(s.employees[1].age, 1)
        XCTAssertEqual(s.employees[2].name, "f")
        XCTAssertEqual(s.employees[2].jobTitle, "g")
        XCTAssertEqual(s.employees[2].age, 1)
        XCTAssertEqual(s.employees[3].name, "g")
        XCTAssertEqual(s.employees[3].jobTitle, "h")
        XCTAssertEqual(s.employees[3].age, 1)
        XCTAssertEqual(s.ceo.name, "i")
        XCTAssertEqual(s.ceo.jobTitle, "j")
        XCTAssertEqual(s.ceo.age, 1)
        XCTAssertNil(s.cto)
    }
    
    func testInterfaceProtocolEncode() throws {
        XCTAssertTrue(false, "Not implemented")
        let data = try AminoEncoder.encode(ListProtocol(MyList: [ItemStruct(number: 1), ItemStruct(number: 3)]))
        XCTAssertEqual(data, [10, 1, 97,
                              22, 3, 4,
                              10, 1, 98, 18, 1, 99, 24, 2, 4,
                              10, 1, 100, 18, 1, 101, 24, 2, 4,
                              10, 1, 102, 18, 1, 103, 24, 2, 4,
                              10, 1, 103, 18, 1, 104, 24, 2, 4,
                              27, 10, 1, 105, 18, 1, 106, 24, 2, 4,
                              4])

    
        XCTAssertTrue(false, "Not implemented")
    }
 
    func testInterfaceProtocolDecode() {
        XCTAssertTrue(false, "Not implemented")
    }
    
    func testInterfaceClassEncode() throws {
        XCTAssertTrue(false, "Not implemented")
        let data = try AminoEncoder.encode(List(MyList: [Item(number: 1), Item(number: 3)]))
        XCTAssertEqual(data, [10, 1, 97,
                              22, 3, 4,
                              10, 1, 98, 18, 1, 99, 24, 2, 4,
                              10, 1, 100, 18, 1, 101, 24, 2, 4,
                              10, 1, 102, 18, 1, 103, 24, 2, 4,
                              10, 1, 103, 18, 1, 104, 24, 2, 4,
                              27, 10, 1, 105, 18, 1, 106, 24, 2, 4,
                              4])
        
    }
    
    
    func testInterfaceClassDecode() {
        XCTAssertTrue(false, "Not implemented")
    }


    static var allTests = [
        ("testSimpleStructEncoding", testSimpleStructEncoding),
        ("testStringEncoding", testStringEncoding),
        ("testStringDecoding", testStringDecoding),
        ("testDataEncoding", testDataEncoding),
        ("testDataDecoding", testDataDecoding),
        ("testPrimitiveEncoding", testPrimitiveEncoding),
        ("testPrimitiveNegativeEncoding", testPrimitiveNegativeEncoding),
        ("testPrimitiveDecoding", testPrimitiveDecoding),
        ("testPrimitiveNegativeDecoding", testPrimitiveNegativeDecoding),
        ("testStringEncode", testStringEncode),
        ("testStringDecode", testStringDecode),
        ("testStringRoundTrip", testStringRoundTrip),
        ("testArrayNoNillableEncode", testArrayNoNillableEncode),
        ("testArrayNoNillableDecode", testArrayNoNillableDecode),
        ("testArrayNoNillableRoundTrip", testArrayNoNillableRoundTrip),
        ("testStructWithNillableEncode", testStructWithNillableEncode),
        ("testStructWithNillableDecode", testStructWithNillableDecode),
        ("testZigZagEncoding", testZigZagEncoding),
        ("testZigZagDecoding", testZigZagDecoding),
        ("testZigZagRoundTrip", testZigZagRoundTrip),
        ("testVarintEncoding", testVarintEncoding),
        ("testVarintDecoding", testVarintDecoding),
        ("testVarintRoundTrip", testVarintRoundTrip),
        ("testComplexStructEncode", testComplexStructEncode),
        ("testComplexStructDecode", testComplexStructDecode),
        ("testInterfaceProtocolEncode", testInterfaceProtocolEncode),
        ("testInterfaceProtocolDecode", testInterfaceProtocolDecode),
        ("testInterfaceClassEncode", testInterfaceClassEncode),
        ("testInterfaceClassDecode", testInterfaceClassDecode),
    ]
}


private func AssertEqual<T>(_ lhs: T, _ rhs: T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(String(describing: lhs), String(describing: rhs), file: file, line: line)
}

private func AssertRoundtrip<T: AminoCodable>(_ original: T, file: StaticString = #file, line: UInt = #line) {
    do {
        let data = try AminoEncoder.encode(original)
        let roundtripped = try AminoDecoder.decode(T.self, data: data)
        AssertEqual(original, roundtripped, file: file, line: line)
    } catch {
        XCTFail("Unexpected error: \(error)", file: file, line: line)
    }
}


