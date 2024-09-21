#!/bin/bash

# Definição de cores
GREEN='\033[0;32m'  # Cor verde
RED='\033[0;31m'    # Cor vermelha
YELLOW='\033[1;33m' # Cor amarela
NC='\033[0m'        # Sem cor (para resetar)

echo -e "${YELLOW}Acessando Diretório...${NC}"
cd Site-Institucional
echo -e "${GREEN}Diretório Acessado...${NC}"

echo -e "${YELLOW}Atualizando Aplicação...${NC}"
git pull
echo -e "${GREEN}Aplicação Atualizada...${NC}"