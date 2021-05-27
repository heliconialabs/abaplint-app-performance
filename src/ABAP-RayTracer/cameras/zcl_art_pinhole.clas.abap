CLASS zcl_art_pinhole DEFINITION
  PUBLIC
  INHERITING FROM zcl_art_camera
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS:
      new_copy
        IMPORTING
          i_pinhole         TYPE REF TO zcl_art_pinhole
        RETURNING
          VALUE(r_instance) TYPE REF TO zcl_art_pinhole,

      new_default
        RETURNING
          VALUE(r_instance) TYPE REF TO zcl_art_pinhole.


    METHODS:
      render_scene REDEFINITION,

      assignment_by_pinhole
        IMPORTING
          i_rhs            TYPE REF TO zcl_art_pinhole
        RETURNING
          VALUE(r_pinhole) TYPE REF TO zcl_art_pinhole,

      set_view_plane_distance
        IMPORTING
          i_view_plane_distance TYPE decfloat16,

      set_zoom_factor
        IMPORTING
          i_zoom_factor TYPE decfloat16,

      get_view_plane_distance
        RETURNING
          VALUE(r_view_plane_distance) TYPE decfloat16,

      get_zoom_factor
        RETURNING
          VALUE(r_zoom_factor) TYPE decfloat16,

      get_direction
        IMPORTING
          i_point            TYPE REF TO zcl_art_point2d
        RETURNING
          VALUE(r_direction) TYPE REF TO zcl_art_vector3d.


  PRIVATE SECTION.
    DATA:
      _view_plane_distance TYPE decfloat16,
      _zoom_factor         TYPE decfloat16.


    METHODS:
      constructor
        IMPORTING
          i_pinhole TYPE REF TO zcl_art_pinhole OPTIONAL. "Copy constructor

ENDCLASS.



CLASS zcl_art_pinhole IMPLEMENTATION.


  METHOD assignment_by_pinhole.
    ASSERT i_rhs IS BOUND.
    r_pinhole = me.
    CHECK me <> i_rhs.

    assignment_by_camera( i_rhs ).

    set_view_plane_distance( i_rhs->_view_plane_distance ).
    set_zoom_factor( i_rhs->_zoom_factor ).
  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).

    "Copy constructor
    IF i_pinhole IS SUPPLIED.
      ASSERT i_pinhole IS BOUND.
      assignment_by_pinhole( i_pinhole ).
      RETURN.
    ENDIF.

    "Default Constructor.
    _view_plane_distance = '500'.
    _zoom_factor = '1'.
  ENDMETHOD.


  METHOD get_direction.
    DATA(u) = _u->get_product_by_decfloat( i_point->x ).
    DATA(v) = _v->get_product_by_decfloat( i_point->y ).
    DATA(w) = _w->get_product_by_decfloat( _view_plane_distance ).

    r_direction = u->get_sum_by_vector( v )->get_difference_by_vector( w ).

    r_direction->normalize( ).
  ENDMETHOD.


  METHOD render_scene.
    c_world->num_rays = 0.
    DATA(viewplane) = c_world->viewplane.
    DATA(tracer) = c_world->tracer.

    DATA num TYPE int4.
    num = sqrt( viewplane->num_samples ).

    viewplane->set_pixel_size( viewplane->pixel_size / _zoom_factor ).

    DATA(ray) = zcl_art_ray=>new_default( ).
    ray->origin = zcl_art_point3d=>new_copy( _eye ).

    "Sample point on a pixel
    DATA(sample_point) = NEW zcl_art_point2d( ).

    DATA:
      row              TYPE int4,
      column           TYPE int4,
      sub_pixel_row    TYPE int4,
      sub_pixel_column TYPE int4,
      depth            TYPE int4.

    WHILE row < viewplane->vres.
      column = 0.
      WHILE column < viewplane->hres.
        "Also called L, which is a symbol for radiance
        DATA(radiance) = zcl_art_rgb_color=>new_black( ).

        sub_pixel_row = 0.
        WHILE sub_pixel_row < num.
          sub_pixel_column = 0.
          WHILE sub_pixel_column < num.

            sample_point->x = viewplane->pixel_size * ( column - '0.5' * viewplane->hres + ( sub_pixel_column + '0.5' ) ).
            sample_point->y = viewplane->pixel_size * ( row - '0.5' * viewplane->vres + ( sub_pixel_row + '0.5' ) ).

            ray->direction = zcl_art_vector3d=>new_copy( get_direction( sample_point ) ).

            radiance->add_and_assign_by_color( tracer->trace_ray( i_ray = ray  i_depth = depth ) ).
            ADD 1 TO c_world->num_rays.

            ADD 1 TO sub_pixel_column.
          ENDWHILE.

          ADD 1 TO sub_pixel_row.
        ENDWHILE.

        radiance->divide_and_assign_by_decfloat( CONV #( viewplane->num_samples ) ).
        radiance->multiply_and_assign_by_decflt( _exposure_time ).

        c_world->display_pixel(
          i_row = row
          i_column = column
          i_pixel_color = radiance ).

        ADD 1 TO column.
      ENDWHILE.

      ADD 1 TO row.
    ENDWHILE.
  ENDMETHOD.


  METHOD set_view_plane_distance.
    _view_plane_distance = i_view_plane_distance.
  ENDMETHOD.


  METHOD set_zoom_factor.
    _zoom_factor = i_zoom_factor.
  ENDMETHOD.


  METHOD new_copy.
    ASSERT i_pinhole IS BOUND.
    r_instance = NEW #( i_pinhole = i_pinhole ).
  ENDMETHOD.


  METHOD new_default.
    r_instance = NEW #( ).
  ENDMETHOD.


  METHOD get_view_plane_distance.
    r_view_plane_distance = _view_plane_distance.
  ENDMETHOD.


  METHOD get_zoom_factor.
    r_zoom_factor = _zoom_factor.
  ENDMETHOD.
ENDCLASS.
