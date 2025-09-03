*&---------------------------------------------------------------------*
*& Report ZBK_SEHIR_LISTELEME
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBK_SEHIR_LISTELEME.

*farklı dosyaları buraya ekle
*         değişkenler,types,tables
INCLUDE: zbk_sehir_listeleme_top,
*         class'lar,method tanımları
         zbk_sehir_listeleme_cls,
*         formlar, SELECT, ALV çağrısı
         zbk_sehir_listeleme_mdl.

*program buradan çalışmaya başlar
START-OF-SELECTION.
*  CREATE OBJECT go_main.
*  go_main->start_screen( ).
