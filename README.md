# RAP-Repository
ABAP RESTful Application Programming Model
SAP RAP Travel Management Application

A Managed RAP application built on SAP BTP ABAP Environment (Trial) — implementing a 3-level Travel → Booking → Booking Supplement hierarchy with full CRUD, draft handling, early numbering, dynamic feature control, and a rich Fiori Elements UI.

What This App Demonstrates
RAP Concept	Implementation
Managed BO	Full CRUD with managed implementation type
3-Level Composition	Travel → Booking → Booking Supplement (parent-child-grandchild)
Draft Handling	with draft — Edit, Activate, Discard, Resume, Prepare
Early Numbering	Number range (/DMO/TRAVL) for Travel, sequential for Booking (+10 increment) and Supplement
Instance Action	acceptTravel with dynamic feature control
Dynamic Feature Control	Delete button + BookingFee field disabled when status = Accepted
Static Feature Control	field(readonly) on IDs, field(mandatory) on required fields
Value Helps	Agency (/DMO/I_Agency), Customer (/DMO/I_Customer), Status (/DMO/I_Overall_Status_VH)
Text Associations	AgencyName, CustomerName, StatusText resolved via CDS associations
Status Criticality	CASE expression mapping status to traffic-light colors (Open=grey, Accepted=green)
Metadata Extensions	Full UI annotations for all 3 entity levels — list page, object page, facets
Separate Behavior Pools	One handler class per entity (Travel, Booking, BookingSupplement)
Projection Layer	Separate projection views + projection BDEF with use draft
OData V4 Service	Service Definition + Service Binding
Architecture
┌──────────────────────────────────────────────────────────┐
│  Service Binding (ZRN_SB_TRAVEL_V4 — OData V4 UI)       │
├──────────────────────────────────────────────────────────┤
│  Service Definition (ZRN_TRAVEL_PROCESSOR_USECASE)       │
├──────────────────────────────────────────────────────────┤
│  Projection BDEF (ZRN_TRAVEL_PROCESSOR)                  │
│    use create/update/delete, use draft, use action        │
├──────────────┬──────────────────┬────────────────────────┤
│ ZRN_TRAVEL_  │ ZRN_BOOKING_     │ ZRN_BOOKSUPPL_         │
│ PROCESSOR    │ PROCESSOR        │ PROCESSOR              │
│ (projection) │ (projection)     │ (projection)           │
├──────────────┴──────────────────┴────────────────────────┤
│  Root BDEF (ZRN_TRAVEL_ROOT) — managed, strict(2)        │
│    draft, early numbering, feature control, action        │
├──────────────┬──────────────────┬────────────────────────┤
│ ZRN_TRAVEL_  │ ZRN_BOOKING      │ ZRN_BOOKSUPPL          │
│ ROOT         │ (child)          │ (grandchild)           │
│ (interface)  │ (interface)      │ (interface)            │
├──────────────┴──────────────────┴────────────────────────┤
│  /dmo/travel_m  │  /dmo/booking_m  │  /dmo/booksuppl_m   │
│  Draft: ztravel_draft, zbook_draft, zbooksuppl_draft     │
└──────────────────────────────────────────────────────────┘
Key Objects
Layer	Object Name	Purpose
CDS Interface	ZRN_TRAVEL_ROOT	Root — Travel with associations to Agency, Customer, Currency, Status
CDS Interface	ZRN_BOOKING	Child — Booking with associations to Customer, Carrier, Connection
CDS Interface	ZRN_BOOKSUPPL	Grandchild — Supplement with association to Product
CDS Projection	ZRN_TRAVEL_PROCESSOR	Travel projection (transactional_query)
CDS Projection	ZRN_BOOKING_PROCESSOR	Booking projection with redirected compositions
CDS Projection	ZRN_BOOKSUPPL_PROCESSOR	Supplement projection
MDE	ZRN_TRAVEL_MDE	Travel UI — header data points, collection facet, field groups, booking line items
MDE	ZRN_BOOKING_MDE	Booking UI — collection facet, supplement line items
MDE	ZRN_BOOKINGSUPPL_MDE	Supplement UI — collection facet with field groups
BDEF	ZRN_TRAVEL_ROOT	Root behavior — managed, draft, early numbering, feature control
BDEF	ZRN_TRAVEL_PROCESSOR	Projection behavior — use wrapper
Class	ZBP_RN_TRAVEL_ROOT	Travel handler — numbering, feature control, authorization
Class	ZBP_RN_BOOKING	Booking handler — supplement numbering
Class	ZBP_RN_BOOKINGSUPPL	Supplement handler
Behavior Pool Methods

Travel handler (zbp_rn_travel_root):

earlynumbering_create — Number range-based Travel ID using /DMO/TRAVL with proper error handling (cx_number_ranges, return codes, threshold warnings)
earlynumbering_cba_Booking — Sequential Booking ID generation (increments by 10)
get_instance_features — Dynamic feature control: disables Delete and locks BookingFee when status is Accepted
get_instance_authorizations / get_global_authorizations — Authorization stubs

Booking handler (zbp_rn_booking):

earlynumbering_cba_Bookingsupp — Sequential Supplement ID with composite key grouping (TravelId + BookingId)
Object Page UI Design

Travel Object Page:

Header: Status data point (with criticality colors) + Total Price data point
Tab 1: "More Information" collection containing:
"More Info" — identification fields
"Dates" — BeginDate, EndDate, OverallStatus
"Prices" — BookingFee, TotalPrice, CurrencyCode
Tab 2: "Bookings" — line item table of child bookings

Booking Object Page:

Tab 1: "Booking Details" collection with Booking Info + Pricings
Tab 2: "Supplements" — line item table of grandchild supplements

Supplement Object Page:

Tab 1: "Supplement Details" collection with Supplement Info + Pricings
Built With
SAP BTP ABAP Environment (Trial)
ABAP Development Tools (Eclipse)
SAP RESTful ABAP Programming Model (RAP)
DMO Flight Reference Scenario tables
OData V4
Author

Rachana N Ghanathe — SAP S/4HANA ABAP Consultant
