#!/bin/bash

# Definição de cores
GREEN='\033[0;32m'  # Cor verde
RED='\033[0;31m'    # Cor vermelha
YELLOW='\033[1;33m' # Cor amarela
NC='\033[0m'        # Sem cor (para resetar)

echo -e "${YELLOW}Instalando Aplicação...${NC}"
git clone https://github.com/TechGuard-Solutions/Site-Institucional.git
echo -e "${GREEN}Aplicação Instalada...${NC}"

echo -e "${YELLOW}Instalando Ferramentas...${NC}"
cd Site-Institucional/ShellScripts
bash VerificacaoInstalacaoSJN.sh
echo -e "${GREEN}Ferramentas Instaladas...${NC}"