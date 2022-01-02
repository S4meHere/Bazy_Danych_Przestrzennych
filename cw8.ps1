#######################  Aktualna data i data utworzenia skryptu ####################### 

$data = Get-Date 
${TIMESTAMP}  = "{0:MM-dd-yyyy}" -f ($data) 
${TIMESTAMP}
$data

#######################  Change log ####################### 

$skrypt = "C:\Users\anklo\OneDrive\Pulpit\BDP\cw8.ps1"
$log = "C:\Users\anklo\OneDrive\Pulpit\BDP\\Cwiczenie8_${TIMESTAMP}.log"

# tworzy changelog
$skrypt_log = Get-ItemProperty $skrypt | Format-Wide -Property CreationTime
"#######################  Change log #######################`n`nData utworzenia skryptu:" > "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"

# zapisuje date utworzenia 
$skrypt_log >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"




####################### Pobieranie pliku #######################

#lokalizacja pliku źródłowego 
$url = "https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip"

#miejsce zapisu pliku
$plik = "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_Nov2021.zip"

#pobieranie pliku 
Invoke-WebRequest -Uri $url -OutFile $plik

Write-Host "`nPobieranie pliku działa"

$data = Get-Date 
$data, "   -   Pobieranie pliku   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"




####################### Rozpakowanie pliku #######################

#scieżka do winrara
$WinRAR = "C:\Program Files\WinRAR\WinRAR.exe"
$haslo = "agh"

#ustawienie lokalizacji
Set-Location "C:\Users\anklo\OneDrive\Pulpit\BDP"

#rozpakowywanie 
Start-Process "$WinRAR" -ArgumentList "x -y `"$plik`" -p$haslo"

Write-Host " `nRozpakowywanie pliku działa "

$data = Get-Date 
$data, "   -   Rozpakowanie pliku   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"


####################### Poprawność pliku #######################


$nrIndeksu = "402868"
$Plik_1 = Get-Content "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_Nov2021.csv"

#szuka pustych lini  
$poprawny_plik = for($i = 0; $i -lt $Plik_1.Count; $i++)
                 {
                  if($Plik_1[$i] -ne "")
                     {
                         $Plik_1[$i]  
                     }
                 } 

#plik z błędnymi wierszami
$poprawny_plik[0] > "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_Nov2021.bad_${TIMESTAMP}"


#porównaj plik wejściowy z plikiem Customers_old.csv, pozostaw te wiersze, które nie występują w pliku Customers_old.csv
$Plik_2 = Get-Content "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_old.csv"
for($i = 1; $i -lt $poprawny_plik.Count; $i++)
{
  for($j = 0; $j -lt $Plik_2.Count; $j++)
    {
       if($poprawny_plik[$i] -eq $Plik_2[$j])
         {
             $poprawny_plik[$i] >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_Nov2021.bad_${TIMESTAMP}"
             $poprawny_plik[$i] = $null
          }
   }
 } 

#końcowy plik po walidacji
$poprawny_plik > "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_Nov2021.csv" 

Write-Host " `nPoprawność pliku działa "


$data = Get-Date 
$data, "   -   Poprawność pliku  -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"




####################### Dodawanie tabeli #######################


#ustawianie lokalizacji
Set-Location 'C:\Program Files\PostgreSQL\13\bin\'


#logowanie do postgresa
$env:USER = "lab8"
$env:PGPASSWORD = 'lab89'
$env:DATABASE = "lab8"
$env:NEWDATABASE = "customers"
$env:TABLE = "CUSTOMERS_$nrIndeksu"
$env:SERVER  ="PostgreSQL 13"
$env:PORT = "5432"


#dodawanie tabeli
./psql.exe -U lab8 -d $env:NEWDATABASE -c "DROP TABLE IF EXISTS $env:TABLE"
./psql.exe -U lab8 -d $env:DATABASE -w -c "DROP DATABASE IF EXISTS $env:NEWDATABASE"
./psql.exe -U lab8 -d $env:DATABASE -w -c "CREATE DATABASE $env:NEWDATABASE"
./psql.exe -U lab8 -d $env:NEWDATABASE -c "CREATE TABLE IF NOT EXISTS $env:TABLE (first_name VARCHAR(100), last_name VARCHAR(100) PRIMARY KEY, email VARCHAR(100), lat VARCHAR(100) NOT NULL, long VARCHAR(100) NOT NULL)"


