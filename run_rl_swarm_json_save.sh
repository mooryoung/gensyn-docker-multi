set -euo pipefail

# Best-effort: relax hivemind timeouts if present
PY_SITE=$(python - <<'PY' 2>/dev/null || true
import sysconfig
print(sysconfig.get_paths().get('purelib',''))
PY
)
if [ -n "${PY_SITE}" ] && [ -f "${PY_SITE}/hivemind/p2p/p2p_daemon.py" ]; then
  sed -i 's/startup_timeout: float = 15/startup_timeout: float = 120/' "${PY_SITE}/hivemind/p2p/p2p_daemon.py" || true
  find "${PY_SITE}/hivemind/" -name "*.pyc" -delete || true
fi


ROOT="$PWD"

# ROOT_DIR — абсолютный путь на корень клонированного rl-swarm
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export PUB_MULTI_ADDRS
export PEER_MULTI_ADDRS
export HOST_MULTI_ADDRS
export IDENTITY_PATH
export CONNECT_TO_TESTNET
export ORG_ID
export HF_HUB_DOWNLOAD_TIMEOUT=120  # 2 minutes
export PYTHONPATH="$ROOT:${PYTHONPATH:-}"

# Check if public multi-address is given else set to default
DEFAULT_PUB_MULTI_ADDRS=""
PUB_MULTI_ADDRS=${PUB_MULTI_ADDRS:-$DEFAULT_PUB_MULTI_ADDRS}

# Check if peer multi-address is given else set to default
DEFAULT_PEER_MULTI_ADDRS="/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ" # gensyn coordinator node
PEER_MULTI_ADDRS=${PEER_MULTI_ADDRS:-$DEFAULT_PEER_MULTI_ADDRS}

# Check if host multi-address is given else set to default
DEFAULT_HOST_MULTI_ADDRS="/ip4/0.0.0.0/tcp/38331"
HOST_MULTI_ADDRS=${HOST_MULTI_ADDRS:-$DEFAULT_HOST_MULTI_ADDRS}

# Path to an RSA private key. If this path does not exist, a new key pair will be created.
# Remove this file if you want a new PeerID.
DEFAULT_IDENTITY_PATH="$ROOT"/swarm.pem
IDENTITY_PATH=${IDENTITY_PATH:-$DEFAULT_IDENTITY_PATH}

SMALL_SWARM_CONTRACT="0x69C6e1D608ec64885E7b185d39b04B491a71768C"
BIG_SWARM_CONTRACT="0x6947c6E196a48B77eFa9331EC1E3e45f3Ee5Fd58"

# Will ignore any visible GPUs if set.
CPU_ONLY=${CPU_ONLY:-""}

# Set if successfully parsed from modal-login/temp-data/userData.json.
ORG_ID=${ORG_ID:-""}

GREEN_TEXT="\033[32m"
BLUE_TEXT="\033[34m"
RESET_TEXT="\033[0m"

echo_green() {
    echo -e "$GREEN_TEXT$1$RESET_TEXT"
}

echo_blue() {
    echo -e "$BLUE_TEXT$1$RESET_TEXT"
}

ROOT_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"

# Function to clean up the server process upon exit
cleanup() {
    echo_green ">> Shutting down trainer..."

    # Remove modal credentials if they exist
    # m-r $ROOT_DIR/modal-login/temp-data/*.json 2> /dev/null || true

    # Kill all processes belonging to this script's process group
    kill -- -$$ || true

    exit 0
}

trap cleanup EXIT

echo -e "\033[38;5;224m"
cat << "EOF"
    ██████  ██            ███████ ██     ██  █████  ██████  ███    ███
    ██   ██ ██            ██      ██     ██ ██   ██ ██   ██ ████  ████
    ██████  ██      █████ ███████ ██  █  ██ ███████ ██████  ██ ████ ██
    ██   ██ ██                 ██ ██ ███ ██ ██   ██ ██   ██ ██  ██  ██
    ██   ██ ███████       ███████  ███ ███  ██   ██ ██   ██ ██      ██

    From Gensyn

EOF

NON_INTERACTIVE=${NON_INTERACTIVE:-1}
JOIN_TESTNET=${JOIN_TESTNET:-true}
SWARM=${SWARM:-A}
PARAM_B=${PARAM_B:-0.5}

if [ "$NON_INTERACTIVE" = "1" ]; then
    CONNECT_TO_TESTNET=$JOIN_TESTNET
    case "${SWARM^^}" in
        A) USE_BIG_SWARM=false ;;
        B) USE_BIG_SWARM=true ;;
        *) USE_BIG_SWARM=false ;;
    esac
