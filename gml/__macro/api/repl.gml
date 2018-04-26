// Mostly from GMLive.
:alarm_get(:index):
:alarm_set(:index, value:number)
//{ Instance
instance_exists(obj:index):
instance_number(obj:index):
instance_position(x:number, y:number, obj:index):
instance_nearest(x:number, y:number, obj:index):
instance_furthest(x:number, y:number, obj:index):
instance_place(x:number, y:number, obj:index):
instance_find(obj:index, n:index);
:instance_destroy(...)~
:instance_copy(performevent:bool):
//}
//{ Motion
:motion_set(dir:number, speed:number)
:motion_add(dir:number, speed:number)
:place_free(x:number, y:number):
:place_empty(x:number, y:number):
:place_meeting(x:number, y:number, obj:index):
:place_snapped(hsnap:number, vsnap:number):
:move_random(hsnap:number, vsnap:number)
:move_snap(hsnap:number, vsnap:number)
:move_towards_point(x:number, y:number, sp:number)
:move_contact_solid(dir:number, maxdist:number)
:move_contact_all(dir:number, maxdist:number)
:move_outside_solid(dir:number, maxdist:number)
:move_outside_all(dir:number, maxdist:number)
:move_bounce_solid(advanced:bool)
:move_bounce_all(advanced:bool)
:move_wrap(hor:bool, vert:bool, margin:number)
:distance_to_point(x:number, y:number):
:distance_to_object(obj:index):
:position_empty(x:number, y:number):
:position_meeting(x:number, y:number, obj:index):
//}
//{
:mp_linear_step(x:number,y:number,speed:number,checkall:bool):
:mp_potential_step(x:number,y:number,speed:number,checkall:bool):
:mp_linear_step_object(x:number,y:number,speed:number,obj:index):
:mp_potential_step_object(x:number,y:number,speed:number,obj:index):
:mp_linear_path(path:index,x:number,y:number,step:number,checkall:bool):
:mp_potential_path(path:index,x:number,y:number,step:number,factor:number,checkall:bool):
:mp_linear_path_object(path:index,x:number,y:number,step:number,obj:index):
:mp_potential_path_object(path:index,x:number,y:number,step:number,factor:number,obj:index):
:mp_grid_path(:index,path:index,xstart:number,ystart:number,xgoal:number,ygoal:number,allowdiag:bool):
//}
//{ Collision
:collision_point(x:number, y:number, obj:index, prec:bool, notme:bool):
:collision_rectangle(x1:number, y1:number, x2:number, y2:number, obj:index, prec, notme):
:collision_circle(x1:number, y1:number, radius, obj:index, prec, notme):
:collision_ellipse(x1:number, y1:number, x2:number, y2:number, obj:index, prec, notme):
:collision_line(x1:number, y1:number, x2:number, y2:number, obj:index, prec, notme):
//}
//{ Collision helpers
point_in_rectangle(px, py, x1:number, y1:number, x2:number, y2:number):
point_in_triangle(px, py, x1:number, y1:number, x2:number, y2:number, x3:number, y3:number):
point_in_circle(px, py, cx, cy, rad):
rectangle_in_rectangle(sx1:number, sy1:number, sx2:number, sy2:number, dx1:number, dy1:number, dx2:number, dy2:number):
rectangle_in_triangle(sx1:number, sy1:number, sx2:number, sy2:number, x1:number, y1:number, x2:number, y2:number, x3:number, y3:number):
rectangle_in_circle(sx1:number, sy1:number, sx2:number, sy2:number, cx:number, cy:number, rad:number):
//}
//{
room*
room_previous(numb):
room_next(numb):
//}
//{ Type checking
is_bool(val)#:
is_real(val)#:
is_string(val)#:
is_array(val)#:
is_undefined(val)#:
is_int32(val)#:
is_int64(val)#:
is_ptr(val)#:
is_vec3(val)#:
is_vec4(val)#:
is_matrix(val)#:
typeof(val)#:
ptr(val):
//}
//{ Arrays
array_create(size:number):
array_length_1d(value):
array_length_2d(value, index:number):
array_height_2d(value):
array_equals(one, two):
//}
//{ Math
abs(x:number)#:
round(x:number)#:
floor(x:number)#:
ceil(x:number)#:
sign(x:number)#:
frac(x:number)#:
sqrt(x:number)#:
sqr(x:number)#:
exp(x:number)#:
ln(x:number)#:
log2(x:number)#:
log10(x:number)#:
sin(radian_angle:number)#:
cos(radian_angle:number)#:
tan(radian_angle:number)#:
arcsin(x:number)#:
arccos(x:number)#:
arctan(x:number)#:
arctan2(y:number, x:number)#:
dsin(degree_angle:number)#:
dcos(degree_angle:number)#:
dtan(degree_angle:number)#:
darcsin(x:number)#:
darccos(x:number)#:
darctan(x:number)#:
darctan2(y:number, x:number)#:
degtorad(x:number)#:
radtodeg(x:number)#:
power(x:number, n:number)#:
logn(n:number, x:number)#:
min(...)#~
max(...)#~
mean(...)#:
median(...)#:
clamp(val:number, min:number, max:number)#:
lerp(val1:number, val2:number, amount:number)#:
dot_product(x1:number, y1:number, x2:number, y2:number)#:
dot_product_3d(x1:number, y1:number, z1:number, x2:number, y2:number, z2:number)#:
dot_product_normalised(x1:number, y1:number, x2:number, y2:number)£#:
dot_product_normalized(x1:number, y1:number, x2:number, y2:number)$#:
dot_product_3d_normalised(x1:number, y1:number, z1:number, x2:number, y2:number, z2:number)£#:
dot_product_3d_normalized(x1:number, y1:number, z1:number, x2:number, y2:number, z2:number)$#:
angle_difference(src:number, dest:number)#:
point_distance_3d(x1:number, y1:number, z1:number, x2:number, y2:number, z2:number)#:
point_distance(x1:number, y1:number, x2:number, y2:number)#:
point_direction(x1:number, y1:number, x2:number, y2:number)#:
lengthdir_x(len:number, dir:number)#:
lengthdir_y(len:number, dir:number)#:
//}
//{
random(x:number):
irandom(x:number):
random_range(:number,:number):
irandom_range(:number,:number):
randomize():
choose(...)~
//}
//{ date
date_current_datetime():
date_valid_datetime(year,month,day,hour,minute,second):
date_inc_year(date,amount):
date_inc_month(date,amount):
date_inc_week(date,amount):
date_inc_day(date,amount):
date_inc_hour(date,amount):
date_inc_minute(date,amount):
date_inc_second(date,amount):
date_year_span(date1,date2):
date_month_span(date1,date2):
date_week_span(date1,date2):
date_day_span(date1,date2):
date_hour_span(date1,date2):
date_minute_span(date1,date2):
date_second_span(date1,date2):
date_compare_datetime(date1,date2):
date_compare_date(date1,date2):
date_compare_time(date1,date2):
date_date_of(date):
date_time_of(date):
date_datetime_string(date):
date_date_string(date):
date_time_string(date):
date_days_in_month(date):
date_days_in_year(date):
date_leap_year(date):
date_is_today(date):
get_timer():
//}
//{ Conversions
real(val)#:
string(val)#:
int64(val)#:
string_format(val:number,total:number,dec:number)#:
chr(val)#:
ansi_char(val)#:
ord(char)#:
//}
//{ String operations
string_length(str:string)#:
string_byte_length(str:string)#:
string_pos(substr:string, str:string)#:
string_copy(str:string, index:number, count:number)#:
string_char_at(str:string, index:number)#:
string_ord_at(str:string, index:number)#:
string_byte_at(str:string, index:number)#:
string_set_byte_at(str:string, index:number, val:number)#:
string_delete(str:string, index:number, count:number)#:
string_insert(substr:string, str:string, index:number)#:
string_lower(str:string)#:
string_upper(str:string)#:
string_repeat(str:string, count:number)#:
string_letters(str:string)#:
string_digits(str:string)#:
string_lettersdigits(str:string)#:
string_replace(str:string, substr:string, newstr:string)#:
string_replace_all(str:string, substr:string, newstr:string)#:
string_count(substr:string, str:string)#:
string_hash_to_newline(string)#:
//}
//{ Color functions
make_colour_rgb(red:number, green:number, blue:number)#:
make_color_rgb(red:number, green:number, blue:number)#:
make_colour_hsv(hue:number, saturation:number, value:number)#:
make_color_hsv(hue:number, saturation:number, value:number)#:
colour_get_red(col)#:
color_get_red(col)#:
colour_get_green(col)#:
color_get_green(col)#:
colour_get_blue(col)#:
color_get_blue(col)#:
colour_get_hue(col)#:
color_get_hue(col)#:
colour_get_saturation(col)#:
color_get_saturation(col)#:
colour_get_value(col)#:
color_get_value(col)#:
merge_colour(col1, col2, amount:number)#:
merge_color(col1, col2, amount:number)#:
//}
//{ Drawing - state
draw_set_colour(:color)
draw_set_color(:color)
draw_set_alpha(alpha:number)
draw_get_colour():
draw_get_color():
draw_get_alpha():
draw_set_font(:font)
draw_set_halign(halign:int)
draw_set_valign(valign:int)
string_width(:string):
string_height(:string):
string_width_ext(string:string, sep:number, w:number):
string_height_ext(string:string, sep:number, w:number):
//}
//{ Drawing - texture state
sprite_get_uvs(spr:index, subimg:number):
font_get_uvs(font:index):
sprite_get_texture(spr:index, subimg:number):
font_get_texture(font:index):
texture_get_width(texid):
texture_get_height(texid):
//}
//{ Matrix
matrix_multiply(a, b):
matrix_transform_vertex(matrix, x, y, z):
matrix_stack_top():
matrix_stack_pop():
//}
//{ input
keyboard_check(key:index):
keyboard_check_pressed(key:index):
keyboard_check_released(key:index):
keyboard_check_direct(key:index):
keyboard_clear(key:index)
//
mouse_check_button(button:index):
mouse_check_button_pressed(button:index):
mouse_check_button_released(button:index):
mouse_wheel_up():
mouse_wheel_down():
//
gamepad_button_count(device:index):
gamepad_button_check(device:index, buttonIndex:index):
gamepad_button_check_pressed(device:index, buttonIndex:index):
gamepad_button_check_released(device:index, buttonIndex:index):
gamepad_button_value(device:index, buttonIndex:index):
gamepad_axis_count(axis:index):
gamepad_axis_value(device:index, axisIndex:index):
//
device_mouse_check_button(:index,:index):
device_mouse_check_button_pressed(:index,:index):
device_mouse_check_button_released(:index,:index):
device_mouse_x(:index):
device_mouse_y(:index):
device_mouse_raw_x(:index):
device_mouse_raw_y(:index):
device_mouse_x_to_gui(:index):
device_mouse_y_to_gui(:index):
//}

