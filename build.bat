@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ================================
echo LENDO CONFIGURACOES
echo ================================

for /f "tokens=1,2 delims==" %%a in (config.properties) do (
    set "%%a=%%b"
)

echo React path: %react.project.path%
echo Java path: %java.project.path%

REM ================================
REM BUILD DO REACT
REM ================================
echo.
echo ================================
echo BUILDANDO REACT
echo ================================

cd /d "%react.project.path%" || goto erro

call npm install || goto erro
call %react.build.command% || goto erro

REM ================================
REM PREPARANDO PASTA STATIC
REM ================================
echo.
echo ================================
echo PREPARANDO STATIC
echo ================================

set "STATIC_PATH=%java.project.path%\src\main\resources\static"

IF EXIST "%STATIC_PATH%" (
    echo Removendo pasta static antiga...
    rmdir /s /q "%STATIC_PATH%" || goto erro
)

echo Criando nova pasta static...
mkdir "%STATIC_PATH%" || goto erro

REM ================================
REM COPIANDO ARQUIVOS
REM ================================
echo.
echo ================================
echo COPIANDO BUILD DO REACT
echo ================================

xcopy "%react.project.path%\%react.dist.folder%\*" "%STATIC_PATH%\" /E /H /C /I /Y || goto erro

REM ================================
REM BUILD DO JAVA
REM ================================
echo.
echo ================================
echo BUILDANDO JAVA (JAR)
echo ================================

cd /d "%java.project.path%" || goto erro

REM ================================
REM CONFIGURAR JAVA (PORTATIL OU GLOBAL)
REM ================================
echo Verificando Java...

REM TENTA JAVA PORTATIL
IF EXIST "%~dp0tools\java\jdk-17\bin\java.exe" (
    echo Usando Java portatil...
    set "JAVA_HOME=%~dp0tools\java\jdk-17"
    set "PATH=%JAVA_HOME%\bin;%PATH%"
    goto java_ok
)

REM USA JAVA DA MAQUINA
IF NOT DEFINED JAVA_HOME (
    echo.
    echo JAVA_HOME nao esta configurado!
    echo Instale o Java 17 ou use java portatil em tools\java\jdk-17
    goto erro
)

IF NOT EXIST "%JAVA_HOME%\bin\java.exe" (
    echo.
    echo JAVA_HOME invalido!
    echo Nao foi encontrado java.exe em:
    echo %JAVA_HOME%\bin
    goto erro
)

echo Usando Java da maquina: %JAVA_HOME%

:java_ok

REM ================================
REM MAVEN PORTATIL
REM ================================
set "MAVEN_CMD=%~dp0tools\maven\bin\mvn.cmd"

IF EXIST "%MAVEN_CMD%" (
    echo Usando Maven portatil...
    call "%MAVEN_CMD%" clean package || goto erro
) ELSE (
    echo.
    echo Maven portatil nao encontrado!
    echo Esperado em: tools\maven\bin\mvn.cmd
    goto erro
)

echo.
echo ================================
echo BUILD FINALIZADO COM SUCESSO
echo ================================

pause
exit /b 0

REM ================================
REM TRATAMENTO DE ERRO
REM ================================
:erro
echo.
echo ================================
echo ERRO NO PROCESSO
echo ================================
pause
exit /b 1