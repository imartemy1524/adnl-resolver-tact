import "@stdlib/deploy";
import "@stdlib/dns";
import "./utils.tact";
contract AdnlResolver with DNSResolver {

    init() {
    }
    override fun doResolveDNS(subdomain: Slice, category: Int): DNSResolveResult{
        try{
            let subdomainLength = dnsExtractTopDomainLength(subdomain);
            //resolve adnl.
            if(subdomainLength == 4*8){
                return DNSResolveResult{
                    prefix: 4*8,
                    record: dnsResolveNext(myAddress())
                }
            }
            else{
                let prefix = subdomain.bits();
                let ans: Int = 0;
                // hex representation of adnl
                if (subdomainLength == 64*8){
                    ans = subdomain.asString().cellFromHex().beginParse().loadUint(256);
                }
                // base32 + representation of adnl
                if(subdomainLength == 55*8){
                    ans = decodeRawAdnl(subdomain.asString());
                }
                if ans == 0 {
                    return DNSResolveResult{prefix: 0, record: null};
                }
                let dict: map<Int as uint256, Cell> = emptyMap();
                dict.set(sha256("site"), dnsResolveWebsiteADNL(ans));
                let record = category == 0 ? dict.asCell(): dict.get(category);
                return DNSResolveResult{ prefix, record};
            }

        }catch(e){
            dump(beginComment().concat("Error: ").concat(e.toString()).toCell());
            return DNSResolveResult{prefix: subdomain.bits(), record: null};
        }
    }
    receive(m: Slice){}

}
