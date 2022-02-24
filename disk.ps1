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
    #Répertoire n'est pas trouvé
    if(-not (Test-Path -Path $logPath -ErrorAction Stop)){
        New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null  #Out-Null permet de ne pas afficher plein de lignes dans la console
        New-Item -ItemType File -Path $logFile | Out-Null
    }
}
#Attraper les erreurs pour ne pas faire crash
catch {
    throw
}

#Commentaire de début de script pour dire d'ou la commande a été exécuté dans les logs
Add-Content -Path $logFile -Value "[INFO] Execution en cours de $PSCommandPath"

#Vérifier que PoshGram est installé sinon on log l'erreur dans notre fichier log
if(-not (Get-Module -Name PoshGram -ListAvailable)){
    Add-Content -Path $logFile -Value "[ERREUR] PoshGram n'est pas installé."
    throw
}
else{
    Add-Content -Path $logFile -Value "[INFO] PoshGram est installé."
}

#Collecter les informations du disque dur

if($PSVersionTable.Platform -eq 'Unix'){ #les commandes sont différentes sur linux donc on doit avoir deux sections de commandes selon le OS
    #used
    #free
    $volume = Get-PSDrive -Name $Drive
    #Vérifier si le drive existe
    if($volume){
        $total = $volume.Used + $volume.Free
    }else{
        Add-Content -Path $logFile -Value "[ERREUR] $Drive n'est pas existant"
    }
}
else{
    
}
