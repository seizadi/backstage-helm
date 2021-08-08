# [Backstage](https://backstage.io)

This is your newly scaffolded Backstage App, Good Luck!

To start the app, run:

```sh
yarn install
yarn dev
```

Thing left to do:
   * Test helm chart
   * Set up the software catalog: https://backstage.io/docs/features/software-catalog/configuration
   * Add authentication: https://backstage.io/docs/auth/

## Testing Helm Chart

   * Download helm chart from backstage repo: https://github.com/backstage/backstage/tree/master/contrib/chart/backstage
```sh
mkdir repo; cd repo
wget https://github.com/backstage/backstage/tree/master/contrib/chart/backstage
```
Rebuild charts directory:
```sh
cd backstage
helm dependency build
kubectl create namespace backstage
helm install -n backstage backstage .
```

Update Ingress to use updated API schema:
```yaml
apiVersion: networking.k8s.io/v1
```

Create namespace backstage and run the chart:
```bash
k create namesapce backstage
helm install -n backstage backstage .
```

Fails Auth:
```bash
❯ k get pods
NAME                                    READY   STATUS             RESTARTS   AGE
backstage-backend-c6c854d77-nfq5c       0/1     CrashLoopBackOff   2          71s
backstage-lighthouse-57cbd987cf-pqhtm   0/1     Error              2          71s
backstage-postgresql-0                  1/1     Running            0          71s

❯ k logs backstage-backend-c6c854d77-nfq5c
2021-08-07T06:00:38.529Z backstage info Loaded config from app-config.yaml, app-config.development.yaml, env 
2021-08-07T06:00:38.541Z backstage info Created UrlReader predicateMux{readers=azure{host=dev.azure.com,authed=true},bitbucket{host=bitbucket.org,authed=false},github{host=github.com,authed=true},gitlab{host=gitlab.com,authed=true},fetch{} 
Backend failed to start up error: password authentication failed for user "backend-user"
```
