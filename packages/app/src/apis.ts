import {
  ScmIntegrationsApi, scmIntegrationsApiRef
} from '@backstage/integration-react';
import { AnyApiFactory, configApiRef, createApiFactory, discoveryApiRef } from '@backstage/core-plugin-api';
import { costInsightsApiRef } from '@backstage/plugin-cost-insights';
import { CostInsightsClient } from '@internal/plugin-cost-insights-backend';

// const alert = new ExampleCostInsightsClient().getAlerts('pied-piper').then((value) => console.log(value));
export const apis: AnyApiFactory[] = [
  createApiFactory({
    api: scmIntegrationsApiRef,
    deps: { configApi: configApiRef },
    factory: ({ configApi }) => ScmIntegrationsApi.fromConfig(configApi),
  }),
 // createApiFactory(costInsightsApiRef, new ExampleCostInsightsClient()),
  createApiFactory({
    api: costInsightsApiRef,
    deps: { discoveryApi: discoveryApiRef },
    factory: ({ discoveryApi }) => new CostInsightsClient({ discoveryApi }),
  }),
];

