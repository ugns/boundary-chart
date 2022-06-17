{{/*
Handle `boundary databse init` options for the boundary-controller initContainer.
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
{{- $address := .Values.vault.address -}}
{{- $tls := .Values.vault.tls -}}
{{- range .Values.keys.vault -}}
kms "transit" {
    purpose         = {{ .purpose | quote }}
    address         = {{ $address | quote }}
    disable_renewal = {{ default "false" .disableRenewal | quote }}
    key_name        = {{ .keyName | quote }}
    mount_path      = {{ .mountPath | quote }}
    namespace       = {{ default "" .namespace | quote }}
{{- with $tls -}}
    tls_ca_cert     = {{ default "" .caCert | quote }}
    tls_client_cert = {{ default "" .clientCert | quote }}
    tls_client_key  = {{ default "" .clientKey | quote }}
    tls_server_name = {{ default "" .serverName | quote }}
    tls_skip_verify = {{ default "false" .skipVerify | quote }}
{{- end -}}
}
{{ end -}}
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
{{- $address := .Values.vault.address -}}
{{- $tls := .Values.vault.tls -}}
{{- range .Values.keys.vault -}}
{{- if eq .purpose "worker-auth" -}}
kms "transit" {
    purpose         = {{ .purpose | quote }}
    address         = {{ $address | quote }}
    disable_renewal = {{ default "false" .disableRenewal | quote }}
    key_name        = {{ .keyName | quote }}
    mount_path      = {{ .mountPath | quote }}
    namespace       = {{ default "" .namespace | quote }}
{{- with $tls -}}
    tls_ca_cert     = {{ default "" .caCert | quote }}
    tls_client_cert = {{ default "" .clientCert | quote }}
    tls_client_key  = {{ default "" .clientKey | quote }}
    tls_server_name = {{ default "" .serverName | quote }}
    tls_skip_verify = {{ default "false" .skipVerify | quote }}
{{- end -}}
}
{{ end -}}
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
