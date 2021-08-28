import { CostInsightsClient } from './api';

describe('cost-insights-api', () => {
    it('should export plugin', () => {
        expect(CostInsightsClient).toBeDefined();
    });
});
