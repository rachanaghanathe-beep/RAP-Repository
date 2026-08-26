CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      entities FOR CREATE Booking\_Bookingsupplement.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA max_suppl_id TYPE /dmo/booking_supplement_id.

    "" Step 1: Get all the booking requests and their supplement data from the transactional draft buffer
    READ ENTITIES OF zrn_travel_root IN LOCAL MODE
      ENTITY Booking BY \_BookingSupplement
      FROM CORRESPONDING #( entities )
      LINK DATA(supplements).

       " Step 2: Loop and group incoming records by their composite parent keys (TravelId + BookingId)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>)
      GROUP BY ( TravelId = <booking_group>-TravelId BookingId = <booking_group>-BookingId )
      ASSIGNING FIELD-SYMBOL(<ls_group>).

      CLEAR max_suppl_id.

       LOOP AT supplements INTO DATA(ls_suppl) USING KEY entity
        WHERE source-TravelId  = <ls_group>-TravelId
          AND source-BookingId = <ls_group>-BookingId.

        IF max_suppl_id < ls_suppl-target-BookingSupplementId.
        max_suppl_id = ls_suppl-target-BookingSupplementId.
      ENDIF.
     endloop.

     LOOP AT GROUP <ls_group> ASSIGNING FIELD-SYMBOL(<ls_member>).
      LOOP AT <ls_member>-%target INTO DATA(ls_target).
        IF max_suppl_id < ls_target-BookingSupplementId.
          max_suppl_id = ls_target-BookingSupplementId.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " CORRECTION: Loop over the group members to assign the numbers and update mapped structure
    LOOP AT GROUP <ls_group> ASSIGNING FIELD-SYMBOL(<ls_member_num>).
      LOOP AT <ls_member_num>-%target ASSIGNING FIELD-SYMBOL(<suppl_wo_numbers>).
        IF <suppl_wo_numbers>-BookingSupplementId IS INITIAL.
          max_suppl_id += 1.
          DATA(lv_assigned_suppl_id) = max_suppl_id.
        ELSE.
          lv_assigned_suppl_id = <suppl_wo_numbers>-BookingSupplementId.
        ENDIF.

        " Step 6: Populate mapped structure safely using the group member fields
        APPEND VALUE #( %cid                = <suppl_wo_numbers>-%cid
                        %key                = <suppl_wo_numbers>-%key
                        %is_draft           = <ls_member_num>-%is_draft
                        TravelId            = <ls_group>-TravelId
                        BookingId           = <ls_group>-BookingId
                        BookingSupplementId = lv_assigned_suppl_id )
               TO mapped-bookingsupplement.
      ENDLOOP.
    ENDLOOP.

  ENDLOOP.



  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

