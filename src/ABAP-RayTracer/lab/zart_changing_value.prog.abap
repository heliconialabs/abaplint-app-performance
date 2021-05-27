*&---------------------------------------------------------------------*
*& Report zart_changing_value
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zart_changing_value.

CLASS cl_foo DEFINITION.
  PUBLIC SECTION.
    METHODS foobar
      CHANGING
        VALUE(c_value) TYPE int4.
ENDCLASS.

CLASS cl_foo IMPLEMENTATION.
  METHOD foobar.
    IF c_value <> 42.
      c_value = 42.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  DATA(foo) = NEW cl_foo( ).
  DATA value TYPE int4.
  foo->foobar( CHANGING c_value = value ).
  WRITE value.
