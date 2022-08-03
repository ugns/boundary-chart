{{/*
  Generate path to vault certificates
  usage: {{- include "vault.tls.file.path" (dict "File" filename "globalContext" $) -}}
*/}}
{{- define "vault.tls.file.path" -}}
{{- if and .globalContext.Values.vault.tls.secretName .File -}}
{{- printf "/vault/tls/%s" .File | quote -}}
{{- else -}}
""
{{- end -}}
{{- end -}}

{{- define "vault.tls.caCert.file" -}}
{{- include "vault.tls.file.path" (dict "File" (default "ca.crt" .Values.vault.tls.caCertKey) "globalContext" $) -}}
{{- end -}}
{{- define "vault.tls.caPublic.file" -}}
{{- include "vault.tls.file.path" (dict "File" (default "" .Values.vault.tls.caPublicKey) "globalContext" $) -}}
{{- end -}}
{{- define "vault.tls.clientCert.file" -}}
{{- include "vault.tls.file.path" (dict "File" (default "" .Values.vault.tls.clientCertKey) "globalContext" $) -}}
{{- end -}}
{{- define "vault.tls.clientPublic.file" -}}
{{- include "vault.tls.file.path" (dict "File" (default "" .Values.vault.tls.clientPublicKey) "globalContext" $) -}}
{{- end -}}

{{/*
  Create a kms "transit" configuration block
  usage: {{- include "kms.transit.block" (dict kms" . "globalContext" $ ") }}
*/}}
{{- define "kms.transit.block" -}}
{{- $globalContext := .globalContext -}}
{{- $tls := .globalContext.Values.vault.tls -}}
{{- with .kms }}
kms "transit" {
    purpose         = {{ .purpose | quote }}
    address         = {{ $globalContext.Values.vault.address | quote }}
    disable_renewal = {{ default "false" .disableRenewal | quote }}
    key_name        = {{ .keyName | quote }}
    mount_path      = {{ .mountPath | quote }}
    namespace       = {{ default "" .namespace | quote }}
    {{- with $tls }}
    tls_ca_cert     = {{ include "vault.tls.caCert.file" $globalContext }}
    tls_client_cert = {{ include "vault.tls.clientCert.file" $globalContext }}
    tls_client_key  = {{ include "vault.tls.clientPublic.file" $globalContext }}
    tls_server_name = {{ default "" .serverName | quote }}
    tls_skip_verify = {{ default "false" .skipVerify | quote }}
    {{- end }}
}
{{ end }}
{{- end -}}

{{/*
  Handle annotations for vault-agent tls.
*/}}
{{- define "vault.tls.annotations" -}}
{{- with .Values.vault.tls }}
{{- if .secretName -}}
vault.hashicorp.com/tls-secret: {{ .secretName }}
vault.hashicorp.com/ca-cert: {{ include "vault.tls.caCert.file" $ }}
vault.hashicorp.com/ca-key: {{ include "vault.tls.caPublic.file" $ }}
vault.hashicorp.com/client-cert: {{ include "vault.tls.clientCert.file" $ }}
vault.hashicorp.com/client-key: {{ include "vault.tls.clientPublic.file" $ }}
{{- end }} {{/* end of if .secretName */}}
{{- if .serverName }}
vault.hashicorp.com/tls-server-name: {{ default "" .serverName | quote }}
{{- end }}
vault.hashicorp.com/tls-skip-verify: {{ default "false" .skipVerify | quote }}
{{- end }} {{/* end of with */}}
{{- end -}} {{/* end of define */}}

{{/*
  Handle annotations for vault-agent.
*/}}
{{- define "vault-agent.annotations" -}}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/agent-pre-populate-only: "true"
vault.hashicorp.com/agent-cache-enable: "true"
vault.hashicorp.com/service: {{ .Values.vault.address | quote }}
vault.hashicorp.com/role: {{ .Values.vault.role | quote }}
vault.hashicorp.com/agent-inject-token: "true"
{{ include "vault.tls.annotations" . }}
{{- end -}} {{/* end of define */}}

