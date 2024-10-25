import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/adnl_resolver.tact',
    options: {
        debug: false,
    },
};
