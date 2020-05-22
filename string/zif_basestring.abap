interface ZIF_BASESTRING
  public .


  interfaces ZIF_STRING_DECISION .
  interfaces ZIF_STRING_FORMAT .
  interfaces ZIF_STRING_OPERATION .

  aliases APPEND
    for ZIF_STRING_OPERATION~APPEND .
  aliases CONTAINSPATTERN
    for ZIF_STRING_DECISION~CONTAINSPATTERN .
  aliases ENDSWITH
    for ZIF_STRING_DECISION~ENDSWITH .
  aliases ISNULLOREMPTY
    for ZIF_STRING_DECISION~ISNULLOREMPTY .
  aliases ISNUMBER
    for ZIF_STRING_DECISION~ISNUMBER .
  aliases LOCALDATE
    for ZIF_STRING_FORMAT~LOCALDATE .
  aliases REPLACE
    for ZIF_STRING_OPERATION~REPLACE .
  aliases SPLIT
    for ZIF_STRING_OPERATION~SPLIT .
  aliases STARTSWITH
    for ZIF_STRING_DECISION~STARTSWITH .
  aliases STARTWITHLOWER
    for ZIF_STRING_OPERATION~STARTWITHLOWER .
  aliases STARTWITHUPPER
    for ZIF_STRING_OPERATION~STARTWITHUPPER .
  aliases SUBSTRING
    for ZIF_STRING_OPERATION~SUBSTRING .
  aliases TODATE
    for ZIF_STRING_FORMAT~TODATE .
  aliases TOLOWER
    for ZIF_STRING_OPERATION~TOLOWER .
  aliases TOUPPER
    for ZIF_STRING_OPERATION~TOUPPER .
  aliases TRIM
    for ZIF_STRING_OPERATION~TRIM .

  class-data STRING type STRING .
  class-data LENGTH type INT4 .
  "!Bu örneği döndürür String; gerçek bir dönüştürme işlemi gerçekleştirilir.
  methods TOSTRING
    importing
      !_STRING type ANY
    returning
      value(RESULT) type ref to ZIF_BASESTRING .
  "! Her öğe arasında belirtilen ayırıcı kullanarak bir dize dizinin tüm öğeleri art arda ekler.
  methods JOIN
    importing
      !_STRING type STRING
    returning
      value(RESULT) type STRING .
endinterface.
