REPORT zselscreenDemo.
TABLES: sscrfields.
PARAMETERS: _matnr TYPE matnr.

INITIALIZATION.
sscrfields-functxt_01 = |@09@ Button 1|.
sscrfields-functxt_02 = |@08@ Button 2|.
sscrfields-functxt_03 = |@07@ Button 3|.
sscrfields-functxt_04 = |@08@ Button 4|.
sscrfields-functxt_05 = |@05@ Button 5|.

SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.
SELECTION-SCREEN FUNCTION KEY 3.
SELECTION-SCREEN FUNCTION KEY 4.
SELECTION-SCREEN FUNCTION KEY 5.


AT SELECTION-SCREEN.
  IF sscrfields-ucomm = 'FC01'.
    sscrfields-ucomm = 'ONLI'." Continue for Start of selection.
  ENDIF.


START-OF-SELECTION.
WRITE: 'TEST'.
