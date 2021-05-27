"! The World class does not have a copy constructor or an assignment operator, for the following reasons:
"! <ol>
"! <li>There's no need to copy construct or assign the World</li>
"! <li>We wouldn't want to do this anyway, because the world can contain an arbitrary amount of data</li>
"! <li><p>These operations wouldn't work because the world is self-referencing:</p>
"! <p>the Tracer base class contains a pointer to the world. If we wrote a correct copy constructor for the
"! Tracer class, the World copy constructor would call itself recursively until we ran out of memory.</p></li>
"! </ol>
CLASS zcl_art_world DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.


  PUBLIC SECTION.
    TYPES:
      t_lights TYPE STANDARD TABLE OF REF TO zcl_art_light WITH EMPTY KEY.


    DATA:
      background_color TYPE REF TO zcl_art_rgb_color READ-ONLY,
      bitmap           TYPE REF TO zcl_art_bitmap READ-ONLY,
      function         TYPE REF TO zcl_art_function_definition READ-ONLY,
      viewplane        TYPE REF TO zcl_art_viewplane READ-ONLY,
      num_rays         TYPE int4,
      eye              TYPE decfloat16,
      distance         TYPE decfloat16,
      tracer           TYPE REF TO zcl_art_tracer READ-ONLY,
      camera           TYPE REF TO zcl_art_camera READ-ONLY,

      "! For chapter 3 only
      sphere           TYPE REF TO zcl_art_sphere READ-ONLY,

      ambient_light    TYPE REF TO zcl_art_light READ-ONLY,
      lights           TYPE t_lights READ-ONLY.


    METHODS:
      constructor
        IMPORTING
          i_image_height_in_pixel TYPE int4 OPTIONAL
          i_image_width_in_pixel  TYPE int4 OPTIONAL,

      add_object
        IMPORTING
          i_object TYPE REF TO zcl_art_geometric_object,

      add_light
        IMPORTING
          i_light TYPE REF TO zcl_art_light,

      set_ambient_light
        IMPORTING
          i_light TYPE REF TO zcl_art_light,

      build,

      render_scene,

      render_perspective,

      hit_bare_bones_objects
        IMPORTING
          i_ray              TYPE REF TO zcl_art_ray
        RETURNING
          VALUE(r_shade_rec) TYPE REF TO zcl_art_shade_rec,

      hit_objects
        IMPORTING
          i_ray              TYPE REF TO zcl_art_ray
        RETURNING
          VALUE(r_shade_rec) TYPE REF TO zcl_art_shade_rec,

      get_num_objects
        RETURNING
          VALUE(r_num_objects) TYPE int4,

      "! It's used for unittests only
      set_bitmap
        IMPORTING
          i_bitmap TYPE REF TO zcl_art_bitmap,

      display_pixel
        IMPORTING
          i_row         TYPE int4
          i_column      TYPE int4
          i_pixel_color TYPE REF TO zcl_art_rgb_color,

      set_function
        IMPORTING
          i_function TYPE REF TO zcl_art_function_definition.


  PRIVATE SECTION.
    TYPES:
      geometric_objects TYPE STANDARD TABLE OF REF TO zcl_art_geometric_object WITH EMPTY KEY.


    DATA:
      _objects TYPE geometric_objects.


    METHODS:
      build_single_sphere,

      build_multiple_objects,

      build_from_image_mask,

      build_horizont,

      max_to_one
        IMPORTING
          i_color        TYPE REF TO zcl_art_rgb_color
        RETURNING
          VALUE(r_color) TYPE REF TO zcl_art_rgb_color,

      "! Set color to red if any component is greater than one
      clamp_to_color
        IMPORTING
          i_color        TYPE REF TO zcl_art_rgb_color
        RETURNING
          VALUE(r_color) TYPE REF TO zcl_art_rgb_color,

      build_sinusoid_function,

      set_camera
        IMPORTING
          i_camera TYPE REF TO zcl_art_camera,

      build_with_pinhole,

      build_with_material,

      build_paul.

