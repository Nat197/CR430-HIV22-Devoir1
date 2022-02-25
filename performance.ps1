<#
    Titre: Module powershell de vérification des performances de l'ordinateur
    Auteur : Nathan Bourgoin et Gabriel Bellemare
    Date : 25/02/2022
    Version : 1.0
    Système d'exploitation: Windows seulement
    Description : Ce module powershell va permettre de vérifier l'utilisation des ressources de l'ordinateur.
    Le script permet d'évaluer la consommation en pourcentage du processeur, de la mémoire ram ainsi que
    le trafic réseau entrant et sortant. L'utilisateur peut spécifier les limites qu'il désire. Des notifications
    seront ensuite envoyées si la consommation est plus grande que la limite spécifié. Les vérification
    seront enregistrées dans un fichier log. 
#>

#Déclaration de parametres obligatoires par l'utilisateur pour définir les limites d'utilisation
param (
    [Parameter(Mandatory = $true)]  #Critères du paramètre
    [string]  #Type du paramètre
    $Max_Memory, #Nom du paramètre
    [Parameter(Mandatory = $true)] 
    [string]  
    $Max_CPU,
    [Parameter(Mandatory = $true)] 
    [string]  
    $Max_BytesReceived,
    [Parameter(Mandatory = $true)] 
    [string]  
    $Max_BytesSent
)
#Répertoire des logs
$logPath = 'C:\Logs'

#Chemin complet vers le fichier log
$logFile = "$logPath\diskCheck.log"

#Vérifier si le répertoire est existant
try {
    #Répertoire n'est pas trouvé
    if (-not (Test-Path -Path $logPath -ErrorAction Stop)) {
        $date = Get-Date
        Add-Content -Path $logFile -Value "[$date] [INFO] Le repertoire de sorti n'existe pas. Un repertoire va etre creer."
        New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null  #Out-Null permet de ne pas afficher plein de lignes dans la console
        New-Item -ItemType File -Path $logFile | Out-Null
        Add-Content -Path $logFile -Value "[$date] [INFO] Un repertoire de sorti a ete creer"
    }
}
#Attraper les erreurs pour ne pas faire crash
catch {
    throw
}

$date = Get-Date
#Commentaire de début de script pour dire d'ou la commande a été exécuté dans les logs

Add-Content -Path $logFile -Value "[$date] [INFO] Execution en cours de $PSCommandPath"

#Vérifier que PoshGram est installé sinon on log l'erreur dans notre fichier log
if (-not (Get-Module -Name PoshGram -ListAvailable)) {
    Add-Content -Path $logFile -Value "[$date] [ERREUR] PoshGram n'est pas installé."
    throw
}
else {
    Add-Content -Path $logFile -Value "[$date] [INFO] PoshGram est installé."
}

