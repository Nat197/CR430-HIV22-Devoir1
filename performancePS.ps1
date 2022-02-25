
$computerName = $env:COMPUTERNAME

$cpu = Get-Counter -Counter "\Processeur(_Total)\% temps processeur" -SampleInterval 1 -MaxSamples 1
$memoryFreeSpaceMegabytes = Get-Counter -Counter "\Mémoire\Mégaoctets disponibles" -SampleInterval 1 -MaxSamples 1 
$networkBandePassanteWIFI = Get-Counter -Counter "\Interface réseau(Intel[R] Wi-Fi 6 AX201 160MHz)\Bande passante actuelle" -SampleInterval 1 -MaxSamples 1 
$physicalDiskTotalOctets = Get-Counter -Counter "\Disque physique(_Total)\Octets disque/s" -SampleInterval 1 -MaxSamples 1 
$physicalDiskPourcentageInactivite = Get-Counter -Counter "\Disque physique(_Total)\% d’inactivité" -SampleInterval 1 -MaxSamples 1 
        
$properties = @{
    cpu = $cpu.CounterSamples.CookedValue
    memoryFreeSpaceMegabytes = $memoryFreeSpaceMegabytes.CounterSamples.CookedValue
    networkBandePassanteWIFI = $networkBandePassanteWIFI.CounterSamples.CookedValue
    physicalDiskTotalOctets = $physicalDiskTotalOctets.CounterSamples.CookedValue
    physicalDiskPourcentageInactivite = $physicalDiskPourcentageInactivite.CounterSamples.CookedValue
}
$exportObject = New-Object psobject -Property $propertie
#Repertoire ou le fichier de resultat sera sauvergarder
$RepertoireSortie = "C:\DevoirCR430_Performance-Counters"

#Verifie si le repertoire de sortie existe, si non il va le creer.
if (-not(Test-Path $RepertoireSortie))
{
    Write-Host "Le repertoire de sorti n'existe pas. Un repertoire va etre creer."
    $null = New-Item -Path $RepertoireSortie -ItemType "Directory"
    Write-Host "Un repertoire de sorti a ete creer"
}

#Enleve le \ a la fin du Path si nessecaire.
if ($RepertoireSortie.EndsWith("\")) {$RepertoireSortie = $RepertoireSortie.Substring(0, $RepertoireSortie.Length - 1)}

$FichierSortie = "$RepertoireSortie\{$computerName}) $(Get-Date -Format "yyyy_MM_dd HH_mm_ss")-Performance.cvs" 


Write-Host $exportObject
Export-Csv -Path $FichierSortie -InputObject $exportObject -Force


