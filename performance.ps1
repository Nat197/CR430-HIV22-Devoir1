





#Emplacement des logs

#Vérification du OS et sélection de l'emplacement selon le OS
if($PSVersionTable.Platform -eq 'Unix'){
    $logPath = '/tmp'
}
else{
    $logPath = 'C:\Logs'
}

$logFile = "$logPath"

#Repertoire ou le fichier de resultat sera sauvergarder
$RepertoireSortie = "C:\Users\"GetCurrent().Name"\Desktop\Compteurs des Performances"

#Set le nom de l'ordinateur pour lequel les donnees de performance seront collecter.
#Laissez vide pour l'ordinateur local
$NomOrdinateur = ""

#Collection d'interval par secondes
$IntervaleEchantillon = 20

#Nombre d'echantillon qu'on veut collecter. 
#Set le nombre a 0 si on veut un collection continue.
$EchantillonMax = 260 

#Verifie si le repertoire de sortie existe, si non il va le creer.
if (-not(Test-Path $RepertoireSortie))
    {
        
        Write-Host "Le repertoire de sorti n'existe pas. Un repertoire va etre creer."
        $null = New-Item -Path $RepertoireSortie -ItemType "Directory"
        Write-Host "Un repertoire de sorti a ete creer"
    }

#Enleve le \ a la fin du Path si nessecaire.
if ($RepertoireSortie.EndsWith("\")) {$RepertoireSortie = $RepertoireSortie.Substring(0, $RepertoireSortie.Length - 1)}
