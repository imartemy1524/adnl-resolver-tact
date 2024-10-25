import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { AdnlResolver } from '../wrappers/AdnlResolver';
import '@ton/test-utils';

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
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: adnlResolver.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        const first = await  adnlResolver.getDecodeRawAdnl('xht4zipz2i3yecg3qies3qsnblzdmbcu75sjgrlvfsannnk5g3cdrai\0');
        const second = await adnlResolver.getDecodeHexAdnl('cf3e650fce91bc1046dc10496e12685791b022a7fb249a2ba96406b5aae9b621\0');
        const ans = first.beginParse().loadBuffer(first.bits.length/8);
        const ans2 = second.beginParse().loadBuffer(second.bits.length/8);
        expect(ans.toString('hex')).toEqual(ans2.toString('hex'));
        expect(ans.toString('hex')).toBe('cf3e650fce91bc1046dc10496e12685791b022a7fb249a2ba96406b5aae9b621')
    });


});