try {
    #Déclaration des valeurs des performances à analyser

    #Pourcentage de la mémoire RAM utilisé
    $CompObject = Get-CimInstance -Class WIN32_OperatingSystem
    $Memory_load = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory) * 100) / $CompObject.TotalVisibleMemorySize)

    #Pourcentage d'utilisation du processeur
    $Processor = Get-CimInstance Win32_Processor 
    $Processor_load = $Processor.LoadPercentage

    #Utilisation du réseau / Quantité D'envoi et de réception
    $CimInstance = Get-CimInstance -class Win32_PerfFormattedData_Tcpip_NetworkInterface  
    $BytesReceived = $CimInstance.BytesReceivedPerSec
    $BytesSent = $CimInstance.BytesSentPerSec
}
catch {
    throw
}
#On importe le module Poshgram pour envoyer les notifications
try {
    #On importe le module Poshgram qui va permettre d'envoyer les messages a un chat Telegram
    Import-Module -Name PoshGram -ErrorAction Stop  
    Add-Content -Path $logFile -Value "[INFO] Module PoshGram a été importé avec succès"

    #Vérification de l'utilisation selon les limites définies par l'utilisateur
    if ($Memory_load -ge $Max_Memory) {
        $date = Get-Date
        Add-Content -Path $logFile -Value "[$date] [ALERTE] La consommation de RAM est à $Memory_load%"
        $alerte = "[RAM élevée] La consommation de RAM est à $Memory_load%"

        Add-Content -Path $logFile -Value "[$date] [INFO] Envoi de la notification telegram"

        #Parametres necessaires à l'envoi d'un telegram text message
        $message = @{
            BotToken    = "XXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #obtenu lors de la creation du bot dans telegram (cr430_bot)
            ChatID      = "-XXXXXXXXXXXX" #ID du groupe telegram créé
            Message     = $alerte  #Message de notre notification
            ErrorAction = 'Stop'
        }
    }
    if ($Processor_load -ge $Max_CPU) {
        $date = Get-Date
        Add-Content -Path $logFile -Value "[$date] [ALERTE]  La consommation du CPU est à $Memory_load%"
        $alerte = "[CPU élevée] La consommation du CPU est à $Memory_load%"

        Add-Content -Path $logFile -Value "[$date] [INFO] Envoi de la notification telegram"

        #Parametres necessaires à l'envoi d'un telegram text message
        $message = @{
            BotToken    = "XXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #obtenu lors de la creation du bot dans telegram (cr430_bot)
            ChatID      = "-XXXXXXXXXXXX" #ID du groupe telegram créé
            Message     = $alerte  #Message de notre notification
            ErrorAction = 'Stop'
        }
    }
    if ($BytesReceived -ge $Max_BytesReceived) {
        $date = Get-Date
        Add-Content -Path $logFile -Value "[$date] [ALERTE]  Le nombre de paquet reçues est à $BytesReceived bytes"
        $alerte = "[Traffic réseau élevé]  Le nombre de paquet reçues est à $BytesReceived bytes"

        Add-Content -Path $logFile -Value "[$date] [INFO] Envoi de la notification telegram"

        #Parametres necessaires à l'envoi d'un telegram text message
        $message = @{
            BotToken    = "XXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #obtenu lors de la creation du bot dans telegram (cr430_bot)
            ChatID      = "-XXXXXXXXXXXX" #ID du groupe telegram créé
            Message     = $alerte  #Message de notre notification
            ErrorAction = 'Stop'
        }
    }
    if ($BytesSent -ge $Max_BytesSent) {
        $date = Get-Date
        Add-Content -Path $logFile -Value "[$date] [ALERTE]  Le nombre de paquet envoyé est à $BytesSent bytes"
        $alerte = "[Traffic réseau élevé]  Le nombre de paquet envoyé est à $BytesSent bytes"

        Add-Content -Path $logFile -Value "[$date] [INFO] Envoi de la notification telegram"

        #Parametres necessaires à l'envoi d'un telegram text message
        $message = @{
            BotToken    = "XXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #obtenu lors de la creation du bot dans telegram (cr430_bot)
            ChatID      = "-XXXXXXXXXXXX" #ID du groupe telegram créé
            Message     = $alerte  #Message de notre notification
            ErrorAction = 'Stop'
        }
    }
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

#Parametres necessaires à l'envoi d'un telegram text message
$message = @{
    BotToken    = "XXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #obtenu lors de la creation du bot dans telegram (cr430_bot)
    ChatID      = "-XXXXXXXXXXXX" #ID du groupe telegram créé
    Message     = $alerte  #Message de notre notification
    ErrorAction = 'Stop'
}
#Envoie du message contenant la notification dans le channel telegram spécifié
#C'est le bot créé (cr430_bot) qui envoit ce message
try {
    Send-TelegramTextMessage @message
    Add-Content -Path $logFile -Value "[INFO] Message envoyé avec succès"
}
catch {
    Add-Content -Path $logFile -Value "[ERREUR] Une erreur est survenue lors de l'envoi du message"
    Add-Content -Path $logFile -Value $_
    throw
}






