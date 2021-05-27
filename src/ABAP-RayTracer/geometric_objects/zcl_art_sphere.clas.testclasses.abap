CLASS ucl_art_sphere DEFINITION
  FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      _shade_rec TYPE REF TO zcl_art_shade_rec.


    METHODS:
      setup,

      new_default FOR TESTING,
      new_copy FOR TESTING,
      new_by_center_and_radius FOR TESTING,

      set_center_by_components FOR TESTING,
      set_center_by_point FOR TESTING,
      set_center_by_value FOR TESTING,
      set_radius FOR TESTING,

      hit1 FOR TESTING,
      hit2 FOR TESTING,
      hit3 FOR TESTING,
      hit4 FOR TESTING,
      hit5 FOR TESTING,
      hit6 FOR TESTING,
      hit7 FOR TESTING.

ENDCLASS.


CLASS ucl_art_sphere IMPLEMENTATION.
  METHOD setup.
    DATA(world) = NEW zcl_art_world( ).
    _shade_rec = zcl_art_shade_rec=>new_from_world( world ).
  ENDMETHOD.


  METHOD new_default.
    "Default constructor generates a sphere in the world origin with a radius of one

    "When
    DATA(cut) = zcl_art_sphere=>new_default( ).

    "Then
    cl_abap_unit_assert=>assert_equals( act = cut->get_radius( )  exp = 1 ).

    DATA(center) = cut->get_center( ).
    cl_abap_unit_assert=>assert_equals( act = center->x  exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = center->y  exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = center->z  exp = 0 ).
  ENDMETHOD.


  METHOD new_copy.
    "Copy constructor generates a new instance of a sphere based on another sphere

    "Given
    DATA(center) = zcl_art_point3d=>new_unified( 2 ).
    DATA(sphere) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = center
      i_radius = '.5' ).

    DATA(color) = zcl_art_rgb_color=>new_unified( 2 ).
    sphere->set_color_by_color( color ).

    "When
    DATA(cut) = zcl_art_sphere=>new_copy( sphere ).

    "Then
    cl_abap_unit_assert=>assert_true( xsdbool( sphere <> cut ) ).

    DATA(new_center) = cut->get_center( ).
    cl_abap_unit_assert=>assert_true( xsdbool( new_center <> center ) ).
    cl_abap_unit_assert=>assert_equals( act = new_center->x  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = new_center->y  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = new_center->z  exp = 2 ).

    cl_abap_unit_assert=>assert_equals( act = cut->get_radius( )  exp = '0.5' ).

    DATA(new_color) = cut->get_color( ).
    cl_abap_unit_assert=>assert_true( xsdbool( new_color <> color ) ).
    cl_abap_unit_assert=>assert_equals( act = new_color->r  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = new_color->g  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = new_color->b  exp = 2 ).
  ENDMETHOD.


  METHOD new_by_center_and_radius.
    "Constructs a new instance of a sphere based on a point and a radius

    "When
    DATA(cut) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_unified( 2 )
      i_radius = '.5' ).

    "Then
    DATA(center) = cut->get_center( ).
    cl_abap_unit_assert=>assert_equals( act = center->x  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = center->y  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = center->z  exp = 2 ).

    cl_abap_unit_assert=>assert_equals( act = cut->get_radius( )  exp = '0.5' ).

    cl_abap_unit_assert=>assert_bound( act = cut->get_color( ) ).
  ENDMETHOD.


  METHOD set_center_by_components.
    "Test, that setting the center by its individual components x y z works

    "Given
    DATA(cut) = zcl_art_sphere=>new_default( ).

    "When
    cut->set_center_by_components( i_x = 2  i_y = 4  i_z = 6 ).

    "Then
    DATA(center) = cut->get_center( ).
    cl_abap_unit_assert=>assert_equals( act = center->x  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = center->y  exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = center->z  exp = 6 ).
  ENDMETHOD.


  METHOD set_center_by_point.
    "Test, that setting the center by a 3D point instance works

    "Given
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(point) = zcl_art_point3d=>new_individual( i_x = 2  i_y = 4  i_z = 6 ).

    "When
    cut->set_center_by_point( point ).

    "Then
    DATA(center) = cut->get_center( ).
    cl_abap_unit_assert=>assert_equals( act = center->x  exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = center->y  exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = center->z  exp = 6 ).
  ENDMETHOD.


  METHOD set_center_by_value.
    "Test, that setting the center by a value for all its components x y z works

    "Given
    DATA(cut) = zcl_art_sphere=>new_default( ).

    "When
    cut->set_center_by_value( 3 ).

    "Then
    DATA(center) = cut->get_center( ).
    cl_abap_unit_assert=>assert_equals( act = center->x  exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = center->y  exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = center->z  exp = 3 ).
  ENDMETHOD.


  METHOD set_radius.
    "Test, that setting the radius of the sphere works

    "Given
    DATA(cut) = zcl_art_sphere=>new_default( ).

    "When
    cut->set_radius( 3 ).

    "Then
    cl_abap_unit_assert=>assert_equals( act = cut->get_radius( )  exp = 3 ).
  ENDMETHOD.


  METHOD hit1.
    "Test, that a ray can miss the sphere when being above

    "Given
    DATA tmin TYPE decfloat16.
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(ray) = zcl_art_ray=>new_from_point_and_vector(
      i_direction = zcl_art_vector3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 )
      i_origin = zcl_art_point3d=>new_unified( 2 ) ).

    "When
    DATA(hit) = cut->hit(
      EXPORTING
        i_ray = ray
      IMPORTING
        e_tmin = tmin
      CHANGING
        c_shade_rec = _shade_rec ).

    "Then
    cl_abap_unit_assert=>assert_false( hit ).
    cl_abap_unit_assert=>assert_equals( act = tmin  exp = 0 ).
  ENDMETHOD.


  METHOD hit2.
    "Test, that a ray can hit the sphere twice (front and back)

    "Given
    DATA tmin TYPE decfloat16.
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(ray) = zcl_art_ray=>new_from_point_and_vector(
      i_direction = zcl_art_vector3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 )
      i_origin = zcl_art_point3d=>new_individual( i_x = -2  i_y = 0  i_z = 0 ) ).

    "When
    DATA(hit) = cut->hit(
      EXPORTING
        i_ray = ray
      IMPORTING
        e_tmin = tmin
      CHANGING
        c_shade_rec = _shade_rec ).

    "Then
    cl_abap_unit_assert=>assert_true( hit ).
    cl_abap_unit_assert=>assert_equals( act = tmin  exp = 1 ).
  ENDMETHOD.


  METHOD hit3.
    "Test, that a ray can hits the sphere once (just the shell)

    "Given
    DATA tmin TYPE decfloat16.
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(ray) = zcl_art_ray=>new_from_point_and_vector(
      i_direction = zcl_art_vector3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 )
      i_origin = zcl_art_point3d=>new_individual( i_x = -1  i_y = 1  i_z = 0 ) ).

    "When
    DATA(hit) = cut->hit(
      EXPORTING
        i_ray = ray
      IMPORTING
        e_tmin = tmin
      CHANGING
        c_shade_rec = _shade_rec ).

    "Then
    cl_abap_unit_assert=>assert_true( hit ).
    cl_abap_unit_assert=>assert_equals( act = tmin  exp = 1 ).
  ENDMETHOD.


  METHOD hit4.
    "Test, that a ray can miss the sphere when being behind

    "Given
    DATA tmin TYPE decfloat16.
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(ray) = zcl_art_ray=>new_from_point_and_vector(
      i_direction = zcl_art_vector3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 )
      i_origin = zcl_art_point3d=>new_individual( i_x = 2  i_y = 0  i_z = 0 ) ).

    "When
    DATA(hit) = cut->hit(
      EXPORTING
        i_ray = ray
      IMPORTING
        e_tmin = tmin
      CHANGING
        c_shade_rec = _shade_rec ).

    "Then
    cl_abap_unit_assert=>assert_false( hit ).
    cl_abap_unit_assert=>assert_equals( act = tmin  exp = 0 ).
  ENDMETHOD.

  METHOD hit5.
    "Test, that no hit gets counted when a ray is being cast on the spheres shell traveling outward

    "Given
    DATA tmin TYPE decfloat16.
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(ray) = zcl_art_ray=>new_from_point_and_vector(
      i_direction = zcl_art_vector3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 )
      i_origin = zcl_art_point3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 ) ).

    "When
    DATA(hit) = cut->hit(
      EXPORTING
        i_ray = ray
      IMPORTING
        e_tmin = tmin
      CHANGING
        c_shade_rec = _shade_rec ).

    "Then
    cl_abap_unit_assert=>assert_false( hit ).
    cl_abap_unit_assert=>assert_equals( act = tmin  exp = 0 ).
  ENDMETHOD.


  METHOD hit6.
    "Test, that a ray can hit the sphere from the inside

    "Given
    DATA tmin TYPE decfloat16.
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(ray) = zcl_art_ray=>new_from_point_and_vector(
      i_direction = zcl_art_vector3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 )
      i_origin = zcl_art_point3d=>new_individual( i_x = 0  i_y = 0  i_z = 0 ) ).

    "When
    DATA(hit) = cut->hit(
      EXPORTING
        i_ray = ray
      IMPORTING
        e_tmin = tmin
      CHANGING
        c_shade_rec = _shade_rec ).

    "Then
    cl_abap_unit_assert=>assert_true( hit ).
    cl_abap_unit_assert=>assert_equals( act = tmin  exp = 1 ).
  ENDMETHOD.


  METHOD hit7.
    "Test, that a ray can hit the sphere twice when originating on the sphere shell facing inward

    "Given
    DATA tmin TYPE decfloat16.
    DATA(cut) = zcl_art_sphere=>new_default( ).
    DATA(ray) = zcl_art_ray=>new_from_point_and_vector(
      i_direction = zcl_art_vector3d=>new_individual( i_x = 1  i_y = 0  i_z = 0 )
      i_origin = zcl_art_point3d=>new_individual( i_x = -1  i_y = 0  i_z = 0 ) ).

    "When
    DATA(hit) = cut->hit(
      EXPORTING
        i_ray = ray
      IMPORTING
        e_tmin = tmin
      CHANGING
        c_shade_rec = _shade_rec ).

    "Then
    cl_abap_unit_assert=>assert_true( hit ).
    cl_abap_unit_assert=>assert_equals( act = tmin  exp = 2 ).
  ENDMETHOD.
ENDCLASS.
