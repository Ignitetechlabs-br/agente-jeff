# 🚀 Setup do Agente Jeff - Guia Completo

Este guia te ajuda a configurar e começar a usar os scripts do Jeff no Windows com Git Bash.

---

## 📋 Pré-requisitos

Antes de começar, você precisa ter instalado:
- ✅ Git (com Git Bash)
- ✅ GitHub CLI (gh)
- ✅ jq (processador JSON)

---

## 🔧 Instalação Passo a Passo

### Passo 1: Verificar Git Bash

**1.1. Abrir Git Bash**
- Pressione `Windows + S`
- Digite "Git Bash"
- Clique em "Git Bash"

**1.2. Verificar se está funcionando**
```bash
git --version
```

**Resultado esperado:**
```
git version 2.x.x
```

**❌ Se não funcionar:**
- Baixe e instale o Git: https://git-scm.com/download/win
- Durante instalação, selecione "Git Bash Here"

---

### Passo 2: Instalar GitHub CLI

**2.1. Verificar se já está instalado**
```bash
gh --version
```

**✅ Se aparecer a versão:** Pule para o Passo 3

**❌ Se não estiver instalado:**

**Opção A: Instalar via Winget (Windows 10/11)**
```bash
# Abrir PowerShell como Administrador
winget install --id GitHub.cli
```

**Opção B: Instalar via Chocolatey**
```bash
# Se você tem Chocolatey instalado
choco install gh
```

**Opção C: Instalar via Scoop**
```bash
# Se você tem Scoop instalado
scoop install gh
```

**Opção D: Download Manual**
1. Acesse: https://cli.github.com/
2. Clique em "Download for Windows"
3. Execute o instalador (.msi)
4. Siga as instruções na tela
5. **IMPORTANTE:** Feche e reabra o Git Bash após instalação

**2.2. Verificar instalação**
```bash
# Fechar e reabrir Git Bash
gh --version
```

---

### Passo 3: Instalar jq

**3.1. Verificar se já está instalado**
```bash
jq --version
```

**✅ Se aparecer a versão:** Pule para o Passo 4

**❌ Se não estiver instalado:**

**Opção A: Instalar via Chocolatey (Recomendado)**
```bash
# Abrir PowerShell como Administrador
choco install jq
```

**Opção B: Instalar via Scoop**
```bash
scoop install jq
```

**Opção C: Download Manual**
1. Acesse: https://stedolan.github.io/jq/download/
2. Baixe `jq-win64.exe`
3. Renomeie para `jq.exe`
4. Mova para `C:\Program Files\Git\usr\bin\`
5. Feche e reabra Git Bash

**3.2. Verificar instalação**
```bash
# Fechar e reabrir Git Bash
jq --version
```

---

### Passo 4: Autenticar no GitHub

**4.1. Fazer login**
```bash
gh auth login
```

**4.2. Responder às perguntas:**

```
? What account do you want to log into?
> GitHub.com

? What is your preferred protocol for Git operations?
> HTTPS

? Authenticate Git with your GitHub credentials?
> Yes

? How would you like to authenticate GitHub CLI?
> Login with a web browser
```

**4.3. Copiar o código que aparece**

Exemplo:
```
! First copy your one-time code: ABCD-1234
Press Enter to open github.com in your browser...
```

**4.4. Pressionar Enter** → Abrirá o navegador

**4.5. Cole o código** no GitHub e autorize

**4.6. Verificar autenticação**
```bash
gh auth status
```

**Resultado esperado:**
```
✓ Logged in to github.com as SEU_USUARIO
```

---

### Passo 5: Navegar até o Projeto

**5.1. Ir para a pasta do Jeff**
```bash
cd "C:\Users\bruno\Documents\Work\Ignite Tech Labs\agente-jeff\scripts"
```

**5.2. Listar arquivos**
```bash
ls -la
```

**Resultado esperado:**
```
config.sh
daily-standup.sh
metrics.sh
sprint-report.sh
move-card.sh
assign-agent.sh
README.md
```

---

### Passo 6: Dar Permissão de Execução (Linux/Mac/WSL)

**No Git Bash do Windows, este passo é OPCIONAL**

```bash
chmod +x *.sh
```

---

### Passo 7: Testar o Primeiro Script

**7.1. Executar daily standup**
```bash
./daily-standup.sh
```

**7.2. O que você deve ver:**

✅ **Se funcionar:**
```
╔══════════════════════════════════════════╗
║       DAILY STANDUP - PROJETO X         ║
╚══════════════════════════════════════════╝

📅 Data: 21/01/2026 - 19:45

🚫 ISSUES BLOQUEADAS:
  ✓ Nenhuma issue bloqueada

⚙️  ISSUES EM EXECUÇÃO:
  ...
```

❌ **Se der erro:**

**Erro: "No such file or directory"**
```bash
# Verificar se está no diretório correto
pwd

# Deve mostrar: .../agente-jeff/scripts
# Se não, volte ao Passo 5.1
```

**Erro: "gh: command not found"**
```bash
# GitHub CLI não instalado
# Volte ao Passo 2
```

**Erro: "jq: command not found"**
```bash
# jq não instalado
# Volte ao Passo 3
```

---

## 🎯 Uso Diário

Depois do setup, você pode usar assim:

### Manhã (9h) - Daily Standup

```bash
# 1. Abrir Git Bash
# 2. Navegar até scripts
cd "C:\Users\bruno\Documents\Work\Ignite Tech Labs\agente-jeff\scripts"

