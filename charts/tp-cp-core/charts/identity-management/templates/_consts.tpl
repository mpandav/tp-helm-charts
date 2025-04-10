{{/*
    Copyright © 2024. Cloud Software Group, Inc.
    This file is subject to the license terms contained
    in the license file that is distributed with this file.
*/}}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "tp-identity-management.consts.appName" }}tp-identity-management{{ end -}}

{{/* Component we're a part of. */}}
{{- define "tp-identity-management.consts.component" }}cp{{ end -}}

{{/* Team we're a part of. */}}
{{- define "tp-identity-management.consts.team" }}tp-cp{{ end -}}

{{/* Namespace we're going into. */}}
{{- define "tp-identity-management.consts.namespace" }}{{ .Release.Namespace }}{{ end -}}

{{- define "tp-identity-management.cic-env-configmap" }}cp-env{{ end -}}
{{- define "tp-identity-management.consts.cp-db-configuration" }}provider-cp-database-config{{ end -}}

{{- define "tp-control-plane-env-configmap" }}tp-cp-core-env{{ end -}}
{{- define "tp-control-plane-dnsdomain-configmap" }}tp-cp-core-dnsdomains{{ end -}}

{{/* Control plane environment configuration. This will have shared configuration used across control plane components. */}}
{{- define "cp-env" -}}
{{- $data := (lookup "v1" "ConfigMap" .Release.Namespace "cp-env") }}
{{- $data | toYaml }}
{{- end }}

{{/* Get control plane environment configuration value from a key. key = key name in configmap, default = If key not found or configmap does not exist then the return default  */}}
{{/* required = if this key is mandatory or not, Release = get cm namespace from inbuilt .Release object */}}
{{/* usage =  include "cp-env.get" (dict "key" "CP_SERVICE_ACCOUNT_NAME" "default" "control-plane-sa" "required" "true"  "Release" .Release )  */}}
{{- define "cp-env.get" }}
{{- $cm := ((include "cp-env" .)| fromYaml) }}
{{- if $cm }} {{- /* configmap exists */ -}}
  {{- if (hasKey $cm "data") }}
    {{- if (hasKey $cm.data .key) }}
      {{- $val := (get $cm.data .key) }}
      {{- $val }}
    {{- else -}} {{- /* key does not exists */ -}}
       {{- if eq .required "true" }}{{ fail (printf "%s missing key in configmap cp-env" .key)}}{{ else }}{{ .default }}{{ end }}
    {{- end -}}
  {{- else -}}{{- /* data key does not exists */ -}}
    {{- if eq .required "true" }}{{ fail (printf "data key missing in configmap cp-env")}}{{ else }}{{ .default }}{{ end }}
  {{- end }}
{{- else }} {{- /* configmap does not exists */ -}}
    {{- if eq .required "true" }}{{ fail (printf "missing configmap cp-env")}}{{ else }}{{ .default }}{{ end }}
{{- end }}
{{- end }}

{{/* Container registry for control plane. default value empty */}}
{{- define "cp-core-configuration.container-registry" }}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY" "default" "" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* set repository based on the registry url. We will have different repo for each one. */}}
{{- define "cp-core-configuration.image-repository" -}}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_REPO" "default" "tibco-platform-docker-prod" "required" "false" "Release" .Release )}}
{{- end -}}

{{- define "cp-core-configuration.container-registry.secret" }}
  {{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_IMAGE_PULL_SECRET_NAME" "default" "" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane DNS domain. default value cp1 */}}
{{- define "cp-core-configuration.cp-dns-domain" }}
  {{- include "cp-env.get" (dict "key" "CP_DNS_DOMAIN" "default" "cp1" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane instance Id. default value cp1 */}}
{{- define "cp-core-configuration.cp-instance-id" }}
  {{- include "cp-env.get" (dict "key" "CP_INSTANCE_ID" "default" "cp1" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* PVC configured for control plane. Fail if the pvc not exist */}}
{{- define "cp-core-configuration.pvc-name" }}
{{- if .Values.pvcName }}
  {{- .Values.pvcName }}
{{- else }}
{{- include "cp-env.get" (dict "key" "CP_PVC_NAME" "default" "control-plane-pvc" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{- define "cp-core-bootstrap.otel.services" -}}
{{- "otel-services" }}
{{- end }}

{{- define "cp-core-configuration.enableLogging" }}
  {{- $isEnableLogging := "" -}}
    {{- if eq "true" (include "cp-env.get" (dict "key" "CP_LOGGING_FLUENTBIT_ENABLED" "default" "true" "required" "false"  "Release" .Release )) -}}
        {{- $isEnableLogging = "1" -}}
    {{- end -}}
  {{ $isEnableLogging }}
{{- end }}

{{- define "identity-management.client-id-secret-key" }}
{{- if eq .Values.global.tibco.self_hosted_deployment true }}
    {{- "identity-management-client-id-secret-key" }}
{{- else }}
    {{- "tp-identity-management-idps-conf-override" }}
{{- end }}
{{- end }}

{{- define "identity-management-jwt-key-store-password" }}
{{- if eq .Values.global.tibco.self_hosted_deployment true }}
    {{- "identity-management-jwt-key-store-password" }}
{{- else }}
    {{- "tp-identity-management-idps-conf-override" }}
{{- end }}
{{- end }}

{{- define "identity-management-sp-key-store-password" }}
{{- if eq .Values.global.tibco.self_hosted_deployment true }}
    {{- "identity-management-sp-key-store-password" }}
{{- else }}
    {{- "tp-identity-management-idps-conf-override" }}
{{- end }}
{{- end }}

{{- define "identity-management-jwt-keystore-url" }}
{{- if eq .Values.global.tibco.self_hosted_deployment true }}
    {{- "identity-management-jwt-keystore-url" }}
{{- else }}
    {{- "tp-identity-management-idps-conf-override" }}
{{- end }}
{{- end }}
