<# : parte batch
@echo off
fltmc >nul 2>&1
if errorlevel 1 if not "%~1"=="elevado" (
  echo Pidiendo permisos de administrador...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList 'elevado' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ([IO.File]::ReadAllText('%~f0'))"
exit /b
#>

# AcelerarPC: limpieza y ajustes seguros para Windows 10/11.
# No toca el registro ni desactiva servicios: todo lo que hace es reversible
# o solo borra archivos temporales.

$ErrorActionPreference = 'SilentlyContinue'
$Host.UI.RawUI.WindowTitle = 'AcelerarPC'
$Drive = $env:SystemDrive

function Get-FreeGB { (New-Object IO.DriveInfo $Drive).AvailableFreeSpace / 1GB }
function Titulo($t) { Write-Host ''; Write-Host "== $t ==" -ForegroundColor Cyan }
function Info($t)   { Write-Host "  $t" }
function Ok($t)     { Write-Host "  [OK] $t" -ForegroundColor Green }
function Aviso($t)  { Write-Host "  [!] $t" -ForegroundColor Yellow }
function Confirmar($pregunta) { "$(Read-Host "  $pregunta (s/n)")" -match '^\s*[sS]' }
function Pausa { Write-Host ''; Read-Host '  Pulsa Enter para volver al menú' | Out-Null }

function Vaciar-Carpeta($ruta) {
  if (Test-Path -LiteralPath $ruta) {
    Get-ChildItem -LiteralPath $ruta -Force | Remove-Item -Recurse -Force
  }
}

function Limpiar-Temporales {
  Titulo 'Limpieza rápida'
  $antes = Get-FreeGB
  Info 'Temporales del usuario...'
  Vaciar-Carpeta $env:TEMP
  Info 'Temporales de Windows...'
  Vaciar-Carpeta "$env:SystemRoot\Temp"
  Info 'Caché de descargas de Windows Update...'
  $svcs = Get-Service wuauserv, bits | Where-Object Status -eq 'Running'
  $svcs | Stop-Service -Force
  Vaciar-Carpeta "$env:SystemRoot\SoftwareDistribution\Download"
  $svcs | Start-Service
  Info 'Caché de Optimización de distribución...'
  if (Get-Command Delete-DeliveryOptimizationCache) { Delete-DeliveryOptimizationCache -Force }
  Info 'Informes de errores antiguos...'
  Vaciar-Carpeta "$env:ProgramData\Microsoft\Windows\WER\ReportArchive"
  Vaciar-Carpeta "$env:ProgramData\Microsoft\Windows\WER\ReportQueue"
  $despues = Get-FreeGB
  Ok ('Liberados {0:N2} GB. Libre ahora en {1}: {2:N1} GB' -f [math]::Max(0, $despues - $antes), $Drive, $despues)
  Info '(Algunos archivos en uso no se pueden borrar; es normal.)'
}

function Vaciar-Papelera {
  Titulo 'Vaciar papelera'
  if (Confirmar 'Se borrará para siempre lo que hay en la papelera. ¿Seguir?') {
    $antes = Get-FreeGB
    Clear-RecycleBin -Force
    Ok ('Papelera vacía. Liberados {0:N2} GB' -f [math]::Max(0, (Get-FreeGB) - $antes))
  } else { Info 'Cancelado.' }
}

function Diagnostico {
  Titulo 'Diagnóstico: qué está frenando el PC'
  $os  = Get-CimInstance Win32_OperatingSystem
  $cpu = @(Get-CimInstance Win32_Processor)
  $ramTotal = $os.TotalVisibleMemorySize / 1MB
  $ramUsada = $ramTotal - $os.FreePhysicalMemory / 1MB
  $ramPct   = 100 * $ramUsada / $ramTotal
  $uptime   = (Get-Date) - $os.LastBootUpTime
  $cpuPct   = ($cpu | Measure-Object LoadPercentage -Average).Average
  $disco    = New-Object IO.DriveInfo $Drive
  $discoPct = 100 * $disco.AvailableFreeSpace / $disco.TotalSize
  $numDisco = (Get-Partition -DriveLetter $Drive.TrimEnd(':')).DiskNumber
  $tipo     = (Get-PhysicalDisk | Where-Object DeviceId -eq "$numDisco").MediaType
  if ("$tipo" -notin 'SSD', 'HDD', 'SCM') { $tipo = 'desconocido' }
  $inicio   = @(Get-CimInstance Win32_StartupCommand).Count

  Info ('Procesador : {0}' -f $cpu[0].Name.Trim())
  Info ('Uso de CPU : {0:N0} %' -f $cpuPct)
  Info ('RAM        : {0:N1} de {1:N1} GB en uso ({2:N0} %)' -f $ramUsada, $ramTotal, $ramPct)
  Info ('Disco {0}   : {1:N1} GB libres de {2:N1} GB ({3:N0} %), tipo: {4}' -f $Drive, ($disco.AvailableFreeSpace / 1GB), ($disco.TotalSize / 1GB), $discoPct, $tipo)
  Info ('Encendido  : {0} días y {1} horas sin reiniciar' -f $uptime.Days, $uptime.Hours)
  Info ('Programas al inicio: {0}' -f $inicio)

  Write-Host ''
  Info 'Lo que más RAM usa:'
  Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 8 | ForEach-Object {
    Info ('   {0,-32} {1,7:N0} MB' -f $_.ProcessName, ($_.WorkingSet64 / 1MB))
  }

  Write-Host ''
  Info 'Lo que más CPU usa ahora:'
  $nucleos = [Environment]::ProcessorCount
  Get-CimInstance Win32_PerfFormattedData_PerfProc_Process | Out-Null
  Start-Sleep -Seconds 1
  Get-CimInstance Win32_PerfFormattedData_PerfProc_Process |
    Where-Object { $_.Name -notin '_Total', 'Idle' } |
    Sort-Object PercentProcessorTime -Descending | Select-Object -First 5 | ForEach-Object {
      Info ('   {0,-32} {1,7:N0} %' -f $_.Name, ($_.PercentProcessorTime / $nucleos))
    }

  Write-Host ''
  Info 'Recomendaciones:'
  $hay = $false
  if ($uptime.Days -ge 3) {
    Aviso 'Hace días que no reinicias. Usa "Reiniciar" (no "Apagar": con el inicio rápido, apagar no limpia la memoria).'; $hay = $true
  }
  if ($ramPct -ge 85) {
    Aviso 'La RAM está casi llena. Cierra programas o pestañas del navegador (mira la lista de arriba).'; $hay = $true
  }
  if ($ramTotal -lt 7.5) {
    Aviso ('Solo tienes {0:N0} GB de RAM. Para Windows 10/11 lo cómodo son 8 GB o más.' -f $ramTotal); $hay = $true
  }
  if ($discoPct -lt 15) {
    Aviso "El disco $Drive está casi lleno. Usa las opciones 1 y 2 y borra lo que no uses."; $hay = $true
  }
  if ($tipo -eq 'HDD') {
    Aviso 'Windows está en un disco duro mecánico (HDD). Es la causa nº1 de lentitud: pasar a un SSD es la mejora más grande que puedes hacer.'; $hay = $true
  }
  if ($inicio -gt 8) {
    Aviso 'Muchos programas arrancan con Windows. Usa la opción 4 para quitar los que no necesites.'; $hay = $true
  }
  $vm = Get-Process vmmem, vmmemWSA, vmmemWSL
  if ($vm) {
    Aviso ('WSA/WSL está usando {0:N1} GB de RAM. Apágalo con la opción 9 cuando no lo uses.' -f (($vm | Measure-Object WorkingSet64 -Sum).Sum / 1GB)); $hay = $true
  }
  if (-not $hay) { Ok 'No se ve nada grave. Si sigue lento, prueba las opciones 7 y 8.' }
}

function Programas-Inicio {
  Titulo 'Programas que arrancan con Windows'
  $items = @(Get-CimInstance Win32_StartupCommand | Sort-Object Name)
  $items | ForEach-Object { Info ('- {0}' -f $_.Name) }
  Info ('Total: {0} (puede incluir alguno ya desactivado)' -f $items.Count)
  Write-Host ''
  Aviso 'Se abrirá Configuración > Aplicaciones de arranque. Desactiva lo que no necesites al encender.'
  Info  'Deja activados antivirus, drivers de audio/táctil y lo que uses siempre.'
  Start-Process 'ms-settings:startupapps'
}

function Plan-Energia {
  Titulo 'Plan de energía'
  $alto = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
  $equilibrado = '381b4222-f694-41f0-9685-ff5bb260df2e'
  Info ('Actual: {0}' -f (powercfg /getactivescheme))
  Info '1) Alto rendimiento (más rápido, en portátil gasta más batería)'
  Info '2) Equilibrado (el de fábrica)'
  switch ("$(Read-Host '  Elige 1 o 2')".Trim()) {
    '1' {
      powercfg /setactive $alto 2>$null
      if ($LASTEXITCODE -ne 0) {
        $salida = powercfg /duplicatescheme $alto 2>$null
        $nuevo = [regex]::Match("$salida", '[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}').Value
        if ($nuevo) { powercfg /setactive $nuevo 2>$null }
      }
      if ($LASTEXITCODE -eq 0) { Ok 'Alto rendimiento activado.' }
      else {
        Aviso 'Este equipo no permite ese plan. Se abrirá Configuración: en "Modo de energía" elige "Máximo rendimiento".'
        Start-Process 'ms-settings:powersleep'
      }
    }
    '2' {
      powercfg /setactive $equilibrado 2>$null
      Ok 'Plan equilibrado activado.'
    }
    default { Info 'Sin cambios.' }
  }
}

function Efectos-Visuales {
  Titulo 'Efectos visuales'
  Info 'Se abrirá "Opciones de rendimiento". En la pestaña Efectos visuales:'
  Info '  - Elige "Ajustar para obtener el mejor rendimiento"'
  Info '  - (Opcional) Vuelve a marcar "Suavizar bordes para las fuentes de pantalla" para que el texto se vea bien'
  Info '  - Pulsa Aceptar'
  Start-Process SystemPropertiesPerformance.exe
}

function Optimizar-Disco {
  Titulo "Optimizar disco $Drive"
  Info 'Windows elige solo: TRIM si es SSD, desfragmentar si es HDD. Puede tardar un rato.'
  Optimize-Volume -DriveLetter $Drive.TrimEnd(':') -Verbose
  Ok 'Terminado.'
}

function Reparar-Windows {
  Titulo 'Reparar Windows (DISM + SFC)'
  Aviso 'Tarda entre 10 y 40 minutos y necesita internet. No cierres la ventana.'
  if (-not (Confirmar '¿Empezar ahora?')) { Info 'Cancelado.'; return }
  Info 'Paso 1/3: reparando la imagen de Windows...'
  DISM /Online /Cleanup-Image /RestoreHealth
  Info 'Paso 2/3: comprobando archivos del sistema...'
  sfc /scannow
  Info 'Paso 3/3: limpiando componentes viejos de actualizaciones...'
  DISM /Online /Cleanup-Image /StartComponentCleanup
  Ok 'Terminado. Reinicia el PC para aplicar las reparaciones.'
}

function Apagar-WSA {
  Titulo 'Apagar WSA / WSL para liberar RAM'
  $vm = Get-Process vmmem, vmmemWSA, vmmemWSL
  if (-not $vm) { Info 'WSA y WSL no están encendidos. Nada que hacer.'; return }
  $vm | ForEach-Object { Info ('{0}: {1:N1} GB' -f $_.Name, ($_.WorkingSet64 / 1GB)) }
  Aviso 'Se cerrarán las apps de Android y las distros de Linux/Docker abiertas.'
  if (-not (Confirmar '¿Apagar?')) { Info 'Cancelado.'; return }
  $wsa = Get-AppxPackage -Name MicrosoftCorporationII.WindowsSubsystemForAndroid
  if ($wsa) {
    $cliente = Join-Path $wsa.InstallLocation 'WsaClient\WsaClient.exe'
    if (Test-Path $cliente) { & $cliente /shutdown } else { Stop-Process -Name WsaClient -Force }
  }
  if (Get-Process vmmem, vmmemWSL) { wsl --shutdown }
  Start-Sleep -Seconds 3
  if (Get-Process vmmemWSA) {
    Aviso 'WSA sigue encendido. Ábrelo en "Subsistema de Windows para Android" y pulsa "Apagar".'
  } else { Ok 'Listo, RAM liberada.' }
}

function Todo-Recomendado {
  Limpiar-Temporales
  Optimizar-Disco
  Diagnostico
}

while ($true) {
  Clear-Host
  Write-Host ''
  Write-Host '  ==========================================' -ForegroundColor Cyan
  Write-Host '                 ACELERAR  PC' -ForegroundColor Cyan
  Write-Host '  ==========================================' -ForegroundColor Cyan
  Write-Host ''
  Write-Host '   1) Limpieza rápida (temporales y cachés)'
  Write-Host '   2) Vaciar papelera'
  Write-Host '   3) Diagnóstico: qué está frenando el PC'
  Write-Host '   4) Programas que arrancan con Windows'
  Write-Host '   5) Plan de energía (alto rendimiento)'
  Write-Host '   6) Quitar animaciones y efectos visuales'
  Write-Host '   7) Optimizar disco (TRIM / desfragmentar)'
  Write-Host '   8) Reparar Windows (DISM + SFC, tarda)'
  Write-Host '   9) Apagar WSA / WSL para liberar RAM'
  Write-Host ''
  Write-Host '   T) Todo lo recomendado (1 + 7 + 3)' -ForegroundColor Green
  Write-Host '   0) Salir'
  Write-Host ''
  switch ("$(Read-Host '  Elige una opción')".Trim().ToUpper()) {
    '1' { Limpiar-Temporales; Pausa }
    '2' { Vaciar-Papelera; Pausa }
    '3' { Diagnostico; Pausa }
    '4' { Programas-Inicio; Pausa }
    '5' { Plan-Energia; Pausa }
    '6' { Efectos-Visuales; Pausa }
    '7' { Optimizar-Disco; Pausa }
    '8' { Reparar-Windows; Pausa }
    '9' { Apagar-WSA; Pausa }
    'T' { Todo-Recomendado; Pausa }
    '0' { exit }
  }
}
