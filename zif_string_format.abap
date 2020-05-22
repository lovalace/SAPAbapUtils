interface ZIF_STRING_FORMAT
  public .

"! String değeri tarih formatında çevirir
  methods TODATE
    RETURNING VALUE(RESULT) type DATS .
 "! Verilen değeri Yerel tarih değerine çevirir.  Örnek: 31.12.2018
  methods LOCALDATE
    RETURNING VALUE(RESULT) type STRING .
endinterface.
