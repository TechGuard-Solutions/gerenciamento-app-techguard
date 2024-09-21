#!/bin/bash

# Definição de cores
GREEN='\033[0;32m'  # Cor verde
RED='\033[0;31m'    # Cor vermelha
YELLOW='\033[1;33m' # Cor amarela
NC='\033[0m'        # Sem cor (para resetar)

echo -e "${YELLOW}Acessando Diretório...${NC}"
cd ..
cd AplicacaoTechGuard
cd site-institucional
echo -e "${GREEN}Diretório Acessado...${NC}"
echo -e "${YELLOW}Iniciando Aplicação...${NC}"
bash iniciar.sh