ENDCLASS.



CLASS zcl_art_world IMPLEMENTATION.


  METHOD add_object.
    INSERT i_object INTO TABLE _objects.
  ENDMETHOD.


  METHOD build.
*    build_single_sphere( ).
*    build_multiple_objects( ).
*    build_horizont( ).
*    build_from_image_mask( ).
*    build_sinusoid_function( ).
*    build_with_pinhole( ).
*    build_with_material( ).
build_paul(  ).

    ASSERT me->tracer IS BOUND.
    ASSERT me->viewplane IS BOUND.

    me->bitmap = NEW zcl_art_bitmap(
      i_image_height_in_pixel = me->viewplane->vres
      i_image_width_in_pixel = me->viewplane->hres ).
  ENDMETHOD.


  METHOD build_from_image_mask.
    me->viewplane->set_num_samples( 16 ).

    cl_mime_repository_api=>get_api( )->get(
      EXPORTING
        i_url = `/SAP/PUBLIC/ZART/sap_logo_black_and_white.bmp`
*        i_url = `/SAP/PUBLIC/ZART/pixelbaker_logo_mask.bmp`
      IMPORTING
        e_content = DATA(img) ).

    DATA factor TYPE decfloat16 VALUE '2.0'.
    DATA density TYPE int4 VALUE 2.
    DATA hres TYPE int4.
    DATA vres TYPE int4.

    DATA(converter) = cl_abap_conv_in_ce=>create(
      endian = cl_abap_char_utilities=>endian
      input = img ).

    converter->skip_x( n = 18 ).
    converter->read( EXPORTING n = 4 IMPORTING data = hres ).
    converter->read( EXPORTING n = 4 IMPORTING data = vres ).

    me->viewplane->set_hres( hres * factor ).
    me->viewplane->set_vres( vres * factor ).

    me->background_color = zcl_art_rgb_color=>new_black( ).
    tracer = NEW zcl_art_multiple_objects( me ).

    DATA:
      sphere    TYPE REF TO zcl_art_sphere,
      b         TYPE x,
      g         TYPE x,
      r         TYPE x,
      x         TYPE decfloat16,
      y         TYPE decfloat16,
      row       TYPE int4,
      column    TYPE int4,
      half_hres TYPE decfloat16,
      half_vres TYPE decfloat16.


    converter->skip_x( n = 28 ).

    half_hres = ( hres * factor ) / 2.
    half_vres = ( vres * factor ) / -2.

    DATA(rand) = cl_abap_random_decfloat16=>create( seed = 354345 ).


    WHILE row < vres.
      column = 0.
      WHILE column < hres.
        CLEAR: b, g, r.
        converter->read( EXPORTING n = 1 IMPORTING data = b ).
        converter->read( EXPORTING n = 1 IMPORTING data = g ).
        converter->read( EXPORTING n = 1 IMPORTING data = r ).

        IF b = 0 AND g = 0 AND r = 0.
          IF ( column MOD density ) = 0 AND
             ( row MOD density ) = 0.
            x = ( column * factor ) - half_hres.
            y = half_vres + ( row * factor ).
            sphere = zcl_art_sphere=>new_default( ).
            sphere->set_color_by_components( i_r = rand->get_next( ) i_g = rand->get_next( ) i_b = rand->get_next( ) ).
            sphere->set_center_by_components( i_x = x i_y = y i_z = 0 ).
            sphere->set_radius( ( rand->get_next( ) * 2 ) ).
            add_object( sphere ).
          ENDIF.
        ENDIF.
        ADD 1 TO column.
      ENDWHILE.

      converter->skip_x( n = 3 ).
      ADD 1 TO row.
    ENDWHILE.
  ENDMETHOD.


  METHOD build_horizont.
    me->eye = 90.
    me->distance = 6.
    me->viewplane->set_hres( 200 ).
    me->viewplane->set_vres( 200 ).
    me->viewplane->set_num_samples( 16 ).

    me->background_color = zcl_art_rgb_color=>new_black( ).
    me->tracer = NEW zcl_art_multiple_objects( me ).

    DATA(plane) = zcl_art_plane=>new_by_normal_and_point(
      i_point = zcl_art_point3d=>new_individual( i_x = 0  i_y = -100  i_z = 0 )
      i_normal = zcl_art_normal=>new_individual( i_x = 0  i_y = 1     i_z = 0 ) ).
    plane->set_color_by_components( i_r = 0 i_g = '1' i_b = 0 ).
    add_object( plane ).
  ENDMETHOD.


  METHOD build_multiple_objects.
    me->eye = 90.
    me->distance = 6.
    me->viewplane->set_hres( 200 ).
    me->viewplane->set_vres( 200 ).
    me->viewplane->set_num_samples( 16 ).

    me->background_color = zcl_art_rgb_color=>new_black( ).
    me->tracer = NEW zcl_art_multiple_objects( me ).

    DATA sphere TYPE REF TO zcl_art_sphere.

    sphere = zcl_art_sphere=>new_default( ).
    sphere->set_center_by_components( i_x = 0 i_y = -25 i_z = 0 ).
    sphere->set_radius( '80.0' ).
    sphere->set_color_by_components( i_r = 1 i_g = 0 i_b = 0 ).
    add_object( sphere ).

    sphere = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_individual( i_x = 0 i_y = 30 i_z = 0 )
      i_radius = 60 ).
    sphere->set_color_by_components( i_r = 1 i_g = 1 i_b = 0 ).
    add_object( sphere ).

    DATA(plane) = zcl_art_plane=>new_by_normal_and_point(
      i_point = zcl_art_point3d=>new_default( )
      i_normal = zcl_art_normal=>new_individual( i_x = 0 i_y = 1 i_z = 1 ) ).
    plane->set_color_by_components( i_r = 0 i_g = '0.3' i_b = 0 ).
    add_object( plane ).
  ENDMETHOD.


  METHOD build_single_sphere.
    me->viewplane->set_hres( 200 ).
    me->viewplane->set_vres( 200 ).
    me->viewplane->set_pixel_size( '1.0' ).
    me->viewplane->set_gamma( '2.2' ).
    me->viewplane->set_num_samples( 1 ).

    me->background_color = zcl_art_rgb_color=>new_white( ).
    me->tracer = NEW zcl_art_single_sphere( me ).

    me->sphere->set_center_by_value( '0.0' ).
    me->sphere->set_radius( '85.0' ).
  ENDMETHOD.


  METHOD build_sinusoid_function.
    me->viewplane->set_hres( 512 ).
    me->viewplane->set_vres( 512 ).
    me->viewplane->set_pixel_size( '1.0' ).
    me->viewplane->set_gamma( '2.2' ).
    me->viewplane->set_sampler( zcl_art_nrooks=>new_by_num_samples( 25 ) ).

    me->tracer = NEW zcl_art_function_tracer( me ).

    set_function( NEW zcl_art_sinusoid_function( ) ).
  ENDMETHOD.


  METHOD build_with_pinhole.
    me->viewplane->set_hres( 300 ).
    me->viewplane->set_vres( 300 ).
    me->viewplane->set_num_samples( 1 ).

    me->tracer = NEW zcl_art_multiple_objects( me ).

    DATA(pinhole) = zcl_art_pinhole=>new_default( ).

    pinhole->set_eye_by_components( i_x = 0  i_y = 0  i_z = 500 ).
    pinhole->set_lookat_by_components( i_x = 0  i_y = 0  i_z = 0 ).
    pinhole->set_view_plane_distance( 500 ).

    pinhole->set_roll( 5 ).
    pinhole->set_yaw( -5 ).
    pinhole->set_pitch( -5 ).