{{- define "vault-agent.template.annotations.database-creds" -}}
{{- $ := .globalContext -}}
vault.hashicorp.com/agent-inject-secret-boundary-database-creds: {{ .VaultPath | quote }}
vault.hashicorp.com/agent-inject-template-boundary-database-creds: |
  {{ printf "{{- with secret \"%s\" -}}" .VaultPath }}
  {{ `postgresql://` }}
  {{- /* Create postgres URI according to vault KV engine version. */}}
  {{ `{{- if and .Data.metadata .Data.data -}}` }}
  {{ `{{- printf "%s:%s" .Data.data.username .Data.data.password }}` }}
  {{ `{{- else -}}` }}
  {{ `{{- printf "%s:%s" .Data.username .Data.password }}` }}
  {{ `{{- end -}}` }}
  {{ printf "@%s:%s/%s" $.Values.database.address (default "5432" $.Values.database.port) (default "boundary" $.Values.database.name) }}{{- if ne $.Values.database.ssl true }}?sslmode=disable{{- end }}
  {{ `{{- end }}` }}
{{- end -}}

{{/*
Handle `boundary database init` options for the boundary-controller initContainer.
*/}}
{{- define "boundary.database.init" -}}
{{- range $option := .Values.controller.initOptions -}}
{{- printf " -%s" $option -}}
{{- end -}}
{{- end -}}

{{/*
Handle the Boundary controller public_cluster_address formatting.
*/}}
{{- define "boundary.controller.cluster_address" -}}
{{- $fullname := include "boundary.fullname" . -}}
{{ default (printf "%s.%s:%d" $fullname .Release.Namespace (.Values.controller.service.ports.cluster.number | int)) .Values.publicClusterAddress }}
{{- end -}}

{{/*
Handle the Boundary controller public_cluster_address formatting.
*/}}
{{- define "boundary.worker.public_address" -}}
{{ default "localhost" .Values.publicAddress }}:{{ default "9202" (.Values.worker.service.ports.proxy.number | int) }}
{{- end -}}

{{/*
Handle configuration of Boundary controller KMS configuration blocks.
*/}}
{{- define "boundary.controller.kms" -}}
{{- if .Values.vault.enabled -}}
{{- range .Values.keys.vault -}}
{{- include "kms.transit.block" (dict "kms" . "globalContext" $ ) }}
{{- end -}}
{{- end -}}

{{- if .Values.aead.enabled -}}
{{- range .Values.keys.aead -}}
kms "aead" {
    purpose   = {{ .purpose | quote }}
    key_id    = {{ default (printf "global_%s" (.purpose)) .id | quote }}
    aead_type = {{ default "aes-gcm" .type |  quote }}
    key       = {{ .key | quote }}
}
{{ end -}}
{{- end -}}

{{- if .Values.awskms.enabled -}}
{{- range .Values.keys.awskms -}}
kms "awskms" {
    purpose    = {{ .purpose | quote }}
    kms_key_id = {{ .kmsKeyId | quote }}
}
{{ end -}}
{{- end -}}
{{- end -}}

{{/*
Handle configuration of Boundary worker KMS configuration blocks.
*/}}
{{- define "boundary.worker.kms" -}}
{{- if .Values.aead.enabled -}}
{{- range .Values.keys.aead -}}
{{- if eq .purpose "worker-auth" -}}
kms "aead" {
    purpose   = {{ .purpose | quote }}
    key_id    = {{ default (printf "global_%s" .purpose) .id | quote }}
    aead_type = {{ default "aes-gcm" .type |  quote }}
    key       = {{ .key | quote }}
}
{{ end -}}
{{- end -}}
{{- end -}}

{{- if .Values.vault.enabled -}}
{{- range .Values.keys.vault -}}
{{- if eq .purpose "worker-auth" -}}
{{- include "kms.transit.block" (dict "kms" . "globalContext" $ ) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- if .Values.awskms.enabled -}}
{{- range .Values.keys.awskms -}}
{{- if eq .purpose "worker-auth" -}}
kms "awskms" {
    purpose    = {{ .purpose | quote }}
    kms_key_id = {{ .kmsKeyId | quote }}
}
{{ end -}}
{{- end -}}
{{- end -}}
{{- end -}}
