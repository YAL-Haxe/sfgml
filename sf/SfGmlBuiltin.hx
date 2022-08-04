package sf;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlBuiltin {
	
	public static var keywords:String = "globalvar var begin end if then else for while do until repeat switch case default break continue with exit return self other noone all global local mod div not and or xor enum struct function try catch throw finally constructor delete method undefined";
	
	public static var vars:String = "application_surface argument argument0 argument1 argument10 argument11 argument12 argument13 argument14 argument15 argument2 argument3 argument4 argument5 argument6 argument7 argument8 argument9 argument_count argument_relative async_load background_alpha background_blend background_color background_colour background_foreground background_height background_hspeed background_htiled background_index background_showcolor background_showcolour background_visible background_vspeed background_vtiled background_width background_x background_xscale background_y background_yscale browser_height browser_width caption_health caption_lives caption_score current_day current_hour current_minute current_month current_second current_time current_weekday current_year cursor_sprite debug_mode delta_time display_aa error_last error_occurred event_action event_number event_object event_type fps fps_real game_display_name game_id game_project_name game_save_id gamemaker_pro gamemaker_registered gamemaker_version health iap_data instance_count instance_id keyboard_key keyboard_lastchar keyboard_lastkey keyboard_string lives mouse_button mouse_lastbutton mouse_x mouse_y os_browser os_device os_type os_version pointer_invalid pointer_null program_directory room room_caption room_first room_height room_last room_persistent room_speed room_width score secure_mode show_health show_lives show_score temp_directory transition_color transition_kind transition_steps undefined view_angle view_current view_enabled view_hborder view_hport view_hspeed view_hview view_object view_surface_id view_vborder view_visible view_vspeed view_wport view_wview view_xport view_xview view_yport view_yview webgl_enabled working_directory alarm bbox_bottom bbox_left bbox_right bbox_top depth direction friction gravity gravity_direction hspeed id image_alpha image_angle image_blend image_index image_number image_single image_speed image_xscale image_yscale mask_index object_index path_endaction path_index path_orientation path_position path_positionprevious path_scale path_speed persistent phy_active phy_angular_damping phy_angular_velocity phy_bullet phy_col_normal_x phy_col_normal_y phy_collision_points phy_collision_x phy_collision_y phy_com_x phy_com_y phy_dynamic phy_fixed_rotation phy_inertia phy_kinematic phy_linear_damping phy_linear_velocity_x phy_linear_velocity_y phy_mass phy_position_x phy_position_xprevious phy_position_y phy_position_yprevious phy_rotation phy_sleeping phy_speed phy_speed_x phy_speed_y solid speed sprite_height sprite_index sprite_width sprite_xoffset sprite_yoffset timeline_index timeline_loop timeline_position timeline_running timeline_speed visible vspeed x xprevious xstart y yprevious ystart";
	
	public static var functions:String = "YoYo_AchievementsAvailable YoYo_AddVirtualKey YoYo_CheckSecurity YoYo_DeleteVirtualKey YoYo_DisableAds YoYo_EnableAds YoYo_EnableAlphaBlend YoYo_GetCPUDetails YoYo_GetConfig YoYo_GetDevice YoYo_GetDomain YoYo_GetPictureSprite YoYo_GetPlatform YoYo_GetSessionKey YoYo_GetTiltX YoYo_GetTiltY YoYo_GetTiltZ YoYo_GetTimer YoYo_HideVirtualKey YoYo_IsKeypadOpen YoYo_LeaveRating YoYo_LoginAchievements YoYo_LogoutAchievements YoYo_MouseCheckButton YoYo_MouseCheckButtonPressed YoYo_MouseCheckButtonReleased YoYo_MouseX YoYo_MouseXRaw YoYo_MouseY YoYo_MouseYRaw YoYo_OSPauseEvent YoYo_OpenURL YoYo_OpenURL_ext YoYo_OpenURL_full YoYo_PostAchievement YoYo_PostScore YoYo_SelectPicture YoYo_ShowVirtualKey abs achievement_available achievement_event achievement_get_challenges achievement_get_info achievement_get_pic achievement_increment achievement_load_friends achievement_load_leaderboard achievement_load_progress achievement_login achievement_login_status achievement_logout achievement_post achievement_post_score achievement_reset achievement_send_challenge achievement_show achievement_show_achievements achievement_show_challenge_notifications achievement_show_leaderboards action_another_room action_bounce action_change_object action_color action_colour action_create_object action_create_object_motion action_create_object_random action_current_room action_draw_arrow action_draw_background action_draw_ellipse action_draw_ellipse_gradient action_draw_gradient_hor action_draw_gradient_vert action_draw_health action_draw_life action_draw_life_images action_draw_line action_draw_rectangle action_draw_score action_draw_sprite action_draw_text action_draw_text_transformed action_draw_variable action_effect action_end_game action_end_sound action_execute_script action_font action_fullscreen action_highscore_clear action_if action_if_aligned action_if_collision action_if_dice action_if_empty action_if_health action_if_life action_if_mouse action_if_next_room action_if_number action_if_object action_if_previous_room action_if_question action_if_score action_if_sound action_if_variable action_inherited action_kill_object action_kill_position action_linear_step action_load_game action_message action_move action_move_contact action_move_point action_move_random action_move_start action_move_to action_next_room action_partemit_burst action_partemit_create action_partemit_destroy action_partemit_stream action_partsyst_clear action_partsyst_create action_partsyst_destroy action_parttype_color action_parttype_colour action_parttype_create action_parttype_gravity action_parttype_life action_parttype_secondary action_parttype_speed action_path action_path_end action_path_position action_path_speed action_potential_step action_previous_room action_replace_background action_replace_sound action_replace_sprite action_restart_game action_reverse_xdir action_reverse_ydir action_save_game action_set_alarm action_set_cursor action_set_friction action_set_gravity action_set_health action_set_hspeed action_set_life action_set_motion action_set_score action_set_timeline_position action_set_timeline_speed action_set_vspeed action_snap action_snapshot action_sound action_sprite_color action_sprite_colour action_sprite_set action_sprite_transform action_timeline_pause action_timeline_set action_timeline_start action_timeline_stop action_webpage action_wrap ads_disable ads_enable ads_engagement_active ads_engagement_available ads_engagement_launch ads_event ads_event_preload ads_get_display_height ads_get_display_width ads_interstitial_available ads_interstitial_display ads_move ads_set_reward_callback ads_setup alarm_get alarm_set analytics_event analytics_event_ext angle_difference ansi_char application_get_position application_surface_draw_enable application_surface_enable application_surface_is_enabled arccos arcsin arctan arctan2 array_get array_get_2D array_height_2d array_length_1d array_length_2d array_set array_set_2D array_set_2D_post array_set_2D_pre array_set_post array_set_pre asset_get_index asset_get_type audio_channel_num audio_create_buffer_sound audio_create_play_queue audio_create_stream audio_create_sync_group audio_debug audio_destroy_stream audio_destroy_sync_group audio_emitter_create audio_emitter_exists audio_emitter_falloff audio_emitter_free audio_emitter_gain audio_emitter_get_gain audio_emitter_get_listener_mask audio_emitter_get_pitch audio_emitter_get_vx audio_emitter_get_vy audio_emitter_get_vz audio_emitter_get_x audio_emitter_get_y audio_emitter_get_z audio_emitter_pitch audio_emitter_position audio_emitter_set_listener_mask audio_emitter_velocity audio_exists audio_falloff_set_model audio_free_buffer_sound audio_free_play_queue audio_get_listener_count audio_get_listener_info audio_get_listener_mask audio_get_master_gain audio_get_name audio_get_recorder_count audio_get_recorder_info audio_get_type audio_group_is_loaded audio_group_load audio_group_load_progress audio_group_name audio_group_set_gain audio_group_stop_all audio_group_unload audio_is_paused audio_is_playing audio_listener_get_data audio_listener_orientation audio_listener_position audio_listener_set_orientation audio_listener_set_position audio_listener_set_velocity audio_listener_velocity audio_master_gain audio_pause_all audio_pause_sound audio_pause_sync_group audio_play_in_sync_group audio_play_sound audio_play_sound_at audio_play_sound_on audio_queue_sound audio_resume_all audio_resume_sound audio_resume_sync_group audio_set_listener_mask audio_set_master_gain audio_sound_gain audio_sound_get_gain audio_sound_get_listener_mask audio_sound_get_pitch audio_sound_get_track_position audio_sound_length audio_sound_pitch audio_sound_set_listener_mask audio_sound_set_track_position audio_start_recording audio_start_sync_group audio_stop_all audio_stop_recording audio_stop_sound audio_stop_sync_group audio_sync_group_debug audio_sync_group_get_track_pos audio_sync_group_is_playing audio_system background_add background_assign background_create_color background_create_colour background_create_from_surface background_create_gradient background_delete background_duplicate background_exists background_get_height background_get_name background_get_texture background_get_uvs background_get_width background_prefetch background_prefetch_multi background_replace background_save background_set_alpha_from_background base64_decode base64_encode browser_input_capture buffer_async_group_begin buffer_async_group_end buffer_async_group_option buffer_base64_decode buffer_base64_decode_ext buffer_base64_encode buffer_copy buffer_copy_from_vertex_buffer buffer_create buffer_create_from_vertex_buffer buffer_create_from_vertex_buffer_ext buffer_delete buffer_fill buffer_get_address buffer_get_size buffer_get_surface buffer_load buffer_load_async buffer_load_ext buffer_load_partial buffer_md5 buffer_peek buffer_poke buffer_read buffer_resize buffer_save buffer_save_async buffer_save_ext buffer_seek buffer_set_surface buffer_sha1 buffer_sizeof buffer_tell buffer_write ceil choose chr clamp clickable_add clickable_add_ext clickable_change clickable_change_ext clickable_delete clickable_exists clickable_set_style clipboard_get_text clipboard_has_text clipboard_set_text cloud_file_save cloud_string_save cloud_synchronise code_is_compiled collision_circle collision_ellipse collision_line collision_point collision_rectangle color_get_blue color_get_green color_get_hue color_get_red color_get_saturation color_get_value colour_get_blue colour_get_green colour_get_hue colour_get_red colour_get_saturation colour_get_value cos d3d_draw_block d3d_draw_cone d3d_draw_cylinder d3d_draw_ellipsoid d3d_draw_floor d3d_draw_wall d3d_end d3d_light_define_ambient d3d_light_define_direction d3d_light_define_point d3d_light_enable d3d_model_block d3d_model_clear d3d_model_cone d3d_model_create d3d_model_cylinder d3d_model_destroy d3d_model_draw d3d_model_ellipsoid d3d_model_floor d3d_model_load d3d_model_primitive_begin d3d_model_primitive_end d3d_model_save d3d_model_vertex d3d_model_vertex_color d3d_model_vertex_colour d3d_model_vertex_normal d3d_model_vertex_normal_color d3d_model_vertex_normal_colour d3d_model_vertex_normal_texture d3d_model_vertex_normal_texture_color d3d_model_vertex_normal_texture_colour d3d_model_vertex_texture d3d_model_vertex_texture_color d3d_model_vertex_texture_colour d3d_model_wall d3d_primitive_begin d3d_primitive_begin_texture d3d_primitive_end d3d_set_culling d3d_set_depth d3d_set_fog d3d_set_hidden d3d_set_lighting d3d_set_perspective d3d_set_projection d3d_set_projection_ext d3d_set_projection_ortho d3d_set_projection_perspective d3d_set_shading d3d_set_zwriteenable d3d_start d3d_transform_add_rotation_axis d3d_transform_add_rotation_x d3d_transform_add_rotation_y d3d_transform_add_rotation_z d3d_transform_add_scaling d3d_transform_add_translation d3d_transform_set_identity d3d_transform_set_rotation_axis d3d_transform_set_rotation_x d3d_transform_set_rotation_y d3d_transform_set_rotation_z d3d_transform_set_scaling d3d_transform_set_translation d3d_transform_stack_clear d3d_transform_stack_discard d3d_transform_stack_empty d3d_transform_stack_pop d3d_transform_stack_push d3d_transform_stack_top d3d_transform_vertex d3d_vertex d3d_vertex_color d3d_vertex_colour d3d_vertex_normal d3d_vertex_normal_color d3d_vertex_normal_colour d3d_vertex_normal_texture d3d_vertex_normal_texture_color d3d_vertex_normal_texture_colour d3d_vertex_texture d3d_vertex_texture_color d3d_vertex_texture_colour darccos darcsin darctan darctan2 date_compare_date date_compare_datetime date_compare_time date_create_datetime date_current_datetime date_date_of date_date_string date_datetime_string date_day_span date_days_in_month date_days_in_year date_get_day date_get_day_of_year date_get_hour date_get_hour_of_year date_get_minute date_get_minute_of_year date_get_month date_get_second date_get_second_of_year date_get_timezone date_get_week date_get_weekday date_get_year date_hour_span date_inc_day date_inc_hour date_inc_minute date_inc_month date_inc_second date_inc_week date_inc_year date_is_today date_leap_year date_minute_span date_month_span date_second_span date_set_timezone date_time_of date_time_string date_valid_datetime date_week_span date_year_span dcos degtorad device_get_tilt_x device_get_tilt_y device_get_tilt_z device_is_keypad_open device_mouse_check_button device_mouse_check_button_pressed device_mouse_check_button_released device_mouse_dbclick_enable device_mouse_raw_x device_mouse_raw_y device_mouse_x device_mouse_x_to_gui device_mouse_y device_mouse_y_to_gui directory_create directory_destroy directory_exists display_get_dpi_x display_get_dpi_y display_get_gui_height display_get_gui_width display_get_height display_get_orientation display_get_width display_get_windows_alternate_sync display_get_windows_vertex_buffer_method display_mouse_get_x display_mouse_get_y display_mouse_set display_reset display_set_gui_maximise display_set_gui_size display_set_windows_alternate_sync display_set_windows_vertex_buffer_method distance_to_object distance_to_point dot_product dot_product_3d dot_product_3d_normalised dot_product_normalised draw_arrow draw_background draw_background_ext draw_background_general draw_background_part draw_background_part_ext draw_background_stretched draw_background_stretched_ext draw_background_tiled draw_background_tiled_ext draw_button draw_circle draw_circle_color draw_circle_colour draw_clear draw_clear_alpha draw_ellipse draw_ellipse_color draw_ellipse_colour draw_enable_alphablend draw_enable_drawevent draw_enable_swf_aa draw_flush draw_get_alpha draw_get_alpha_test draw_get_alpha_test_ref_value draw_get_color draw_get_colour draw_get_swf_aa_level draw_getpixel draw_getpixel_ext draw_healthbar draw_highscore draw_line draw_line_color draw_line_colour draw_line_width draw_line_width_color draw_line_width_colour draw_path draw_point draw_point_color draw_point_colour draw_primitive_begin draw_primitive_begin_texture draw_primitive_end draw_rectangle draw_rectangle_color draw_rectangle_colour draw_roundrect draw_roundrect_color draw_roundrect_color_ext draw_roundrect_colour draw_roundrect_colour_ext draw_roundrect_ext draw_self draw_set_alpha draw_set_alpha_test draw_set_alpha_test_ref_value draw_set_blend_mode draw_set_blend_mode_ext draw_set_circle_precision draw_set_color draw_set_color_write_enable draw_set_colour draw_set_colour_write_enable draw_set_font draw_set_halign draw_set_swf_aa_level draw_set_valign draw_skeleton draw_skeleton_collision draw_skeleton_time draw_sprite draw_sprite_ext draw_sprite_general draw_sprite_part draw_sprite_part_ext draw_sprite_pos draw_sprite_stretched draw_sprite_stretched_ext draw_sprite_tiled draw_sprite_tiled_ext draw_surface draw_surface_ext draw_surface_general draw_surface_part draw_surface_part_ext draw_surface_stretched draw_surface_stretched_ext draw_surface_tiled draw_surface_tiled_ext draw_text draw_text_color draw_text_colour draw_text_ext draw_text_ext_color draw_text_ext_colour draw_text_ext_transformed draw_text_ext_transformed_color draw_text_ext_transformed_colour draw_text_transformed draw_text_transformed_color draw_text_transformed_colour draw_texture_flush draw_triangle draw_triangle_color draw_triangle_colour draw_vertex draw_vertex_color draw_vertex_colour draw_vertex_texture draw_vertex_texture_color draw_vertex_texture_colour ds_exists ds_grid_add ds_grid_add_disk ds_grid_add_grid_region ds_grid_add_region ds_grid_clear ds_grid_copy ds_grid_create ds_grid_destroy ds_grid_get ds_grid_get_disk_max ds_grid_get_disk_mean ds_grid_get_disk_min ds_grid_get_disk_sum ds_grid_get_max ds_grid_get_mean ds_grid_get_min ds_grid_get_pre ds_grid_get_sum ds_grid_height ds_grid_multiply ds_grid_multiply_disk ds_grid_multiply_grid_region ds_grid_multiply_region ds_grid_read ds_grid_resize ds_grid_set ds_grid_set_disk ds_grid_set_grid_region ds_grid_set_pre ds_grid_set_region ds_grid_shuffle ds_grid_sort ds_grid_value_disk_exists ds_grid_value_disk_x ds_grid_value_disk_y ds_grid_value_exists ds_grid_value_x ds_grid_value_y ds_grid_width ds_grid_write ds_list_add ds_list_clear ds_list_copy ds_list_create ds_list_delete ds_list_destroy ds_list_empty ds_list_find_index ds_list_find_value ds_list_insert ds_list_mark_as_list ds_list_mark_as_map ds_list_read ds_list_replace ds_list_set ds_list_set_post ds_list_set_pre ds_list_shuffle ds_list_size ds_list_sort ds_list_write ds_map_add ds_map_add_list ds_map_add_map ds_map_clear ds_map_copy ds_map_create ds_map_delete ds_map_destroy ds_map_empty ds_map_exists ds_map_find_first ds_map_find_last ds_map_find_next ds_map_find_previous ds_map_find_value ds_map_read ds_map_replace ds_map_replace_list ds_map_replace_map ds_map_secure_load ds_map_secure_save ds_map_set ds_map_set_post ds_map_set_pre ds_map_size ds_map_write ds_priority_add ds_priority_change_priority ds_priority_clear ds_priority_copy ds_priority_create ds_priority_delete_max ds_priority_delete_min ds_priority_delete_value ds_priority_destroy ds_priority_empty ds_priority_find_max ds_priority_find_min ds_priority_find_priority ds_priority_read ds_priority_size ds_priority_write ds_queue_clear ds_queue_copy ds_queue_create ds_queue_dequeue ds_queue_destroy ds_queue_empty ds_queue_enqueue ds_queue_head ds_queue_read ds_queue_size ds_queue_tail ds_queue_write ds_set_precision ds_stack_clear ds_stack_copy ds_stack_create ds_stack_destroy ds_stack_empty ds_stack_pop ds_stack_push ds_stack_read ds_stack_size ds_stack_top ds_stack_write dsin dtan effect_clear effect_create_above effect_create_below environment_get_variable event_inherited event_perform event_perform_object event_user exp external_call external_define external_free facebook_accesstoken facebook_check_permission facebook_dialog facebook_graph_request facebook_init facebook_launch_offerwall facebook_login facebook_logout facebook_post_message facebook_request_publish_permissions facebook_request_read_permissions facebook_send_invite facebook_status facebook_user_id file_attributes file_bin_close file_bin_open file_bin_position file_bin_read_byte file_bin_rewrite file_bin_seek file_bin_size file_bin_write_byte file_copy file_delete file_exists file_find_close file_find_first file_find_next file_rename file_text_close file_text_eof file_text_eoln file_text_open_append file_text_open_from_string file_text_open_read file_text_open_write file_text_read_real file_text_read_string file_text_readln file_text_write_real file_text_write_string file_text_writeln filename_change_ext filename_dir filename_drive filename_ext filename_name filename_path floor font_add font_add_sprite font_add_sprite_ext font_delete font_exists font_get_bold font_get_first font_get_fontname font_get_italic font_get_last font_get_name font_get_size font_get_texture font_get_uvs font_replace font_replace_sprite font_replace_sprite_ext font_set_cache_size frac game_end game_load game_load_buffer game_restart game_save game_save_buffer gamepad_axis_count gamepad_axis_value gamepad_button_check gamepad_button_check_pressed gamepad_button_check_released gamepad_button_count gamepad_button_value gamepad_get_axis_deadzone gamepad_get_button_threshold gamepad_get_description gamepad_get_device_count gamepad_is_connected gamepad_is_supported gamepad_set_axis_deadzone gamepad_set_button_threshold gamepad_set_color gamepad_set_colour gamepad_set_vibration get_integer get_integer_async get_login_async get_open_filename get_open_filename_ext get_save_filename get_save_filename_ext get_string get_string_async get_timer gml_pragma gml_release_mode highscore_add highscore_clear highscore_name highscore_value http_get http_get_file http_post_string http_request iap_acquire iap_activate iap_consume iap_enumerate_products iap_is_purchased iap_product_details iap_purchase_details iap_restore_all iap_status immersion_play_effect immersion_stop ini_close ini_key_delete ini_key_exists ini_open ini_open_from_string ini_read_real ini_read_string ini_section_delete ini_section_exists ini_write_real ini_write_string instance_activate_all instance_activate_object instance_activate_region instance_change instance_copy instance_create instance_deactivate_all instance_deactivate_object instance_deactivate_region instance_destroy instance_exists instance_find instance_furthest instance_nearest instance_number instance_place instance_position int64 io_clear irandom irandom_range is_array is_bool is_int32 is_int64 is_matrix is_ptr is_real is_string is_undefined is_vec3 is_vec4 joystick_axes joystick_buttons joystick_check_button joystick_direction joystick_exists joystick_has_pov joystick_name joystick_pov joystick_rpos joystick_upos joystick_vpos joystick_xpos joystick_ypos joystick_zpos json_decode json_encode keyboard_check keyboard_check_direct keyboard_check_pressed keyboard_check_released keyboard_clear keyboard_get_map keyboard_get_numlock keyboard_key_press keyboard_key_release keyboard_set_map keyboard_set_numlock keyboard_unset_map lengthdir_x lengthdir_y lerp ln log10 log2 logn make_color_hsv make_color_rgb make_colour_hsv make_colour_rgb math_get_epsilon math_set_epsilon matrix_build matrix_get matrix_multiply matrix_set max md5_file md5_string_unicode md5_string_utf8 mean median merge_color merge_colour min motion_add motion_set mouse_check_button mouse_check_button_pressed mouse_check_button_released mouse_clear mouse_wheel_down mouse_wheel_up move_bounce move_bounce_all move_bounce_solid move_contact move_contact_all move_contact_solid move_outside_all move_outside_solid move_random move_snap move_towards_point move_wrap mp_grid_add_cell mp_grid_add_instances mp_grid_add_rectangle mp_grid_clear_all mp_grid_clear_cell mp_grid_clear_rectangle mp_grid_create mp_grid_destroy mp_grid_draw mp_grid_get_cell mp_grid_path mp_grid_to_ds_grid mp_linear_path mp_linear_path_object mp_linear_step mp_linear_step_object mp_potential_path mp_potential_path_object mp_potential_settings mp_potential_step mp_potential_step_object network_connect network_connect_raw network_create_server network_create_server_raw network_create_socket network_create_socket_ext network_destroy network_destroy network_get_address network_resolve network_send_broadcast network_send_packet network_send_raw network_send_udp network_send_udp_raw network_set_config network_set_timeout object_exists object_get_depth object_get_mask object_get_name object_get_parent object_get_persistent object_get_physics object_get_solid object_get_sprite object_get_visible object_is_ancestor object_set_depth object_set_mask object_set_persistent object_set_solid object_set_sprite object_set_visible ord os_get_config os_get_info os_get_language os_get_region os_is_network_connected os_is_paused os_lock_orientation os_powersave_enable parameter_count parameter_string part_emitter_burst part_emitter_clear part_emitter_create part_emitter_destroy part_emitter_destroy_all part_emitter_exists part_emitter_region part_emitter_stream part_particles_clear part_particles_count part_particles_create part_particles_create_color part_particles_create_colour part_system_automatic_draw part_system_automatic_update part_system_clear part_system_create part_system_depth part_system_destroy part_system_draw_order part_system_drawit part_system_exists part_system_position part_system_update part_type_alpha part_type_alpha1 part_type_alpha2 part_type_alpha3 part_type_blend part_type_clear part_type_color part_type_color1 part_type_color2 part_type_color3 part_type_color_hsv part_type_color_mix part_type_color_rgb part_type_colour part_type_colour1 part_type_colour2 part_type_colour3 part_type_colour_hsv part_type_colour_mix part_type_colour_rgb part_type_create part_type_death part_type_destroy part_type_direction part_type_exists part_type_gravity part_type_life part_type_orientation part_type_scale part_type_shape part_type_size part_type_speed part_type_sprite part_type_step path_add path_add_point path_append path_assign path_change_point path_clear_points path_delete path_delete_point path_duplicate path_end path_exists path_flip path_get_closed path_get_kind path_get_length path_get_name path_get_number path_get_point_speed path_get_point_x path_get_point_y path_get_precision path_get_speed path_get_time path_get_x path_get_y path_insert_point path_mirror path_rescale path_reverse path_rotate path_set_closed path_set_kind path_set_precision path_shift path_start physics_apply_angular_impulse physics_apply_force physics_apply_impulse physics_apply_local_force physics_apply_local_impulse physics_apply_torque physics_draw_debug physics_fixture_add_point physics_fixture_bind physics_fixture_bind_ext physics_fixture_create physics_fixture_delete physics_fixture_set_angular_damping physics_fixture_set_awake physics_fixture_set_box_shape physics_fixture_set_chain_shape physics_fixture_set_circle_shape physics_fixture_set_collision_group physics_fixture_set_density physics_fixture_set_edge_shape physics_fixture_set_friction physics_fixture_set_kinematic physics_fixture_set_linear_damping physics_fixture_set_polygon_shape physics_fixture_set_restitution physics_fixture_set_sensor physics_get_density physics_get_friction physics_get_restitution physics_joint_delete physics_joint_distance_create physics_joint_enable_motor physics_joint_friction_create physics_joint_gear_create physics_joint_get_value physics_joint_prismatic_create physics_joint_pulley_create physics_joint_revolute_create physics_joint_rope_create physics_joint_set_value physics_joint_weld_create physics_joint_wheel_create physics_mass_properties physics_particle_count physics_particle_create physics_particle_delete physics_particle_delete_region_box physics_particle_delete_region_circle physics_particle_delete_region_poly physics_particle_draw physics_particle_draw_ext physics_particle_get_damping physics_particle_get_data physics_particle_get_data_particle physics_particle_get_density physics_particle_get_gravity_scale physics_particle_get_group_flags physics_particle_get_max_count physics_particle_get_radius physics_particle_group_add_point physics_particle_group_begin physics_particle_group_box physics_particle_group_circle physics_particle_group_count physics_particle_group_delete physics_particle_group_end physics_particle_group_get_ang_vel physics_particle_group_get_angle physics_particle_group_get_centre_x physics_particle_group_get_centre_y physics_particle_group_get_data physics_particle_group_get_inertia physics_particle_group_get_mass physics_particle_group_get_vel_x physics_particle_group_get_vel_y physics_particle_group_get_x physics_particle_group_get_y physics_particle_group_join physics_particle_group_polygon physics_particle_set_category_flags physics_particle_set_damping physics_particle_set_density physics_particle_set_flags physics_particle_set_gravity_scale physics_particle_set_group_flags physics_particle_set_max_count physics_particle_set_radius physics_pause_enable physics_remove_fixture physics_set_density physics_set_friction physics_set_restitution physics_test_overlap physics_world_create physics_world_draw_debug physics_world_gravity physics_world_update_iterations physics_world_update_speed place_empty place_free place_meeting place_snapped playhaven_add_notification_badge playhaven_hide_notification_badge playhaven_position_notification_badge playhaven_update_notification_badge pocketchange_display_reward pocketchange_display_shop point_direction point_distance point_distance_3d point_in_circle point_in_rectangle point_in_triangle position_change position_destroy position_empty position_meeting power ptr push_cancel_local_notification push_get_first_local_notification push_get_next_local_notification push_local_notification radtodeg random random_get_seed random_range random_set_seed random_use_old_version randomize real rectangle_in_circle rectangle_in_rectangle rectangle_in_triangle room_add room_assign room_duplicate room_exists room_get_name room_goto room_goto_next room_goto_previous room_instance_add room_instance_clear room_next room_previous room_restart room_set_background room_set_background_color room_set_background_colour room_set_height room_set_persistent room_set_view room_set_view_enabled room_set_width room_tile_add room_tile_add_ext room_tile_clear round screen_save screen_save_part script_execute script_exists script_get_name sha1_file sha1_string_unicode sha1_string_utf8 shader_enable_corner_id shader_get_sampler_index shader_get_uniform shader_is_compiled shader_reset shader_set shader_set_uniform_f shader_set_uniform_f_array shader_set_uniform_i shader_set_uniform_i_array shader_set_uniform_matrix shader_set_uniform_matrix_array shaders_are_supported shop_leave_rating show_debug_message show_debug_overlay show_error show_message show_message show_message_async show_question show_question_async sign sin skeleton_animation_clear skeleton_animation_get skeleton_animation_get_duration skeleton_animation_get_ext skeleton_animation_list skeleton_animation_mix skeleton_animation_set skeleton_animation_set_ext skeleton_attachment_create skeleton_attachment_get skeleton_attachment_set skeleton_bone_data_get skeleton_bone_data_set skeleton_bone_state_get skeleton_bone_state_set skeleton_collision_draw_set skeleton_skin_get skeleton_skin_list skeleton_skin_set skeleton_slot_data sound_delete sound_exists sound_fade sound_get_name sound_global_volume sound_isplaying sound_loop sound_play sound_stop sound_stop_all sound_volume sprite_add sprite_add_from_surface sprite_assign sprite_collision_mask sprite_create_from_surface sprite_delete sprite_duplicate sprite_exists sprite_get_bbox_bottom sprite_get_bbox_left sprite_get_bbox_right sprite_get_bbox_top sprite_get_height sprite_get_name sprite_get_number sprite_get_texture sprite_get_tpe sprite_get_uvs sprite_get_width sprite_get_xoffset sprite_get_yoffset sprite_merge sprite_prefetch sprite_prefetch_multi sprite_replace sprite_save sprite_save_strip sprite_set_alpha_from_sprite sprite_set_cache_size sprite_set_cache_size_ext sprite_set_offset sqr sqrt steam_activate_overlay steam_activate_overlay_browser steam_activate_overlay_store steam_activate_overlay_user steam_available_languages steam_clear_achievement steam_create_leaderboard steam_current_game_language steam_download_friends_scores steam_download_scores steam_download_scores_around_user steam_file_delete steam_file_exists steam_file_persisted steam_file_read steam_file_share steam_file_size steam_file_write steam_file_write_file steam_get_achievement steam_get_app_id steam_get_persona_name steam_get_quota_free steam_get_quota_total steam_get_stat_avg_rate steam_get_stat_float steam_get_stat_int steam_get_user_account_id steam_get_user_persona_name steam_get_user_steam_id steam_initialised steam_is_cloud_enabled_for_account steam_is_cloud_enabled_for_app steam_is_overlay_activated steam_is_overlay_enabled steam_is_screenshot_requested steam_is_user_logged_on steam_publish_workshop_file steam_reset_all_stats steam_reset_all_stats_achievements steam_send_screenshot steam_set_achievement steam_set_stat_avg_rate steam_set_stat_float steam_set_stat_int steam_stats_ready steam_ugc_create_item steam_ugc_create_query_all steam_ugc_create_query_all_ex steam_ugc_create_query_user steam_ugc_create_query_user_ex steam_ugc_download steam_ugc_get_item_install_info steam_ugc_get_item_update_info steam_ugc_get_item_update_progress steam_ugc_get_subscribed_items steam_ugc_num_subscribed_items steam_ugc_query_add_excluded_tag steam_ugc_query_add_required_tag steam_ugc_query_set_allow_cached_response steam_ugc_query_set_cloud_filename_filter steam_ugc_query_set_match_any_tag steam_ugc_query_set_ranked_by_trend_days steam_ugc_query_set_return_long_description steam_ugc_query_set_return_total_only steam_ugc_query_set_search_text steam_ugc_request_item_details steam_ugc_send_query steam_ugc_set_item_content steam_ugc_set_item_description steam_ugc_set_item_preview steam_ugc_set_item_tags steam_ugc_set_item_title steam_ugc_set_item_visibility steam_ugc_start_item_update steam_ugc_submit_item_update steam_ugc_subscribe_item steam_ugc_unsubscribe_item steam_upload_score steam_upload_score_buffer steam_user_installed_dlc steam_user_owns_dlc string string_byte_at string_byte_length string_char_at string_copy string_count string_delete string_digits string_format string_height string_height_ext string_insert string_length string_letters string_lettersdigits string_lower string_ord_at string_pos string_repeat string_replace string_replace_all string_set_byte_at string_upper string_width string_width_ext surface_copy surface_copy_part surface_create surface_create_ext surface_exists surface_free surface_get_height surface_get_texture surface_get_width surface_getpixel surface_getpixel_ext surface_reset_target surface_resize surface_save surface_save_part surface_set_target surface_set_target_ext tan texture_exists texture_get_height texture_get_texel_height texture_get_texel_width texture_get_width texture_set_blending texture_set_interpolation texture_set_interpolation_ext texture_set_repeat texture_set_repeat_ext texture_set_stage tile_add tile_delete tile_delete_at tile_exists tile_find tile_get_alpha tile_get_background tile_get_blend tile_get_count tile_get_depth tile_get_height tile_get_id tile_get_ids tile_get_ids_at_depth tile_get_left tile_get_top tile_get_visible tile_get_width tile_get_x tile_get_xscale tile_get_y tile_get_yscale tile_layer_delete tile_layer_delete_at tile_layer_depth tile_layer_find tile_layer_hide tile_layer_shift tile_layer_show tile_set_alpha tile_set_background tile_set_blend tile_set_depth tile_set_position tile_set_region tile_set_scale tile_set_visible timeline_add timeline_clear timeline_delete timeline_exists timeline_get_name timeline_max_moment timeline_moment_add_script timeline_moment_clear timeline_size url_get_domain url_open url_open_ext url_open_full uwp_check_privilege uwp_is_constrained uwp_is_suspending uwp_license_trial_time_remaining uwp_license_trial_user uwp_license_trial_version uwp_show_help uwp_suspend uwp_was_closed_by_user uwp_was_terminated vertex_argb vertex_begin vertex_colour vertex_create_buffer vertex_create_buffer_ext vertex_create_buffer_from_buffer vertex_create_buffer_from_buffer_ext vertex_delete_buffer vertex_end vertex_float1 vertex_float2 vertex_float3 vertex_float4 vertex_format_add_colour vertex_format_add_custom vertex_format_add_normal vertex_format_add_position vertex_format_add_position_3d vertex_format_add_textcoord vertex_format_begin vertex_format_delete vertex_format_end vertex_freeze vertex_get_buffer_size vertex_get_number vertex_normal vertex_position vertex_position_3d vertex_submit vertex_texcoord vertex_ubyte4 virtual_key_add virtual_key_delete virtual_key_hide virtual_key_show win8_appbar_add_element win8_appbar_enable win8_appbar_remove_element win8_device_touchscreen_available win8_license_initialize_sandbox win8_license_trial_version win8_livetile_badge_clear win8_livetile_badge_notification win8_livetile_notification_begin win8_livetile_notification_end win8_livetile_notification_expiry win8_livetile_notification_image_add win8_livetile_notification_secondary_begin win8_livetile_notification_tag win8_livetile_notification_text_add win8_livetile_queue_enable win8_livetile_tile_clear win8_livetile_tile_notification win8_search_add_suggestions win8_search_disable win8_search_enable win8_secondarytile_badge_notification win8_secondarytile_delete win8_secondarytile_pin win8_settingscharm_add_entry win8_settingscharm_add_html_entry win8_settingscharm_add_xaml_entry win8_settingscharm_get_xaml_property win8_settingscharm_remove_entry win8_settingscharm_set_xaml_property win8_share_file win8_share_image win8_share_screenshot win8_share_text win8_share_url window_center window_device window_get_caption window_get_color window_get_colour window_get_cursor window_get_fullscreen window_get_height window_get_visible_rects window_get_width window_get_x window_get_y window_handle window_has_focus window_mouse_get_x window_mouse_get_y window_mouse_set window_set_caption window_set_color window_set_colour window_set_cursor window_set_fullscreen window_set_max_height window_set_max_width window_set_min_height window_set_min_width window_set_position window_set_rectangle window_set_size window_view_mouse_get_x window_view_mouse_get_y window_views_mouse_get_x window_views_mouse_get_y winphone_license_trial_version winphone_tile_back_content winphone_tile_back_content_wide winphone_tile_back_image winphone_tile_back_image_wide winphone_tile_back_title winphone_tile_background_color winphone_tile_background_colour winphone_tile_count winphone_tile_cycle_images winphone_tile_front_image winphone_tile_front_image_small winphone_tile_front_image_wide winphone_tile_icon_image winphone_tile_small_background_image winphone_tile_small_icon_image winphone_tile_title winphone_tile_wide_content xboxlive_agegroup_for_user xboxlive_appdisplayname_for_user xboxlive_chat_add_user_to_channel xboxlive_chat_remove_user_from_channel xboxlive_chat_set_muted xboxlive_fire_event xboxlive_gamedisplayname_for_user xboxlive_gamerscore_for_user xboxlive_generate_player_session_id xboxlive_get_activating_user xboxlive_get_file_error xboxlive_get_savedata_user xboxlive_get_stats_for_user xboxlive_get_user xboxlive_get_user_count xboxlive_matchmaking_create xboxlive_matchmaking_find xboxlive_matchmaking_join_invite xboxlive_matchmaking_send_invites xboxlive_matchmaking_session_get_users xboxlive_matchmaking_session_leave xboxlive_matchmaking_set_joinable_session xboxlive_matchmaking_start xboxlive_matchmaking_stop xboxlive_pad_count_for_user xboxlive_pad_for_user xboxlive_reputation_for_user xboxlive_set_rich_presence xboxlive_set_savedata_user xboxlive_set_service_configuration_id xboxlive_show_account_picker xboxlive_show_profile_card_for_user xboxlive_sponsor_for_user xboxlive_sprite_add_from_gamerpicture xboxlive_stats_setup xboxlive_user_for_pad xboxlive_user_id_for_user xboxlive_user_is_active xboxlive_user_is_guest xboxlive_user_is_remote xboxlive_user_is_signed_in zip_unzip";
}