else
    while true; do
        echo -en $GREEN_TEXT
        read -p ">> Would you like to connect to the Testnet? [Y/n] " yn
        echo -en $RESET_TEXT
        yn=${yn:-Y}
        case $yn in
            [Yy]*)  CONNECT_TO_TESTNET=true && break ;;
            [Nn]*)  CONNECT_TO_TESTNET=false && break ;;
            *)  echo ">>> Please answer yes or no." ;;
        esac
    done

    while true; do
        echo -en $GREEN_TEXT
        read -p ">> Which swarm would you like to join (Math (A) or Math Hard (B))? [A/b] " ab
        echo -en $RESET_TEXT
        ab=${ab:-A}
        case $ab in
            [Aa]*)  USE_BIG_SWARM=false && break ;;
            [Bb]*)  USE_BIG_SWARM=true && break ;;
            *)  echo ">>> Please answer A or B." ;;
        esac
    done

    while true; do
        echo -en $GREEN_TEXT
        read -p ">> How many parameters (in billions)? [0.5, 1.5, 7, 32, 72] " pc
        echo -en $RESET_TEXT
        pc=${pc:-0.5}
        case $pc in
            0.5 | 1.5 | 7 | 32 | 72) PARAM_B=$pc && break ;;
            *)  echo ">>> Please answer in [0.5, 1.5, 7, 32, 72]." ;;
        esac
    done
fi

if [ "$USE_BIG_SWARM" = true ]; then
    SWARM_CONTRACT="$BIG_SWARM_CONTRACT"
else
    SWARM_CONTRACT="$SMALL_SWARM_CONTRACT"
fi

DISABLE_MODAL_LOGIN=${DISABLE_MODAL_LOGIN:-1}
if [ "$CONNECT_TO_TESTNET" = true ] && [ "$DISABLE_MODAL_LOGIN" != "1" ]; then
    # Run modal_login server.
    echo "Please login to create an Ethereum Server Wallet"
    cd modal-login
    # Check if the yarn command exists; if not, install Yarn.

    # Node.js + NVM setup
    if ! command -v node > /dev/null 2>&1; then
        echo "Node.js not found. Installing NVM and latest Node.js..."
        export NVM_DIR="$HOME/.nvm"
        if [ ! -d "$NVM_DIR" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        fi
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm install node
    else
        echo "Node.js is already installed: $(node -v)"
    fi

    if ! command -v yarn > /dev/null 2>&1; then
        # Detect Ubuntu (including WSL Ubuntu) and install Yarn accordingly
        if grep -qi "ubuntu" /etc/os-release 2> /dev/null || uname -r | grep -qi "microsoft"; then
            echo "Detected Ubuntu or WSL Ubuntu. Installing Yarn via apt..."
            curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt update && sudo apt install -y yarn
        else
            echo "Yarn not found. Installing Yarn globally with npm (no profile edits)…"
            # This lands in $NVM_DIR/versions/node/<ver>/bin which is already on PATH
            npm install -g --silent yarn
        fi
    fi
    yarn install
    yarn dev > /dev/null 2>&1 & # Run in background and suppress output

    SERVER_PID=$!  # Store the process ID
    echo "Started server process: $SERVER_PID"
    sleep 5

    # Try to open the URL in the default browser
    if open http://localhost:3000 2> /dev/null; then
        echo_green ">> Successfully opened http://localhost:3000 in your default browser."
    else
        echo ">> Failed to open http://localhost:3000. Please open it manually."
    fi

    cd ..

    if [ ! -f "modal-login/temp-data/userData.json" ]; then
        echo_green ">> Waiting for modal userData.json to be created..."
        while [ ! -f "modal-login/temp-data/userData.json" ]; do
            sleep 5
        done
        echo "Found userData.json. Proceeding..."
    fi

    ORG_ID=$(awk 'BEGIN { FS = "\"" } !/^[ \t]*[{}]/ { print $(NF - 1); exit }' modal-login/temp-data/userData.json)
    echo "Your ORG_ID is set to: $ORG_ID"

    # Wait until the API key is activated by the client
    echo "Waiting for API key to become activated..."
    while true; do
        STATUS=$(curl -s "http://localhost:3000/api/get-api-key-status?orgId=$ORG_ID")
        if [[ "$STATUS" == "activated" ]]; then
            echo "API key is activated! Proceeding..."
            break
        else
            echo "Waiting for API key to be activated..."
            sleep 5
        fi
    done

    ENV_FILE="$ROOT"/modal-login/.env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        sed -i '' "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"
    else
        # Linux version
        sed -i "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"
    fi
fi

echo_green ">> Getting requirements..."

pip install --upgrade pip setuptools wheel

install_cpu_requirements() {
    if [ -f "$ROOT/requirements-cpu.txt" ]; then
        pip install -r "$ROOT/requirements-cpu.txt"
        return 0
    elif [ -f "$ROOT/requirements.txt" ]; then
        pip install -r "$ROOT/requirements.txt"
        return 0
    else
        echo "No requirements-cpu.txt or requirements.txt found. Assuming deps preinstalled."
        return 0
    fi
}

install_gpu_requirements() {
    if [ -f "$ROOT/requirements-gpu.txt" ]; then
        pip install -r "$ROOT/requirements-gpu.txt"
    elif [ -f "$ROOT/requirements.txt" ]; then
        pip install -r "$ROOT/requirements.txt"
    else
        echo "No GPU/standard requirements file found. Assuming deps preinstalled."
    fi
    # Optional GPU extra
    pip install flash-attn --no-build-isolation || true
}

if [ -n "$CPU_ONLY" ] || ! command -v nvidia-smi &> /dev/null; then
    # CPU-only mode or no NVIDIA GPU found
    install_cpu_requirements
    CONFIG_PATH="$ROOT/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml" # TODO: Fix naming.
    GAME="gsm8k"
else
    # NVIDIA GPU found
    install_gpu_requirements

    case "$PARAM_B" in
        32 | 72) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-bnb-4bit-deepseek-r1.yaml" ;;
        0.5 | 1.5 | 7) CONFIG_PATH="$ROOT/hivemind_exp/configs/gpu/grpo-qwen-2.5-${PARAM_B}b-deepseek-r1.yaml" ;;
        *)  echo ">>> Please answer in [0.5, 1.5, 7, 32, 72]." ;;
    esac
    if [ "$USE_BIG_SWARM" = true ]; then
        GAME="dapo"
    else
        GAME="gsm8k"
    fi
