/************************************************************************
 * @description A list of colours required for each UI version/theme of premiere I've encountered. I only use the darkest themes, if you use a different theme you'll need to fill out your own
 * @author tomshi, taranVH
 * @date 2026/11/11
 * @version 1.1.0
 ***********************************************************************/

class timelineColours {
	static Spectrum := {
		v26: {
			darkest: [
				"timeline1",  0x3F3F3F, ;timeline colour inbetween two clips inside the in/out points ON a targeted track
				"timeline2",  0x303030, ;timeline colour of the separating LINES between targeted AND non targeted tracks inside the in/out points
				"timeline3",  0x191919, ;the timeline colour inside in/out points on a UNTARGETED track
				"timeline4",  0x1D1D1D, ;the colour of the bare timeline NOT inside the in out points (above any tracks)
				"timeline5",  0xE2E2E2, ;the colour of a SELECTED blank space on the timeline, NOT in the in/out points
				"timeline6",  0xE7E7E7, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
				"timeline7",  0xC1C1C1, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
			],
			dark: [
				"timeline1",  0x515151,
				"timeline2",  0x3F3F3F,
				"timeline3",  0x2B2B2B,
				"timeline4",  0x323232,
				"timeline5",  0xCDCDCD,
				"timeline6",  0xD5D5D5,
				"timeline7",  0xAFAFAF,
			],
			light: [
				"timeline1",  0xFAFAFA,
				"timeline2",  0xE6E6E6,
				"timeline3",  0xD3D3D3,
				"timeline4",  0xF8F8F8,
				"timeline5",  0x070707,
				"timeline6",  0x2D2D2D,
				"timeline7",  0x060606,
			]
		}
	}
}