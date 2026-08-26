CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE Travel.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
       entities FOR CREATE Travel\_Booking.


ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

   DATA: entity        TYPE STRUCTURE FOR CREATE zrn_travel_root,
          travel_id_max TYPE /dmo/travel_id.

    "" Step 1: Safely handle instances that already have a Travel ID assigned
    LOOP AT entities INTO entity WHERE TravelId IS NOT INITIAL.
      APPEND VALUE #( %cid = entity-%cid %key = entity-%key TravelId = entity-TravelId ) TO mapped-travel.
    ENDLOOP.

    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE TravelId IS NOT INITIAL.
    IF entities_wo_travelid IS INITIAL.
      RETURN.
    ENDIF.

    "" Step 2: Request sequence blocks from the number range object
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = CONV #( '/DMO/TRAVL' )
            quantity          = CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).

      "" Step 3: Handle execution errors cleanly
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges ) TO reported-travel.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO failed-travel.
        ENDLOOP.
        RETURN.
    ENDTRY.

     "" Step 4 & 5: Process Number Range thresholds
    CASE number_range_return_code.
      WHEN '1'.
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>number_range_depleted severity = if_abap_behv_message=>severity-warning ) ) TO reported-travel.
        ENDLOOP.
      WHEN '2' OR '3'.
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_sufficient_numbers severity = if_abap_behv_message=>severity-warning ) ) TO reported-travel.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %fail-cause = if_abap_behv=>cause-conflict ) TO failed-travel.
        ENDLOOP.
        RETURN.
    ENDCASE.

    ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).

    "" Step 6 & 7: Map out the calculated database IDs
    travel_id_max = number_range_key - number_range_returned_quantity.
    LOOP AT entities_wo_travelid INTO entity.
      travel_id_max += 1.

      "" Crucial: Supply %key alongside %cid so active conversions don't dump
      APPEND VALUE #(
          %cid      = entity-%cid
          %key      = entity-%key
          %is_draft = entity-%is_draft
          TravelId  = travel_id_max
        ) TO mapped-travel.
    ENDLOOP.


  endmethod.

  method earlynumbering_cba_Booking.

  DATA max_booking_id TYPE /dmo/booking_id.

  " Step 1: Get all the travel requests and their booking data from the transactional draft buffer
  READ ENTITIES OF zrn_travel_root IN LOCAL MODE
    ENTITY travel BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(bookings).

  "" Step 2: Get the highest booking number which is already there in DB or active Draft buffer
  LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelId.

  CLEAR max_booking_id.
    ""Step 2: get the highest booking number which is already there
    LOOP AT bookings INTO DATA(ls_booking) USING KEY entity
    WHERE source-TravelId = <travel_group>-TravelId.
      IF max_booking_id < ls_booking-target-BookingId.
        max_booking_id = ls_booking-target-BookingId.
      ENDIF.
    ENDLOOP.
    ""Step 3: get the asigned booking numbers for incoming request
    LOOP AT entities INTO DATA(ls_entity) USING KEY entity
    WHERE TravelId = <travel_group>-TravelId.
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        IF max_booking_id < ls_target-BookingId.
          max_booking_id = ls_target-BookingId.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    ""Step 4: loop over all the entities of travel with same travel id
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>) USING KEY entity WHERE TravelId = <travel_group>-TravelId.
      ""Step 5: assign new booking IDs to the booking entity inside each travel
      LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
        IF <booking_wo_numbers>-BookingId IS INITIAL.
            max_booking_id += 10.
            DATA(lv_assigned_booking_id) = max_booking_id.
          ELSE.
            lv_assigned_booking_id = <booking_wo_numbers>-BookingId.
          ENDIF.

 APPEND VALUE #(
              %cid      = <booking_wo_numbers>-%cid
              %key      = <booking_wo_numbers>-%key
              %is_draft = <travel>-%is_draft
              TravelId  = <travel>-TravelId
              BookingId = lv_assigned_booking_id
            ) TO mapped-booking.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  endmethod.



ENDCLASS.
