#!/bin/bash
# Script para calcular métricas do projeto

# Carregar configuração
source "$(dirname "$0")/config.sh"

DAYS=${1:-7}  # Padrão: últimos 7 dias

echo -e "${COLOR_CYAN}╔══════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_CYAN}║         MÉTRICAS - PROJETO X             ║${COLOR_RESET}"
echo -e "${COLOR_CYAN}║      Últimos $DAYS dias                      ║${COLOR_RESET}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Data de corte
SINCE_DATE=$(date -d "$DAYS days ago" '+%Y-%m-%d' 2>/dev/null || date -v-${DAYS}d '+%Y-%m-%d')

# 1. VELOCITY - Issues fechadas
echo -e "${COLOR_BLUE}📊 VELOCITY${COLOR_RESET}"
CLOSED_ISSUES=$(gh issue list --repo "$REPO_DOCS" --state closed --search "closed:>=$SINCE_DATE" --json number --limit 1000 | jq '. | length')
VELOCITY_PER_DAY=$(awk "BEGIN {printf \"%.2f\", $CLOSED_ISSUES/$DAYS}")

echo -e "  Issues fechadas: ${COLOR_GREEN}$CLOSED_ISSUES${COLOR_RESET}"
echo -e "  Velocity por dia: ${COLOR_GREEN}$VELOCITY_PER_DAY${COLOR_RESET}"
echo ""

# 2. THROUGHPUT - PRs merged
echo -e "${COLOR_BLUE}🔀 THROUGHPUT${COLOR_RESET}"
MERGED_PRS_FRONTEND=$(gh pr list --repo "$REPO_FRONTEND" --state merged --search "merged:>=$SINCE_DATE" --json number --limit 1000 | jq '. | length')
MERGED_PRS_BACKEND=$(gh pr list --repo "$REPO_BACKEND" --state merged --search "merged:>=$SINCE_DATE" --json number --limit 1000 | jq '. | length')
TOTAL_MERGED=$((MERGED_PRS_FRONTEND + MERGED_PRS_BACKEND))
THROUGHPUT_PER_DAY=$(awk "BEGIN {printf \"%.2f\", $TOTAL_MERGED/$DAYS}")

echo -e "  PRs merged (Frontend): ${COLOR_GREEN}$MERGED_PRS_FRONTEND${COLOR_RESET}"
echo -e "  PRs merged (Backend): ${COLOR_GREEN}$MERGED_PRS_BACKEND${COLOR_RESET}"
echo -e "  Total: ${COLOR_GREEN}$TOTAL_MERGED${COLOR_RESET}"
echo -e "  Throughput por dia: ${COLOR_GREEN}$THROUGHPUT_PER_DAY${COLOR_RESET}"
echo ""

# 3. WORK IN PROGRESS (WIP)
echo -e "${COLOR_BLUE}⚙️  WORK IN PROGRESS (WIP)${COLOR_RESET}"
WIP=$(gh issue list --repo "$REPO_DOCS" --state open --json number,labels | jq '[.[] | select(.labels[].name | test("in-progress|em-execucao"))] | length')

echo -e "  Issues em execução: ${COLOR_YELLOW}$WIP${COLOR_RESET}"

if [ "$WIP" -gt 10 ]; then
    echo -e "  ${COLOR_RED}⚠️  WIP muito alto! Recomendado: < 10${COLOR_RESET}"
elif [ "$WIP" -gt 5 ]; then
    echo -e "  ${COLOR_YELLOW}⚠️  WIP moderado. Recomendado: < 5${COLOR_RESET}"
else
    echo -e "  ${COLOR_GREEN}✓ WIP saudável${COLOR_RESET}"
fi
echo ""

# 4. BLOCKED ITEMS
echo -e "${COLOR_BLUE}🚫 ITEMS BLOQUEADOS${COLOR_RESET}"
BLOCKED=$(gh issue list --repo "$REPO_DOCS" --label "$LABEL_BLOCKED" --state open --json number,createdAt)
BLOCKED_COUNT=$(echo "$BLOCKED" | jq '. | length')
echo -e "  Issues bloqueadas: ${COLOR_RED}$BLOCKED_COUNT${COLOR_RESET}"

