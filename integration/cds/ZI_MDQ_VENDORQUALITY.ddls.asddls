@AbapCatalog.sqlViewName: 'ZV_MDQ_VENDQUAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Core Data Service View for Vendor Master Quality Pushdown'

define view ZI_MDQ_VendorQuality as select from lfa1
  left outer join lfb1 on lfb1.lifnr = lfa1.lifnr
  left outer join lfm1 on lfm1.lifnr = lfa1.lifnr
{
  key lfa1.lifnr as VendorNumber,
  lfa1.name1 as VendorName,
  lfa1.stras as StreetAddress,
  lfa1.ort01 as City,
  lfa1.pstlz as PostalCode,
  lfa1.land1 as CountryKey,
  lfa1.stcd1 as TaxNumber1,
  lfb1.zterm as PaymentTerms,
  lfm1.ekorg as PurchasingOrganization,
  lfa1.sperr as CentralBlock,
  
  /* HANA DB Quality Flags Pushdown */
  case when lfa1.name1 is null or lfa1.name1 = '' then 'X' else '' end as IsMissingName,
  case when lfa1.stcd1 is null or lfa1.stcd1 = '' then 'X' else '' end as IsMissingTaxId,
  case when lfb1.zterm is null or lfb1.zterm = '' then 'X' else '' end as IsMissingPaymentTerms,
  case when lfm1.ekorg is null or lfm1.ekorg = '' then 'X' else '' end as IsMissingPurchasingOrg
}
