inst_table = {
    "ADD"   : "0101",
    "SUB"   : "0110",
    "LOAD"  : "0100",
    "STORE" : "0011",
    "JUMP"   : "1"
}

space_table = {
    "code"   : 128,
    "unused" : 112,
    "data"   :  16
}

fields_table = {
    "opcode"  : 4,
    "address" : 4,
    "jump"    : 7
}
