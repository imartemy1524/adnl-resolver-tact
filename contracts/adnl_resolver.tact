import "@stdlib/deploy";
import "@stdlib/dns";
import "./utils.tact";
contract AdnlResolver with DNSResolver {

    init() {
    }
    override fun doResolveDNS(subdomain: Slice, category: Int): DNSResolveResult{
        let length = (subdomain.bits() - 8) / 8;
        try{
            let ans: Int = 0;
            // hex representation of adnl
            if (length == 64){
                ans = subdomain.asString().cellFromHex().beginParse().loadUint(256);
            }
            // base32 + representation of adnl
            if(length == 55){
                ans = decodeRawAdnl(subdomain.asString()).beginParse().loadUint(256);
            }
            if ans == 0{
                return DNSResolveResult{
                prefix: 0, record: null};
            }
            let dict: map<Int as uint256, Cell> = emptyMap();
            dict.set(sha256("site"), dnsResolveWebsiteADNL(ans));

            let record = category == 0 ?  dict.asCell(): dict.get(category);
            return DNSResolveResult{
            prefix: subdomain.bits(), record};
        }catch(e){
            dump(beginComment().concat("Error: ").concat(e.toString()).toCell());
            return DNSResolveResult{prefix: subdomain.bits(), record: null};
        }
    }
    receive(m: Slice){}

}
