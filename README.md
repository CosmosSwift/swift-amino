# swift-amino

Swift implementation of https://github.com/tendermint/go-amino/

This is work in progress, which was put on hold until there is more clarity on Amino. As of late 2019, the direction for Amino seems to be full compatibility with proto3, so we will hold off making any further changes unless required by the CosmosSwift project.

currently: 
- Interfaces not handled
- float and doubles not handled
- dictionaries not handled
- timestamps are not handled


TODO:
- add handling of interfaces and concrete types
- add handling of timestamps

- move back to proto3 format: remove groups, interfaces
- there is a problem with varint for int8, int16 (in the zigzag function)
- when struct types are registered as Amino compliant, they should automatically register themselves
