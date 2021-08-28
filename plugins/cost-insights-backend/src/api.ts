import { DiscoveryApi } from '@backstage/core';
import {
    Alert,
    Cost,
    CostInsightsApi, Entity,
    Group,
    MetricData,
    ProductInsightsOptions,
    Project,
    ProjectGrowthAlert,
    UnlabeledDataflowAlert,
    // KubernetesMigrationAlert, // FIXME - Not Exported in plugin-cost-insights index.d.ts
} from "@backstage/plugin-cost-insights";

type Options = {
    discoveryApi: DiscoveryApi;
    proxyPathBase?: string;
};

type Date = {
    date: string;
}

type Groups = {
    groups: Group[];
}

type Projects = {
    projects: Project[];
}

type Alerts = {
    alerts: any[];
}

export class FetchError extends Error {
    get name(): string {
        return this.constructor.name;
    }

    static async forResponse(resp: Response): Promise<FetchError> {
        return new FetchError(
            `Request failed with status code ${
                resp.status
            }.\nReason: ${await resp.text()}`,
        );
    }
}

export class CostInsightsClient implements CostInsightsApi {
    private readonly discoveryApi: DiscoveryApi;
    private readonly proxyPathBase: string | undefined;

    constructor(options: Options) {
        this.discoveryApi = options.discoveryApi;
        this.proxyPathBase = options.proxyPathBase ?? '' // Default if undefined;
    }

    private async getApiUrl( path: string) {
        const proxyUrl = await this.discoveryApi.getBaseUrl('proxy');
        return `${proxyUrl}${this.proxyPathBase}/cost-insights-plugin/cost-insights-backend/v1/${path}`;
    }

    // private request(_: any, res: any): Promise<any> {
    //     return new Promise(resolve => setTimeout(resolve, 0, res));
    // }

    private async fetch<T = any>(input: string, init?: RequestInit): Promise<T> {
        const url = await this.getApiUrl(input);
        const resp = await fetch(url, init);
        if (!resp.ok) throw await FetchError.forResponse(resp);
        return await resp.json();
    }

    private async getDate(resp: Promise<Date>): Promise<string> {
        return await resp.then((resp) => resp.date);
    }

    getLastCompleteBillingDate(): Promise<string> {
        return this.getDate(this.fetch<Date>(
            'last_complete_billing_date',
        ));
    }

    private async getGroups(resp: Promise<Groups>): Promise<Group[]> {
        return await resp.then((resp) => resp.groups);
    }

    async getUserGroups(userId: string): Promise<Group[]> {
        const params = new URLSearchParams();
        if (typeof userId === 'string') params.append('user_id', userId);
        return this.getGroups(this.fetch<Groups>(
            `user_groups?${params.toString()}`,
        ));
    }

    private async getProjects(resp: Promise<Projects>): Promise<Project[]> {
        return await resp.then((resp) => resp.projects);
    }

    async getGroupProjects(group: string): Promise<Project[]> {
        const params = new URLSearchParams();
        if (typeof group === 'string') params.append('group', group);
        return this.getProjects(this.fetch<Projects>(
            `group_projects?${params.toString()}`,
        ));
    }

    async getDailyMetricData(
        metric: string,
        intervals: string,
    ): Promise<MetricData> {
        const params = new URLSearchParams();
        if (typeof metric === 'string') params.append('metric', metric);
        if (typeof intervals === 'string') params.append('intervals', intervals);
        return this.fetch<MetricData>(
            `daily_metric_data?${params.toString()}`,
        );
    }

    async getGroupDailyCost(
        group: string,
        intervals: string,
    ): Promise<Cost> {
        const params = new URLSearchParams();
        if (typeof group === 'string') params.append('group', group);
        if (typeof intervals === 'string') params.append('intervals', intervals);
        return this.fetch<Cost>(
            `group_daily_cost?${params.toString()}`,
        );
    }

    async getProjectDailyCost(project: string, intervals: string): Promise<Cost> {
        const params = new URLSearchParams();
        if (typeof project === 'string') params.append('project', project);
        if (typeof intervals === 'string') params.append('intervals', intervals);
        return this.fetch<Cost>(
            `group_daily_cost?${params.toString()}`,
        );
    }

    async getProductInsights(options: ProductInsightsOptions): Promise<Entity> {
        const params = new URLSearchParams();
        if ('product' in options) {
            if (typeof options.product === 'string') params.append('product', options.product);
        }
        if ('project' in options) {
            if (typeof options.project === 'string') params.append('project', options.project);
        }
        if ('group' in options) {
            if (typeof options.group === 'string') params.append('project', options.group);
        }
        if ('intervals' in options) {
            if (typeof options.intervals === 'string') params.append('intervals', options.intervals);
        }
        return this.fetch<Entity>(
            `product_insights?${params.toString()}`,
        );
    }

    private async getBackendAlerts(resp: Promise<Alerts>): Promise<Alert[]> {
        return await resp.then((resp) => {
            return resp.alerts.map((alert) => {
                switch(alert.type) {
                    case 'ProjectGrowthAlert':
                        const growthAlert = new ProjectGrowthAlert(alert);
                        return(growthAlert);
                    case 'UnlabeledDataflowAlert':
                        return(new UnlabeledDataflowAlert(alert));
                    // TODO - Put this back in when it is exported.
                    // case 'KubernetesMigrationAlert':
                    //     return(alert);
                    default:
                        return(alert);
                }
            });
        });
    }

    async getAlerts(group: string): Promise<Alert[]> {
        const params = new URLSearchParams();
        if (typeof group === 'string') params.append('group', group);
        return this.getBackendAlerts(this.fetch<Alerts>(
            `alerts?${params.toString()}`,
        ));
    }
}
