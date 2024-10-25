import { beginCell, toNano } from '@ton/core';
import { AdnlResolver } from '../wrappers/AdnlResolver';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const adnlResolver = provider.open(await AdnlResolver.fromInit());

    await adnlResolver.send(
        provider.sender(),
        {
            value: toNano('0.01'),
        },
        beginCell().endCell().asSlice(),
    );

    await provider.waitForDeploy(adnlResolver.address);

}
