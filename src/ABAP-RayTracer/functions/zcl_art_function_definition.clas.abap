CLASS zcl_art_function_definition DEFINITION
  PUBLIC
  ABSTRACT.

  PUBLIC SECTION.
    METHODS:
      solve ABSTRACT
        IMPORTING
          i_x            TYPE decfloat16
          i_y            TYPE decfloat16
        RETURNING
          VALUE(r_value) TYPE decfloat16.

ENDCLASS.


CLASS zcl_art_function_definition IMPLEMENTATION.
ENDCLASS.
