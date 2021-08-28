import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { costInsightsBackendPlugin, CostInsightsBackendPage } from '../src/plugin';

createDevApp()
  .registerPlugin(costInsightsBackendPlugin)
  .addPage({
    element: <CostInsightsBackendPage />,
    title: 'Root Page',
    path: '/cost-insights-backend'
  })
  .render();
