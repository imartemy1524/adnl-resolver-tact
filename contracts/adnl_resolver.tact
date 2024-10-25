import "@stdlib/deploy";
import "@stdlib/dns";
inline fun base32DigitToNumber(digit: Int): Int {
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
        if (byte >= 97 && byte <= 122) {
            result = result.storeUint(byte - 32, 8);
        } else {
            result = result.storeUint(byte, 8);
        }
    }
    return result.asSlice().asString();
}
inline fun decodeRawAdnl(data: String): Cell{
    // Base32 decode
    let realBase32 = beginString().concat("F").concat(data.upper()).toSlice();
    dump(realBase32.asString());
    let ans = beginCell();
    repeat(realBase32.bits()/(8*8)) {
        let block0 = base32DigitToNumber(realBase32.loadUint(8));
        let block1 = base32DigitToNumber(realBase32.loadUint(8));
        let block2 = base32DigitToNumber(realBase32.loadUint(8));
        let block3 = base32DigitToNumber(realBase32.loadUint(8));
        let block4 = base32DigitToNumber(realBase32.loadUint(8));
        let block5 = base32DigitToNumber(realBase32.loadUint(8));
        let block6 = base32DigitToNumber(realBase32.loadUint(8));
        let block7 = base32DigitToNumber(realBase32.loadUint(8));
        let byte1 = (block0 << 3) | (block1 >> 2);
        let byte2 = ((block1 & 3) << 6) | (block2 << 1) | (block3 >> 4);
        let byte3 = ((block3 & 15) << 4) | (block4 >> 1);
        let byte4 = ((block4 & 1) << 7) | (block5 << 2) | (block6 >> 3);
        let byte5 = ((block6 & 7) << 5) | block7;
        ans = ans.storeUint(byte1, 8)
            .storeUint(byte2, 8)
            .storeUint(byte3, 8)
            .storeUint(byte4, 8)
            .storeUint(byte5, 8);
//        dump(ans.asSlice().asString());
    }
    let notCropped = ans.endCell();
    let g = notCropped.asSlice();
    g.skipBits(8);
    let final = g.loadBits(32*8);
    return final.asCell();
}
inline fun decodeSerialized(data: Slice, category: Int): DNSResolveResult {
    let length = data.bits();
    if (length == 55){
        let result = beginCell()
            .storeSlice(data)
            .endCell();
        return DNSResolveResult{prefix: 55, record: result};
    }
    return DNSResolveResult{prefix: 0, record: null};
}
//def digit_to_value(hex_digit):
//    # Convert a single hex digit to its corresponding integer value
//    if '0' <= hex_digit <= '9':
//        return ord(hex_digit) - ord('0')
//    elif 'A' <= hex_digit <= 'F':
//        return ord(hex_digit) - ord('A') + 10
//    elif 'a' <= hex_digit <= 'f':
//        return ord(hex_digit) - ord('a') + 10
//    else:
//        raise ValueError(f"Invalid hex digit: {hex_digit}")
inline fun hexStringToDigit(hex_digit: Int): Int {
    if (hex_digit >= 48 && hex_digit <= 57) {
        return hex_digit - 48;
    }
    if (hex_digit >= 65 && hex_digit <= 70) {
        return hex_digit - 65 + 10;
    }
    if (hex_digit >= 97 && hex_digit <= 102) {
        return hex_digit - 97 + 10;
    }
    dump("ERROR");
    return 0;
}
extends inline fun cellFromHex(self: String): Cell {
    let binary = self.asSlice();
    let result = beginCell();
    repeat((binary.bits()/16)) {
        let byteA = binary.loadUint(8);
        let byteB = binary.loadUint(8);
        let value = (hexStringToDigit(byteA) << 4) | hexStringToDigit(byteB);
        result = result.storeUint(value, 8);
    }
    return result.endCell();
}
contract AdnlResolver with Deployable, DNSResolver {

    init() {

    }
    override fun doResolveDNS(subdomain: Slice, category: Int): DNSResolveResult{
        let length = (subdomain.bits() - 8) / 8;
        if (length == 55){
//            return decodeSerialized(subdomain.loadBits(55*8), category);
        }
        return DNSResolveResult{prefix: 0, record: null};
    }
    get fun decodeHexAdnl(data: String): Cell {
        return data.cellFromHex();
    }
    get fun decodeRawAdnl(data: String): Cell {
       return decodeRawAdnl(data);
    }

}
