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
if ($PSVersionTable.Platform -eq 'Unix') {
    $logPath = '/tmp'
}
else {
    $logPath = 'C:\Logs'
}

#Chemin complet vers le fichier log
$logFile = "$logPath\diskCheck.log"

#Vérifier si le répertoire est existant
try {
    #Répertoire n'est pas trouvé
    if (-not (Test-Path -Path $logPath -ErrorAction Stop)) {
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
if (-not (Get-Module -Name PoshGram -ListAvailable)) {
    Add-Content -Path $logFile -Value "[ERREUR] PoshGram n'est pas installé."
    throw
}
else {
    Add-Content -Path $logFile -Value "[INFO] PoshGram est installé."
}

#Collecter les informations du disque dur

#Si une erreur survient le -ErrorAction Stop va attraper cette erreur
try {
    #Systeme Linux
    if ($PSVersionTable.Platform -eq 'Unix') {
        #les commandes sont différentes sur linux donc on doit avoir deux sections de commandes selon le OS
        #used
        #free
        $volume = Get-PSDrive -Name $Drive -ErrorAction Stop
        #Vérifier si le drive existe
        if ($volume) {
            $total = $volume.Used + $volume.Free  #déterminer l'espace total de notre disque
            $espaceLibre = [int](($volume.Free / $total) * 100)  #Division espace libre avec espace total converti en pourcentage

            Add-Content -Path $logFile -Value "[INFO] Espace libre : $espaceLibre"
        }
        else {
            Add-Content -Path $logFile -Value "[ERREUR] $Drive n'est pas existant"
            throw
        }
    }
    #Systeme Windows
    else {
        #Sélectionner le disque dont la lettre correspond a celle spécifié par l'utilisateur
        $volume = Get-Volume -ErrorAction Stop | Where-Object($_.DriveLetter -eq $Drive) 

        if ($volume) {
            $total = $volume.Size #Sur windows la propriété size calcule notre espace directement
            $espaceLibre = [int](($volume.Free / $total) * 100)  #Division espace libre avec espace total converti en pourcentage

            Add-Content -Path $logFile -Value "[INFO] Espace libre : $espaceLibre"
        }
        else {
            Add-Content -Path $logFile -Value "[ERREUR] $Drive n'est pas existant"
            throw
        }
    }

}
catch {
    #Ajouter l'erreur dans les logs
    Add-Content -Path $logFile -Value "[ERREUR] Impossible d'obtenir les informations"
    #Erreur originale
    Add-Content -Path $logFile -Value $_
    throw
    
}

#Systeme Linux
if ($PSVersionTable.Platform -eq 'Unix') {
    #les commandes sont différentes sur linux donc on doit avoir deux sections de commandes selon le OS
    #used
    #free
    $volume = Get-PSDrive -Name $Drive
    #Vérifier si le drive existe
    if ($volume) {
        $total = $volume.Used + $volume.Free  #déterminer l'espace total de notre disque
        $espaceLibre = [int](($volume.Free / $total) * 100)  #Division espace libre avec espace total converti en pourcentage

        Add-Content -Path $logFile -Value "[INFO] Espace libre : $espaceLibre"
    }
    else {
        Add-Content -Path $logFile -Value "[ERREUR] $Drive n'est pas existant"
        throw
    }
}
#Systeme Windows
else {
    #Sélectionner le disque dont la lettre correspond a celle spécifié par l'utilisateur
    $volume = Get-Volume-ErrorAction Stop | Where-Object($_.DriveLetter -eq $Drive) 

    if ($volume) {
        $total = $volume.Size #Sur windows la propriété size calcule notre espace directement
        $espaceLibre = [int](($volume.Free / $total) * 100)  #Division espace libre avec espace total converti en pourcentage

        Add-Content -Path $logFile -Value "[INFO] Espace libre : $espaceLibre"
    }
    else {
        Add-Content -Path $logFile -Value "[ERREUR] $Drive n'est pas existant"
        throw
    }
}


#Envoyer notre messsage Telegram si l'espace du disque est bas

if($espaceLibre -le 20){
    try {
        Import-Module - Name PoshGram -ErrorAction Stop
        Add-Content -Path $logFile -Value "[INFO] Module PoshGram a été importé avec succès"
    }
    catch {
        Add-Content -Path $logFile -Value "[ERREUR] Module PoshGram n'a pas pu être importé"
        #Ajout duFichier spécifique de l'erreur
        Add-Content -Path $logFile -Value $_
    }

    Add-Content -Path $logFile -Value "[INFO] Envoi de la notification telegram"

    $botToken = "5265838193:AAHyjN5YwfwDEiX8zCnXM4anZgu4pxj9qag"
    $chat = "-5288861772"
    Send-TelegramTextMessage -BotToken $botToken -ChatID $chat -Message "L'espace disponible de votre disque est bas"
}