//{
buffer_tell(:buffer):
buffer_peek(:buffer, offset:int, type:index):
buffer_md5(:buffer, offset:int, size:int):
buffer_sha1(:buffer, offset:int, size:int):
buffer_base64_encode(:buffer, offset:int, size:int):
buffer_base64_decode(:string):
buffer_base64_decode_ext(:buffer, :string, offset:int):
buffer_sizeof(type:index):
//}

//{ audio
audio_play_sound(soundid:index,priority:number,loops:bool):
audio_play_sound_on(em:index,soundid:index,priority:number,loops:bool):
audio_play_sound_at(soundid:index,x:number,y:number,z:number, falloff_ref_dist:number,falloff_max_dist:number,falloff_factor:number,loops:bool, priority:number):
audio_sound_length(sound:index):
audio_play_in_sync_group(sync:index, snd:index):
audio_group_name(group:index):
audio_start_recording(rec:number):
//}

//{
timeline_add()!:
timeline_max_moment(:index):
//
sprite_duplicate(:index):
sprite_add(fname:string,imgnumb:int,removeback:bool,smooth:bool,xorig:number,yorig:number)!:
sprite_create_from_surface(:index,x:number,y:number,w:number,h:number,removeback:bool,smooth:bool,xorig:number,yorig:number)!:
sprite_add_from_surface(ind:index,id:index,x:number,y:number,w:number,h:number,removeback:bool,smooth:bool)!:
//
font_add(:string,:number,:bool,:bool,:int,:int)!:
font_add_sprite(spr:index,first:int,prop:bool,sep:number)!:
font_add_sprite_ext(spr:index,:string,:bool,:number)!:
//
path_add()!:
path_duplicate(:index)!:
//
room_add()!:
room_duplicate(:index)!:
room_instance_add(:index,:number,:number,:index):
//
shader_current():
shaders_are_supported():