*    pinhole->set_eye_by_components( i_x = 300  i_y = 400  i_z = 500 ).
*    pinhole->set_lookat_by_components( i_x = 0  i_y = 0  i_z = -50 ).
*    pinhole->set_view_plane_distance( '400' ).


    pinhole->compute_uvw( ).
    set_camera( pinhole ).

    DATA(sphere) = zcl_art_sphere=>new_by_center_and_radius(
                     i_center = zcl_art_point3d=>new_individual( i_x = -45  i_y = 45  i_z = 40 )
                     i_radius = '50' ).
    sphere->set_color_by_components( i_r = 1  i_g = 0  i_b = 0 ).
    add_object( sphere ).

    DATA(plane) = zcl_art_plane=>new_by_normal_and_point(
                    i_normal = zcl_art_normal=>new_individual( i_x = 0  i_y = 1  i_z = 0 )
                    i_point = zcl_art_point3d=>new_individual( i_x = 0  i_y = -101  i_z = 0 ) ).
    plane->set_color_by_components( i_r = 0  i_g = 1  i_b = 0 ).
    add_object( plane ).
  ENDMETHOD.


  METHOD clamp_to_color.
    r_color = zcl_art_rgb_color=>new_copy( i_color ).

    IF r_color->r > '1.0' OR
       r_color->g > '1.0' OR
       r_color->b > '1.0'.

      r_color->r = '1.0'.
      r_color->g = '0.0'.
      r_color->b = '0.0'.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    me->viewplane = zcl_art_viewplane=>new_default( ).

    IF i_image_height_in_pixel IS SUPPLIED.
      ASSERT i_image_height_in_pixel > 0.
      me->viewplane->set_hres( i_image_height_in_pixel ).
    ENDIF.

    IF i_image_width_in_pixel IS SUPPLIED.
      ASSERT i_image_width_in_pixel > 0.
      me->viewplane->set_hres( i_image_width_in_pixel ).
    ENDIF.

    me->background_color = zcl_art_rgb_color=>new_black( ).
    me->sphere = zcl_art_sphere=>new_default( ).
    me->bitmap = NEW zcl_art_bitmap(
      i_image_height_in_pixel = me->viewplane->vres
      i_image_width_in_pixel = me->viewplane->hres ).
    me->tracer = NEW zcl_art_multiple_objects( me ).

    ambient_light = zcl_art_ambient=>new_default( ).
  ENDMETHOD.


  METHOD display_pixel.
    " i_pixel_color is the pixel color computed by the ray tracer
    " its RGB floating point components can be arbitrarily large
    " mapped_color has all components in the range [0, 1], but still floating point
    " display color has integer components for computer display
    " the Mac's components are in the range [0, 65535]
    " a PC's components will probably be in the range [0, 255]
    " the system-dependent code is in the function convert_to_display_color
    " the function SetCPixel is a Mac OS function

    DATA mapped_color TYPE REF TO zcl_art_rgb_color.

    IF me->viewplane->show_out_of_gamut = abap_true.
      mapped_color = clamp_to_color( i_pixel_color ).
    ELSE.
      mapped_color = max_to_one( i_pixel_color ).
    ENDIF.

    IF me->viewplane->gamma <> '1.0'.
      mapped_color = mapped_color->powc( me->viewplane->inv_gamma ).
    ENDIF.

    DATA(x) = i_column.
    DATA(y) = me->viewplane->vres - i_row - 1.

    DATA r TYPE int4.
    DATA g TYPE int4.
    DATA b TYPE int4.
    r = mapped_color->r * 255.
    g = mapped_color->g * 255.
    b = mapped_color->b * 255.

    me->bitmap->add_pixel(
      VALUE #(
        x = x
        y = y
        r = r
        g = g
        b = b ) ).

