@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection - Processor case'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZRN_BOOKING_PROCESSOR as projection on ZRN_BOOKING
{
    key TravelId,
 key BookingId,
 BookingDate,
 CustomerId,
 CarrierId,
 ConnectionId,
 FlightDate,
 FlightPrice,
 CurrencyCode,
 BookingStatus,
 LastChangedAt,
 /* Associations */
 _BookingStatus,
 _BookingSupplement: redirected to composition child ZRN_BOOKSUPPL_PROCESSOR,
 _Carrier,
 _Connection,
 _Customer,
 _Travel: redirected to parent ZRN_TRAVEL_PROCESSOR
    
}
