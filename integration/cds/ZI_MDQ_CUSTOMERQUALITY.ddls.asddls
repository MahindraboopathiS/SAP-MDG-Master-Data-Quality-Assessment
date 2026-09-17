@AbapCatalog.sqlViewName: 'ZV_MDQ_CUSTQUAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Core Data Service View for Customer Master Quality Pushdown'

define view ZI_MDQ_CustomerQuality as select from kna1
  left outer join knb1 on knb1.kunnr = kna1.kunnr
  left outer join knvv on knvv.kunnr = kna1.kunnr
{
  key kna1.kunnr as CustomerNumber,
  kna1.name1 as CustomerName,
  kna1.stras as StreetAddress,
  kna1.ort01 as City,
  kna1.pstlz as PostalCode,
  kna1.land1 as CountryKey,
  kna1.stcd1 as TaxNumber1,
  knb1.zterm as PaymentTerms,
  knvv.vkorg as SalesOrganization,
  kna1.sperr as CentralBlock,
  knvv.kdgrp as CustomerGroup,
  
  /* HANA DB Quality Flags Pushdown */
  case when kna1.name1 is null or kna1.name1 = '' then 'X' else '' end as IsMissingName,
  case when kna1.stcd1 is null or kna1.stcd1 = '' then 'X' else '' end as IsMissingTaxId,
  case when kna1.land1 is null or kna1.land1 = '' then 'X' else '' end as IsMissingCountry,
  case when knb1.zterm is null or knb1.zterm = '' then 'X' else '' end as IsMissingPaymentTerms
}
