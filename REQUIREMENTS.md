##### REQUIREMENTS.md

# SAP Master Data Quality Checker

> Documento de requerimientos diseñado para un proyecto demostrativo de portfolio profesional SAP.
> El objetivo es evidenciar criterio funcional, dominio técnico ABAP/SAP y buenas prácticas de ingeniería aplicadas a la calidad de datos maestros dentro de entornos SAP R/3 y SAP S/4HANA.

---

## 1. Overview

### Project Name

SAP Master Data Quality Checker

### Purpose

Herramienta de análisis, validación y scoring de calidad de datos maestros SAP para materiales, clientes, proveedores y Business Partners.

### Target Audience

- Technical Recruiters
- SAP Functional Consultants
- SAP ABAP Developers
- SAP Data Migration Specialists
- SAP MDG Consultants
- SAP Architects
- SAP S/4HANA Transformation Teams

### Business Problem

La calidad deficiente de datos maestros es una de las principales causas de:

- Errores en procesos logísticos.
- Errores durante migraciones SAP.
- Problemas de integración.
- Inconsistencias financieras.
- Rechazos en procesos EDI.
- Datos duplicados.
- Incremento de costos operativos.

### Core Objectives

- Detectar registros incompletos.
- Identificar inconsistencias funcionales.
- Detectar potenciales duplicados.
- Calcular métricas de calidad.
- Generar score de completitud.
- Facilitar data cleansing previo a migraciones.
- Demostrar conocimiento funcional y técnico SAP.

### SAP Functional Scope

#### MM

- Material Master

#### SD

- Customer Master

#### FI

- Customer Accounting Data
- Vendor Accounting Data

#### Procurement

- Vendor Master

#### Master Data Governance

- Data Quality
- Data Cleansing
- Data Migration

---

## 2. Core Principles (Non-Negotiable)

### Business Value First

La herramienta debe entregar resultados accionables para equipos funcionales.

### Explainable Results

Toda observación debe indicar:

- Qué campo presenta un problema.
- Por qué es un problema.
- Cómo corregirlo.

### SAP Standard First

Utilizar tablas estándar SAP siempre que sea posible.

### Configurable Rules

Las reglas no deben estar hardcodeadas.

### Security First

Toda consulta debe respetar autorizaciones SAP.

### Cloud & S/4HANA Ready

La solución debe poder evolucionar hacia:

- CDS Views
- Fiori
- RAP
- SAP BTP

### Performance Driven

Los análisis deben ejecutarse sobre volúmenes elevados de datos.

### Clean ABAP

Código moderno y mantenible.

---

## 3. Engineering Standards & ABAP Development Guidelines

### 3.1 Software Engineering

- SOLID
- DRY
- KISS
- YAGNI
- Low Coupling
- High Cohesion
- Separation of Concerns
- Dependency Injection

### 3.2 Clean ABAP

#### Naming

- Nombres descriptivos
- Orientados al negocio

#### Classes

- Responsabilidad única

#### Methods

- Máximo una responsabilidad

#### Constants

- Obligatorias para valores fijos

#### Exceptions

- Basadas en clases

#### Testing

- ABAP Unit obligatorio

### 3.3 Performance Standards

#### Database Access

Prohibido:

```abap
SELECT ...
  INTO ...
  ENDSELECT.
```

Requerido:

```abap
SELECT ...
 INTO TABLE ...
```

#### Rules

- Evitar SELECT dentro de LOOP.
- Evitar SELECT *.
- Utilizar índices estándar.
- Aplicar filtros tempranos.
- Procesar en paquetes para grandes volúmenes.

### 3.4 Security Standards

- AUTHORITY-CHECK obligatorio.
- Sin acceso no autorizado a datos maestros.
- Logging de ejecuciones.
- Protección de datos personales.
- No almacenar información sensible.

### 3.5 Quality Gates

- ATC
- SCI
- ABAP Unit
- Peer Review
- Pull Request Review

---

## 4. System Architecture

### 4.1 Presentation Layer

#### R/3

- ALV Grid
- SALV

#### S/4HANA

