import { toNano } from '@ton/core';
import { AdnlResolver } from '../wrappers/AdnlResolver';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const adnlResolver = provider.open(await AdnlResolver.fromInit(BigInt(Math.floor(Math.random() * 10000))));

    await adnlResolver.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(adnlResolver.address);

    console.log('ID', await adnlResolver.getId());
}