Write-Host " `nPoprawność pliku działa "

$data = Get-Date 
$data, "   -   Dodawanie tabeli   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"



####################### Załadowanie danych #######################


#zamiana , na ','
$poprawny_plik_2 = $poprawny_plik -replace ",", "','"


#wczytywanie danych do tabeli
for($i=1; $i -lt $poprawny_plik_2.Count; $i++)
{
    $poprawny_plik_2[$i] = "'" + $poprawny_plik_2[$i] + "'"
    $wczytaj = $poprawny_plik_2[$i]
    ./psql.exe -U lab8 -d $env:NEWDATABASE -w -c "INSERT INTO $env:TABLE (first_name, last_name, email, lat, long) VALUES($wczytaj)"
}

#wyświetlenie tabeli
./psql.exe -U lab8 -d $env:NEWDATABASE -w -c "SELECT * FROM $env:TABLE"

Write-Host " `nPzaładowanie danych działa "


$data = Get-Date 
$data, "   -   Załadowanie danych   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"



####################### Przeniesienie pliku #######################

#stworzenie katalogu PROCESSED
New-Item -Path 'C:\Users\anklo\OneDrive\Pulpit\BDP\PROCESSED' -ItemType Directory

Set-Location C:\Users\anklo\OneDrive\Pulpit\BDP

#przeniesienie do podkatalogu i zmiana nazwy
Move-Item -Path "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_Nov2021.csv" -Destination "C:\Users\anklo\OneDrive\Pulpit\BDP\PROCESSED" -PassThru -ErrorAction Stop
Rename-Item -Path "C:\Users\anklo\OneDrive\Pulpit\BDP\PROCESSED\Customers_Nov2021.csv" "${TIMESTAMP}_Customers_Nov2021.csv"

Write-Host " `nprzeniesienie pliku działa "


$data = Get-Date 
$data, "   -   Przeniesienie pliku   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"



####################### Wysłanie maila #######################


#ponowne wczytanie plików
$Plik_zinternetu = $Plik_1
$poprawny_plik = Get-Content "C:\Users\anklo\OneDrive\Pulpit\BDP\PROCESSED\${TIMESTAMP}_Customers_Nov2021.csv"
$plik_bledy = Get-Content "C:\Users\anklo\OneDrive\Pulpit\BDP\Customers_Nov2021.bad_${TIMESTAMP}"


#obliczenia
$wszystkie_wiersze = $Plik_zinternetu.Count
$wszystkie_wiersze
$wiersze_po_czyszeniu = $poprawny_plik.Count
$wiersze_po_czyszeniu
$duplikaty = $plik_bledy.Count
$duplikaty
$dane_tabela = $poprawny_plik.Count -1
$dane_tabela


#wywłanie maila
$MyEmail = "an.klopotowska@gmail.com"
$SMTP= "smtp.gmail.com"
$To = "an.klopotowska@gmail.com"
$Subject = "CUSTOMERS LOAD - ${TIMESTAMP}"
$Body = "liczba wierszy w pliku pobranym z internetu: $wszystkie_wiersze`n
liczba poprawnych wierszy (po czyszczeniu): $wiersze_po_czyszeniu`n
liczba duplikatow w pliku wejsciowym: $duplikaty`n 
ilosc danych zaladowanych do tabeli: $dane_tabela `n"

$Creds = (Get-Credential -Credential $MyEmail)

Send-MailMessage -To $MyEmail -From $MyEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587 -DeliveryNotificationOption never

Write-Host " `nWysłanie maila działa działa "


$data = Get-Date 
$data, "   -   Wysłanie maila   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"



####################### Kwerenda SQL ###############################

#utworenie pliku txt
New-Item -Path 'C:\Users\anklo\OneDrive\Pulpit\BDP\zapytanie.txt' -ItemType File

