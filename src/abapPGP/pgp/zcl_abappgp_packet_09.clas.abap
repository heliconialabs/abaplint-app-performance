CLASS zcl_abappgp_packet_09 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abappgp_packet .

    ALIASES from_stream
      FOR zif_abappgp_packet~from_stream .
    ALIASES get_name
      FOR zif_abappgp_packet~get_name .
    ALIASES get_tag
      FOR zif_abappgp_packet~get_tag .
    ALIASES to_stream
      FOR zif_abappgp_packet~to_stream .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAPPGP_PACKET_09 IMPLEMENTATION.


  METHOD zif_abappgp_packet~dump.

    rv_dump = |{ get_name( ) }(tag { get_tag( ) })({ to_stream( )->get_length( ) } bytes)\n\ttodo\n|.

  ENDMETHOD.


  METHOD zif_abappgp_packet~from_stream.

* todo

    CREATE OBJECT ri_packet
      TYPE zcl_abappgp_packet_09.

  ENDMETHOD.


  METHOD zif_abappgp_packet~get_name.

    rv_name = 'Symmetrically Encrypted Data Packet'(001).

  ENDMETHOD.


  METHOD zif_abappgp_packet~get_tag.

    rv_tag = zif_abappgp_constants=>c_tag-symmetrical_enc.

  ENDMETHOD.


  METHOD zif_abappgp_packet~to_stream.

* todo

    CREATE OBJECT ro_stream.

  ENDMETHOD.
ENDCLASS.