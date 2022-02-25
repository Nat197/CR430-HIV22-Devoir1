#Repertoire ou le fichier de resultat sera sauvergarder
$RepertoireSortie = "C:\Compteurs-des-Performances"

#Set le nom de l'ordinateur pour lequel les donnees de performance seront collecter.
#Laissez vide pour l'ordinateur local
$NomOrdinateur = ""

#Collection d'interval par secondes
$sampleInterval = 15

#Nombre d'echantillon qu'on veut collecter. 
#Set le nombre a 0 si on veut un collection continue.
$maxSamples  = 240

#Verifie si le repertoire de sortie existe, si non il va le creer.
if (-not(Test-Path $RepertoireSortie))
    {
        
        Write-Host "Le repertoire de sorti n'existe pas. Un repertoire va etre creer."
        $null = New-Item -Path $RepertoireSortie -ItemType "Directory"
        Write-Host "Un repertoire de sorti a ete creer"
    }

#Enleve le \ a la fin du Path si nessecaire.
if ($RepertoireSortie.EndsWith("\")) {$RepertoireSortie = $RepertoireSortie.Substring(0, $RepertoireSortie.Length - 1)}

#Creation du nom de fichier de sortie comme etant : le nom de l'ordinateur suivi de la date.csv
$FichierSortie = "$RepertoireSortie\$(if($NomOrdinateur -eq '')
                                        {$env:COMPUTERNAME} 
                                        else 
                                        {$NomOrdinateur}) $(Get-Date -Format "yyyy_MM_dd HH_mm_ss").csv"
 
#Affiche les parametres a l'ecran.
Write-Host "
 
Recuperation des donnees...
Entrez Ctrl+C pour quitter."
 
#Specify the list of performance counters to collect.
    $counters =(
        "\Processeur(_Total)\% temps processeur",
        "\Mémoire\Mégaoctets disponibles",
        "\Interface réseau(Intel[R] Wi-Fi 6 AX201 160MHz)\Bande passante actuelle",
        "\Disque physique(_Total)\Octets disque/s"
    )

    $variables = @{
        SampleInterval = $sampleInterval
        Counter = $counters
    }


     
#Either set the sample interval or specify to collect continuous.
if ($maxSamples -eq 0 -or $null) {$variables.Add("Continue",1)}
else {$variables.Add("MaxSamples","$maxSamples")}
    
#Ajout du nom de l'ordinateur si le nom n'est pas vide
if ($NomOrdinateur -ne "" -or $null) {$variables.Add("ComputerName","$NomOrdinateur")}

#Show the variables then execute the command while storing the results in a file.
Get-Counter @Variables | Export-Csv -Path $FichierSortie -Force