#wisanie do pliku kwerendy
Set-Content -Path 'C:\Users\anklo\OneDrive\Pulpit\BDP\zapytanie.txt' -Value " 
 alter table customers_402868 alter column lat type double precision using lat::double precision;
alter table customers_402868 alter column long type double precision using long::double precision;

SELECT first_name, last_name  INTO best_customers_402868 FROM customers_402868
            WHERE ST_DistanceSpheroid( 
        ST_Point(lat, long), ST_Point(41.39988501005976, -75.67329768604034),
        'SPHEROID[""WGS 84"",6378137,298.257223563]') <= 50000"
        
#sprawdzenie czy tabela już nie istnieje
Set-Location 'C:\Program Files\PostgreSQL\13\bin\'
$NOWATABELA = "BEST_CUSTOMERS_402868"
./psql.exe -U lab8 -d $env:NEWDATABASE -w -c "DROP TABLE IF EXISTS $NOWATABELA"

#uruchomienie zapytania
./psql.exe -U lab8 -d $env:NEWDATABASE -w -c "CREATE EXTENSION postgis"
./psql.exe -U lab8 -d $env:NEWDATABASE -w -f "C:\Users\anklo\OneDrive\Pulpit\BDP\zapytanie.txt"

Write-Host " `nKwerenda SQL działa "

      $data = Get-Date 
$data, "   -   Kwerenda SQL   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"


####################### Export tabeli #######################

#zapisuje tabele
$zapis = ./psql.exe -U lab8 -d $env:NEWDATABASE -w -c "SELECT * FROM $NOWATABELA" 
$zapis
$tab = @()

#????
for ($i=2; $i -lt $zapis.Count-2; $i++)
{
    $dane = New-Object -TypeName PSObject
    $dane | Add-Member -Name 'first_name' -MemberType Noteproperty -Value $zapis[$i].Split( "|")[0]
    $dane | Add-Member -Name 'last_name' -MemberType Noteproperty -Value $zapis[$i].Split( "|")[1]
    $dane | Add-Member -Name 'odleglosc' -MemberType Noteproperty -Value $zapis[$i].Split( "|")[2]
    $tab += $dane
}

#ekspoert tabeli 
$tab | Export-Csv -Path "C:\Users\anklo\OneDrive\Pulpit\BDP\$NOWATABELA.csv" -NoTypeInformation


Write-Host " `nExport tabeli działa "

$data = Get-Date 
$data, "   -   Export tabeli   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"



####################### Skompresowanie pliku #######################


Compress-Archive -Path "C:\Users\anklo\OneDrive\Pulpit\BDP\$NOWATABELA.csv" -DestinationPath "C:\Users\anklo\OneDrive\Pulpit\BDP\$NOWATABELA.zip"

Write-Host " `nSkompresowanie pliku działa "

$data = Get-Date 
$data, "   -   Skompresowanie pliku   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"



####################### Wysłanie pliku mailem #######################

#dodanie daty utworzenia
Get-ItemProperty "C:\Users\anklo\OneDrive\Pulpit\BDP\$NOWATABELA.csv" | Format-Wide -Property CreationTime > "C:\Users\anklo\OneDrive\Pulpit\BDP\data.txt"
$data = Get-Content "C:\Users\anklo\OneDrive\Pulpit\BDP\data.txt"

Remove-Item -Path "C:\Users\anklo\OneDrive\Pulpit\BDP\data.txt"

#zapis danych
$wiersze = $zapis.Count -3
$Skompresowany_plik = "C:\Users\anklo\OneDrive\Pulpit\BDP\$NOWATABELA.zip"

#utworzenie treści 
$Body2 = "`n`nData ostatniej modyfikacji pliku:$data
Ilosc wierszy w pliku CSV:   $wiersze"

$Creds = (Get-Credential -Credential "$MyEmail")

#wysłanie maila
Send-MailMessage -To $To -From $MyEmail -Subject $Subject -Body $Body2 -Attachments $Skompresowany_plik -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587 -DeliveryNotificationOption never

$data = Get-Date 
$data, "   -   Wysłanie pliku mailem   -   Successful!" >> "C:\Users\anklo\OneDrive\Pulpit\BDP\Cwiczenie8_${TIMESTAMP}.log"
