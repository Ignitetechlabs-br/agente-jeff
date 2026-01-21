#!/bin/bash
# Script para gerar relatório de Sprint

# Carregar configuração
source "$(dirname "$0")/config.sh"

# Parâmetros
SPRINT_LABEL=${1:-"sprint:current"}
OUTPUT_FILE=${2:-"sprint-report-$(date '+%Y%m%d').md"}

echo -e "${COLOR_BLUE}Gerando relatório da sprint...${COLOR_RESET}"
echo ""

# Buscar issues da sprint
COMPLETED=$(gh issue list --repo "$REPO_DOCS" --label "$SPRINT_LABEL" --state closed --json number,title,closedAt,labels --limit 100)
OPEN=$(gh issue list --repo "$REPO_DOCS" --label "$SPRINT_LABEL" --state open --json number,title,labels --limit 100)

COMPLETED_COUNT=$(echo "$COMPLETED" | jq '. | length')
OPEN_COUNT=$(echo "$OPEN" | jq '. | length')
TOTAL_COUNT=$((COMPLETED_COUNT + OPEN_COUNT))

# Gerar relatório
cat > "$OUTPUT_FILE" << EOF
# Sprint Review - $(date '+%d/%m/%Y')

## 📊 Visão Geral

- **Total de Issues:** $TOTAL_COUNT
- **Completadas:** $COMPLETED_COUNT ($(awk "BEGIN {printf \"%.1f\", ($COMPLETED_COUNT/$TOTAL_COUNT)*100}")%)
- **Pendentes:** $OPEN_COUNT ($(awk "BEGIN {printf \"%.1f\", ($OPEN_COUNT/$TOTAL_COUNT)*100}")%)

## ✅ Issues Completadas

EOF

if [ "$COMPLETED_COUNT" -gt 0 ]; then
    echo "$COMPLETED" | jq -r '.[] | "- [x] #\(.number) - \(.title)"' >> "$OUTPUT_FILE"
else
    echo "Nenhuma issue completada." >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << EOF

## ⏳ Issues Pendentes

EOF

if [ "$OPEN_COUNT" -gt 0 ]; then
    echo "$OPEN" | jq -r '.[] | "- [ ] #\(.number) - \(.title)"' >> "$OUTPUT_FILE"
else
    echo "Nenhuma issue pendente." >> "$OUTPUT_FILE"
fi

# Métricas
cat >> "$OUTPUT_FILE" << EOF

## 📈 Métricas

### Velocity
- **Issues Completadas:** $COMPLETED_COUNT
- **Taxa de Conclusão:** $(awk "BEGIN {printf \"%.1f\", ($COMPLETED_COUNT/$TOTAL_COUNT)*100}")%

### Distribuição por Tipo
EOF

# Contar bugs, features, etc
BUGS=$(echo "$COMPLETED" | jq '[.[] | select(.labels[].name | test("bug"))] | length')
FEATURES=$(echo "$COMPLETED" | jq '[.[] | select(.labels[].name | test("feature|enhancement"))] | length')
DOCS=$(echo "$COMPLETED" | jq '[.[] | select(.labels[].name | test("documentation"))] | length')

cat >> "$OUTPUT_FILE" << EOF
- 🐛 Bugs corrigidos: $BUGS
- ✨ Features implementadas: $FEATURES
- 📝 Documentação: $DOCS

## 🎯 Próximos Passos

EOF

if [ "$OPEN_COUNT" -gt 0 ]; then
    cat >> "$OUTPUT_FILE" << EOF
As seguintes issues precisam ser priorizadas para a próxima sprint:

EOF
    echo "$OPEN" | jq -r '.[] | "1. Issue #\(.number) - \(.title)"' >> "$OUTPUT_FILE"
else
    cat >> "$OUTPUT_FILE" << EOF
Todas as issues da sprint foram completadas! 🎉

Sugestões:
1. Planejar próxima sprint
2. Revisar backlog
3. Atualizar roadmap
EOF
fi

cat >> "$OUTPUT_FILE" << EOF

---

*Relatório gerado automaticamente por Jeff em $(date '+%d/%m/%Y às %H:%M')*
EOF

echo -e "${COLOR_GREEN}✓ Relatório gerado: $OUTPUT_FILE${COLOR_RESET}"
echo ""
echo -e "${COLOR_CYAN}Resumo:${COLOR_RESET}"
echo -e "  Total: $TOTAL_COUNT issues"
echo -e "  Completadas: ${COLOR_GREEN}$COMPLETED_COUNT${COLOR_RESET}"
echo -e "  Pendentes: ${COLOR_YELLOW}$OPEN_COUNT${COLOR_RESET}"
echo -e "  Taxa de conclusão: $(awk "BEGIN {printf \"%.1f\", ($COMPLETED_COUNT/$TOTAL_COUNT)*100}")%"
echo ""
