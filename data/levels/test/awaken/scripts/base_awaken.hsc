;=================================
;======== Globals ================
;=================================
(global boolean begin_set FALSE)
(global short p0_tp 0)
(global short p1_tp 0)
(global short gravityrng 0)
(global short moverng 0)
(global short waverng 0)

(script static void survival_countdown_timer
    (sound_impulse_start "sound\sfx\ui\countdown_for_respawn" none 1.0)
    (sleep 30)
    (sound_impulse_start "sound\sfx\ui\countdown_for_respawn" none 1.0)
    (sleep 30)
    (sound_impulse_start "sound\sfx\ui\countdown_for_respawn" none 1.0)
    (sleep 30)
    (sound_impulse_start "sound\sfx\ui\player_respawn" none 1.0)
    (sleep 30)
)
  
(script static void cinematic_snap_to_black
	; Kill player control
	(player_enable_input false)
	(player_camera_control false)

	(fade_out 0 0 0 0)
	; Edit sound channels, other stuff here
	(cinematic_start)
	(cinematic_show_letterbox true)
	(camera_control on)
)

(script static void cinematic_fade_from_black
	(cinematic_stop)
	; Edit sound channels, other stuff here
	(camera_control off)
	(fade_in 0 0 0 15)
	(sleep 15)

	; Restore player control
	(player_enable_input true)
	(player_camera_control true)
)

(script static void fade_to_white
	; Kill player control
	(player_enable_input false)
	(player_camera_control false)

	; Fade out
	(fade_out 1 1 1 30) ; pbertone - changed from 15 to 30 (9/23) 
	(sleep 30) ; pbertone - changed from 15 to 30 (9/23) 
	(camera_control on)
)

(script static void fade_from_white
	; Edit sound channels, other stuff here
	(camera_control off)
	(fade_in 1 1 1 15)
	(sleep 15)

	; Restore player control
	(player_enable_input true)
	(player_camera_control true)
)

;===========================================
;========== Music Scripts ==================
;===========================================
(global short s_music_initial 0)
(global short s_music_final 0)
(global looping_sound m_survival_start "sound\sinomatixx_music\b30_ledge_music")
(global looping_sound m_new_set "sound\sinomatixx_music\d40_bridge_music01")
(global looping_sound m_initial_wave "levels\a10\music\a10_01")
(global looping_sound m_final_wave "levels\d40\music\d40_01")

(script static void surival_set_music
    (set s_music_initial (random_range 0 5))
    (cond
        ((= s_music_initial 0)
            (set m_initial_wave "levels\a10\music\a10_01")
        )
        ((= s_music_initial 1)
            (set m_initial_wave "levels\a10\music\a10_02")
        )
        ((= s_music_initial 2)
            (set m_initial_wave "levels\a10\music\a10_03")
        )
        ((= s_music_initial 3)
            (set m_initial_wave "levels\a10\music\a10_04")
        )
        ((= s_music_initial 4)
            (set m_initial_wave "levels\a10\music\a10_05")
        )
    )
    (sleep 1)
    (set s_music_final (random_range 0 5))
    (cond
        ((= s_music_final 0)
            (set m_final_wave "levels\d40\music\d40_01")
        )
        ((= s_music_final 1)
            (set m_final_wave "levels\d40\music\d40_02")
        )
        ((= s_music_final 2)
            (set m_final_wave "levels\d40\music\d40_03")
        )
        ((= s_music_final 3)
            (set m_final_wave "levels\d40\music\d40_04")
        )
        ((= s_music_final 4)
            (set m_final_wave "levels\d40\music\d40_05")
        )
    )
)

;===========================================
;========== Player exclusion Scripts =======
;===========================================
(script static void player0_out_of_bounds_tele
	(object_teleport (player0) p0)
	(set p0_tp (+ p0_tp 1))
)

(script static void player1_out_of_bounds_tele
	(object_teleport (player1) p1)
	(set p1_tp (+ p1_tp 1))
)

(script static void player0_out_of_bounds
	(if (>= p0_tp 3)
		(unit_kill (player0))
		(player0_out_of_bounds_tele))
)

(script static void player1_out_of_bounds
	(if (>= p1_tp 3)
		(unit_kill (player1))
		(player1_out_of_bounds_tele))
)

(script continuous Player_exclusion
	(if (or (volume_test_object player_exclusion_left (player0))
			(volume_test_object player_exclusion_right (player0))
			(volume_test_object player_exclusion_front (player0))	
			(volume_test_object player_exclusion_right_upper (player0))
			(volume_test_object player_exclusion_left_upper (player0)))
		(player0_out_of_bounds))
	(if (or (volume_test_object player_exclusion_left (player1))
			(volume_test_object player_exclusion_right (player1))
			(volume_test_object player_exclusion_front (player1))	
			(volume_test_object player_exclusion_right_upper (player1))
			(volume_test_object player_exclusion_left_upper (player1)))
		(player1_out_of_bounds))
	(sleep 5)
)

