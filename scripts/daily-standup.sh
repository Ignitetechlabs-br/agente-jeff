#!/bin/bash
# Script para Daily Standup automatizado

# Carregar configuração
source "$(dirname "$0")/config.sh"

echo -e "${COLOR_CYAN}╔══════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_CYAN}║       DAILY STANDUP - PROJETO X         ║${COLOR_RESET}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Data atual
echo -e "${COLOR_BLUE}📅 Data: $(date '+%d/%m/%Y - %H:%M')${COLOR_RESET}"
echo ""

# Issues Bloqueadas
echo -e "${COLOR_RED}🚫 ISSUES BLOQUEADAS:${COLOR_RESET}"
BLOCKED=$(gh issue list --repo "$REPO_DOCS" --label "$LABEL_BLOCKED" --state open --json number,title,assignees --limit 20)
BLOCKED_COUNT=$(echo "$BLOCKED" | jq '. | length')

if [ "$BLOCKED_COUNT" -gt 0 ]; then
    echo "$BLOCKED" | jq -r '.[] | "  #\(.number) - \(.title) [@\(.assignees[].login // "sem assignee")]"'
else
    echo -e "  ${COLOR_GREEN}✓ Nenhuma issue bloqueada${COLOR_RESET}"
fi
echo ""

# Issues Em Execução
echo -e "${COLOR_YELLOW}⚙️  ISSUES EM EXECUÇÃO:${COLOR_RESET}"
IN_PROGRESS=$(gh issue list --repo "$REPO_DOCS" --state open --json number,title,assignees,labels --limit 50 | jq '[.[] | select(.labels[].name | test("in-progress|em-execucao"))]')
IN_PROGRESS_COUNT=$(echo "$IN_PROGRESS" | jq '. | length')

if [ "$IN_PROGRESS_COUNT" -gt 0 ]; then
    echo "$IN_PROGRESS" | jq -r '.[] | "  #\(.number) - \(.title) [@\(.assignees[].login // "sem assignee")]"'
else
    echo -e "  ${COLOR_YELLOW}! Nenhuma issue em execução${COLOR_RESET}"
fi
echo ""

# Issues Aguardando Review
echo -e "${COLOR_MAGENTA}👀 AGUARDANDO REVISÃO:${COLOR_RESET}"
REVIEW=$(gh issue list --repo "$REPO_DOCS" --label "$LABEL_READY_REVIEW" --state open --json number,title,assignees --limit 20)
REVIEW_COUNT=$(echo "$REVIEW" | jq '. | length')

if [ "$REVIEW_COUNT" -gt 0 ]; then
    echo "$REVIEW" | jq -r '.[] | "  #\(.number) - \(.title) [@\(.assignees[].login // "sem assignee")]"'
else
    echo -e "  ${COLOR_GREEN}✓ Nenhuma issue aguardando review${COLOR_RESET}"
fi
echo ""

# Issues Aguardando QA
echo -e "${COLOR_CYAN}🧪 AGUARDANDO QA:${COLOR_RESET}"
QA=$(gh issue list --repo "$REPO_DOCS" --label "$LABEL_READY_QA" --state open --json number,title,assignees --limit 20)
QA_COUNT=$(echo "$QA" | jq '. | length')

if [ "$QA_COUNT" -gt 0 ]; then
    echo "$QA" | jq -r '.[] | "  #\(.number) - \(.title) [@\(.assignees[].login // "sem assignee")]"'
else
    echo -e "  ${COLOR_GREEN}✓ Nenhuma issue aguardando QA${COLOR_RESET}"
fi
echo ""

# PRs Abertos
echo -e "${COLOR_BLUE}📝 PULL REQUESTS ABERTOS:${COLOR_RESET}"
echo -e "${COLOR_WHITE}Frontend:${COLOR_RESET}"
PR_FRONTEND=$(gh pr list --repo "$REPO_FRONTEND" --state open --json number,title,author --limit 10)
PR_FRONTEND_COUNT=$(echo "$PR_FRONTEND" | jq '. | length')

if [ "$PR_FRONTEND_COUNT" -gt 0 ]; then
    echo "$PR_FRONTEND" | jq -r '.[] | "  #\(.number) - \(.title) [@\(.author.login)]"'
