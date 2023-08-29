*&---------------------------------------------------------------------*
*& Report ZPBCR_EXPORT_IMPORT_TABLE_DATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPBCR_EXPORT_IMPORT_TABLE_DATA MESSAGE-ID ZBC_EXPORT_IMPORT_DA.

TYPES: BEGIN OF Y_EXPORT_TABLE,
        LENG TYPE I,
        DATA(255) TYPE X,
       END OF Y_EXPORT_TABLE.

TYPES: BEGIN OF Y_FILEBIN_DATA,
        FILEDATA(255) TYPE X,
       END OF Y_FILEBIN_DATA.

SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-001.
PARAMETERS: P_TABLE TYPE DD02L-TABNAME.
PARAMETERS: P_WHERE TYPE STRING.
PARAMETERS: P_CREG TYPE I.
SELECTION-SCREEN END OF BLOCK BL1.

SELECTION-SCREEN BEGIN OF BLOCK BL2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_EXPORT RADIOBUTTON GROUP R1 DEFAULT 'X' USER-COMMAND TEST,
            P_IMPORT RADIOBUTTON GROUP R1.
PARAMETERS: P_DELTB AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK BL2.
SELECTION-SCREEN BEGIN OF BLOCK BL3 WITH FRAME TITLE TEXT-003.
PARAMETERS: P_FILEN TYPE STRING.
PARAMETERS: P_LOCL RADIOBUTTON GROUP R2 DEFAULT 'X',
            P_SERV RADIOBUTTON GROUP R2.
SELECTION-SCREEN END OF BLOCK BL3.
.

INITIALIZATION.
 PERFORM zf_change_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILEN.
  PERFORM ZF_FILE_F4.

AT SELECTION-SCREEN OUTPUT.
 PERFORM zf_change_screen.

AT SELECTION-SCREEN.
   IF SY-UCOMM = 'ONLI'.
      PERFORM zf_exec.
   ENDIF.
*&---------------------------------------------------------------------*
*& Form zf_exec
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zf_exec .


DATA: WF_REF TYPE REF TO data.
DATA: LX_DATA_BUFFER TYPE XSTRING.
DATA: LC_TABLE TYPE DD02L-TABNAME.
DATA: LI_BINSIZE TYPE I.
DATA: LT_FILEBIN_DATA TYPE TABLE OF Y_FILEBIN_DATA.
FIELD-SYMBOLS: <FS_TABLE> TYPE STANDARD TABLE.

IF P_EXPORT = 'X'.
LC_TABLE = P_TABLE.
CREATE DATA WF_REF TYPE TABLE OF (LC_TABLE).
ASSIGN wf_ref->* to <FS_TABLE>.

IF P_CREG IS INITIAL.
SELECT *
       FROM (LC_TABLE)
       INTO TABLE <FS_TABLE>
       WHERE (P_WHERE).
ELSE.
SELECT *
       FROM (LC_TABLE)
       INTO TABLE <FS_TABLE>
       UP TO P_CREG ROWS
       WHERE (P_WHERE).
ENDIF.

EXPORT LC_TABLE <FS_TABLE> TO DATA BUFFER LX_DATA_BUFFER COMPRESSION ON.

IF P_LOCL = 'X'.
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    BUFFER                = LX_DATA_BUFFER
*   APPEND_TO_TABLE       = ' '
  IMPORTING
    OUTPUT_LENGTH         = LI_BINSIZE
  TABLES
    BINARY_TAB            = LT_FILEBIN_DATA
          .


CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    BIN_FILESIZE                    = LI_BINSIZE
    FILENAME                        = P_FILEN
    FILETYPE                        = 'BIN'
*   APPEND                          = ' '
*   WRITE_FIELD_SEPARATOR           = ' '
*   HEADER                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
*   CODEPAGE                        = ' '
*   IGNORE_CERR                     = ABAP_TRUE
*   REPLACEMENT                     = '#'
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
*   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*   SHOW_TRANSFER_STATUS            = ABAP_TRUE
*   VIRUS_SCAN_PROFILE              = '/SCET/GUI_DOWNLOAD'
* IMPORTING
*   FILELENGTH                      =
  TABLES
    DATA_TAB                        = LT_FILEBIN_DATA
*   FIELDNAMES                      =
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.
ELSE.
  OPEN DATASET P_FILEN FOR OUTPUT IN BINARY MODE.
   TRANSFER LX_DATA_BUFFER TO P_FILEN.
  CLOSE DATASET P_FILEN.
  message s005.
ENDIF.


ELSE.

IF P_LOCL = 'X'.
CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    FILENAME                      = P_FILEN
    FILETYPE                      = 'BIN'
*   HAS_FIELD_SEPARATOR           = ' '
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE                      = ' '
*   CODEPAGE                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
  IMPORTING
    FILELENGTH                    = LI_BINSIZE
*   HEADER                        =
  TABLES
    DATA_TAB                      = LT_FILEBIN_DATA