# 3. Executar daily
./daily-standup.sh
```

### Durante o Dia - Comandos Úteis

```bash
# Ver métricas da semana
./metrics.sh 7

# Atribuir issue para um agente
./assign-agent.sh 42 marcus   # Análise
./assign-agent.sh 43 sara     # Frontend
./assign-agent.sh 44 roberto  # Backend
./assign-agent.sh 45 henrique # Review
./assign-agent.sh 46 julia    # QA

# Ver issues bloqueadas
gh issue list --repo Ignitetechlabs-br/marketplace_docs --label "blocked"

# Ver PRs abertos
gh pr list --repo Ignitetechlabs-br/marketplace_frontend
gh pr list --repo Ignitetechlabs-br/marketplace_backend
```

### Fim de Sprint - Relatório

```bash
# Gerar relatório da sprint
./sprint-report.sh

# Ver métricas dos últimos 14 dias
./metrics.sh 14
```

---

## 💡 Dica: Criar Atalhos

Para não precisar digitar o caminho completo toda vez:

### Criar Alias no Git Bash

**1. Editar arquivo de configuração**
```bash
nano ~/.bashrc
```

**2. Adicionar no final do arquivo:**
```bash
# Atalhos do Jeff
alias jeff='cd "/c/Users/bruno/Documents/Work/Ignite Tech Labs/agente-jeff/scripts"'
alias jeff-daily='cd "/c/Users/bruno/Documents/Work/Ignite Tech Labs/agente-jeff/scripts" && ./daily-standup.sh'
alias jeff-metrics='cd "/c/Users/bruno/Documents/Work/Ignite Tech Labs/agente-jeff/scripts" && ./metrics.sh'
alias jeff-sprint='cd "/c/Users/bruno/Documents/Work/Ignite Tech Labs/agente-jeff/scripts" && ./sprint-report.sh'
```

**3. Salvar e sair**
- Pressione `Ctrl + O` (salvar)
- Pressione `Enter`
- Pressione `Ctrl + X` (sair)

**4. Recarregar configuração**
```bash
source ~/.bashrc
```

**5. Usar os atalhos** (de qualquer pasta!)
```bash
jeff-daily        # Daily standup
jeff-metrics      # Métricas
jeff-sprint       # Relatório de sprint
jeff              # Ir para pasta de scripts
```

---

## 🆘 Solução de Problemas

### Problema: "bash: ./daily-standup.sh: Permission denied"

**Solução:**
```bash
chmod +x *.sh
```

---

### Problema: "error: pathspec '*.sh' did not match any file(s) known to git"

**Causa:** Você não está no diretório correto

**Solução:**
```bash
# Verificar onde você está
pwd

# Ir para o diretório correto
cd "C:\Users\bruno\Documents\Work\Ignite Tech Labs\agente-jeff\scripts"

# Confirmar que os arquivos existem
ls -la *.sh
```

---

### Problema: "No repository found"

**Causa:** Scripts tentam acessar repositórios que não existem ou você não tem acesso

**Solução:**
```bash
# Verificar autenticação
gh auth status

# Se não estiver autenticado
gh auth login

# Verificar acesso ao repositório
gh repo view Ignitetechlabs-br/marketplace_docs
```

---

### Problema: Scripts não encontram config.sh

**Causa:** Você está executando de outro diretório

**Solução:**
```bash
# SEMPRE executar da pasta scripts
cd "C:\Users\bruno\Documents\Work\Ignite Tech Labs\agente-jeff/scripts"
./daily-standup.sh
```

---

### Problema: "date: invalid option"

**Causa:** Comando `date` no Git Bash pode ter sintaxe diferente

**Solução:** Isso é esperado em alguns comandos. Os scripts funcionarão mesmo com alguns avisos.

---

### Problema: jq não funciona após instalação

**Solução:**
```bash
# 1. Fechar TODAS as janelas do Git Bash
# 2. Reabrir Git Bash
# 3. Testar
jq --version
```

---

## 📚 Próximos Passos

Depois do setup:

1. ✅ **Ler documentação completa:** `.claude/agents/jeff-scrum.md`
2. ✅ **Ver exemplos de uso:** `scripts/README.md`
3. ✅ **Explorar templates:** `templates/`
4. ✅ **Executar daily standup:** `./daily-standup.sh`
5. ✅ **Calcular métricas:** `./metrics.sh`

---

## 🎯 Checklist de Setup

Use este checklist para verificar se tudo está pronto:

```
Setup Completo do Jeff:

□ Git Bash instalado e funcionando
□ GitHub CLI (gh) instalado
  □ gh --version funciona
  □ gh auth status mostra autenticado
□ jq instalado
  □ jq --version funciona
□ Navegou até pasta scripts
  □ pwd mostra .../agente-jeff/scripts
  □ ls mostra todos os .sh
□ Executou ./daily-standup.sh com sucesso
□ (Opcional) Criou aliases no ~/.bashrc
```

---

## 📞 Ajuda

Se ainda tiver problemas:

1. Verifique a documentação completa em `scripts/README.md`
2. Leia o documento principal em `.claude/agents/jeff-scrum.md`
3. Revise este guia desde o início
4. Verifique se todos os pré-requisitos estão instalados

---

**Pronto! Agora você está pronto para usar o Jeff como um Scrum Master profissional! 🎯✨**