*    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    IF x = 0.
*      WRITE /1(*) y NO-GAP.
*    ENDIF.
*
*    IF r > 0 OR g > 0 OR b > 0.
*      WRITE AT x(1) '#'.
*    ENDIF.
*    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ENDMETHOD.


  METHOD get_num_objects.
    r_num_objects = lines( _objects ).
  ENDMETHOD.


  METHOD hit_bare_bones_objects.
    DATA:
      t    TYPE decfloat16,
      tmin TYPE decfloat16 VALUE '10000000000'.

    r_shade_rec = zcl_art_shade_rec=>new_from_world( me ).

    LOOP AT _objects ASSIGNING FIELD-SYMBOL(<object>).
      DATA(hit) = <object>->hit(
        EXPORTING
          i_ray = i_ray
        IMPORTING
          e_tmin = t
        CHANGING
          c_shade_rec = r_shade_rec ).

      IF hit = abap_true AND
         t < tmin.
        r_shade_rec->hit_an_object = abap_true.
        tmin = t.
        r_shade_rec->color = <object>->get_color( ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD max_to_one.
    DATA max_value TYPE decfloat16.
    max_value = nmax( val1 = i_color->r
                      val2 = nmax( val1 = i_color->g
                                   val2 = i_color->b  ) ).

    IF max_value > '1.0'.
      r_color = i_color->get_quotient_by_decfloat( max_value ).
    ELSE.
      r_color = i_color.
    ENDIF.
  ENDMETHOD.


  METHOD render_perspective.
    DATA(ray) = zcl_art_ray=>new_default( ).
    ray->origin = zcl_art_point3d=>new_individual( i_x = 0  i_y = 0  i_z = me->eye ).

    DATA(hres) = me->viewplane->hres.
    DATA(vres) = me->viewplane->vres.
    DATA(pixel_size) = me->viewplane->pixel_size.

    DATA row TYPE int4.
    DATA column TYPE int4.
    WHILE row < vres.
      column = 0.
      WHILE column < hres.
        ray->direction = zcl_art_vector3d=>new_individual(
          i_x = pixel_size * ( column - '0.5' * ( hres - '1.0' ) )
          i_y = pixel_size * ( row - '0.5' * ( vres - '1.0' ) )
          i_z = -1 * me->distance ).

        ray->direction->normalize( ).

        DATA(pixel_color) = zcl_art_rgb_color=>new_copy( tracer->trace_ray( ray ) ).

        display_pixel(
          i_row = row
          i_column = column
          i_pixel_color = pixel_color ).

        ADD 1 TO column.
      ENDWHILE.

      ADD 1 TO row.
    ENDWHILE.
  ENDMETHOD.


  METHOD render_scene.
    me->num_rays = 0.

    DATA zw TYPE decfloat16 VALUE '100.0'. "hard wired in

    DATA(hres) = me->viewplane->hres.
    DATA(vres) = me->viewplane->vres.
    DATA(pixel_size) = me->viewplane->pixel_size.
    DATA(sample_point) = NEW zcl_art_point2d( ).
    DATA(pixel_point) = NEW zcl_art_point2d( ).

    DATA n TYPE int2.
    n = sqrt( me->viewplane->num_samples ).

    DATA(rand) = cl_abap_random_decfloat16=>create( ).

    DATA(ray) = zcl_art_ray=>new_default( ).
    ray->direction = zcl_art_vector3d=>new_individual( i_x = 0  i_y = 0  i_z = -1 ).

    DATA row TYPE int4.
    DATA column TYPE int4.
    WHILE row < vres.
      column = 0.
      WHILE column < hres.
        DATA(pixel_color) = zcl_art_rgb_color=>new_black( ).

        DO me->viewplane->num_samples TIMES.
          sample_point = me->viewplane->sampler->sample_unit_square( ).
          pixel_point->x = pixel_size * ( column - '0.5' * hres + sample_point->x ).
          pixel_point->y = pixel_size * ( row - '0.5' * vres + sample_point->y ).

          ray->origin = zcl_art_point3d=>new_individual(
            i_x = pixel_point->x
            i_y = pixel_point->y
            i_z = zw ).

          pixel_color->add_and_assign_by_color( tracer->trace_ray( ray ) ).
          ADD 1 TO me->num_rays.
        ENDDO.

        "Average the color
        pixel_color->divide_and_assign_by_decfloat( CONV #( me->viewplane->num_samples ) ).

        display_pixel(
          i_row = row
          i_column = column
          i_pixel_color = pixel_color ).
        ADD 1 TO column.
      ENDWHILE.

      ADD 1 TO row.
    ENDWHILE.
  ENDMETHOD.


  METHOD set_bitmap.
    ASSERT i_bitmap IS BOUND.
    me->bitmap = i_bitmap.
  ENDMETHOD.


  METHOD set_camera.
    ASSERT i_camera IS BOUND.
    me->camera = i_camera.
  ENDMETHOD.


  METHOD set_function.
    ASSERT i_function IS BOUND.
    me->function = i_function.
  ENDMETHOD.


  METHOD add_light.
    ASSERT i_light IS BOUND.
    INSERT i_light INTO TABLE me->lights.
  ENDMETHOD.


  METHOD set_ambient_light.
    ASSERT i_light IS BOUND.
    me->ambient_light = i_light.
  ENDMETHOD.


  METHOD hit_objects.
    r_shade_rec = zcl_art_shade_rec=>new_from_world( me ).

    DATA t TYPE decfloat16.

    DATA(normal) = zcl_art_normal=>new_default( ).

    DATA(local_hit_point) = zcl_art_point3d=>new_default( ).

    DATA tmin TYPE decfloat16 VALUE zcl_art_constants=>k_huge_value.

    LOOP AT _objects ASSIGNING FIELD-SYMBOL(<object>).
      DATA(hit) = <object>->hit(
        EXPORTING
          i_ray = i_ray
        IMPORTING
          e_tmin = t
        CHANGING
          c_shade_rec = r_shade_rec ).

      IF hit = abap_true AND
         t < tmin.
        r_shade_rec->hit_an_object = abap_true.
        tmin = t.
        r_shade_rec->material = <object>->get_material( ).
        r_shade_rec->hit_point = i_ray->origin->get_sum_by_vector( i_ray->direction->get_product_by_decfloat( t )  ).
        normal->assignment_by_normal( r_shade_rec->normal ).
        local_hit_point->assignment( r_shade_rec->local_hit_point ).
      ENDIF.
    ENDLOOP.

    IF r_shade_rec->hit_an_object = abap_true.
      r_shade_rec->t = tmin.
      r_shade_rec->normal = normal.
      r_shade_rec->local_hit_point = local_hit_point.
    ENDIF.
  ENDMETHOD.


  METHOD build_with_material.
    me->viewplane->set_hres( 200 ).
    me->viewplane->set_vres( 200 ).
    me->viewplane->set_num_samples( 1 ).

    me->tracer = NEW zcl_art_raycast( me ).

    DATA(ambient) = zcl_art_ambient=>new_default( ).
    ambient->scale_radiance( 1 ).
    ambient->set_color_by_components( i_r = 0  i_g = 0  i_b = 1 ).
    set_ambient_light( ambient ).

    DATA(pinhole) = zcl_art_pinhole=>new_default( ).

    pinhole->set_eye_by_components( i_x = 0  i_y = 0  i_z = 400 ).
    pinhole->set_lookat_by_components( i_x = -5  i_y = 0  i_z = 0 ).
    pinhole->set_view_plane_distance( 850 ).
    pinhole->compute_uvw( ).
    set_camera( pinhole ).

    DATA(pointlight) = zcl_art_pointlight=>new_default( ).
    pointlight->set_location_by_components( i_dx = 100  i_dy = 500  i_dz = 150 ).
    pointlight->scale_radiance( 3 ).
    add_light( pointlight ).

    DATA(pointlight2) = zcl_art_pointlight=>new_default( ).
    pointlight2->set_location_by_components( i_dx = -100  i_dy = -500  i_dz = 150 ).
    pointlight2->scale_radiance( 3 ).
    add_light( pointlight2 ).

    DATA(matte1) = zcl_art_matte=>new_default( ).
    matte1->set_ka( '0.25' ).
    matte1->set_kd( '0.65' ).
    matte1->set_cd_by_components( i_r = 1  i_g = 1  i_b = 0 ).

    DATA(sphere1) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_individual( i_x = 10  i_y = -5  i_z = 0 )
      i_radius = '27' ).
    sphere1->set_material( matte1 ).
    add_object( sphere1 ).

    DATA(matte2) = zcl_art_matte=>new_default( ).
    matte2->set_ka( '0.25' ).
    matte2->set_kd( '0.65' ).
    matte2->set_cd_by_components( i_r = 1  i_g = 0  i_b = 0 ).

    DATA(sphere2) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_individual( i_x = -20  i_y = 5  i_z = -30 )
      i_radius = '27' ).
    sphere2->set_material( matte2 ).
    add_object( sphere2 ).

    DATA(matte3) = zcl_art_matte=>new_default( ).
    matte3->set_ka( '0.25' ).
    matte3->set_kd( '0.65' ).
    matte3->set_cd_by_components( i_r = 0  i_g = 0  i_b = 1 ).

    DATA(plane) = zcl_art_plane=>new_by_normal_and_point(
      i_normal = zcl_art_normal=>new_individual( i_x = 0  i_y = 1  i_z = 0 )
      i_point = zcl_art_point3d=>new_individual( i_x = 0  i_y = -101  i_z = 0 ) ).
    plane->set_material( matte3 ).
    add_object( plane ).
  ENDMETHOD.

  METHOD build_paul.
    me->viewplane->set_hres( 400 ).
    me->viewplane->set_vres( 400 ).
    me->viewplane->set_num_samples( 16 ).

    me->tracer = NEW zcl_art_raycast( me ).

    DATA(ambient) = zcl_art_ambient=>new_default( ).
    ambient->scale_radiance( 1 ).
    ambient->set_color_by_components( i_r = 1  i_g = 0  i_b = 0 ).
    set_ambient_light( ambient ).

    DATA(pinhole) = zcl_art_pinhole=>new_default( ).

    pinhole->set_eye_by_components( i_x = 0  i_y = 0  i_z = 400 ).
    pinhole->set_lookat_by_components( i_x = -5  i_y = 0  i_z = 0 ).
    pinhole->set_view_plane_distance( 850 ).
    pinhole->compute_uvw( ).
    set_camera( pinhole ).

    DATA(pointlight) = zcl_art_pointlight=>new_default( ).
    pointlight->set_location_by_components( i_dx = 0  i_dy = 500  i_dz = 0 ).
    pointlight->scale_radiance( 3 ).
    add_light( pointlight ).

    DATA(matte) = zcl_art_matte=>new_default( ).
    matte->set_ka( '0.25' ).
    matte->set_kd( '0.65' ).
    matte->set_cd_by_components( i_r = 1  i_g = 1  i_b = 0 ).

    DATA(sphere1) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_individual( i_x = 10  i_y = -5  i_z = 0 )
      i_radius = '27' ).
    sphere1->set_material( matte ).
    add_object( sphere1 ).


    DATA(sphere2) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_individual( i_x = -20  i_y = 5  i_z = -30 )
      i_radius = '27' ).
    sphere2->set_material( matte ).
    add_object( sphere2 ).

    DATA(sphere3) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_individual( i_x = 10  i_y = -15  i_z = 0 )
      i_radius = '27' ).
    sphere3->set_material( matte ).
    add_object( sphere3 ).

    DATA(matte2) = zcl_art_matte=>new_default( ).
    matte2->set_ka( '0.25' ).
    matte2->set_kd( '0.65' ).
    matte2->set_cd_by_components( i_r = 1  i_g = 0  i_b = 0 ).

    DATA(sphere4) = zcl_art_sphere=>new_by_center_and_radius(
      i_center = zcl_art_point3d=>new_individual( i_x = -20  i_y = 15  i_z = -30 )
      i_radius = '27' ).
    sphere4->set_material( matte2 ).
    add_object( sphere4 ).
  ENDMETHOD.

ENDCLASS.
