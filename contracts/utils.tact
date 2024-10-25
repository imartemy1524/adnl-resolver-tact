struct DNSPointerToWebsiteADNL{
    code: Int as uint16;
    //domain name ADNL
    domain: Int as uint256;
    flags: Int as uint8;
}

fun base32DigitToNumber(digit: Int): Int {
    if (digit >= 65 && digit <= 90) {
        return digit - 65;
    }
    if (digit >= 50 && digit <= 55) {
        return digit - 24;
    }
    require(false, "Invalid base32 digit");
    return 0;
}
extends inline fun upper(self: String): String {
    let result = beginCell();
    let binary = self.asSlice();
    repeat(binary.bits()/8) {
        let byte = binary.loadUint(8);
        result = result.storeUint(byte >= 97 && byte <= 122?byte - 32:byte, 8);
    }
    return result.asSlice().asString();
}
inline fun decodeRawAdnl(data: String): Int{
    // Base32 decode
//    let realBase32 = beginString().concat("F").concat(data.upper()).toSlice();
    let realBase32 = beginCell().storeUint(70, 8).storeSlice(data.upper().asSlice()).asSlice();
    let ans = beginCell();
    repeat(realBase32.bits()/(8*8)) {

        ans = ans.storeUint((base32DigitToNumber(realBase32.loadUint(8)) << 3) | (base32DigitToNumber(realBase32.preloadUint(8)) >> 2), 8)
                .storeUint(((base32DigitToNumber(realBase32.loadUint(8)) & 3) << 6) | (base32DigitToNumber(realBase32.loadUint(8)) << 1) | (base32DigitToNumber(realBase32.preloadUint(8)) >> 4), 8)
                .storeUint(((base32DigitToNumber(realBase32.loadUint(8)) & 15) << 4) | (base32DigitToNumber(realBase32.preloadUint(8)) >> 1), 8)
                .storeUint(((base32DigitToNumber(realBase32.loadUint(8)) & 1) << 7) | (base32DigitToNumber(realBase32.loadUint(8)) << 2) | (base32DigitToNumber(realBase32.preloadUint(8)) >> 3), 8)
                .storeUint(((base32DigitToNumber(realBase32.loadUint(8)) & 7) << 5) | base32DigitToNumber(realBase32.loadUint(8)), 8);

    }
//    let notCropped = ans.endCell();
    let g = ans.asSlice();
    g.skipBits(8);
    return g.loadUint(256);
}
inline fun hexStringToDigit(ascii: Int): Int {
    // 0-9
    if (ascii >= 48 && ascii <= 57) {
        return ascii - 48;
    }
    // A-F
    if (ascii >= 65 && ascii <= 70) {
        return ascii - 65 + 10;
    }
    // a-f
    if (ascii >= 97 && ascii <= 102) {
        return ascii - 97 + 10;
    }
    require(false, "Invalid hex digit");

    return 0;
}
extends inline fun cellFromHex(self: String): Cell {
    let binary = self.asSlice();
    let result = beginCell();
    repeat((binary.bits()/8)-1){
        result = result.storeUint(hexStringToDigit(binary.loadUint(8)), 4);
    }
    return result.endCell();
}


inline fun dnsResolveWebsiteADNL(name: Int): Cell{
    return DNSPointerToWebsiteADNL{code: 0xad01, domain: name, flags: 0}.toCell();
}