//}

//{
file_text_open_from_string(:string):
file_text_open_write(:string):
file_text_open_append(:string):
file_text_eof(:index):
file_text_eoln(:index):
//
file_bin_open(:string,mode):
file_bin_position(:index):
//
file_attributes(:string,:int):
//
filename_name(:string):
filename_path(:string):
filename_dir(:string):
filename_drive(:string):
filename_ext(:string):
filename_change_ext(:string,:string):
//
ini_close():
//}

//{ misc ds
ds_stack_top(:index):
ds_stack_write(:index):
ds_stack_read(:index,:string,?legacy)
//
ds_queue_empty(:index):
ds_queue_head(:index):
ds_queue_tail(:index):
ds_queue_write(:index):
ds_queue_read(:index,:string,?legacy)
ds_queue_dequeue(:index):
//
ds_list_empty(:index):
ds_list_write(:index):
ds_list_read(:index,:string,?legacy)
//
ds_map_empty(map:index):
ds_map_write(:index):
ds_map_read(:index,:string,?legacy)
//
ds_priority_empty(:index):
ds_priority_delete_min(:index):
ds_priority_delete_max(:index):
ds_priority_find_min(:index):
ds_priority_find_max(:index):
ds_priority_write(:index):
ds_priority_read(:index,:string,?legacy)
//
ds_grid_width(:index):
ds_grid_height(:index):
ds_grid_value_x(:index,x1:number,y1:number,x2:number,y2:number,val):
ds_grid_value_y(:index,x1:number,y1:number,x2:number,y2:number,val):
ds_grid_value_disk_x(:index,xm:number,ym:number,r:number,val):
ds_grid_value_disk_y(:index,xm:number,ym:number,r:number,val):
ds_grid_write(:index):
ds_grid_read(:index,:string,?legacy)
//}