- SAPUI5
- Fiori Elements
- Analytical List Page

### 4.2 Application Layer

#### Components

- Rule Engine
- Scoring Engine
- Duplicate Detection Engine
- Reporting Engine
- Export Service

### 4.3 Data Layer

#### Material Master

- MARA
- MAKT
- MARC
- MARD
- MVKE

#### Customer Master

- KNA1
- KNB1
- KNVV

#### Vendor Master

- LFA1
- LFB1
- LFM1

#### S/4HANA

- BUT000
- BUT020
- BUT0ID
- Business Partner Tables

### 4.4 Integration Layer

- OData
- CDS Views
- RAP (future)

---

## 5. Functional Requirements

### Material Validation

#### FR-001

Detectar materiales sin descripción.

#### FR-002

Detectar materiales sin unidad base.

#### FR-003

Detectar materiales sin grupo de artículos.

#### FR-004

Detectar materiales sin centro asignado.

#### FR-005

Detectar materiales sin datos comerciales.

#### FR-006

Detectar materiales bloqueados.

#### FR-007

Detectar materiales obsoletos.

#### FR-008

Detectar materiales duplicados por descripción.

#### FR-009

Detectar materiales sin clasificación.

#### FR-010

Detectar materiales sin peso o dimensiones.

---

### Customer Validation

#### FR-011

Detectar clientes sin nombre.

#### FR-012

Detectar clientes sin dirección.

#### FR-013

Detectar clientes sin país.

#### FR-014

Detectar clientes sin tax id.

#### FR-015

Detectar clientes sin condiciones de pago.

#### FR-016

Detectar clientes sin organización de ventas.

#### FR-017

Detectar clientes bloqueados.

#### FR-018

Detectar clientes potencialmente duplicados.

#### FR-019

Detectar clientes sin email.

#### FR-020

Detectar clientes sin clasificación comercial.

---

### Vendor Validation

#### FR-021

Detectar proveedores sin tax id.

#### FR-022

Detectar proveedores sin datos de pago.

#### FR-023

Detectar proveedores sin dirección.

#### FR-024

Detectar proveedores duplicados.

#### FR-025

Detectar proveedores bloqueados.

#### FR-026

Detectar proveedores sin organización de compras.

#### FR-027

Detectar proveedores sin clasificación.

#### FR-028

Detectar proveedores sin email.

---

### Rule Engine

#### FR-029

Permitir activar o desactivar reglas.

#### FR-030

Permitir definir severidades.

#### FR-031

Permitir mantenimiento por customizing.

#### FR-032

Permitir agrupar reglas.

#### FR-033

Permitir reglas por objeto de negocio.

---

### Quality Score

#### FR-034

Calcular score por registro.

#### FR-035

Calcular score por objeto.

#### FR-036

Calcular score global.

#### FR-037

Clasificar score:

- Excellent
- Good
- Fair
- Poor
- Critical

#### FR-038

Generar ranking de problemas.

---

### Reporting

#### FR-039

Generar dashboard.

#### FR-040

Generar ALV.

#### FR-041

Exportar Excel.

#### FR-042

Exportar CSV.

#### FR-043

Mostrar resumen ejecutivo.

#### FR-044

Mostrar detalle técnico.

---

### Execution Modes

#### FR-045

Ejecución online.

#### FR-046

Ejecución batch.

#### FR-047

Ejecución por variante.

#### FR-048

Historial de ejecuciones.

---

## 6. Non-Functional Requirements

### NFR-001

Procesar más de 100.000 registros.

### NFR-002

Diseño extensible.

### NFR-003

Configuración desacoplada.

### NFR-004

Sin modificación de datos maestros.

### NFR-005

Modo read-only.

### NFR-006

Trazabilidad completa.

### NFR-007

Logs persistentes.

### NFR-008

Recuperación ante errores.

### NFR-009

Compatibilidad R/3.

### NFR-010

Compatibilidad S/4HANA.

### NFR-011

Sin dumps.

### NFR-012

Documentación obligatoria.

---

## 7. Front-End Architecture

