## to look into:
- when are collision prefix bytes appended? (interfaces and concrete types)

## sources
- https://github.com/tendermint/go-amino/blob/master/README.md
- https://developers.google.com/protocol-buffers/docs/encoding



## 
All naked types are prefixed by the size of the type

## Type prefix

Typ3 | Meaning          | Used For
---- | ---------------- | --------
0    | Varint           | bool, byte, [u]int16, and varint-[u]int[64/32]
1    | 8-Byte           | int64, uint64, float64(unsafe)
2    | Byte-Length      | string, bytes, raw?
5    | 4-Byte           | int32, uint32, float32(unsafe)


The type prefix is encoded on the 3 LSB of the first byte encoding the value
The first 5 MSB are used to encode the position of the field in the encoded structure


## Varint
type prefix: 0
for every byte, the MSB is used to know whether there are more bytes to come (set to 1) or not (set to 0).
the number is encoded usind the 7 LSB
the encoding uses the ZigZag encoding (https://developers.google.com/protocol-buffers/docs/encoding#signed-integers)
`(n << 1) ^ (n >> 31)` or `(n << 1) ^ (n >> 63)`

## 8-Byte
type prefix: 1
value is encoded on next 8 bytes

## Bytes-Length
type prefix: 2
then length of item is encoded as a varint (see above)
then the hex encoded data

## Struct
type is prefixed by size of struct
then if not anonymous struct, it has the type of the struct/class o n 7 or 4 bytes

For each item in the struct, encode as a standalone field, where the position of the field is relative to the enclosing structure `(field_number << 3) | type`

A nil struct field is not encoded at all (no position, no value).

## 4-Byte
type prefix: 5
value is encoded on next 4 bytes

## List

if not scalar type
if list is part of a struct, all elements are prefixed by their type + field number << 3
if list is not part of a struct, additional size of above in front of above

if scalar type
first prefix with length of all elements
each element encoded, without their length prefix

--
- items are always prefixed by their length




-- 
Messages/bytes


optionals
no occurence = nil



repeated fields = lists/array
multiple fields with same key
appear in correct order, may be interceded by other fields (ie not always consecutive)

scalar types are packed, ie:
key = field number, wire type
payload size (in bytes)
elt1
elt2
eltn


non scalar types