if [ "$BLOCKED_COUNT" -gt 0 ]; then
    # Calcular tempo médio bloqueado
    NOW=$(date +%s)
    TOTAL_BLOCKED_TIME=0

    for created_at in $(echo "$BLOCKED" | jq -r '.[].createdAt'); do
        CREATED=$(date -d "$created_at" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created_at" +%s)
        BLOCKED_TIME=$((NOW - CREATED))
        TOTAL_BLOCKED_TIME=$((TOTAL_BLOCKED_TIME + BLOCKED_TIME))
    done

    AVG_BLOCKED_DAYS=$(awk "BEGIN {printf \"%.1f\", ($TOTAL_BLOCKED_TIME/$BLOCKED_COUNT)/86400}")
    echo -e "  Tempo médio bloqueado: ${COLOR_RED}$AVG_BLOCKED_DAYS dias${COLOR_RESET}"

    if [ $(echo "$AVG_BLOCKED_DAYS > 3" | bc) -eq 1 ]; then
        echo -e "  ${COLOR_RED}⚠️  Tempo de bloqueio muito alto!${COLOR_RESET}"
    fi
fi
echo ""

# 5. CYCLE TIME - Tempo médio de conclusão
echo -e "${COLOR_BLUE}⏱️  CYCLE TIME${COLOR_RESET}"
RECENT_CLOSED=$(gh issue list --repo "$REPO_DOCS" --state closed --search "closed:>=$SINCE_DATE" --json number,createdAt,closedAt --limit 100)
RECENT_CLOSED_COUNT=$(echo "$RECENT_CLOSED" | jq '. | length')

if [ "$RECENT_CLOSED_COUNT" -gt 0 ]; then
    TOTAL_CYCLE_TIME=0

    for issue in $(echo "$RECENT_CLOSED" | jq -c '.[]'); do
        CREATED=$(echo "$issue" | jq -r '.createdAt')
        CLOSED=$(echo "$issue" | jq -r '.closedAt')

        CREATED_TS=$(date -d "$CREATED" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED" +%s)
        CLOSED_TS=$(date -d "$CLOSED" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CLOSED" +%s)

        CYCLE_TIME=$((CLOSED_TS - CREATED_TS))
        TOTAL_CYCLE_TIME=$((TOTAL_CYCLE_TIME + CYCLE_TIME))
    done

    AVG_CYCLE_DAYS=$(awk "BEGIN {printf \"%.1f\", ($TOTAL_CYCLE_TIME/$RECENT_CLOSED_COUNT)/86400}")
    echo -e "  Cycle time médio: ${COLOR_GREEN}$AVG_CYCLE_DAYS dias${COLOR_RESET}"

    if [ $(echo "$AVG_CYCLE_DAYS > 7" | bc 2>/dev/null || echo 0) -eq 1 ]; then
        echo -e "  ${COLOR_YELLOW}⚠️  Cycle time alto. Meta: < 7 dias${COLOR_RESET}"
    else
        echo -e "  ${COLOR_GREEN}✓ Cycle time saudável${COLOR_RESET}"
    fi
else
    echo -e "  ${COLOR_YELLOW}Sem dados suficientes${COLOR_RESET}"
fi
echo ""

# 6. BUGS vs FEATURES
echo -e "${COLOR_BLUE}🐛 BUGS vs ✨ FEATURES${COLOR_RESET}"
CLOSED_BUGS=$(gh issue list --repo "$REPO_DOCS" --state closed --label "bug" --search "closed:>=$SINCE_DATE" --json number --limit 1000 | jq '. | length')
CLOSED_FEATURES=$(gh issue list --repo "$REPO_DOCS" --state closed --label "feature,enhancement" --search "closed:>=$SINCE_DATE" --json number --limit 1000 | jq '. | length')

echo -e "  Bugs corrigidos: ${COLOR_RED}$CLOSED_BUGS${COLOR_RESET}"
echo -e "  Features entregues: ${COLOR_GREEN}$CLOSED_FEATURES${COLOR_RESET}"

if [ "$CLOSED_ISSUES" -gt 0 ]; then
    BUG_RATIO=$(awk "BEGIN {printf \"%.1f\", ($CLOSED_BUGS/$CLOSED_ISSUES)*100}")
    FEATURE_RATIO=$(awk "BEGIN {printf \"%.1f\", ($CLOSED_FEATURES/$CLOSED_ISSUES)*100}")
    echo -e "  Proporção bugs: ${COLOR_RED}$BUG_RATIO%${COLOR_RESET}"
    echo -e "  Proporção features: ${COLOR_GREEN}$FEATURE_RATIO%${COLOR_RESET}"

    if [ $(echo "$BUG_RATIO > 50" | bc 2>/dev/null || echo 0) -eq 1 ]; then
        echo -e "  ${COLOR_RED}⚠️  Alto índice de bugs! Considere melhorar QA.${COLOR_RESET}"
    fi
fi
echo ""

# RESUMO FINAL
echo -e "${COLOR_CYAN}╔══════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_CYAN}║              RESUMO GERAL                ║${COLOR_RESET}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════╝${COLOR_RESET}"
echo -e "  📊 Velocity: ${COLOR_GREEN}$VELOCITY_PER_DAY issues/dia${COLOR_RESET}"
echo -e "  🔀 Throughput: ${COLOR_GREEN}$THROUGHPUT_PER_DAY PRs/dia${COLOR_RESET}"
echo -e "  ⚙️  WIP: ${COLOR_YELLOW}$WIP issues${COLOR_RESET}"
echo -e "  🚫 Bloqueadas: ${COLOR_RED}$BLOCKED_COUNT issues${COLOR_RESET}"
echo ""

# Health Score
HEALTH_SCORE=100

if [ "$WIP" -gt 10 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 20)); fi
if [ "$BLOCKED_COUNT" -gt 3 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 20)); fi
if [ $(echo "$AVG_CYCLE_DAYS > 7" | bc 2>/dev/null || echo 0) -eq 1 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 15)); fi
if [ $(echo "$BUG_RATIO > 50" | bc 2>/dev/null || echo 0) -eq 1 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 15)); fi

echo -e "${COLOR_BLUE}🏥 Health Score do Projeto: ${COLOR_RESET}"
if [ "$HEALTH_SCORE" -ge 80 ]; then
    echo -e "  ${COLOR_GREEN}$HEALTH_SCORE/100 - Excelente! 🎉${COLOR_RESET}"
elif [ "$HEALTH_SCORE" -ge 60 ]; then
    echo -e "  ${COLOR_YELLOW}$HEALTH_SCORE/100 - Bom, mas pode melhorar${COLOR_RESET}"
else
    echo -e "  ${COLOR_RED}$HEALTH_SCORE/100 - Atenção necessária! ⚠️${COLOR_RESET}"
fi
echo ""
