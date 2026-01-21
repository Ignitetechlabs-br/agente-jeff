#!/bin/bash
# Script para mover cards entre colunas do Projeto X

# Carregar configuração
source "$(dirname "$0")/config.sh"

# Função para mover card
move_card() {
    local ITEM_ID=$1
    local COLUMN_ID=$2
    local COLUMN_NAME=$3

    echo -e "${COLOR_BLUE}Movendo card ${ITEM_ID} para ${COLUMN_NAME}...${COLOR_RESET}"

    RESULT=$(gh api graphql -f query="mutation {
        updateProjectV2ItemFieldValue(input: {
            projectId: \"${PROJECT_ID}\"
            itemId: \"${ITEM_ID}\"
            fieldId: \"${STATUS_FIELD_ID}\"
            value: { singleSelectOptionId: \"${COLUMN_ID}\" }
        }) {
            projectV2Item { id }
        }
    }")

    if [ $? -eq 0 ]; then
        echo -e "${COLOR_GREEN}✓ Card movido com sucesso!${COLOR_RESET}"
    else
        echo -e "${COLOR_RED}✗ Erro ao mover card${COLOR_RESET}"
        exit 1
    fi
}

# Verificar argumentos
if [ $# -lt 2 ]; then
    echo "Uso: $0 ITEM_ID COLUNA"
    echo ""
    echo "Colunas disponíveis:"
    echo "  inbox          - Mover para Inbox"
    echo "  triagem        - Mover para Triagem"
    echo "  backlog        - Mover para Backlog"
    echo "  em-execucao    - Mover para Em Execução"
    echo "  revisao        - Mover para Revisão"
    echo "  testes         - Mover para Testes"
    echo "  bloqueado      - Mover para Bloqueado"
    echo "  concluido      - Mover para Concluído"
    exit 1
fi

ITEM_ID=$1
COLUMN=$2

case $COLUMN in
    inbox)
        move_card "$ITEM_ID" "$COLUMN_INBOX" "Inbox"
        ;;
    triagem)
        move_card "$ITEM_ID" "$COLUMN_TRIAGEM" "Triagem"
        ;;
    backlog)
        move_card "$ITEM_ID" "$COLUMN_BACKLOG" "Backlog"
        ;;
    em-execucao)
        move_card "$ITEM_ID" "$COLUMN_EM_EXECUCAO" "Em Execução"
        ;;
    revisao)
        move_card "$ITEM_ID" "$COLUMN_REVISAO" "Revisão"
        ;;
    testes)
        move_card "$ITEM_ID" "$COLUMN_TESTES" "Testes"
        ;;
    bloqueado)
        move_card "$ITEM_ID" "$COLUMN_BLOQUEADO" "Bloqueado"
        ;;
    concluido)
        move_card "$ITEM_ID" "$COLUMN_CONCLUIDO" "Concluído"
        ;;
    *)
        echo -e "${COLOR_RED}Coluna inválida: $COLUMN${COLOR_RESET}"
        exit 1
        ;;
esac
