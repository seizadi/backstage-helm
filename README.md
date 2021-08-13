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

## Building front-end and backend

The following steps are common to building both the front-end and the backend parts and MUST be run from the project root:
```sh
yarn install
yarn tsc
yarn build
```

### Front-end
Make sure that the following line is uncommented in the `.dockerignore` file:
   
   `!packages/app/dist`

Run the following command to build the backend:
```sh
docker build -t backstage-frontend -f Dockerfile.hostbuild .
```

### Backend
Make sure that the following line is commented out in the `.dockerignore` file:

   `!packages/app/dist`

Run the following command to build the backend:
```sh
yarn build-image
```

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
This is a strange problem, I looked at the helm files and everything looked right!
I setup port-forward and tested it with psql and I was able to reproduce the
same problem that backstage server was encourtering:
```bash
❯ k port-forward backstage-postgresql-0 5432:5432
Forwarding from 127.0.0.1:5432 -> 5432
```
```bash
❯ psql --username=backend-user --password --host=localhost -d backstage_plugin_catalog
Password:
psql: error: FATAL:  password authentication failed for user "backend-user"
FATAL:  password authentication failed for user "backend-user"
```
You get the password from postgres secret:
```bash
❯ k get secret backstage-postgresql -o yaml
apiVersion: v1
data:
  postgresql-password: a0tSYXppRnR6VA==
kind: Secret
...

❯ echo a0tSYXppRnR6VA== | base64 --decode
kKRaziFtzT
```
It did not make sense and I was able with the same value file configuration bring up just
the database and nothing else, so I decided to rerun the same helm chart a
second time and this time it worked fine!
```bash
❯ psql --username=backend-user --password --host=localhost -d backstage_plugin_catalog
Password:
psql (13.3, server 11.9)
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

backstage_plugin_catalog=> exit
```

Now I tried to bringup the WebUI:
```bash
❯ curl http://demo.example.com
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
```
I noticed front-end is disabled in the default configruation:
```yaml
frontend:
  enabled: false
```
I endabled it and now you can see the WebUI:
```html
❯ curl http://demo.example.com
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1"/>
    <meta name="theme-color" content="#000000"/>
....
```