fi

echo_green ">> Done!"

HF_TOKEN=${HF_TOKEN:-""}
DISABLE_HF_PUSH=${DISABLE_HF_PUSH:-1}
if [ -n "${HF_TOKEN}" ]; then
    HUGGINGFACE_ACCESS_TOKEN=${HF_TOKEN}
elif [ "$NON_INTERACTIVE" = "1" ] && [ "$DISABLE_HF_PUSH" = "1" ]; then
    HUGGINGFACE_ACCESS_TOKEN="None"
else
    echo -en $GREEN_TEXT
    read -p ">> Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N] " yn
    echo -en $RESET_TEXT
    yn=${yn:-N}
    case $yn in
        [Yy]*) read -p "Enter your Hugging Face access token: " HUGGINGFACE_ACCESS_TOKEN ;;
        [Nn]*) HUGGINGFACE_ACCESS_TOKEN="None" ;;
        *) echo ">>> No answer was given, so NO models will be pushed to Hugging Face Hub" && HUGGINGFACE_ACCESS_TOKEN="None" ;;
    esac
fi

echo_green ">> Good luck in the swarm!"
echo_blue ">> Post about rl-swarm on X/twitter! --> https://tinyurl.com/swarmtweet"
echo_blue ">> And remember to star the repo on GitHub! --> https://github.com/gensyn-ai/rl-swarm"

LAUNCH_OFFICIAL=${LAUNCH_OFFICIAL:-1}
if [ "$LAUNCH_OFFICIAL" = "1" ] && command -v rlswarm_official.sh >/dev/null 2>&1; then
    echo_green ">> Launching official rl-swarm script"
    # Environment expected by official script
    export HOST_MULTI_ADDRS
    export IDENTITY_PATH
    export CPU_ONLY
    export ORG_ID
    export CONNECT_TO_TESTNET
    export HF_TOKEN="$HUGGINGFACE_ACCESS_TOKEN"
    exec rlswarm_official.sh
else
    echo_green ">> Launching compatibility path (direct module)"
    if [ -n "$ORG_ID" ]; then
        python -m hivemind_exp.gsm8k.train_single_gpu \
            --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
            --identity_path "$IDENTITY_PATH" \
            --modal_org_id "$ORG_ID" \
            --contract_address "$SWARM_CONTRACT" \
            --config "$CONFIG_PATH" \
            --game "$GAME"
    else
        python -m hivemind_exp.gsm8k.train_single_gpu \
            --hf_token "$HUGGINGFACE_ACCESS_TOKEN" \
            --identity_path "$IDENTITY_PATH" \
            --public_maddr "$PUB_MULTI_ADDRS" \
            --initial_peers "$PEER_MULTI_ADDRS" \
            --host_maddr "$HOST_MULTI_ADDRS" \
            --config "$CONFIG_PATH" \
            --game "$GAME"
    fi
fi

wait  # Keep script running until Ctrl+C