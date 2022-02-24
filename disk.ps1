<#
    Titre: Module powershell de vérification de l'état des disques dur
    Auteur : Nathan Bourgoin et Gabriel Bellemare
    Date : 23/02/2022
    Version : 1.0
    Description : Ce module powershell va permettre de vérifier certaines caractéristiques
    du disque dur et pourra notifier l'utilisateur selon certaines règles établies. Le script
    va vérifier par exemple l'espace disponible et envoyer une notification si l'espace est
    moins de 20%. Les vérification seront enregistrées dans un fichier log. L'utilisateur va 
    spécifier quel disque vérifier ainsi que la limite minimale d'espace.
#>

#Emplacement des logs

#Vérification du OS et sélection de l'emplacement selon le OS
if($PSVersionTable.Platform -eq 'Unix'){
    $logPath = '/tmp'
}
else{
    $logPath = 'C:\Logs'
}

#Chemin complet vers le fichier log
$logFile = "$logPath\diskCheck.log"

#Vérifier si le répertoire est existant
try {
    if(-not (Test-Path -Path $logPath -ErrorAction Stop)){

    }
}
catch {
    
}
