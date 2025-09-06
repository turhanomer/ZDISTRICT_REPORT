*&---------------------------------------------------------------------*
*& Include          ZBK_SEHIR_LISTELEME_TOP
*&---------------------------------------------------------------------*

CLASS lcl_class DEFINITION DEFERRED.

*pointer        ALV için internal table
FIELD-SYMBOLS: <gt_alv> TYPE STANDARD TABLE,
*               tablo satırı pointer
               <gs_alv>,
*               field bazlı pointer
               <gf_alv>.
*      ana class için referans
DATA: go_main TYPE REF TO lcl_class,
*      OO ALV sınıfı
      go_grid TYPE REF TO cl_gui_alv_grid,
*      ALV'yi koyacağımız ekran
      go_container TYPE REF TO cl_gui_custom_container,

*      ALV'de field catalog
      gt_fcat TYPE lvc_t_fcat,
*      field catalog'un satırı
      gs_fcat TYPE lvc_s_fcat,
*      ALV'nin layout ayarları
      gs_layout TYPE lvc_s_layo.
