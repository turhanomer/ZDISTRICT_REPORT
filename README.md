# ZDISTRICT_REPORT

This ABAP project displays cities and their districts in an ALV grid.  
The program dynamically creates columns (ILCE1, ILCE2, ...) based on the city with the maximum number of districts.

## Tables

- **ZIL_TABLO**: MANDT, IL_KODU, IL_ISIM  
- **ZIL_ILCE_TABLO**: MANDT, IL_KODU, ILCE_KODU  
- **ZILCE_TABLO**: MANDT, ILCE_KODU, ILCE_ISIM  

## How it Works

1. Count the number of districts per city.  
2. Find the maximum number of districts and generate that many columns.  
3. Fill each city row with its district names.  
4. Display the result in an ALV grid.  

## Usage

- Place the code in `ZBK_SEHIR_LISTELEME_CLS`.  
- Use screen number `0100`.  
- Custom Control name must be `CC_ALV`.  

## Screenshot
![Project Screenshot](https://github.com/user-attachments/assets/7419708d-792d-42d3-a4bc-9609dae4c790)
