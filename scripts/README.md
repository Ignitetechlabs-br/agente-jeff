# Scripts de Automação - Jeff

Scripts para automatizar tarefas do Scrum Master no Projeto X.

## 📋 Scripts Disponíveis

### 1. `config.sh`
Arquivo de configuração com IDs, repositórios e labels.

**Uso:** Carregado automaticamente pelos outros scripts.

### 2. `daily-standup.sh`
Gera relatório automático do daily standup.

**Uso:**
```bash
./daily-standup.sh
```

**O que mostra:**
- Issues bloqueadas
- Issues em execução
- Issues aguardando review
- Issues aguardando QA
- PRs abertos (frontend e backend)
- Workflows com falha
- Resumo com red flags

### 3. `sprint-report.sh`
Gera relatório completo de sprint.

**Uso:**
```bash
# Usar label padrão (sprint:current)
./sprint-report.sh

# Usar label customizada
./sprint-report.sh "sprint:2024-01"

# Especificar arquivo de saída
./sprint-report.sh "sprint:current" "relatorio.md"
```

**Gera:**
- Arquivo markdown com:
  - Visão geral (issues completadas vs pendentes)
  - Lista de issues completadas
  - Lista de issues pendentes
  - Métricas (velocity, distribuição por tipo)
  - Próximos passos

### 4. `metrics.sh`
Calcula métricas do projeto.

**Uso:**
```bash
# Últimos 7 dias (padrão)
./metrics.sh

# Últimos 30 dias
./metrics.sh 30

# Última semana
./metrics.sh 7
```

**Calcula:**
- Velocity (issues/dia)
- Throughput (PRs/dia)
- Work In Progress (WIP)
- Items bloqueados
- Cycle time médio
- Proporção bugs vs features
- Health Score do projeto

### 5. `move-card.sh`
Move cards entre colunas do Projeto X.

**Uso:**
```bash
./move-card.sh ITEM_ID COLUNA

# Exemplo: mover para backlog
./move-card.sh PVTI_lADODYrjFc4BMMn2zgXYZ12 backlog
```

**Colunas disponíveis:**
- `inbox` - Inbox
- `triagem` - Triagem
- `backlog` - Backlog
- `em-execucao` - Em Execução
- `revisao` - Revisão por Pares
- `testes` - Testes/QA
- `bloqueado` - Bloqueado
- `concluido` - Concluído

**Como obter ITEM_ID:**
```bash
# Listar items do projeto
gh project item-list 2 --owner Ignitetechlabs-br --format json | jq '.items[] | {id, title}'
```

### 6. `assign-agent.sh`
Atribui issues para agentes específicos.

**Uso:**
```bash
./assign-agent.sh ISSUE_NUMBER AGENT

# Exemplos:
./assign-agent.sh 42 marcus    # Atribuir para Marcus (análise)
./assign-agent.sh 43 sara      # Atribuir para Sara (frontend)
./assign-agent.sh 44 roberto   # Atribuir para Roberto (backend)
./assign-agent.sh 45 henrique  # Atribuir para Henrique (review)
./assign-agent.sh 46 julia     # Atribuir para Julia (QA)
```

**Agentes disponíveis:**
- `marcus` - Analista de Requisitos
- `sara` - Frontend Developer
- `roberto` - Backend Developer
- `henrique` - Arquiteto / Code Reviewer
- `julia` - QA Engineer
- `jeff` - Scrum Master

## 🚀 Setup Inicial

### 1. Tornar scripts executáveis (Linux/Mac)
```bash
chmod +x *.sh
```

### 2. Instalar dependências
```bash
# GitHub CLI
# https://cli.github.com/

# jq (para processar JSON)
# Linux: sudo apt install jq
# Mac: brew install jq
# Windows: scoop install jq
```

### 3. Autenticar GitHub CLI
```bash
gh auth login
```

## 📊 Workflows Recomendados

### Rotina Diária
```bash
# 1. Executar daily standup
./daily-standup.sh

# 2. Verificar métricas
./metrics.sh

# 3. Atribuir issues do backlog
./assign-agent.sh 42 sara
./assign-agent.sh 43 roberto
```

### Fim de Sprint
```bash
# 1. Gerar relatório
./sprint-report.sh

# 2. Ver métricas da sprint (últimos 14 dias)
./metrics.sh 14

# 3. Preparar retrospectiva
# Usar template em ../templates/retrospective.md
```

### Weekly Review
```bash
# 1. Métricas da semana
./metrics.sh 7

# 2. Gerar relatório semanal
# Usar template em ../templates/weekly-report.md
```

## 🎨 Personalização

### Cores no Terminal
As cores são definidas em `config.sh`:
- `COLOR_RED` - Erros, bloqueios
- `COLOR_GREEN` - Sucesso, conclusões
- `COLOR_YELLOW` - Avisos, WIP
- `COLOR_BLUE` - Informações
- `COLOR_CYAN` - Títulos
- `COLOR_MAGENTA` - Destaques

### Configurar Repositórios
Edite `config.sh` para atualizar:
- IDs do projeto
- Repositórios
- Labels
- Nomes de agentes

## 🔧 Troubleshooting

### Erro: "gh: command not found"
```bash
# Instale o GitHub CLI
# https://cli.github.com/
```

### Erro: "jq: command not found"
```bash
# Linux
sudo apt install jq

# Mac
brew install jq

# Windows
scoop install jq
```

### Erro: "Permission denied"
```bash
# Linux/Mac
chmod +x script-name.sh

# Windows (Git Bash)
# Os scripts devem funcionar sem chmod
```

### Script não encontra configuração
```bash
# Verifique se config.sh está no mesmo diretório
ls -la config.sh

# Execute do diretório correto
cd scripts/
./daily-standup.sh
```

## 📝 Exemplos de Uso

### Cenário 1: Daily Standup Completo
```bash
cd agente-jeff/scripts
./daily-standup.sh > daily-$(date +%Y%m%d).txt
```

### Cenário 2: Preparar Sprint Review
```bash
# Gerar relatório
./sprint-report.sh "sprint:current" "review-sprint-10.md"

# Calcular métricas da sprint (14 dias)
./metrics.sh 14 > metrics-sprint-10.txt
```

### Cenário 3: Monitoramento Contínuo
```bash
# Criar cronjob para daily automático (Linux/Mac)
crontab -e

# Adicionar linha:
0 9 * * 1-5 cd /path/to/agente-jeff/scripts && ./daily-standup.sh | mail -s "Daily Standup" team@example.com
```

## 🤝 Contribuindo

Melhorias e novos scripts são bem-vindos!

### Padrões
- Use `source config.sh` para carregar configuração
- Use cores para melhorar legibilidade
- Adicione help (`--help` ou sem argumentos)
- Documente no README

---

**Dúvidas?** Consulte a documentação principal em `.claude/agents/jeff-scrum.md`
