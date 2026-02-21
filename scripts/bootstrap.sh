#!/bin/bash
# ══════════════════════════════════════════════════════════════
#  bootstrap.sh
#
#  Usage 1:
#    curl -fsSL https://raw.githubusercontent.com/jslblar080/ai-research-repo/main/scripts/bootstrap.sh | bash
#  Usage 2:
#    git clone https://github.com/jslblar080/ai-research-repo.git
#    cd ai-research-repo
#    bash scripts/bootstrap.sh
# ══════════════════════════════════════════════════════════════

set -euo pipefail

NC='\033[0m'  # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'

log()     { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
info()    { echo -e "${BLUE}[→]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
section() { echo -e "\n${CYAN}══════════════════════════════${NC}"; \
            echo -e "${CYAN}  $1${NC}"; \
            echo -e "${CYAN}══════════════════════════════${NC}"; }

GITHUB_USER="jslblar080"
GITHUB_REPO="ai-research-repo"
GITHUB_BRANCH="main"
REPO_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
WORKDIR="$HOME/${GITHUB_REPO}"

BOOTSTRAP_START=$(date +%s)

# ══════════════════════════════════════════════════════════════
section "0. Environment check"
# ══════════════════════════════════════════════════════════════

info "System information"
echo "  OS     : $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo "  Kernel : $(uname -r)"
echo "  CPU    : $(nproc) cores"
echo "  RAM    : $(free -h | awk '/^Mem:/ {print $2}')"
echo "  Disk   : $(df -h / | awk 'NR==2 {print $4}') free"
echo "  User   : $(whoami)"

info "GPU check"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total,driver_version \
               --format=csv,noheader | \
    awk -F',' '{printf "  GPU: %s | VRAM: %s | Driver: %s\n", $1,$2,$3}'
    CUDA_VER=$(nvidia-smi | grep "CUDA Version" | awk '{print $NF}')
    echo "  CUDA   : $CUDA_VER"
    GPU_AVAILABLE=true
else
    warn "nvidia-smi (X) → Switching to CPU mode"
    GPU_AVAILABLE=false
fi

# ══════════════════════════════════════════════════════════════
section "1. Install system package"
# ══════════════════════════════════════════════════════════════

info "Update apt and install essential packages"
sudo apt-get update -qq
sudo apt-get install -y -qq \
    git \
    curl \
    wget \
    vim \
    tmux \
    htop \
    tree \
    unzip \
    build-essential \
    python3-pip \
    python3-venv \
    python3-dev
log "System package complete"

# ══════════════════════════════════════════════════════════════
# Summary of completion
# ══════════════════════════════════════════════════════════════

BOOTSTRAP_END=$(date +%s)
ELAPSED=$((BOOTSTRAP_END - BOOTSTRAP_START))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Bootstrap complete!          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "  Duration : ${CYAN}${MINUTES}minutes ${SECONDS}seconds${NC}"
echo -e "  Working directory : ${CYAN}${WORKDIR}${NC}"
echo ""
