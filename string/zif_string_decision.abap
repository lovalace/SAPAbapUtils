interface ZIF_STRING_DECISION
  public .

"! Single Usage <strong>ContainsPatter( 'Value' )</strong> <br/>Multiple Usage
"!
"! <strong>"-containspattern( : Value1), Value2)."</strong>
  methods CONTAINSPATTERN
    importing
      !PATTERN type STRING
    returning
      value(RESULT) type BOOLEAN .
"! Verilen değer ile string sonunu Karşılaştıran method.
  methods ENDSWITH
    importing
      !VALUE type STRING
    returning
      value(RESULT) type BOOLEAN.
"! Check Value is initial or space.
  methods ISNULLOREMPTY
    returning
      value(RESULT) type BOOLEAN .
"! Verilen değerin Sayı olup olmadığını kontrol eder.
  methods ISNUMBER
    returning
      value(RESULT) type BOOLEAN .
"! String değerin Value ile başlayıp başlamadığını kontrol eder.
  methods STARTSWITH
    importing
      !VALUE type STRING
    returning
      value(RESULT) type BOOLEAN .
endinterface.
