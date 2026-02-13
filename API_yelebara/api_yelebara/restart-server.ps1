# Script de redémarrage du serveur PHP
# Résout les problèmes de connexion timeout

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   DIAGNOSTIC ET REDÉMARRAGE DU SERVEUR PHP                    " -ForegroundColor Cyan  
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier les processus PHP
Write-Host "📋 Processus PHP en cours:" -ForegroundColor Yellow
$phpProcesses = Get-Process | Where-Object {$_.ProcessName -like "*php*"} | Select-Object Id, ProcessName, StartTime, CPU
$phpProcesses | Format-Table -AutoSize

# 2. Tester la base de données
Write-Host "`n🗄️  Test de la base de données SQLite:" -ForegroundColor Yellow
try {
    $result = sqlite3 "database\database.sqlite" "SELECT COUNT(*) FROM users;"
    Write-Host "  ✅ Base de données accessible - $result utilisateurs" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erreur d'accès à la base de données!" -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor Red
}

# 3. Vérifier les fichiers de verrou
Write-Host "`n🔒 Fichiers de verrou SQLite:" -ForegroundColor Yellow
$shmExists = Test-Path "database\database.sqlite-shm"
$walExists = Test-Path "database\database.sqlite-wal"

if ($shmExists -or $walExists) {
    Write-Host "  ⚠️  Fichiers de verrou détectés:" -ForegroundColor Yellow
    if ($shmExists) { Write-Host "    - database.sqlite-shm existe" }
    if ($walExists) { Write-Host "    - database.sqlite-wal existe" }
    Write-Host "  💡 Ces fichiers seront supprimés après arrêt du serveur" -ForegroundColor Cyan
} else {
    Write-Host "  ✅ Aucun fichier de verrou actif" -ForegroundColor Green
}

# 4. Instructions de redémarrage
Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   INSTRUCTIONS DE REDÉMARRAGE                                  " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Dans le terminal où tourne 'php artisan serve':" -ForegroundColor White
Write-Host "   Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Attendez quelques secondes" -ForegroundColor White
Write-Host ""
Write-Host "3. Relancez le serveur avec:" -ForegroundColor White
Write-Host "   php artisan serve --host=0.0.0.0 --port=8000" -ForegroundColor Green
Write-Host ""
Write-Host "4. Testez la connexion:" -ForegroundColor White
Write-Host "   php artisan tinker" -ForegroundColor Yellow
Write-Host "   >>> \App\Models\User::count()" -ForegroundColor Yellow
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "💡 Le problème actuel est un timeout de connexion" -ForegroundColor Yellow
Write-Host "   Cela indique que le serveur PHP ne répond plus." -ForegroundColor Yellow
Write-Host "   Un simple redémarrage devrait résoudre le problème." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
