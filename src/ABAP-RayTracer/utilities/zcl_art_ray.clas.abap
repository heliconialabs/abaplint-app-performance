CLASS zcl_art_ray DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    DATA:
      direction TYPE REF TO zcl_art_vector3d,
      origin    TYPE REF TO zcl_art_point3d.


    CLASS-METHODS:
      new_default
        RETURNING
          VALUE(r_instance) TYPE REF TO zcl_art_ray,

      new_copy
        IMPORTING
          i_ray             TYPE REF TO zcl_art_ray
        RETURNING
          VALUE(r_instance) TYPE REF TO zcl_art_ray,

      new_from_point_and_vector
        IMPORTING
          i_direction       TYPE REF TO zcl_art_vector3d
          i_origin          TYPE REF TO zcl_art_point3d
        RETURNING
          VALUE(r_instance) TYPE REF TO zcl_art_ray.


    METHODS:
      "! operator=
      assignment
        IMPORTING
          i_rhs        TYPE REF TO zcl_art_ray
        RETURNING
          VALUE(r_ray) TYPE REF TO zcl_art_ray.


  PRIVATE SECTION.
    METHODS:
      constructor
        IMPORTING
          i_direction TYPE REF TO zcl_art_vector3d
          i_origin    TYPE REF TO zcl_art_point3d.

ENDCLASS.



CLASS ZCL_ART_RAY IMPLEMENTATION.


  METHOD assignment.
    IF me <> i_rhs.
      me->origin->assignment( i_rhs->origin ).
      me->direction->assignment_by_vector( i_rhs->direction ).
    ENDIF.

    r_ray = me.
  ENDMETHOD.


  METHOD constructor.
    me->origin = i_origin.
    me->direction = i_direction.
  ENDMETHOD.


  METHOD new_copy.
    ASSERT i_ray IS BOUND.

    r_instance = NEW #(
      i_direction = zcl_art_vector3d=>new_copy( i_ray->direction )
      i_origin    = zcl_art_point3d=>new_copy( i_ray->origin ) ).
  ENDMETHOD.


  METHOD new_default.
    r_instance = NEW #(
      i_direction = zcl_art_vector3d=>new_default( )
      i_origin    = zcl_art_point3d=>new_default( ) ).
  ENDMETHOD.


  METHOD new_from_point_and_vector.
    ASSERT i_direction IS BOUND AND
           i_origin IS BOUND.

    r_instance = NEW #(
      i_direction = zcl_art_vector3d=>new_copy( i_direction )
      i_origin    = zcl_art_point3d=>new_copy( i_origin ) ).
  ENDMETHOD.
ENDCLASS.