;==================================
;========== Startup Scripts =======
;==================================
(script startup welcome
	(object_create torch)
    (sound_looping_start m_survival_start none 1.0)
    (if (> (list_count (players)) 0)
        (cinematic_snap_to_black)
	)
	(hud_set_objective_text obj_firefight)
	(hud_set_help_text obj_firefight)
    (sleep 1)
    (sleep (* 30.0 3.0))
    (if (> (list_count (players)) 0)
        (cinematic_fade_from_black)
	)
    (sleep (* 30.0 2.0))
    (sound_impulse_start "sound\dialog\survival\survival_welcome3" none 1.0)
    (sleep (* 30.0 2.0))
    (sleep (* 30.0 3.0))
    (sound_looping_stop m_survival_start)
	(set begin_set TRUE)
)

;==================================
;========== Assembly Scripts ======
;==================================
(script continuous assembly
	(scenery_animation_start torch "levels\test\awaken\scenery\assembly\assembly" assembly)
	(device_set_position right_platform 1)
	(sleep 84)
	(effect_new_on_object_marker "levels\test\awaken\scenery\assembly\sparks" torch emit-torch-a)
	(sleep 5)
	(effect_new_on_object_marker "levels\test\awaken\scenery\assembly\sparks" torch emit-torch-c)
	(sleep 5)
	(effect_new_on_object_marker "levels\test\awaken\scenery\assembly\sparks" torch emit-torch-b)
	(sleep 30)
	(device_set_position right_platform 0)
	(device_set_position left_platform 1)
	(sleep 35)
	(effect_new_on_object_marker "levels\test\awaken\scenery\assembly\sparks" torch emit-torch-a)
	(sleep 5)
	(effect_new_on_object_marker "levels\test\awaken\scenery\assembly\sparks" torch emit-torch-c)
	(sleep 5)
	(effect_new_on_object_marker "levels\test\awaken\scenery\assembly\sparks" torch emit-torch-b)
	(sleep 70)
	(device_set_position left_platform 0)
	(sleep 82)
)

;===========================================
;========== Gravity Scripts ================
;===========================================
(script static void roll_gravity
	(set gravityrng (random_range 1 99))
	(inspect gravityrng)
	(cond
        ((>= gravityrng 50)
			(physics_set_gravity 0.75))
        ((>= gravityrng 75)
			(physics_set_gravity 0.5))
        ((>= gravityrng 80)
			(physics_set_gravity 0.1))			
        ((>= gravityrng 90)
			(physics_set_gravity 3))
	)
)

;==================================
;========== Wave Scripts ==========
;==================================
(script static void create_objects
	(object_create_anew equip_hp_0)
	(object_create_anew equip_hp_1)
	(object_create_anew equip_ar_0)
	(object_create_anew equip_ar_1)
	(object_create_anew equip_ar_2)
	(object_create_anew equip_pistol_0)
	(object_create_anew equip_pistol_1)
	(object_create_anew equip_pistol_2)
	(object_create_anew equip_sg_0)
	(object_create_anew equip_sg_1)
	(object_create_anew equip_sg_2)
	(object_create_anew equip_sg_3)
	(object_create_anew equip_sg_4)
	(object_create_anew equip_sg_5)
	(object_create_anew equip_sg_6)
	(object_create_anew equip_sg_7)
	(object_create_anew equip_sg_8)
	(object_create_anew equip_sr_0)
	(object_create_anew equip_sr_1)
	(object_create_anew equip_sr_2)
	(object_create_anew equip_sr_3)
	(object_create_anew equip_sr_4)
	(object_create_anew equip_sr_5)
	(object_create_anew equip_sr_6)
	(object_create_anew equip_ft_0)
	(object_create_anew equip_ft_1)
	(object_create_anew equip_ft_2)
	(object_create_anew equip_ft_3)
	(object_create_anew equip_ft_4)
	(object_create_anew equip_rl_0)
	(object_create_anew equip_rl_1)
	(object_create_anew equip_rl_2)
	(object_create_anew equip_rl_3)
	(object_create_anew weapon_ar_0)
	(object_create_anew weapon_ar_1)
	(object_create_anew weapon_pistol_0)
	(object_create_anew weapon_pistol_1)
)

(script continuous elevator_door
	(sleep_until (volume_test_objects player_exclusion_front (ai_actors ff_enc)))
	(device_set_position elevator_door 1)
	(sleep 500)
	(device_set_position elevator_door 0)
)

(script continuous jump_wave_0
	(sleep_until (and (volume_test_objects walkway (ai_actors ff_enc/0_a_e_ul))
					  (volume_test_objects walkway (ai_actors ff_enc/0_a_e_ur))))
	(sleep 60)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/0_a_e_ul) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/0_a_e_ul) 0)) move_1_180))
	)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/0_a_e_ul) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/0_a_e_ul) 1)) move_1_180))
	)
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/0_a_e_ur) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/0_a_e_ur) 0)) move_1_180))
	)	
)

