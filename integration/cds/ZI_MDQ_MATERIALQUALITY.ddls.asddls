@AbapCatalog.sqlViewName: 'ZV_MDQ_MATQUAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Core Data Service View for Material Master Quality Pushdown'

define view ZI_MDQ_MaterialQuality as select from mara
  left outer join makt on makt.matnr = mara.matnr and makt.spras = $session.system_language
  left outer join marc on marc.matnr = mara.matnr
  left outer join mvke on mvke.matnr = mara.matnr
{
  key mara.matnr as MaterialNumber,
  mara.mtart as MaterialType,
  mara.matkl as MaterialGroup,
  mara.meins as BaseUnitOfMeasure,
  makt.maktx as MaterialDescription,
  marc.werks as Plant,
  mvke.vkorg as SalesOrganization,
  mara.mstae as MaintenanceStatus,
  mara.lvorm as DeletionFlag,
  mara.brgew as GrossWeight,
  mara.ntgew as NetWeight,
  mara.gewei as WeightUnit,
  
  /* HANA DB Quality Flags Pushdown */
  case when makt.maktx is null or makt.maktx = '' then 'X' else '' end as IsMissingDescription,
  case when mara.meins is null or mara.meins = '' then 'X' else '' end as IsMissingUnit,
  case when mara.matkl is null or mara.matkl = '' then 'X' else '' end as IsMissingGroup,
  case when marc.werks is null or marc.werks = '' then 'X' else '' end as IsMissingPlant
}