//{
json_encode(map:index):
json_decode(:string):
load_csv(:string):
base64_encode(:string):
base64_decode(:string):
md5_string_unicode(:string):
md5_string_utf8(:string):
md5_file(:string):
sha1_string_unicode(:string):
sha1_string_utf8(:string):
sha1_file(:string):
//
http_post_string(:string,:string):
http_request(url:string, method, header_map, body):
//}

script_execute(...)~
gml_pragma(...)~

//{ misc system
window_handle():
window_device():
window_has_focus():
//
clipboard_has_text():
display_reset(aa, vsync):
//
parameter_count():
parameter_string(:index):
//
show_question(str:string):
show_question_async(:string):
get_integer(:string,:number):
get_integer_async(:string,:number):
get_string(:string,:string):
get_string_async(:string,:string):
get_login_async(:string,:string):
get_open_filename(:string,:string):
get_save_filename(:string,:string):
get_open_filename_ext(:string,:string,:string,:string):
get_save_filename_ext(:string,:string,:string,:string):
//
highscore_name(:index):
highscore_value(:index):
//
clickable_add(x,y,spritetpe,URL,target,params):
clickable_add_ext(x,y,spritetpe,URL,target,params,scale,alpha):
//}

//{ steam
steam_initialised():
steam_file_persisted(:string):
steam_file_write(:string, data, :number):
steam_file_write_file(:string, :string):
steam_user_owns_dlc(_id):
steam_user_installed_dlc(_id):
steam_upload_score(:string, :number):
steam_upload_score_ext(:string, :number, :bool):
steam_download_scores_around_user(lb_name,range_start,range_end):
steam_download_scores(lb_name,start_idx,end_idx):
steam_download_friends_scores(lb_name):
steam_upload_score_buffer(lb_name, score, buffer_id):
steam_upload_score_buffer_ext(lb_name, score, buffer_id, forceupdate):
steam_current_game_language():
steam_available_languages():
steam_ugc_download(ugc_handle, dest_filename):
steam_ugc_submit_item_update(ugc_update_handle, change_note):
steam_ugc_subscribe_item(published_file_id):
steam_ugc_unsubscribe_item(published_file_id):
steam_ugc_num_subscribed_items():
steam_ugc_request_item_details(published_file_id, max_age_seconds):
steam_ugc_query_set_cloud_filename_filter(ugc_query_handle , match_cloud_filename):
ugc_query_CreatedByFollowedUsersRankedByPublicationDate#
//}

// Mishaps:
font_replace(...)&
bm_complex&
ge_lose&
phy_particle_flag_colormixing&
phy_particle_data_flag_color&
buffer_generalerror&
buffer_outofspace&
buffer_outofbounds&
buffer_invalidtype&
vertex_usage_color&
vertex_type_color&

//{
x@
y@
xprevious@
yprevious@
xstart@
ystart@
hspeed@
vspeed@
direction@
speed@
friction@
visible@
//
sprite_index@
sprite_width@
sprite_height@
sprite_xoffset@
sprite_yoffset@
image_number@
image_index@
image_speed@
depth@
image_xscale@
image_yscale@
image_angle@
image_alpha@
image_blend@
bbox_left@
bbox_right@
bbox_top@
bbox_bottom@
//
path_index*@
path_position@
path_positionprevious@
path_speed@
path_scale@
path_orientation@
path_endaction@
//
object_index*@
id*@
solid@
persistent@
mask_index@
//
timeline_index@
timeline_position@
timeline_speed@
timeline_running@
timeline_loop@
//
phy_rotation@
phy_position_x@
phy_position_y@
phy_angular_velocity@
phy_linear_velocity_x@
phy_linear_velocity_y@
phy_speed_x@
phy_speed_y@
phy_speed*@
phy_angular_damping@
phy_linear_damping@
phy_bullet@
phy_fixed_rotation@
phy_active@
phy_mass*@
phy_inertia*@
phy_com_x*@
phy_com_y*@
phy_dynamic*@
phy_kinematic*@
phy_sleeping*@
phy_collision_points*@
phy_collision_x*@
phy_collision_y*@
phy_col_normal_x*@
phy_col_normal_y*@
phy_position_xprevious*@
phy_position_yprevious*@
//}
