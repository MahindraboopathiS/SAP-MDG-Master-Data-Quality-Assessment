@AbapCatalog.sqlViewName: 'ZV_MDQ_BPQUAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Core Data Service View for Business Partner Quality Pushdown'

define view ZI_MDQ_BusinessPartnerQuality as select from but000
  left outer join but020 on but020.partner = but000.partner
  left outer join but0id on but0id.partner = but000.partner
{
  key but000.partner as BusinessPartnerNumber,
  but000.type as BusinessPartnerType,
  but000.name_org1 as OrganizationName1,
  but000.name_first as FirstName,
  but000.name_last as LastName,
  but000.bu_sort1 as SearchTerm1,
  but020.addrnumber as AddressNumber,
  but0id.idnumber as IdentificationNumber,
  
  /* HANA DB Quality Flags Pushdown */
  case when (but000.name_org1 is null or but000.name_org1 = '') 
        and (but000.name_last is null or but000.name_last = '') then 'X' else '' end as IsMissingName
}