(script continuous jump_wave_1
	(sleep_until (and (volume_test_objects walkway (ai_actors ff_enc/1_a_e_s_ul))
					  (volume_test_objects walkway (ai_actors ff_enc/1_a_e_sm_ur))))
	(sleep 60)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/1_a_e_s_ul) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/1_a_e_s_ul) 0)) move_1_180))
	)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/1_a_e_s_ul) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/1_a_e_s_ul) 1)) move_1_180))
	)
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/1_a_e_sm_ur) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/1_a_e_sm_ur) 0)) move_1_180))
	)	
)

(script continuous jump_wave_2
	(sleep_until (and (volume_test_objects walkway (ai_actors ff_enc/2_a_e_ul))
					  (volume_test_objects walkway (ai_actors ff_enc/2_a_e_ur))))
	(sleep 60)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ul) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ul) 0)) move_1_180))
	)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ul) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ul) 1)) move_1_180))
	)
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ur) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ur) 0)) move_1_180))
	)	
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ur) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/2_a_e_ur) 1)) move_1_180))
	)	
)

(script continuous jump_wave_3_a
	(sleep_until (and (volume_test_objects walkway (ai_actors ff_enc/3_a_e_ul))
					  (volume_test_objects walkway (ai_actors ff_enc/3_a_e_ur))))
	(sleep 60)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ul) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ul) 0)) move_1_180))
	)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ul) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ul) 1)) move_1_180))
	)
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ur) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ur) 0)) move_1_180))
	)	
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ur) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_a_e_ur) 1)) move_1_180))
	)	
)

(script continuous jump_wave_3_b
	(sleep_until (and (volume_test_objects walkway (ai_actors ff_enc/3_b_e_ul))
					  (volume_test_objects walkway (ai_actors ff_enc/3_b_e_ur))))
	(sleep 60)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ul) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ul) 0)) move_1_180))
	)
	(set moverng (random_range 1 3))
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ul) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ul) 1)) move_1_180))
	)
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ur) 0)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ur) 0)) move_1_180))
	)	
	(set moverng (random_range 1 3))	
	(cond
        ((= moverng 1)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ur) 1)) move_1_0))
        ((= moverng 2)
			(ai_command_list_by_unit (unit (list_get (ai_actors ff_enc/3_b_e_ur) 1)) move_1_180))
	)	
)

(script continuous survival_mode
    (surival_set_music)
	(sleep_until begin_set 1)
	(survival_countdown_timer)
	(sound_impulse_start "sound\dialog\survival\survival_new_set" none 1.0)
	(create_objects)

	; place wave 0
    (sound_looping_start m_initial_wave none 1.0)
	(roll_gravity)
	(ai_place ff_enc/0_a_e_ul)
	(ai_place ff_enc/0_a_e_ur)
	(ai_place ff_enc/0_a_g_hl)
	(ai_place ff_enc/0_a_g_hr)
	(sleep_until (= 0 (ai_living_count ff_enc)))
	(physics_constants_reset)
	(sleep (* (random_range 3 5) 30.0))
	
	; place wave 1
	(roll_gravity)
	(ai_place ff_enc/1_a_e_s_ul)
	(ai_place ff_enc/1_a_e_sm_ur)
	(ai_place ff_enc/1_a_g_j_hl)
	(ai_place ff_enc/1_a_g_j_hr)
	(sleep_until (= 0 (ai_living_count ff_enc)))
	(physics_constants_reset)
	(sleep (* (random_range 3 5) 30.0))
	
	; place wave 2
	(roll_gravity)
	(ai_place ff_enc/2_a_e_ul)
	(ai_place ff_enc/2_a_e_ur)
	(ai_place ff_enc/2_a_g_j_hl)
	(ai_place ff_enc/2_a_g_j_hr)
	(sleep_until (= 0 (ai_living_count ff_enc)))
    (sound_looping_stop m_initial_wave)
	(physics_constants_reset)
	(sleep (* (random_range 3 5) 30.0))
	
	; place wave 3
	(roll_gravity)
    (sound_looping_start m_final_wave none 1.0)
	(set waverng (random_range 1 3))	
	(cond
        ((= waverng 1)
			(ai_place ff_enc/3_a_e_e)
			(ai_place ff_enc/3_a_e_ul)
			(ai_place ff_enc/3_a_e_ur)
			(ai_place ff_enc/3_a_g_j_hl)
			(ai_place ff_enc/3_a_g_j_hr)
			(sleep 400)
			(ai_command_list ff_enc/3_a_e_e elevator_move_in))
        ((= waverng 2)
			(ai_place ff_enc/3_b_e_ul)
			(ai_place ff_enc/3_b_e_ur)
			(ai_place ff_enc/3_b_g_j_hl)
			(ai_place ff_enc/3_b_g_j_hr)
			(ai_place ff_enc/3_b_h_e)
			(sleep 400)
			(ai_command_list ff_enc/3_b_h_e elevator_move_in))
	)
	(sleep_until (= 0 (ai_living_count ff_enc)))
    (sound_looping_stop m_final_wave)
	(physics_constants_reset)
	(sleep (* (random_range 3 5) 30.0))
)