*&---------------------------------------------------------------------*
*& Include          ZBK_SEHIR_LISTELEME_CLS
*&---------------------------------------------------------------------*

CLASS lcl_class DEFINITION.
*  class her yerden erişilecek
  PUBLIC SECTION.
*  class içindeki veri alanı
    DATA: lv_columntoaddcount TYPE int4.
    METHODS: start_screen,
      pbo_0100,
      pai_0100 IMPORTING iv_ucomm TYPE sy-ucomm,
      get_data,
*    ALV field catalog bilgisini hazırlar
      set_fcat,
*    layout ayarları yapılır
      set_layout,
      display_alv,
*    ALV'ye ugun internal table yapısı oluşturulur
      get_alv_structure.
ENDCLASS.

CLASS lcl_class IMPLEMENTATION.
*  EKRAN ÇAĞRILDI
  METHOD start_screen.
    CALL SCREEN 0100.
  ENDMETHOD.

  METHOD pbo_0100.
*    GUI status ayarlanır
    SET PF-STATUS 'STATUS_0100'.
    go_main->get_data( ).
    go_main->set_layout( ).
    go_main->display_alv( ).
  ENDMETHOD.

  METHOD pai_0100.
    CASE iv_ucomm.
      WHEN '&BACK'.
        SET SCREEN 0.
    ENDCASE.
  ENDMETHOD.

  METHOD get_data.

*    Şehirlerin ilçe sayısını bul
    SELECT
      il~il_kodu, il~il_isim,
      COUNT( * ) AS ilcecount
      FROM zil_tablo AS il
      LEFT JOIN zil_ilce_tablo AS map ON map~il_kodu EQ il~il_kodu
      LEFT JOIN zilce_tablo AS ilce ON ilce~ilce_kodu EQ map~ilce_kodu
      INTO TABLE @DATA(lt_ilcecount)
      GROUP BY il~il_kodu, il~il_isim.

*      En çok ilçesi olan şehrin ilçe sayısını al
    SORT lt_ilcecount DESCENDING BY ilcecount.

    READ TABLE lt_ilcecount INTO DATA(ls_ilcecount) INDEX 1.

    lv_columntoaddcount = ls_ilcecount-ilcecount.

*      ALV kolonlarını hazırla
    go_main->set_fcat( ).
    go_main->get_alv_structure( ).

    SORT lt_ilcecount ASCENDING BY il_kodu.

*      Tüm şehir-ilçe detaylarını çek
    SELECT
      il~il_kodu,
      ilce~ilce_isim
      FROM zil_tablo AS il
      LEFT JOIN zil_ilce_tablo AS ililce ON il~il_kodu EQ ililce~il_kodu
      LEFT JOIN zilce_tablo AS ilce ON ililce~ilce_kodu EQ ilce~ilce_kodu
      INTO TABLE @DATA(lt_data).

*        Her şehir için satır oluştur
    LOOP AT lt_ilcecount INTO ls_ilcecount.
      ASSIGN COMPONENT 'IL_KODU' OF STRUCTURE <gs_alv> TO <gf_alv>.
      <gf_alv> = ls_ilcecount-il_kodu.

      ASSIGN COMPONENT 'IL_ISIM' OF STRUCTURE <gs_alv> TO <gf_alv>.
      <gf_alv> = ls_ilcecount-il_isim.

*          İlçeleri sırayla yaz
      DATA(counter) = 1.

      LOOP AT lt_data INTO DATA(ls_data).
        IF ls_ilcecount-il_kodu EQ ls_data-il_kodu.
          DATA(columnname) = 'ILCE' && counter.
          ASSIGN COMPONENT columnname OF STRUCTURE <gs_alv> TO <gf_alv>.
          <gf_alv> = ls_data-ilce_isim.
          counter = counter + 1.
        ENDIF.
      ENDLOOP.

