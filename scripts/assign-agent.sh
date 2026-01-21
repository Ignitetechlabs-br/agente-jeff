#!/bin/bash
# Script para atribuir issues para agentes

# Carregar configuração
source "$(dirname "$0")/config.sh"

# Verificar argumentos
if [ $# -lt 2 ]; then
    echo "Uso: $0 ISSUE_NUMBER AGENT"
    echo ""
    echo "Agentes disponíveis:"
    echo "  marcus    - Analista de Requisitos"
    echo "  sara      - Frontend Developer"
    echo "  roberto   - Backend Developer"
    echo "  henrique  - Arquiteto / Code Reviewer"
    echo "  julia     - QA Engineer"
    echo "  jeff      - Scrum Master"
    exit 1
fi

ISSUE_NUMBER=$1
AGENT=$2

# Determinar label do agente
case $AGENT in
    marcus)
        LABEL=$LABEL_MARCUS
        AGENT_NAME="Marcus (Analista)"
        REPO=$REPO_MARCUS
        ;;
    sara)
        LABEL=$LABEL_SARA
        AGENT_NAME="Sara (Frontend)"
        REPO=$REPO_SARA
        ;;
    roberto)
        LABEL=$LABEL_ROBERTO
        AGENT_NAME="Roberto (Backend)"
        REPO=$REPO_ROBERTO
        ;;
    henrique)
        LABEL=$LABEL_HENRIQUE
        AGENT_NAME="Henrique (Arquiteto)"
        REPO=$REPO_HENRIQUE
        ;;
    julia)
        LABEL=$LABEL_JULIA
        AGENT_NAME="Julia (QA)"
        REPO=$REPO_JULIA
        ;;
    jeff)
        LABEL=$LABEL_JEFF
        AGENT_NAME="Jeff (Scrum Master)"
        REPO=$REPO_JEFF
        ;;
    *)
        echo -e "${COLOR_RED}Agente inválido: $AGENT${COLOR_RESET}"
        exit 1
        ;;
esac

echo -e "${COLOR_BLUE}Atribuindo issue #$ISSUE_NUMBER para $AGENT_NAME...${COLOR_RESET}"

# Atribuir label
gh issue edit "$ISSUE_NUMBER" --repo "$REPO_DOCS" --add-label "$LABEL"

if [ $? -eq 0 ]; then
    echo -e "${COLOR_GREEN}✓ Issue atribuída com sucesso!${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}Detalhes:${COLOR_RESET}"
    echo -e "  Issue: #$ISSUE_NUMBER"
    echo -e "  Agente: $AGENT_NAME"
    echo -e "  Repositório do agente: $REPO"
    echo ""
    echo -e "${COLOR_YELLOW}Próximos passos:${COLOR_RESET}"
    echo -e "  1. Notificar o agente sobre a nova tarefa"
    echo -e "  2. Verificar se há dependências"
    echo -e "  3. Confirmar que requisitos estão claros"
else
    echo -e "${COLOR_RED}✗ Erro ao atribuir issue${COLOR_RESET}"
    exit 1
fi
