#!/bin/bash
# =============================================
# Script de deploy automático — Alpha Consórcio
# Requisito: ter o GitHub CLI (gh) instalado
# =============================================

REPO_NAME="alpha-consorcio"
GITHUB_USER=$(gh api user --jq .login 2>/dev/null)

if [ -z "$GITHUB_USER" ]; then
  echo "❌ GitHub CLI não autenticado. Execute: gh auth login"
  exit 1
fi

echo "🚀 Iniciando deploy para GitHub Pages..."
echo "👤 Usuário: $GITHUB_USER"

# Criar repositório se não existir
gh repo view "$GITHUB_USER/$REPO_NAME" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "📦 Criando repositório $REPO_NAME..."
  gh repo create "$REPO_NAME" --public --description "Formulário de Pedido de Faturamento — Alpha Cartas de Crédito"
fi

# Inicializar git local se necessário
if [ ! -d ".git" ]; then
  git init
  git branch -M main
  git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
fi

# Commit e push
git add -A
git commit -m "Deploy formulário Alpha $(date '+%Y-%m-%d %H:%M')"
git push -u origin main --force

# Ativar GitHub Pages via API
echo "🌐 Ativando GitHub Pages..."
gh api --method POST repos/$GITHUB_USER/$REPO_NAME/pages \
  --field source='{"branch":"main","path":"/"}' 2>/dev/null || true

sleep 3

echo ""
echo "✅ Deploy concluído!"
echo "🔗 URL: https://$GITHUB_USER.github.io/$REPO_NAME/"
echo ""
echo "Próximo passo: cole a URL do webhook Make.com em CONFIG.MAKE_WEBHOOK_URL no index.html"
