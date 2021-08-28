import {createApiFactory, createPlugin, discoveryApiRef} from '@backstage/core';
import { costInsightsApiRef } from '@backstage/plugin-cost-insights';
import {CostInsightsClient} from "./api";

export const costInsightsBackendPlugin = createPlugin({
    id: 'cost-insights-backend-plugin',
    apis: [
        createApiFactory({
            api: costInsightsApiRef,
            deps: { discoveryApi: discoveryApiRef },
            factory: ({ discoveryApi }) => new CostInsightsClient({ discoveryApi }),
        }),
    ],
});

