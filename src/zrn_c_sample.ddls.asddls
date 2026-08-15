@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Test Projection'
@Metadata.allowExtensions: true
define root view entity ZRN_C_SAMPLE
  as projection on ZRN_SAMPLE_ROOT
{
  key TravelId,
      AgencyId
//      TotalPrice
}
