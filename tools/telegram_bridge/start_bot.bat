@echo off
chcp 65001 > nul
title Dian Catering Telegram Dev Bridge
cd /d "%~dp0"
python bot.py
pause
