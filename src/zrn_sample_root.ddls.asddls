@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Test'
define root view entity ZRN_SAMPLE_ROOT
  as select from /dmo/travel_m
{
  key travel_id  as TravelId,
      agency_id  as AgencyId
//      total_price as TotalPrice
}
