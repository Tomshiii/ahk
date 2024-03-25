
/**
 * file extended properties
 * @param {String} [sFile=""] Filepath. Relative path will be resolved to fullpath. Function will return null if Root drive is passed.
 * @param {String} [Kind=""] Optional. The "kind" of file. Eg: Music Picture etc. The function will test for Kind before attempting to retrieve properties.
 * @param {Varadic} [P] Pass property names as strings. if last variadic parameter is xInfo the function will return extra file props like A_LoopFileExt, A_LoopFileFullPath etc
 *
 * AHK v2.beta.3 version by neogna2
 * @link https://www.autohotkey.com/r?p=434132
 *
 * based on SKAN's v1 orginal version
 * @link https://www.autohotkey.com/r?p=252539
 * @link https://www.autohotkey.com/boards/viewtopic.php?t=59882&start=20
 * @author neogna2
 */
FileGetExtendedProp( sFile := "", Kind := "", P* ) {
    Static mDetails
    ;deinitialize mDetails with blank parameter sFile
    If (sFile = "")
    {
    	mDetails := ""
        Return
    }

    ;initialize output Map
    mFex := Map()

    ;verify file parameter
    Loop Files RTrim(sfile,"\*/."), "DF"
    {
        If !FileExist( sFile := A_LoopFileFullPath )
            Return
        SplitPath(sFile, &_FileExt, &_Dir, &_Ext, &_File, &_Drv)
            break
    }
    If !IsSet(_FileExt)
        Return

    ;if last parameter is string "xInfo" get extra file info
    If ( p[p.length] = "xInfo" )
    {
        p.Pop()
        mFex["_Attrib"]    := A_LoopFileAttrib
        mFex["_Dir"]       := _Dir
        mFex["_Drv"]       := _Drv
        mFex["_Ext"]       := _Ext
        mFex["_File"]      := _File
        mFex["_File.Ext"]  := _FileExt
        mFex["_FilePath"]  := sFile
        mFex["_FileSize"]  := A_LoopFileSize
        mFex["_FileTimeA"] := A_LoopFileTimeAccessed
        mFex["_FileTimeC"] := A_LoopFileTimeCreated
        mFex["_FileTimeM"] := A_LoopFileTimeModified
    }

    ;ComObject for reading file properties
    objShl := ComObject("Shell.Application")
    objDir := objShl.NameSpace(_Dir)
    objItm := objDir.ParseName(_FileExt)

    ;create static Map of each possible property name/index, later used to read properties via index
    ;"GetDetailsOf(0" gets data from Explorer column details view, https://stackoverflow.com/a/37061433
    ;Windows 10 found 308 properties in December 2021 but search for 400 in case more gets added
    If !isSet(mDetails)
    {
        mDetails := Map()
        i := -1
        While ( i++ < 400 )
            mDetails[ objDir.GetDetailsOf(0,i) ] := i
        ;remove any empty key
        mDetails.Delete("")
    }

    ;if parameter Kind is set then file must match it
    If ( Kind and Kind != objDir.GetDetailsOf(objItm,11) )
        Return

    ;for each property name string in parameter p get the property value
    ;get "System.Audio.ChannelCount" style names (no spaces, dot separator) with ExtendedProperty
    ;https://docs.microsoft.com/en-us/windows/win32/shell/shellfolderitem-extendedproperty
    ;get "Product version" style names (spaces, no dots) with GetDetailsOf
    ;https://docs.microsoft.com/en-us/windows/win32/shell/folder-getdetailsof
    For i, Prop in p
    {
        if mDetails.Has(Prop)
            mFex[Prop] := ObjDir.GetDetailsOf(objItm, PropNum := mDetails[Prop])
        else if ( (Dot:=InStr(Prop,".")) and (Prop:=(Dot=1 ? "System":"") . Prop) )
            mFex[Prop] := objItm.ExtendedProperty(Prop)
    }

    Return mFex
}

