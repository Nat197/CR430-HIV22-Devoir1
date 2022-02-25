<#
    Titre: Module powershell de vérification de l'état des disques dur
    Auteur : Nathan Bourgoin et Gabriel Bellemare
    Date : 23/02/2022
    Version : 1.0
    Système d'exploitation: Windows ou Linux
    Description : Ce module powershell va permettre de vérifier certaines caractéristiques
    du disque dur et pourra notifier l'utilisateur selon certaines règles établies. Le script
    va vérifier par exemple l'espace disponible et envoyer une notification si l'espace est
    moins de 20%. Les vérification seront enregistrées dans un fichier log. L'utilisateur va 
    spécifier quel disque vérifier ainsi que la limite minimale d'espace.
#>


#Déclaration d'un parametre obligatoire qui est la lettre du disque
param (
    [Parameter(Mandatory = $true)]  #Critères du paramètre
    [string]  #Type du paramètre
    $Drive   #Nom du paramètre
)

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
Add-Content -Path $logFile -Value "[$date] [INFO] Execution en cours de $PSCommandPath"

#Vérifier que PoshGram est installé sinon on log l'erreur dans notre fichier log
if (-not (Get-Module -Name PoshGram -ListAvailable)) {
    $date = Get-Date
    Add-Content -Path $logFile -Value "[$date] [ERREUR] PoshGram n'est pas installé."
    throw
}
else {
    $date = Get-Date
    Add-Content -Path $logFile -Value "[$date] [INFO] PoshGram est installé."
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

            Add-Content -Path $logFile -Value "[INFO] Espace libre : $espaceLibre%"
        }
        else {
            Add-Content -Path $logFile -Value "[ERREUR] $Drive n'est pas existant"
            throw
        }
    }
    #Systeme Windows
    else {
        #Sélectionner le disque dont la lettre correspond a celle spécifié par l'utilisateur
        $volume = Get-Volume -ErrorAction Stop | Where-Object{$_.DriveLetter -eq $Drive} 

        if ($volume) {
            $total = $volume.Size #Sur windows la propriété size calcule notre espace directement
            $espaceLibre = [int](($volume.SizeRemaining / $total) * 100)  #Division espace libre avec espace total converti en pourcentage
            $date = Get-Date
            Add-Content -Path $logFile -Value "[$date] [INFO] Espace libre : $espaceLibre%"
        }
        else {
            $date = Get-Date
            Add-Content -Path $logFile -Value "[$date] [ERREUR] $Drive n'est pas existant"
            throw
        }
     }

}
catch {
    #Ajouter l'erreur dans les logs
    $date = Get-Date
    Add-Content -Path $logFile -Value "[$date] [ERREUR] Impossible d'obtenir les informations"
    #Erreur originale
    Add-Content -Path $logFile -Value $_
    throw
    
}

#Envoyer notre messsage Telegram si l'espace du disque est bas

#Si l'espace libre du disque est plus petite que 20% on envoit un message
if($espaceLibre -le 20){
    try {
        #On importe le module Poshgram qui va permettre d'envoyer les messages a un chat Telegram
        $date = Get-Date
        Import-Module -Name PoshGram -ErrorAction Stop  
        Add-Content -Path $logFile -Value "[$date] [INFO] Module PoshGram a été importé avec succès"
    }
    catch {
        $date = Get-Date
        Add-Content -Path $logFile -Value "[$date] [ERREUR] Module PoshGram n'a pas pu être importé"
        #Ajout duFichier spécifique de l'erreur
        Add-Content -Path $logFile -Value $_
        throw
    }
    $date = Get-Date
    Add-Content -Path $logFile -Value "[$date] [INFO] Envoi de la notification telegram"
    Add-Content -Path $logFile -Value "[$date] [ESPACE BAS] Le disque $Drive est à $espaceLibre%"

    #Parametres necessaires à l'envoi d'un telegram text message
	$message = @{
		BotToken = "5265838193:AAHyjN5YwfwDEiX8zCnXM4anZgu4pxj9qag" #obtenu lors de la creation du bot dans telegram (cr430_bot)
		ChatID = "-1001663472259" #ID du groupe telegram créé
		Message = "[ESPACE BAS] Le disque $Drive est à $espaceLibre%"  #Message de notre notification
		ErrorAction = 'Stop'
	}
    
    #Envoie du message contenant la notification dans le channel telegram spécifié
    #C'est le bot créé (cr430_bot) qui envoit ce message
	try {
        $date = Get-Date
		Send-TelegramTextMessage @message
		Add-Content -Path $logFile -Value "[$date]  [INFO] Message envoyé avec succès"
	}
	catch {
        $date = Get-Date
		Add-Content -Path $logFile -Value "[$date] [ERREUR] Une erreur est survenue lors de l'envoi du message"
		Add-Content -Path $logFile -Value $_
        throw
	}

    
}