#include QMK_KEYBOARD_H
static uint8_t f24_tracker;

/* Created by jivanyatra
 * https://github.com/jivanyatra
 *
 * Created for Tomshi
 * Inspired by Taran (LinusTechTips) and his solution for macros
 */

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
	[0] = LAYOUT_planck_1x2uC(RGB_TOG, KC_Q, KC_W, KC_E, KC_R, KC_T, KC_Y, KC_U, KC_I, KC_O, KC_P, KC_BSPC, KC_ESC, KC_A, KC_S, KC_D, KC_F, KC_G, KC_H, KC_J, KC_K, KC_L, KC_SCLN, KC_QUOT, KC_F13, KC_Z, KC_X, KC_C, KC_V, KC_B, KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH, KC_ENT, KC_HOME, KC_F16, KC_F15, KC_END, KC_PGDN, KC_SPC, KC_PGUP, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT)
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case KC_A ... KC_F23: //notice how it skips over F24
		case KC_EXECUTE ... KC_EXSEL: //exsel is the last one before the modifier keys
			if (record->event.pressed) {
				register_code(KC_F24); //this means to send F24 down
				f24_tracker++;
				register_code(keycode);
				return false;
			}
			break;
	}
	return true;
}

void post_process_record_user(uint16_t keycode, keyrecord_t *record) {
	switch (keycode) {
		case KC_A ... KC_F23: //notice how it skips over F24
		case KC_EXECUTE ... KC_EXSL: //exsel is the last one before the modifier keys
			if (!record->event.pressed) {
				f24_tracker--;
				if (!f24_tracker) {
					unregister_code(KC_F24); //this means to send F24 up
				}
			}
			break;
	}
}

void keyboard_post_init_user(void) {
	// Initialize keyboard backlighting at boot
	// Orange, Full Saturation, Half Brightness
	// changed from rgblight_sethsv because it wasn't working
	rgb_matrix_sethsv(36, 255, 127);
}