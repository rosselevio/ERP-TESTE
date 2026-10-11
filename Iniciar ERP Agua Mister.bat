@echo off
setlocal
title Iniciar ERP Agua Mister
color 0B
cd /d "%~dp0"

echo ==========================================================
echo                 ERP AGUA MISTER
echo    Iniciando backend + abrindo o sistema no navegador
echo ==========================================================
echo.

where node >nul 2>&1
if errorlevel 1 (
  echo [ERRO] Node.js nao encontrado.
  echo Baixe a versao LTS em https://nodejs.org e instale.
  echo.
  pause
  exit /b 1
)

if not exist "backend\node_modules" (
  echo Instalando dependencias do backend ^(primeira execucao^)...
  pushd backend
  call npm install
  if errorlevel 1 (
    echo [ERRO] Falha ao instalar dependencias.
    popd
    pause
    exit /b 1
  )
  popd
  echo.
)

echo Abrindo o backend em uma nova janela...
start "ERP Agua Mister - Backend" cmd /k "cd /d "%~dp0backend" && node server.js"

echo Aguardando o servidor responder...
set TENTATIVA=0
:AGUARDA
set /a TENTATIVA+=1
timeout /t 1 /nobreak >nul
node -e "require('http').get('http://127.0.0.1:3000/api/status',function(r){process.exit(r.statusCode<500?0:1)}).on('error',function(){process.exit(1)})" >nul 2>&1
if not errorlevel 1 goto PRONTO
if %TENTATIVA% GEQ 30 goto TIMEOUT
goto AGUARDA

:TIMEOUT
echo [AVISO] O backend demorou para responder.
echo Confira a janela "ERP Agua Mister - Backend" para ver o erro.
echo O sistema sera aberto mesmo assim (modo offline).
goto ABRIR

:PRONTO
echo Backend no ar em http://localhost:3000
goto ABRIR

:ABRIR
echo Abrindo o ERP no navegador...
start "" "%~dp0erp_aguamister.html"
echo.
echo Pronto. Deixe a janela do backend aberta enquanto usar o sistema.
timeout /t 4 /nobreak >nul
exit /b 0
