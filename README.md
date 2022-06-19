# Hashicorp Boundary

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=for-the-badge)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge)
![AppVersion: 0.8.1](https://img.shields.io/badge/AppVersion-0.8.1-informational?style=for-the-badge)

## Description

A Helm chart for Hashicorp Boundary deployment

## Usage
<fill out>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aead.enabled | bool | `true` |  |
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| awskms.enabled | bool | `false` |  |
| controller.ingress.annotations | object | `{}` |  |
| controller.ingress.className | string | `""` |  |
| controller.ingress.enabled | bool | `false` |  |
| controller.ingress.hosts[0].host | string | `"boundary.local"` |  |
| controller.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| controller.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| controller.ingress.hosts[0].paths[0].port | string | `"api"` |  |
| controller.ingress.tls | list | `[]` |  |
| controller.initOptions | string | `nil` |  |
| controller.service.ports.api.number | int | `9200` |  |
| controller.service.ports.cluster.number | int | `9201` |  |
| controller.service.type | string | `"ClusterIP"` |  |
| database.address | string | `"postgresql"` |  |
| database.name | string | `"boundary"` |  |
| database.password | string | `"postgres"` |  |
| database.ssl | bool | `false` |  |
| database.username | string | `"postgres"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"hashicorp/boundary"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| keys.aead | string | `nil` |  |
| keys.awskms | string | `nil` |  |
| keys.vault | string | `nil` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecrets | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| vault.address | string | `"https://vault:8200"` |  |
| vault.database.enabled | bool | `false` |  |
| vault.database.role | string | `"boundary"` |  |
| vault.database.vaultAdminCredPath | string | `"database/static-creds/boundary-db"` |  |
| vault.database.vaultCredPath | string | `"database/creds/boundary-db"` |  |
| vault.enabled | bool | `false` |  |
| worker.ingress.annotations | object | `{}` |  |
| worker.ingress.className | string | `""` |  |
| worker.ingress.enabled | bool | `false` |  |
| worker.ingress.hosts[0].host | string | `"boundary.local"` |  |
| worker.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| worker.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| worker.ingress.hosts[0].paths[0].port | string | `"proxy"` |  |
| worker.ingress.tls | list | `[]` |  |
| worker.service.ports.proxy.number | int | `9202` |  |
| worker.service.type | string | `"ClusterIP"` |  |

**Homepage:** <https://boundaryproject.io>

## Source Code

* <https://github.com/hashicorp/boundary>
* <https://github.com/ugns/boundary-chart>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Jeremy T. Bouse | <Jeremy.Bouse@UnderGrid.net> | <https://undergrid.net> |
