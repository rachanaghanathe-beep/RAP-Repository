@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement Projection - Processor use case'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZRN_BOOKSUPPL_PROCESSOR as projection on ZRN_BOOKSUPPL
{
    key TravelId,
 key BookingId,
 key BookingSupplementId,
 SupplementId,
 Price,
 CurrencyCode,
 LastChangedAt,
 /* Associations */
 _Booking: redirected to parent ZRN_BOOKING_PROCESSOR,
 _Product,
 _SupplementText,
 _Travel: redirected to ZRN_TRAVEL_PROCESSOR
}
