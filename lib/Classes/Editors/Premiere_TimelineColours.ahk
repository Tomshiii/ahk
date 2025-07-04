/************************************************************************
 * @description A list of colours required for each UI version/theme of premiere I've encountered. I only use the darkest themes, if you use a different theme you'll need to fill out your own
 * @author tomshi, taranVH
 * @date 2025/07/02
 * @version 1.0.1
 ***********************************************************************/

class timelineColours {
	static Spectrum := {
		darkest: [
			"timeline1",  0x3C3C3C, ;timeline colour inbetween two clips inside the in/out points ON a targeted track
			"timeline2",  0x303030, ;timeline colour of the separating LINES between targeted AND non targeted tracks inside the in/out points
			"timeline3",  0x191919, ;the timeline colour inside in/out points on a UNTARGETED track
			"timeline11", 0x3B3B3B, ;the timeline colour inside in/out points on a TARGETED track (v24.5+)
			"timeline12", 0x3E3E3E, ;the timeline colour inside in/out points on a TARGETED track (additional)
			"timeline13", 0x3D3D3D, ;the timeline colour inside in/out points on a TARGETED track (additional)
			"timeline14", 0x3F3F3F, ;the timeline colour inside in/out points on a TARGETED track (additional)
			"timeline4",  0x1D1D1D, ;the colour of the bare timeline NOT inside the in out points (above any tracks)
			"timeline8",  0x1D1D1D, ; same as above (not needed on new UI)
			"timeline9",  0x1D1D1D, ; same as above (not needed on new UI)
			"timeline10", 0x1D1D1D, ; same as above (not needed on new UI)
			"timeline5",  0xE2E2E2, ;the colour of a SELECTED blank space on the timeline, NOT in the in/out points
			"timeline6",  0xE7E7E7, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
			"timeline7",  0xC1C1C1, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
		]
	}

	static oldUI := {
		darkest: [
			"timeline1",  0x414141, ;timeline colour inbetween two clips inside the in/out points ON a targeted track
			"timeline2",  0x313131, ;timeline colour of the separating LINES between targeted AND non targeted tracks inside the in/out points
			"timeline3",  0x1b1b1b, ;the timeline colour inside in/out points on a UNTARGETED track
			"timeline11", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (v23-24.4)
			"timeline12", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (additional) (not needed for old UI)
			"timeline13", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (additional) (not needed for old UI)
			"timeline14", 0x424242, ;the timeline colour inside in/out points on a TARGETED track (additional) (not needed for old UI)
			"timeline4",  0x212121, ;the colour of the bare timeline NOT inside the in out points (above any tracks)
			"timeline8",  0x202020, ;the colour of the bare timeline NOT inside the in out points (v22.3.1+)
			"timeline9",  0x1C1C1C, ;the colour of the bare timeline NOT inside the in out points (v23.1+)
			"timeline10", 0x1D1D1D, ;the colour of the bare timeline NOT inside the in out points (v23.4+) (above any tracks)
			"timeline5",  0xDFDFDF, ;the colour of a SELECTED blank space on the timeline, NOT in the in/out points
			"timeline6",  0xE4E4E4, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on a TARGETED track
			"timeline7",  0xBEBEBE, ;the colour of a SELECTED blank space on the timeline, IN the in/out points, on an UNTARGETED track
		]
	}
}