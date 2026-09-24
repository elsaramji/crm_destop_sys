$ErrorActionPreference = 'Stop'

$workDir = Join-Path $PSScriptRoot "excel_temp"
if (Test-Path $workDir) { Remove-Item -Recurse -Force $workDir }
New-Item -ItemType Directory -Path (Join-Path $workDir "_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $workDir "xl\_rels") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $workDir "xl\worksheets") | Out-Null

# 1. [Content_Types].xml
$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStringItem+xml"/>
</Types>
'@
[System.IO.File]::WriteAllText((Join-Path $workDir "[Content_Types].xml"), $contentTypes, [System.Text.Encoding]::UTF8)

# 2. _rels/.rels
$rootRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>
'@
[System.IO.File]::WriteAllText((Join-Path $workDir "_rels\.rels"), $rootRels, [System.Text.Encoding]::UTF8)

# 3. xl/_rels/workbook.xml.rels
$wbRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>
</Relationships>
'@
[System.IO.File]::WriteAllText((Join-Path $workDir "xl\_rels\workbook.xml.rels"), $wbRels, [System.Text.Encoding]::UTF8)

# 4. xl/workbook.xml
$wbXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="Customers" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>
'@
[System.IO.File]::WriteAllText((Join-Path $workDir "xl\workbook.xml"), $wbXml, [System.Text.Encoding]::UTF8)

# 50 Customer Records
$customers = @(
    @{ NID = "29001010101111"; Name = "Mohamed Ahmed El-Sayed"; Phone = "01011110001"; Address = "Nasr City, Cairo"; Email = "mohamed.elsayed@example.com" },
    @{ NID = "29102020202222"; Name = "Fatma Mahmoud Ibrahim"; Phone = "01122220002"; Address = "Smoha, Alexandria"; Email = "fatma.ibrahim@example.com" },
    @{ NID = "29203030303333"; Name = "Tarek Youssef Mostafa"; Phone = "01233330003"; Address = "Dokki, Giza"; Email = "tarek.mostafa@example.com" },
    @{ NID = "29304040404444"; Name = "Sara Adel Abdel-Rahman"; Phone = "01544440004"; Address = "Maadi, Cairo"; Email = "sara.adel@example.com" },
    @{ NID = "29405051205555"; Name = "Omar Khaled Mansour"; Phone = "01055550005, 01255550005"; Address = "Mansoura, Dakahlia"; Email = "omar.mansour@example.com" },
    @{ NID = "29506061306666"; Name = "Nourhan Essam Tawfik"; Phone = "01166660006"; Address = "Zamalek, Cairo"; Email = "nourhan.tawfik@example.com" },
    @{ NID = "29607071407777"; Name = "Mostafa Kamal El-Din"; Phone = "01277770007"; Address = "Banha, Qalyubia"; Email = "mostafa.kamal@example.com" },
    @{ NID = "29708081508888"; Name = "Aya Hany Radwan"; Phone = "01588880008"; Address = "Desouk, Kafr El Sheikh"; Email = "aya.radwan@example.com" },
    @{ NID = "29809091609999"; Name = "Youssef Magdy Soliman"; Phone = "01099990009"; Address = "Tanta, Gharbia"; Email = "youssef.soliman@example.com" },
    @{ NID = "29910101701010"; Name = "Hend Sherif Nabil"; Phone = "01110100010"; Address = "Shebin El Kom, Menofia"; Email = "hend.nabil@example.com" },
    @{ NID = "30011111801111"; Name = "Amr Ezzat Farouk"; Phone = "01211110011"; Address = "Damanhour, Beheira"; Email = "amr.farouk@example.com" },
    @{ NID = "30112121901212"; Name = "Yasmin Medhat Hamdy"; Phone = "01512120012"; Address = "Ismailia City, Ismailia"; Email = "yasmin.hamdy@example.com" },
    @{ NID = "30201152101313"; Name = "Karim Hesham Sabry"; Phone = "01013130013, 01113130013"; Address = "Haram, Giza"; Email = "karim.sabry@example.com" },
    @{ NID = "30302202201414"; Name = "Dina Tamer Abdel-Aziz"; Phone = "01114140014"; Address = "Beni Suef City"; Email = "dina.tamer@example.com" },
    @{ NID = "30403252301515"; Name = "Khaled Walid Zahran"; Phone = "01215150015"; Address = "Faiyum City"; Email = "khaled.zahran@example.com" },
    @{ NID = "28504122401616"; Name = "Rania Fouad El-Kady"; Phone = "01516160016"; Address = "Minya City, Minya"; Email = "rania.elkady@example.com" },
    @{ NID = "28605182501717"; Name = "Mahmoud Samir Qasim"; Phone = "01017170017"; Address = "Asyut City, Asyut"; Email = "mahmoud.qasim@example.com" },
    @{ NID = "28706222601818"; Name = "Salma Bahaa El-Din"; Phone = "01118180018"; Address = "Sohag City, Sohag"; Email = "salma.bahaa@example.com" },
    @{ NID = "28807262701919"; Name = "Ahmed Hossam Badran"; Phone = "01219190019"; Address = "Qena City, Qena"; Email = "ahmed.badran@example.com" },
    @{ NID = "28908302802020"; Name = "Mona Ashraf Fawzy"; Phone = "01520200020"; Address = "Aswan City, Aswan"; Email = "mona.fawzy@example.com" },
    @{ NID = "29009142902121"; Name = "Haitham Shawky Allam"; Phone = "01021210021"; Address = "Luxor City"; Email = "haitham.allam@example.com" },
    @{ NID = "29110183102222"; Name = "Noha Mamdouh Hegazy"; Phone = "01122220022"; Address = "Hurghada, Red Sea"; Email = "noha.hegazy@example.com" },
    @{ NID = "29211223202323"; Name = "Sherif Gamal El-Shamy"; Phone = "01223230023"; Address = "Kharga, New Valley"; Email = "sherif.elshamy@example.com" },
    @{ NID = "29312283302424"; Name = "Mai Alaa El-Gohary"; Phone = "01524240024"; Address = "Marsa Matrouh"; Email = "mai.elgohary@example.com" },
    @{ NID = "29401053402525"; Name = "Ziad Ayman Darwish"; Phone = "01025250025, 01525250025"; Address = "Arish, North Sinai"; Email = "ziad.darwish@example.com" },
    @{ NID = "29502103502626"; Name = "Reem Essam El-Fishawy"; Phone = "01126260026"; Address = "Sharm El-Sheikh, South Sinai"; Email = "reem.elfishawy@example.com" },
    @{ NID = "29603150102727"; Name = "Hassan Atef Abou-Zeid"; Phone = "01227270027"; Address = "Heliopolis, Cairo"; Email = "hassan.abouzeid@example.com" },
    @{ NID = "29704200202828"; Name = "Nada Hisham El-Gazzar"; Phone = "01528280028"; Address = "Roushdy, Alexandria"; Email = "nada.elgazzar@example.com" },
    @{ NID = "29805251202929"; Name = "Bassam Reda Shakir"; Phone = "01029290029"; Address = "Mit Ghamr, Dakahlia"; Email = "bassam.shakir@example.com" },
    @{ NID = "29906301403030"; Name = "Asmaa Wael Metwally"; Phone = "01130300030"; Address = "Shubra El Kheima, Qalyubia"; Email = "asmaa.metwally@example.com" },
    @{ NID = "30007052103131"; Name = "Seif El-Din Hazem"; Phone = "01231310031"; Address = "6th of October, Giza"; Email = "seif.hazem@example.com" },
    @{ NID = "30108100103232"; Name = "Habiba Sameh El-Baz"; Phone = "01532320032"; Address = "New Cairo, Cairo"; Email = "habiba.elbaz@example.com" },
    @{ NID = "30209150203333"; Name = "Marwan Tariq Ashour"; Phone = "01033330033"; Address = "Sidi Gaber, Alexandria"; Email = "marwan.ashour@example.com" },
    @{ NID = "30310201303434"; Name = "Radwa Moustafa Labib"; Phone = "01134340034"; Address = "Zagazig, Sharkia"; Email = "radwa.labib@example.com" },
    @{ NID = "30411251603535"; Name = "Hany Nabil El-Masry"; Phone = "01235350035"; Address = "El Mahalla, Gharbia"; Email = "hany.elmasry@example.com" },
    @{ NID = "28512301703636"; Name = "Omnia Raafat Shenouda"; Phone = "01536360036"; Address = "Ashmoun, Menofia"; Email = "omnia.shenouda@example.com" },
    @{ NID = "28601081803737"; Name = "Walid Mohsen Bakr"; Phone = "01037370037"; Address = "Kafr El Dawwar, Beheira"; Email = "walid.bakr@example.com" },
    @{ NID = "28702142103838"; Name = "Menna Tarek Kassem"; Phone = "01138380038"; Address = "Sheikh Zayed, Giza"; Email = "menna.kassem@example.com" },
    @{ NID = "28803190103939"; Name = "Aly Osama El-Wakeel"; Phone = "01239390039"; Address = "El Shorouk, Cairo"; Email = "aly.elwakeel@example.com" },
    @{ NID = "28904240204040"; Name = "Heba Emad Mansi"; Phone = "01540400040"; Address = "Gleem, Alexandria"; Email = "heba.mansi@example.com" },
    @{ NID = "29005291204141"; Name = "Fady Makram Yassa"; Phone = "01041410041"; Address = "Talkha, Dakahlia"; Email = "fady.yassa@example.com" },
    @{ NID = "29106031404242"; Name = "Mariam Rafik Bishoy"; Phone = "01142420042"; Address = "Qalyub, Qalyubia"; Email = "mariam.bishoy@example.com" },
    @{ NID = "29207082104343"; Name = "Eslam Sabry El-Naggar"; Phone = "01243430043"; Address = "Mohandessin, Giza"; Email = "eslam.elnaggar@example.com" },
    @{ NID = "29308130104444"; Name = "Doaa Saeed Gomaa"; Phone = "01544440044"; Address = "Madinaty, Cairo"; Email = "doaa.gomaa@example.com" },
    @{ NID = "29409180204545"; Name = "Hazem Rashad Okasha"; Phone = "01045450045"; Address = "Loran, Alexandria"; Email = "hazem.okasha@example.com" },
    @{ NID = "29510231304646"; Name = "Shaimaa Fathy Lotfy"; Phone = "01146460046"; Address = "Belbeis, Sharkia"; Email = "shaimaa.lotfy@example.com" },
    @{ NID = "29611281604747"; Name = "Moataz Samy Abdel-Latif"; Phone = "01247470047"; Address = "Zifta, Gharbia"; Email = "moataz.samy@example.com" },
    @{ NID = "29712031704848"; Name = "Yara Morad El-Bishry"; Phone = "01548480048"; Address = "Menouf, Menofia"; Email = "yara.morad@example.com" },
    @{ NID = "29801092104949"; Name = "Rami Talaat El-Kholy"; Phone = "01049490049"; Address = "Agouza, Giza"; Email = "rami.elkholy@example.com" },
    @{ NID = "29902140105050"; Name = "Ghadir Hatem Zaki"; Phone = "01150500050"; Address = "El Rehab, Cairo"; Email = "ghadir.zaki@example.com" }
)

# Shared Strings
$stringsList = New-Object System.Collections.Generic.List[string]
$stringMap = @{}

function Get-StringId($str) {
    if ($stringMap.ContainsKey($str)) {
        return $stringMap[$str]
    }
    $idx = $stringsList.Count
    $stringsList.Add($str)
    $stringMap[$str] = $idx
    return $idx
}

# Header strings
$hNID = Get-StringId "National ID"
$hName = Get-StringId "Full Name"
$hPhone = Get-StringId "Phone Numbers"
$hAddr = Get-StringId "Address"
$hEmail = Get-StringId "Email"

$sheetData = New-Object System.Text.StringBuilder
[void]$sheetData.AppendLine('    <row r="1">')
[void]$sheetData.AppendLine("      <c r=`"A1`" t=`"s`"><v>$hNID</v></c>")
[void]$sheetData.AppendLine("      <c r=`"B1`" t=`"s`"><v>$hName</v></c>")
[void]$sheetData.AppendLine("      <c r=`"C1`" t=`"s`"><v>$hPhone</v></c>")
[void]$sheetData.AppendLine("      <c r=`"D1`" t=`"s`"><v>$hAddr</v></c>")
[void]$sheetData.AppendLine("      <c r=`"E1`" t=`"s`"><v>$hEmail</v></c>")
[void]$sheetData.AppendLine('    </row>')

$r = 2
foreach ($c in $customers) {
    $sNID = Get-StringId $c.NID
    $sName = Get-StringId $c.Name
    $sPhone = Get-StringId $c.Phone
    $sAddr = Get-StringId $c.Address
    $sEmail = Get-StringId $c.Email

    [void]$sheetData.AppendLine("    <row r=`"$r`">")
    [void]$sheetData.AppendLine("      <c r=`"A$r`" t=`"s`"><v>$sNID</v></c>")
    [void]$sheetData.AppendLine("      <c r=`"B$r`" t=`"s`"><v>$sName</v></c>")
    [void]$sheetData.AppendLine("      <c r=`"C$r`" t=`"s`"><v>$sPhone</v></c>")
    [void]$sheetData.AppendLine("      <c r=`"D$r`" t=`"s`"><v>$sAddr</v></c>")
    [void]$sheetData.AppendLine("      <c r=`"E$r`" t=`"s`"><v>$sEmail</v></c>")
    [void]$sheetData.AppendLine('    </row>')
    $r++
}

# 5. xl/sharedStrings.xml
$sstXml = New-Object System.Text.StringBuilder
[void]$sstXml.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
[void]$sstXml.AppendLine("<sst xmlns=`"http://schemas.openxmlformats.org/spreadsheetml/2006/main`" count=`"$($stringsList.Count)`" uniqueCount=`"$($stringsList.Count)`">")
foreach ($s in $stringsList) {
    $escaped = [System.Security.SecurityElement]::Escape($s)
    [void]$sstXml.AppendLine("  <si><t>$escaped</t></si>")
}
[void]$sstXml.AppendLine('</sst>')
[System.IO.File]::WriteAllText((Join-Path $workDir "xl\sharedStrings.xml"), $sstXml.ToString(), [System.Text.Encoding]::UTF8)

# 6. xl/worksheets/sheet1.xml
$wsXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <sheetData>
$($sheetData.ToString())  </sheetData>
</worksheet>
"@
[System.IO.File]::WriteAllText((Join-Path $workDir "xl\worksheets\sheet1.xml"), $wsXml, [System.Text.Encoding]::UTF8)

# Output zip/xlsx
$destPath = "d:\mobile development  advance\crm_destop_sys\customers_50_test.xlsx"
if (Test-Path $destPath) { Remove-Item -Force $destPath }

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($workDir, $destPath)

Remove-Item -Recurse -Force $workDir
Write-Output "Successfully generated: $destPath"
