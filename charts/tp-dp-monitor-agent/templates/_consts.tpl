{{/*
Copyright © 2023-2024. Cloud Software Group, Inc.
This file is subject to the license terms contained
in the license file that is distributed with this file.
*/}}

{{/* A fixed short name for the application. Can be different than the chart name */}}
{{- define "tp-dp-monitor-agent.consts.appName" }}tp-dp-monitor-agent{{ end -}}

{{/* Tenant name. */}}
{{- define "tp-dp-monitor-agent.consts.tenantName" }}finops{{ end -}}

{{/* Component we're a part of. */}}
{{- define "tp-dp-monitor-agent.consts.component" }}finops{{ end -}}

{{/* Team we're a part of. */}}
{{- define "tp-dp-monitor-agent.consts.team" }}tp-finops{{ end -}}

{{- define "tp-dp-monitor-agent.image.registry" }}
  {{- .Values.global.cp.containerRegistry.url }}
{{- end -}}
 
{{/* set repository to the global value. */}}
{{- define "tp-dp-monitor-agent.image.repository" -}}
  {{- .Values.global.cp.containerRegistry.repository }}
{{- end -}}