*          Satırı ALV tablosuna ekle
      INSERT <gs_alv> INTO TABLE <gt_alv>.
      CLEAR <gs_alv>.
    ENDLOOP.
  ENDMETHOD.

*ALV'nin hangi kolonları olacağını söyleyen liste
  METHOD set_fcat.
*    ALV'ye il kolonu ekleniyor, ref table hangi tablodan geldiğini söylüyor
    gs_fcat-ref_table = 'ZIL_TABLO'.
*    hangi alanı gösterdiğini söylüyor
    gs_fcat-ref_field = 'IL_KODU'.
*    ALV'deki kolon adı
    gs_fcat-fieldname = 'IL_KODU'.
    APPEND gs_fcat TO gt_fcat.
    CLEAR gs_fcat.

*    ALV'ye IL_ISIM kolonu ekleniyor
    gs_fcat-ref_table =  'ZIL_TABLO'.
    gs_fcat-ref_field =  'IL_ISIM'.
    gs_fcat-fieldname =  'IL_ISIM'.
    APPEND gs_fcat TO gt_fcat.
    CLEAR gs_fcat.

    DATA(lv_columncount) = 1.

*    kaç ilçe varsa o kadar kolon açacak ilçe1, ilçe2...
    DO lv_columntoaddcount TIMES.
      gs_fcat-ref_table =  'ZILCE_TABLO'.
      gs_fcat-ref_field =  'ILCE_ISIM'.
      gs_fcat-fieldname =  'ILCE' && lv_columncount.

*      seltext, reptext,scrtext_ ALV başlıkları
      gs_fcat-seltext =  'Ilce' && | | && lv_columncount.
      gs_fcat-reptext =  'Ilce' && | | && lv_columncount.
      gs_fcat-scrtext_s =  'Ilce' && | | && lv_columncount.
      gs_fcat-scrtext_m =  'Ilce' && | | && lv_columncount.
      gs_fcat-scrtext_l =  'Ilce' && | | && lv_columncount.

      APPEND gs_fcat TO gt_fcat.
      CLEAR gs_fcat.
      lv_columncount = lv_columncount + 1.
    ENDDO.
  ENDMETHOD.

*  Yeni ALV'yi okunabilir yapıyor: zebra çizgili satırlar
  METHOD set_layout.
    gs_layout-zebra = 'X'.
    gs_layout-cwidth_opt = 'X'.
    gs_layout-col_opt = 'X'.
  ENDMETHOD.

  METHOD display_alv.
*    ALV grid nesnesi
    IF go_grid IS INITIAL.
*      ALV'yi koyacağımız ekran kutusu "CC_ALV"
      CREATE OBJECT go_container
        EXPORTING
          container_name = 'CC_ALV'.
      CREATE OBJECT go_grid
        EXPORTING
          i_parent = go_container.

      go_grid->set_table_for_first_display(
          EXPORTING
*            görünüm ayarları
            is_layout = gs_layout
          CHANGING
*            alv'YE BASILCAK TABLO
            it_outtab = <gt_alv>
*            kolon bilgileri
            it_fieldcatalog = gt_fcat
      ).
    ELSE.
*      ALV daha önce açıldıysa, refresh yap
      CALL METHOD go_grid->refresh_table_display.
    ENDIF.
  ENDMETHOD.

  METHOD get_alv_structure.
*                        boş bir veri objesi
    DATA: lt_table TYPE REF TO data,
          ls_line  TYPE REF TO data.

*    field catalog'a göre dinamik bir internal tablosu
    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog = gt_fcat
      IMPORTING
*        yeni tabloyu lt_table değişkenine ver
        ep_table        = lt_table.
*                           ALV'nin ana tablosu
    ASSIGN lt_table->* TO <gt_alv>.
    CREATE DATA ls_line LIKE LINE OF <gt_alv>.
*                            onun tek satırı
    ASSIGN ls_line->* TO <gs_alv>.
  ENDMETHOD.
ENDCLASS.
