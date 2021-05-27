CLASS zcl_art_tracer DEFINITION
  PUBLIC
  ABSTRACT.

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          i_world TYPE REF TO zcl_art_world,

      trace_ray ABSTRACT
        IMPORTING
          i_ray          TYPE REF TO zcl_art_ray
          i_depth        TYPE int4 OPTIONAL
        RETURNING
          VALUE(r_color) TYPE REF TO zcl_art_rgb_color.


  PROTECTED SECTION.
    DATA:
      _world TYPE REF TO zcl_art_world.

ENDCLASS.



CLASS zcl_art_tracer IMPLEMENTATION.
  METHOD constructor.
    ASSERT i_world IS BOUND.
    _world = i_world.
  ENDMETHOD.
ENDCLASS.
