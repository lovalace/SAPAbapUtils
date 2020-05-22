interface ZIF_STRING_OPERATION
  public .
"! String değerin büyük harfe dönüştürülmüş bir kopyasını döndürür.
  methods TOUPPER
    returning
      value(RESULT) type STRING .
 "! Abap Doc Yazilacak.
  methods TOLOWER
    returning
      value(RESULT) type STRING .
 "! Abap Doc Yazilacak.
  methods SUBSTRING
    importing
      !FROM type INT4
      !TO type INT4 .
 "! Başta ve sondaki tüm boşluk değerlerini kaldırır
  methods TRIM
    returning
      value(RESULT) type STRING .
  "! Abap Doc Yazilacak.
  methods SPLIT
    IMPORTING
     !seperator TYPE char1
     RETURNING VALUE(Result) TYPE string_table.
 "! String değerin ilk farfinin büyük  bir kopyasını döndürür.
  methods STARTWITHUPPER
    returning
      value(RESULT) type STRING .
  "! String değerin ilk farfinin küçük  bir kopyasını döndürür.
  methods STARTWITHLOWER
    returning
      value(RESULT) type STRING .
  "! Verilen değer ile istenilen değeri değiştirerek yeni bir string döndürür.
  methods REPLACE
    importing
      !REPLACE type string
      !TO type string
    returning
      value(RESULT) type STRING .
  "! Verilen tüm öğeleri art arda ekler
  methods APPEND
    importing
      !ADD type STRING
    returning
      value(RESULT) type ref to ZIF_BASESTRING .
endinterface.
