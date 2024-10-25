import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { beginCell, Cell, Slice, toNano } from '@ton/core';
import { AdnlResolver, DNSResolveResult } from '../wrappers/AdnlResolver';
import '@ton/test-utils';
import { sha256_sync } from '@ton/crypto';

describe('AdnlResolver', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let adnlResolver: SandboxContract<AdnlResolver>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        adnlResolver = blockchain.openContract(await AdnlResolver.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await adnlResolver.send(
            deployer.getSender(),
            {
                value: toNano('0.01'),
            },
            beginCell().endCell().asSlice(),
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: adnlResolver.address,
            deploy: true,
            success: true,
        });
    });

    it('should resolve .adnl', async () => {
        const domain = 'xht4zipz2i3yecg3qies3qsnblzdmbcu75sjgrlvfsannnk5g3cdrai\0';

        const answer = await adnlResolver.getDnsresolve(
            beginCell().storeStringTail(domain).endCell().asSlice(),
            BigInt('0x' + sha256_sync('site').toString('hex')),
        );
        const ID = parseAnswer(answer, domain);
        expect(ID).not.toBeNull();
        expect(ID).toBe(0xcf3e650fce91bc1046dc10496e12685791b022a7fb249a2ba96406b5aae9b621n);
    });
    it('should resolve raw', async ()=>{
        const domain = 'cf3e650fce91bc1046dc10496e12685791b022a7fb249a2ba96406b5aae9b621\0';
        const answer = await adnlResolver.getDnsresolve(
            beginCell().storeStringTail(domain).endCell().asSlice(),
            BigInt('0x' + sha256_sync('site').toString('hex')),
        );
        const ID = parseAnswer(answer, domain);
        expect(ID).not.toBeNull();
        expect(ID).toBe(0xcf3e650fce91bc1046dc10496e12685791b022a7fb249a2ba96406b5aae9b621n);

    });
});

function parseAnswer(ans: DNSResolveResult, input: string): bigint | null {
    const {record: answer, prefix} = ans;
    expect(Number(prefix)).toEqual(input.length * 8 );
    if (answer == null) return null;
    const slice = answer.beginParse();
    expect(slice.loadUint(16)).toEqual(0xad01);
    return slice.loadUintBig(256);
}
