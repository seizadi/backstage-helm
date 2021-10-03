backend:
  lighthouseHostname: {{ include "lighthouse.serviceName" . | quote }}
  listen:
      port: {{ .Values.appConfig.backend.listen.port | default 7000 }}
  database:
    client: {{ .Values.appConfig.backend.database.client | quote }}
    connection:
      host: {{ include "backend.postgresql.host" . | quote }}
      port: {{ include "backend.postgresql.port" . | quote }}
      user: {{ include "backend.postgresql.user" . | quote }}
      database: {{ .Values.appConfig.backend.database.connection.database | quote }}
      ssl:
        rejectUnauthorized: {{ .Values.appConfig.backend.database.connection.ssl.rejectUnauthorized | quote }}
        ca: {{ include "backstage.backend.postgresCaFilename" . | quote }}

catalog:
  rules:
    - allow: [Component, System, API, Group, User, Resource, Location]
{{- if .Values.backend.demoData }}
  locations:
    # Backstage example components
    - type: url
      target: https://github.com/backstage/backstage/blob/master/packages/catalog-model/examples/all-components.yaml

    # Backstage example systems
    - type: url
      target: https://github.com/backstage/backstage/blob/master/packages/catalog-model/examples/all-systems.yaml

    # Backstage example APIs
    - type: url
      target: https://github.com/backstage/backstage/blob/master/packages/catalog-model/examples/all-apis.yaml

    # Backstage example resources
    - type: url
      target: https://github.com/backstage/backstage/blob/master/packages/catalog-model/examples/all-resources.yaml

    # Backstage example organization groups
    - type: url
      target: https://github.com/backstage/backstage/blob/master/packages/catalog-model/examples/acme/org.yaml

    # Backstage example templates
    - type: url
      target: https://github.com/backstage/software-templates/blob/main/scaffolder-templates/react-ssr-template/template.yaml
      rules:
        - allow: [Template]
    - type: url
      target: https://github.com/backstage/software-templates/blob/main/scaffolder-templates/springboot-grpc-template/template.yaml
      rules:
        - allow: [Template]
    - type: url
      target: https://github.com/spotify/cookiecutter-golang/blob/master/template.yaml
      rules:
        - allow: [Template]
    - type: url
      target: https://github.com/backstage/software-templates/blob/main/scaffolder-templates/docs-template/template.yaml
      rules:
        - allow: [Template]
{{- else }}
  locations: []
{{- end }}

auth:
  providers:
    microsoft: null

scaffolder:
  azure: null


sentry:
  organization: {{ .Values.appConfig.sentry.organization | quote }}

techdocs:
  generators:
    techdocs: 'local'

costInsights:
  engineerCost: 200000
  products:
# Google Cloud Products
#    computeEngine:
#      name: Compute Engine
#      icon: compute
#    cloudDataflow:
#      name: Cloud Dataflow
#      icon: data
#    cloudStorage:
#      name: Cloud Storage
#      icon: storage
#    bigQuery:
#      name: BigQuery
#      icon: search
#    events:
#      name: Events
#      icon: data
    # AWS Services
    EC2:
      name: EC2
      icon: compute
    EC2Other:
      name: EC2-Other
      icon: data
    S3:
      name: S3
      icon: storage
    RDS:
      name: RDS
      icon: database
    DynamoDB:
      name: DynamoDB
      icon: database
    ElasticSearch:
      name: ElasticSearch
      icon: search
    CloudWatch:
      name: CloudWatch
      icon: data
    CloudTrail:
      name: CloudTrail
      icon: data
    ELB:
      name: ELB
      icon: compute
    EMR:
      name: EMR
      icon: ml
    MSK:
      name: Managed Kafka
      icon: data
    Lambda:
      name: Lambda
      icon: compute
    SQS:
      name: SQS
      icon: data
    SNS:
      name: SNS
      icon: data
  metrics:
    DAR:
      name: Daily Average Requests
      default: true
    DAC:
      name: Daily Active Clients
    BudgetTotal:
      name: Target Cost Total Budget

# FIXME - Add template to add clusters here
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - url: http://127.0.0.1:63867
          name: kind-kind
          authProvider: 'serviceAccount'
          skipTLSVerify: true
          serviceAccountToken: eyJhbGciOiJSUzI1NiIsImtpZCI6IjVyVzEyOGhMVXMxQmJ0V19Fb1dJNXZiT0RzZ3dMRDg3VE53aTJfN0VRYVUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC10b2tlbi14anBzdyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6Ijg3NGFkYjNjLTY0MDctNDAzMS1hYmUxLTg5YmRlYzIzNGI2MSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDprdWJlcm5ldGVzLWRhc2hib2FyZCJ9.gjPg1j1SS0fK8zolKO1jjIvxgSpyb5Cy9ikN5LoUy_mk98-Zzw06RRIg3SH2w4MEtM1cM_maWfF3hwbVWm269LvGX5AxXvu7remKGhN6yWq4i7kUoJS12CsqX2C4mRwwX68fWlMjU5z_HEtHUwc4f5BtOGGYYSnvJ9eVFBw_Z1Dt9QNY7_86FhjgFz-yBWBcg1LN2nW9QKhaodZP6kWZG6Eco0EhzOYUR_9dfVzGUsWRiaSwKWmDw6FAJ3bYesKdnGAJT94QozW1j-zOc_p1JdFk-Bbabz1oZ8VXdyThCglLedprnhv-eOnvGyziD6yQnq-886v7IpkZrU64DQIK4Q
#          dashboardUrl: http://127.0.0.1:4713 # for kind kubectl -n kubernetes-dashboard port-forward deploy/kubernetes-dashboard 4713:443
#          dashboardApp: standard
