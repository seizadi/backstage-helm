import {
  ScmIntegrationsApi, scmIntegrationsApiRef
} from '@backstage/integration-react';
import { AnyApiFactory, configApiRef, createApiFactory } from '@backstage/core-plugin-api';
import { ExampleCostInsightsClient, costInsightsApiRef } from '@backstage/plugin-cost-insights';
// export class CostInsightsClient implements CostInsightsApi { ... }

export const apis: AnyApiFactory[] = [
  createApiFactory({
    api: scmIntegrationsApiRef,
    deps: { configApi: configApiRef },
    factory: ({ configApi }) => ScmIntegrationsApi.fromConfig(configApi),
  }),
  createApiFactory(costInsightsApiRef, new ExampleCostInsightsClient()),

  // createApiFactory({
  //   api: costInsightsApiRef,
  //   deps: {},
  //   factory: () => new CostInsightsClient(),
  // }),
];