* CHANGING
*   ISSCANPERFORMED               = ' '
* EXCEPTIONS
*   FILE_OPEN_ERROR               = 1
*   FILE_READ_ERROR               = 2
*   NO_BATCH                      = 3
*   GUI_REFUSE_FILETRANSFER       = 4
*   INVALID_TYPE                  = 5
*   NO_AUTHORITY                  = 6
*   UNKNOWN_ERROR                 = 7
*   BAD_DATA_FORMAT               = 8
*   HEADER_NOT_ALLOWED            = 9
*   SEPARATOR_NOT_ALLOWED         = 10
*   HEADER_TOO_LONG               = 11
*   UNKNOWN_DP_ERROR              = 12
*   ACCESS_DENIED                 = 13
*   DP_OUT_OF_MEMORY              = 14
*   DISK_FULL                     = 15
*   DP_TIMEOUT                    = 16
*   OTHERS                        = 17
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
  EXPORTING
    INPUT_LENGTH       = LI_BINSIZE
*   FIRST_LINE         = 0
*   LAST_LINE          = 0
  IMPORTING
    BUFFER             = LX_DATA_BUFFER
  TABLES
    BINARY_TAB         = LT_FILEBIN_DATA
* EXCEPTIONS
*   FAILED             = 1
*   OTHERS             = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.
ELSE.
  OPEN DATASET P_FILEN FOR INPUT IN BINARY MODE.
   READ DATASET P_FILEN INTO LX_DATA_BUFFER.
  CLOSE DATASET P_FILEN.
ENDIF.


IMPORT LC_TABLE FROM DATA BUFFER LX_DATA_BUFFER.
CREATE DATA WF_REF TYPE TABLE OF (LC_TABLE).
ASSIGN wf_ref->* to <FS_TABLE>.
IMPORT <FS_TABLE> FROM DATA BUFFER LX_DATA_BUFFER.
IF P_DELTB = 'X'.
   DELETE FROM (LC_TABLE) CLIENT SPECIFIED WHERE MANDT = SY-MANDT.
   COMMIT WORK.
ENDIF.
MODIFY (LC_TABLE) FROM TABLE <FS_TABLE>.
message s004(ZBC_EXPORT_IMPORT_DA) WITH SY-DBCNT LC_TABLE.
COMMIT WORK.



ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zf_change_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zf_change_screen .
 IF P_IMPORT = 'X'.
    LOOP AT SCREEN.
      CHECK SCREEN-NAME CS 'P_TABLE' OR SCREEN-NAME CS 'P_WHERE' OR SCREEN-NAME CS 'P_CREG'.
      SCREEN-INPUT = 0.
      SCREEN-INVISIBLE = 1.
      MODIFY SCREEN.
    ENDLOOP.
 ELSE.
      LOOP AT SCREEN.
      CHECK SCREEN-NAME CS 'P_DELTB'.
      SCREEN-INPUT = 0.
      SCREEN-INVISIBLE = 1.
      MODIFY SCREEN.
    ENDLOOP.
 ENDIF.
ENDFORM.


FORM ZF_FILE_F4 .
DATA: LT_FILETABLE TYPE FILETABLE,
      LS_FILETABLE LIKE LINE OF LT_FILETABLE.
DATA: LC_FILTER TYPE STRING.
DATA: LI_RC TYPE I.
DATA: LC_FILENAME TYPE STRING,
      LC_PATH TYPE STRING.



IF P_LOCL = 'X'.
IF P_EXPORT = 'X'.
            CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
*              EXPORTING
*                WINDOW_TITLE              =
*                DEFAULT_EXTENSION         =
*                DEFAULT_FILE_NAME         =
*                WITH_ENCODING             =
*                FILE_FILTER               =
*                INITIAL_DIRECTORY         =
*                PROMPT_ON_OVERWRITE       = 'X'
              CHANGING
                FILENAME                  = LC_FILENAME
                PATH                      = LC_PATH
                FULLPATH                  = P_FILEN
*                USER_ACTION               =
*                FILE_ENCODING             =
*              EXCEPTIONS
*                CNTL_ERROR                = 1
*                ERROR_NO_GUI              = 2
*                NOT_SUPPORTED_BY_GUI      = 3
*                INVALID_DEFAULT_FILE_NAME = 4
*                others                    = 5
                    .
            IF SY-SUBRC <> 0.
*             Implement suitable error handling here
            ENDIF.
ELSE.
CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
   EXPORTING
*    WINDOW_TITLE            =
*    DEFAULT_EXTENSION       =
*    DEFAULT_FILENAME        =
     FILE_FILTER             = LC_FILTER
*    WITH_ENCODING           =
*    INITIAL_DIRECTORY       =
*    MULTISELECTION          =
  CHANGING
    FILE_TABLE              = LT_FILETABLE
    RC                      = LI_RC
*    USER_ACTION             =
*    FILE_ENCODING           =
  EXCEPTIONS
    FILE_OPEN_DIALOG_FAILED = 1
    CNTL_ERROR              = 2
    ERROR_NO_GUI            = 3
    NOT_SUPPORTED_BY_GUI    = 4
    others                  = 5
        .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

READ TABLE LT_FILETABLE INTO LS_FILETABLE INDEX 1.
P_FILEN = LS_FILETABLE-FILENAME.


ENDIF.


ELSE.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
*     DIRECTORY              = ' '
      FILEMASK               = '*.*'
    IMPORTING
      SERVERFILE             = P_FILEN
   EXCEPTIONS
     CANCELED_BY_USER       = 1
     OTHERS                 = 2
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDIF.




ENDFORM.