### ALV Report

Funciones:

- Sorting
- Filtering
- Grouping
- Totals
- Export

### Fiori App

Funciones:

- Dashboard
- Quality KPIs
- Drill-down
- Charts
- Risk Indicators

---

## 8. Back-End Architecture

### Main Classes

#### ZCL_MDQ_RULE_ENGINE

Responsable de validaciones.

#### ZCL_MDQ_SCORING_ENGINE

Responsable de scoring.

#### ZCL_MDQ_DUPLICATE_ENGINE

Responsable de duplicados.

#### ZCL_MDQ_REPOSITORY

Acceso a datos.

#### ZCL_MDQ_REPORT_SERVICE

Generación de reportes.

#### ZCL_MDQ_AUTH_SERVICE

Autorizaciones.

#### ZCL_MDQ_EXPORT_SERVICE

Exportaciones.

---

### Customizing Tables

#### ZMDQ_RULE

Reglas.

#### ZMDQ_SEVERITY

Severidades.

#### ZMDQ_SCORE_RANGE

Rangos de scoring.

#### ZMDQ_EXECUTION_LOG

Historial.

---

## 9. Data Model

### Core Entities

- MaterialMaster
- CustomerMaster
- VendorMaster
- QualityRule
- ValidationResult
- QualityScore
- DuplicateFinding
- ExecutionRun

### Relationships

```text
Execution Run
    |
    +---- Validation Result
               |
               +---- Quality Rule
               |
               +---- Master Data Object

Quality Score
    |
    +---- Validation Result
```

---

## 10. Repository Structure

```text
02-sap-master-data-quality-checker/
├── README.md
├── REQUIREMENTS.md
├── docs/
│   ├── architecture.md
│   ├── functional-flow.md
│   ├── data-model.md
│   ├── testing.md
│   ├── security.md
│   └── screenshots/
├── abap/
├── frontend/
├── integration/
├── data/
└── .github/
```

---

## 11. DevOps & Infrastructure

- GitHub Actions
- abapGit
- ATC Automation
- Static Analysis
- Semantic Versioning
- Conventional Commits

---

## 12. SBOM

- SAP NetWeaver
- SAP S/4HANA
- ABAP OO
- ABAP Unit
- CDS Views
- OData
- SAPUI5
- Fiori Elements

---

## 13. Key Rules

- Read-Only Only.
- No Productive Data.
- No Credentials.
- Security First.
- Explainable Findings.
- Configurable Rules.
- Clean ABAP Mandatory.

---

## 14. Future Enhancements

- SAP MDG Integration
- SAP Migration Cockpit Integration
- SAP Information Steward Integration
- SAP Data Services Integration
- SAP BTP Extension
- AI-based Duplicate Detection
- Machine Learning Quality Predictions
- SAC Dashboard

---

## 15. Acceptance Criteria

- Reglas configurables.
- Score generado correctamente.
- Dashboard operativo.
- Exportación funcional.
- Logs disponibles.
- Cobertura ABAP Unit.
- Sin findings críticos ATC.

---

## 16. Out of Scope

- Corrección automática de maestros.
- Modificación directa de datos SAP.
- Reemplazo de SAP MDG.
- Integraciones productivas.

---

## 17. Suggested Milestones

### M0

Discovery

### M1

Rule Engine

### M2

Scoring Engine

### M3

Reporting

### M4

Fiori Dashboard

### M5

Portfolio Release

---

## 18. Demo Script

1. Mostrar problema de calidad de datos.
2. Ejecutar análisis.
3. Mostrar findings.
4. Mostrar score.
5. Analizar duplicados.
6. Mostrar arquitectura.
7. Mostrar código.
8. Mostrar roadmap.

---

## 19. Traceability Matrix

- FR → Test Case
- NFR → Quality Validation
- Rule → Business Requirement
- Finding → Corrective Action

---

## 20. References

- SAP Clean ABAP
- SAP Data Migration Methodology
- SAP MDG Concepts
- SAP Business Partner
- SAP S/4HANA Migration Best Practices
- SAP Data Quality Guidelines