else
    echo -e "  ${COLOR_GREEN}✓ Nenhum PR aberto${COLOR_RESET}"
fi

echo -e "${COLOR_WHITE}Backend:${COLOR_RESET}"
PR_BACKEND=$(gh pr list --repo "$REPO_BACKEND" --state open --json number,title,author --limit 10)
PR_BACKEND_COUNT=$(echo "$PR_BACKEND" | jq '. | length')

if [ "$PR_BACKEND_COUNT" -gt 0 ]; then
    echo "$PR_BACKEND" | jq -r '.[] | "  #\(.number) - \(.title) [@\(.author.login)]"'
else
    echo -e "  ${COLOR_GREEN}✓ Nenhum PR aberto${COLOR_RESET}"
fi
echo ""

# Workflows com falha
echo -e "${COLOR_RED}⚠️  WORKFLOWS COM FALHA (últimas 24h):${COLOR_RESET}"
FAILED_RUNS=$(gh run list --repo "$REPO_DOCS" --status failure --created "$(date -d '1 day ago' '+%Y-%m-%d')" --limit 5 --json displayTitle,conclusion 2>/dev/null || gh run list --repo "$REPO_DOCS" --status failure --limit 5 --json displayTitle,conclusion)
FAILED_COUNT=$(echo "$FAILED_RUNS" | jq '. | length')

if [ "$FAILED_COUNT" -gt 0 ]; then
    echo "$FAILED_RUNS" | jq -r '.[] | "  ✗ \(.displayTitle)"'
else
    echo -e "  ${COLOR_GREEN}✓ Nenhum workflow com falha${COLOR_RESET}"
fi
echo ""

# Resumo
echo -e "${COLOR_CYAN}╔══════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_CYAN}║              RESUMO DO DIA               ║${COLOR_RESET}"
echo -e "${COLOR_CYAN}╚══════════════════════════════════════════╝${COLOR_RESET}"
echo -e "  🚫 Bloqueadas:      ${COLOR_RED}${BLOCKED_COUNT}${COLOR_RESET}"
echo -e "  ⚙️  Em Execução:     ${COLOR_YELLOW}${IN_PROGRESS_COUNT}${COLOR_RESET}"
echo -e "  👀 Aguard. Review:  ${COLOR_MAGENTA}${REVIEW_COUNT}${COLOR_RESET}"
echo -e "  🧪 Aguard. QA:      ${COLOR_CYAN}${QA_COUNT}${COLOR_RESET}"
echo -e "  📝 PRs Frontend:    ${BLUE}${PR_FRONTEND_COUNT}${COLOR_RESET}"
echo -e "  📝 PRs Backend:     ${BLUE}${PR_BACKEND_COUNT}${COLOR_RESET}"
echo -e "  ⚠️  Workflows Fail:  ${COLOR_RED}${FAILED_COUNT}${COLOR_RESET}"
echo ""

# Red Flags
RED_FLAGS=0
if [ "$BLOCKED_COUNT" -gt 3 ]; then
    echo -e "${COLOR_RED}🚩 RED FLAG: Muitas issues bloqueadas (> 3)${COLOR_RESET}"
    RED_FLAGS=$((RED_FLAGS + 1))
fi

if [ "$IN_PROGRESS_COUNT" -gt 10 ]; then
    echo -e "${COLOR_RED}🚩 RED FLAG: WIP muito alto (> 10)${COLOR_RESET}"
    RED_FLAGS=$((RED_FLAGS + 1))
fi

if [ "$REVIEW_COUNT" -gt 5 ]; then
    echo -e "${COLOR_RED}🚩 RED FLAG: Muitas issues aguardando review${COLOR_RESET}"
    RED_FLAGS=$((RED_FLAGS + 1))
fi

if [ "$FAILED_COUNT" -gt 3 ]; then
    echo -e "${COLOR_RED}🚩 RED FLAG: Muitos workflows falhando${COLOR_RESET}"
    RED_FLAGS=$((RED_FLAGS + 1))
fi

if [ "$RED_FLAGS" -eq 0 ]; then
    echo -e "${COLOR_GREEN}✓ Tudo funcionando bem! Continue assim! 🎉${COLOR_RESET}"
fi

echo ""
