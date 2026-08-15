@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Root - Projection for Approval'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity ZRN_TRAVEL_PROCESSOR as projection on ZRN_TRAVEL_ROOT
{
   key TravelId,
AgencyId,
CustomerId,
BeginDate,
EndDate,
BookingFee,
TotalPrice,
CurrencyCode,
Description,
OverallStatus,
CreatedBy,
CreatedAt,
LastChangedBy,
LastChangedAt,
AgencyName,
CustomerName,
StatusText,
Criticality,

/* Associations */
_Agency,
_Booking: redirected to composition child ZRN_BOOKING_PROCESSOR,
_Currency,
_Customer,
_OverallStatus
    
}