/*
List of Windows Explorer column header names and index
---+---------------------+-----------------------------+-----------------------------+----------------------------
#  | Windows XP          | Windows 7                   | Windows 8.1                 | Windows 10
---+---------------------+-----------------------------+-----------------------------+----------------------------
0  | Name                | Name                        | Name                        | Name
1  | Size                | Size                        | Size                        | Size
2  | Type                | Item type                   | Item type                   | Item type
3  | Date Modified       | Date modified               | Date modified               | Date modified
4  | Date Created        | Date created                | Date created                | Date created
5  | Date Accessed       | Date accessed               | Date accessed               | Date accessed
6  | Attributes          | Attributes                  | Attributes                  | Attributes
7  | Status              | Offline status              | Offline status              | Offline status
8  | Owner               | Offline availability        | Availability                | Availability
9  | Author              | Perceived type              | Perceived type              | Perceived type
10 | Title               | Owner                       | Owner                       | Owner
11 | Subject             | Kind                        | Kind                        | Kind
12 | Category            | Date taken                  | Date taken                  | Date taken
13 | Pages               | Contributing artists        | Contributing artists        | Contributing artists
14 | Comments            | Album                       | Album                       | Album
15 | Copyright           | Year                        | Year                        | Year
16 | Artist              | Genre                       | Genre                       | Genre
17 | Album Title         | Conductors                  | Conductors                  | Conductors
18 | Year                | Tags                        | Tags                        | Tags
19 | Track Number        | Rating                      | Rating                      | Rating
20 | Genre               | Authors                     | Authors                     | Authors
21 | Duration            | Title                       | Title                       | Title
22 | Bit Rate            | Subject                     | Subject                     | Subject
23 | Protected           | Categories                  | Categories                  | Categories
24 | Camera Model        | Comments                    | Comments                    | Comments
25 | Date Picture Taken  | Copyright                   | Copyright                   | Copyright
26 | Dimensions          | #                           | #                           | #
27 |                     | Length                      | Length                      | Length
28 |                     | Bit rate                    | Bit rate                    | Bit rate
29 | Episode Name        | Protected                   | Protected                   | Protected
30 | Program Description | Camera model                | Camera model                | Camera model
31 |                     | Dimensions                  | Dimensions                  | Dimensions
32 | Audio sample size   | Camera maker                | Camera maker                | Camera maker
33 | Audio sample rate   | Company                     | Company                     | Company
34 | Channels            | File description            | File description            | File description
35 | Company             | Program name                | Program name                | Program name
36 | Description         | Duration                    | Duration                    | Duration
37 | File Version        | Is online                   | Is online                   | Is online
38 | Product Name        | Is recurring                | Is recurring                | Is recurring
39 | Product Version     | Location                    | Location                    | Location
40 |                     | Optional attendee addresses | Optional attendee addresses | Optional attendee addresses
41 |                     | Optional attendees          | Optional attendees          | Optional attendees
42 |                     | Organizer address           | Organizer address           | Organizer address
43 |                     | Organizer name              | Organizer name              | Organizer name
44 |                     | Reminder time               | Reminder time               | Reminder time
45 |                     | Required attendee addresses | Required attendee addresses | Required attendee addresses
46 |                     | Required attendees          | Required attendees          | Required attendees
47 |                     | Resources                   | Resources                   | Resources
48 |                     | Meeting status              | Meeting status              | Meeting status
49 |                     | Free/busy status            | Free/busy status            | Free/busy status
50 |                     | Total size                  | Total size                  | Total size
51 |                     | Account name                | Account name                | Account name
52 |                     | Task status                 | Task status                 |
53 |                     | Computer                    | Computer                    | Task status
54 |                     | Anniversary                 | Anniversary                 | Computer
55 |                     | Assistant's name            | Assistant's name            | Anniversary
56 |                     | Assistant's phone           | Assistant's phone           | Assistant's name
57 |                     | Birthday                    | Birthday                    | Assistant's phone
58 |                     | Business address            | Business address            | Birthday
59 |                     | Business city               | Business city               | Business address
60 |                     | Business country/region     | Business country/region     | Business city
61 |                     | Business P.O. box           | Business P.O. box           | Business country/region
62 |                     | Business postal code        | Business postal code        | Business P.O. box
63 |                     | Business state or province  | Business state or province  | Business postal code
64 |                     | Business street             | Business street             | Business state or province
65 |                     | Business fax                | Business fax                | Business street
66 |                     | Business home page          | Business home page          | Business fax
67 |                     | Business phone              | Business phone              | Business home page
68 |                     | Callback number             | Callback number             | Business phone
69 |                     | Car phone                   | Car phone                   | Callback number
70 |                     | Children                    | Children                    | Car phone
71 |                     | Company main phone          | Company main phone          | Children
72 |                     | Department                  | Department                  | Company main phone
73 |                     | E-mail address              | E-mail address              | Department
74 |                     | E-mail2                     | E-mail2                     | E-mail address
75 |                     | E-mail3                     | E-mail3                     | E-mail2
76 |                     | E-mail list                 | E-mail list                 | E-mail3
77 |                     | E-mail display name         | E-mail display name         | E-mail list
78 |                     | File as                     | File as                     | E-mail display name
79 |                     | First name                  | First name                  | File as
80 |                     | Full name                   | Full name                   | First name
81 |                     | Gender                      | Gender                      | Full name
82 |                     | Given name                  | Given name                  | Gender
83 |                     | Hobbies                     | Hobbies                     | Given name
84 |                     | Home address                | Home address                | Hobbies
85 |                     | Home city                   | Home city                   | Home address
86 |                     | Home country/region         | Home country/region         | Home city
87 |                     | Home P.O. box               | Home P.O. box               | Home country/region
88 |                     | Home postal code            | Home postal code            | Home P.O. box
89 |                     | Home state or province      | Home state or province      | Home postal code
90 |                     | Home street                 | Home street                 | Home state or province
91 |                     | Home fax                    | Home fax                    | Home street
92 |                     | Home phone                  | Home phone                  | Home fax
93 |                     | IM addresses                | IM addresses                | Home phone
94 |                     | Initials                    | Initials                    | IM addresses
95 |                     | Job title                   | Job title                   | Initials
96 |                     | Label                       | Label                       | Job title
97 |                     | Last name                   | Last name                   | Label
98 |                     | Mailing address             | Mailing address             | Last name
99 |                     | Middle name                 | Middle name                 | Mailing address
100|                     | Cell phone                  | Cell phone                  | Middle name
101|                     | Nickname                    | Nickname                    | Cell phone
102|                     | Office location             | Office location             | Nickname
103|                     | Other address               | Other address               | Office location
104|                     | Other city                  | Other city                  | Other address
105|                     | Other country/region        | Other country/region        | Other city
106|                     | Other P.O. box              | Other P.O. box              | Other country/region
107|                     | Other postal code           | Other postal code           | Other P.O. box
108|                     | Other state or province     | Other state or province     | Other postal code
109|                     | Other street                | Other street                | Other state or province
110|                     | Pager                       | Pager                       | Other street
111|                     | Personal title              | Personal title              | Pager
112|                     | City                        | City                        | Personal title
113|                     | Country/region              | Country/region              | City
114|                     | P.O. box                    | P.O. box                    | Country/region
115|                     | Postal code                 | Postal code                 | P.O. box
116|                     | State or province           | State or province           | Postal code
117|                     | Street                      | Street                      | State or province
118|                     | Primary e-mail              | Primary e-mail              | Street
119|                     | Primary phone               | Primary phone               | Primary e-mail
120|                     | Profession                  | Profession                  | Primary phone
121|                     | Spouse/Partner              | Spouse/Partner              | Profession
122|                     | Suffix                      | Suffix                      | Spouse/Partner
123|                     | TTY/TTD phone               | TTY/TTD phone               | Suffix
124|                     | Telex                       | Telex                       | TTY/TTD phone
125|                     | Webpage                     | Webpage                     | Telex
126|                     | Content status              | Content status              | Webpage
127|                     | Content type                | Content type                | Content status
128|                     | Date acquired               | Date acquired               | Content type
129|                     | Date archived               | Date archived               | Date acquired
130|                     | Date completed              | Date completed              | Date archived
131|                     | Device category             | Device category             | Date completed
132|                     | Connected                   | Connected                   | Device category
133|                     | Discovery method            | Discovery method            | Connected
134|                     | Friendly name               | Friendly name               | Discovery method
135|                     | Local computer              | Local computer              | Friendly name
136|                     | Manufacturer                | Manufacturer                | Local computer
137|                     | Model                       | Model                       | Manufacturer
138|                     | Paired                      | Paired                      | Model
139|                     | Classification              | Classification              | Paired
140|                     | Status                      | Status                      | Classification
141|                     | Client ID                   | Status                      | Status
142|                     | Contributors                | Client ID                   | Status
143|                     | Content created             | Contributors                | Client ID
144|                     | Last printed                | Content created             | Contributors
145|                     | Date last saved             | Last printed                | Content created
146|                     | Division                    | Date last saved             | Last printed
147|                     | Document ID                 | Division                    | Date last saved
148|                     | Pages                       | Document ID                 | Division
149|                     | Slides                      | Pages                       | Document ID
150|                     | Total editing time          | Slides                      | Pages
151|                     | Word count                  | Total editing time          | Slides
152|                     | Due date                    | Word count                  | Total editing time
153|                     | End date                    | Due date                    | Word count
154|                     | File count                  | End date                    | Due date
155|                     | Filename                    | File count                  | End date
156|                     | File version                | File extension              | File count
157|                     | Flag color                  | Filename                    | File extension
158|                     | Flag status                 | File version                | Filename
159|                     | Space free                  | Flag color                  | File version
160|                     | Bit depth                   | Flag status                 | Flag color
161|                     | Horizontal resolution       | Space free                  | Flag status
162|                     | Width                       |                             | Space free
163|                     | Vertical resolution         |                             |
164|                     | Height                      | Sharing type                |
165|                     | Importance                  | Bit depth                   | Group
166|                     | Is attachment               | Horizontal resolution       | Sharing type
167|                     | Is deleted                  | Width                       | Bit depth
168|                     | Encryption status           | Vertical resolution         | Horizontal resolution
169|                     | Has flag                    | Height                      | Width
170|                     | Is completed                | Importance                  | Vertical resolution
171|                     | Incomplete                  | Is attachment               | Height
172|                     | Read status                 | Is deleted                  | Importance
173|                     | Shared                      | Encryption status           | Is attachment
174|                     | Creators                    | Has flag                    | Is deleted
175|                     | Date                        | Is completed                | Encryption status
176|                     | Folder name                 | Incomplete                  | Has flag
177|                     | Folder path                 | Read status                 | Is completed
178|                     | Folder                      | Shared                      | Incomplete
179|                     | Participants                | Creators                    | Read status
180|                     | Path                        | Date                        | Shared
181|                     | By location                 | Folder name                 | Creators
182|                     | Type                        | Folder path                 | Date
183|                     | Contact names               | Folder                      | Folder name
184|                     | Entry type                  | Participants                | Folder path
185|                     | Language                    | Path                        | Folder
186|                     | Date visited                | By location                 | Participants
187|                     | Description                 | Type                        | Path
188|                     | Link status                 | Contact names               | By location
189|                     | Link target                 | Entry type                  | Type
190|                     | URL                         | Language                    | Contact names
191|                     | Media created               | Date visited                | Entry type
192|                     | Date released               | Description                 | Language
193|                     | Encoded by                  | Link status                 | Date visited
194|                     | Producers                   | Link target                 | Description
195|                     | Publisher                   | URL                         | Link status
196|                     | Subtitle                    |                             | Link target
197|                     | User web URL                | Media created               | URL
198|                     | Writers                     | Date released               |
199|                     | Attachments                 | Encoded by                  |
200|                     | Bcc addresses               | Episode number              |
201|                     | Bcc                         | Producers                   | Media created
202|                     | Cc addresses                | Publisher                   | Date released
203|                     | Cc                          | Season number               | Encoded by
204|                     | Conversation ID             | Subtitle                    | Episode number
205|                     | Date received               | User web URL                | Producers
206|                     | Date sent                   | Writers                     | Publisher
207|                     | From addresses              |                             | Season number
208|                     | From                        | Attachments                 | Subtitle
209|                     | Has attachments             | Bcc addresses               | User web URL
210|                     | Sender address              | Bcc                         | Writers
211|                     | Sender name                 | Cc addresses                |
212|                     | Store                       | Cc                          | Attachments
213|                     | To addresses                | Conversation ID             | Bcc addresses
214|                     | To do title                 | Date received               | Bcc
215|                     | To                          | Date sent                   | Cc addresses
216|                     | Mileage                     | From addresses              | Cc
217|                     | Album artist                | From                        | Conversation ID
218|                     | Album ID                    | Has attachments             | Date received
219|                     | Beats-per-minute            | Sender address              | Date sent
220|                     | Composers                   | Sender name                 | From addresses
221|                     | Initial key                 | Store                       | From
222|                     | Part of a compilation       | To addresses                | Has attachments
223|                     | Mood                        | To do title                 | Sender address
224|                     | Part of set                 | To                          | Sender name
225|                     | Period                      | Mileage                     | Store
226|                     | Color                       | Album artist                | To addresses
227|                     | Parental rating             | Sort album artist           | To do title
228|                     | Parental rating reason      | Album ID                    | To
229|                     | Space used                  | Sort album                  | Mileage
230|                     | EXIF version                | Sort contributing artists   | Album artist
231|                     | Event                       | Beats-per-minute            | Sort album artist
232|                     | Exposure bias               | Composers                   | Album ID
233|                     | Exposure program            | Sort composer               | Sort album
234|                     | Exposure time               | Initial key                 | Sort contributing artists
235|                     | F-stop                      | Part of a compilation       | Beats-per-minute
236|                     | Flash mode                  | Mood                        | Composers
237|                     | Focal length                | Part of set                 | Sort composer
238|                     | 35mm focal length           | Period                      | Initial key
239|                     | ISO speed                   | Color                       | Part of a compilation
240|                     | Lens maker                  | Parental rating             | Mood
241|                     | Lens model                  | Parental rating reason      | Part of set
242|                     | Light source                | Space used                  | Period
243|                     | Max aperture                | EXIF version                | Color
244|                     | Metering mode               | Event                       | Parental rating
245|                     | Orientation                 | Exposure bias               | Parental rating reason
246|                     | People                      | Exposure program            | Space used
247|                     | Program mode                | Exposure time               | EXIF version
248|                     | Saturation                  | F-stop                      | Event
249|                     | Subject distance            | Flash mode                  | Exposure bias
250|                     | White balance               | Focal length                | Exposure program
251|                     | Priority                    | 35mm focal length           | Exposure time
252|                     | Project                     | ISO speed                   | F-stop
253|                     | Channel number              | Lens maker                  | Flash mode
254|                     | Episode name                | Lens model                  | Focal length
255|                     | Closed captioning           | Light source                | 35mm focal length
256|                     | Rerun                       | Max aperture                | ISO speed
257|                     | SAP                         | Metering mode               | Lens maker
258|                     | Broadcast date              | Orientation                 | Lens model
259|                     | Program description         | People                      | Light source
260|                     | Recording time              | Program mode                | Max aperture
261|                     | Station call sign           | Saturation                  | Metering mode
262|                     | Station name                | Subject distance            | Orientation
263|                     | Summary                     | White balance               | People
264|                     | Snippets                    | Priority                    | Program mode
265|                     | Auto summary                | Project                     | Saturation
266|                     | Search ranking              | Channel number              | Subject distance
267|                     | Sensitivity                 | Episode name                | White balance
268|                     | Shared with                 | Closed captioning           | Priority
269|                     | Sharing status              | Rerun                       | Project
270|                     | Product name                | SAP                         | Channel number
271|                     | Product version             | Broadcast date              | Episode name
272|                     | Support link                | Program description         | Closed captioning
273|                     | Source                      | Recording time              | Rerun
274|                     | Start date                  | Station call sign           | SAP
275|                     | Billing information         | Station name                | Broadcast date
276|                     | Complete                    | Summary                     | Program description
277|                     | Task owner                  | Snippets                    | Recording time
278|                     | Total file size             | Auto summary                | Station call sign
279|                     | Legal trademarks            | Search ranking              | Station name
280|                     | Video compression           | Sensitivity                 | Summary
281|                     | Directors                   | Shared with                 | Snippets
282|                     | Data rate                   | Sharing status              | Auto summary
283|                     | Frame height                |                             | Relevance
284|                     | Frame rate                  | Product name                | Encrypted to
285|                     | Frame width                 | Product version             | Sensitivity
286|                     | Total bitrate               | Support link                | Shared with
287|                     |                             | Source                      | Sharing status
288|                     |                             | Start date                  |
289|                     |                             | Sharing                     | Product name
290|                     |                             | Billing information         | Product version
291|                     | Audio tracks                | Complete                    | Support link
292|                     | Bit depth                   | Task owner                  | Source
293|                     | Contains chapters           | Sort title                  | Start date
294|                     | Content compression         | Total file size             | Sharing
295|                     | Subtitles                   | Legal trademarks            | Billing information
296|                     | Subtitle tracks             | Video compression           | Complete
297|                     | Video tracks                | Directors                   | Task owner
298|                     |                             | Data rate                   | Sort title
299|                     |                             | Frame height                | Total file size
300|                     |                             | Frame rate                  | Legal trademarks
301|                     |                             | Frame width                 | Video compression
302|                     |                             | Video orientation           | Directors
303|                     |                             | Total bitrate               | Data rate
304|                     |                             |                             | Frame height
305|                     |                             |                             | Frame rate
306|                     |                             |                             | Frame width
307|                     |                             |                             | Video orientation
308|                     |                             |                             | Total bitrate
---+---------------------+-----------------------------+-----------------------------+----------------------------
*/
