#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if ! command -v curl &>/dev/null; then
    sudo apt update
    sudo apt install curl -y
fi

if ! command -v docker &>/dev/null; then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker installed successfully.${NC}"
fi

echo -e "${YELLOW}Make your choise:${NC}"
echo -e "${CYAN}1) Start RPC (Hoodi)${NC}"
echo -e "${CYAN}2) Delete RPC${NC}"
echo -ne "${YELLOW}Enter number: ${NC}"
read choice

case $choice in
  1)
    sudo apt update -y
    sudo apt install mc wget curl git htop netcat-openbsd net-tools unzip jq build-essential ncdu tmux make cmake clang pkg-config libssl-dev protobuf-compiler bc lz4 screen ufw -y

    sudo ufw allow 22:65535/tcp
    sudo ufw allow 22:65535/udp
    sudo ufw deny out from any to 10.0.0.0/8
    sudo ufw deny out from any to 192.168.0.0/16
    sudo ufw deny out from any to 100.64.0.0/10
    sudo ufw deny out from any to 198.18.0.0/15
    sudo ufw deny out from any to 169.254.0.0/16
    sudo ufw --force enable

    if ! id "geth_hoodi" &> /dev/null; then
      useradd -s /bin/bash -m geth_hoodi
      sudo usermod -aG sudo geth_hoodi
      sudo usermod -aG docker geth_hoodi
      sudo passwd geth_hoodi
    else
      echo -e "${GREEN}User 'geth_hoodi' already exists.${NC}"
    fi

    if [ ! -d "/home/geth_hoodi/eth-docker" ]; then
      sudo -u geth_hoodi git clone https://github.com/eth-educators/eth-docker.git /home/geth_hoodi/eth-docker
    else
      echo -e "${GREEN}Directory '/home/geth_hoodi/eth-docker' already exists.${NC}"
    fi

    sudo -u geth_hoodi cp /home/geth_hoodi/eth-docker/default.env /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/COMPOSE_FILE=.*/COMPOSE_FILE=teku-cl-only.yml:geth.yml:grafana.yml:grafana-shared.yml:el-shared.yml/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/EL_P2P_PORT=.*/EL_P2P_PORT=40303/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/CL_P2P_PORT=.*/CL_P2P_PORT=49000/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/CL_QUIC_PORT=.*/CL_QUIC_PORT=49001/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/GRAFANA_PORT=.*/GRAFANA_PORT=54000/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/EL_RPC_PORT=.*/EL_RPC_PORT=59545/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/EL_WS_PORT=.*/EL_WS_PORT=59546/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/NETWORK=.*/NETWORK=hoodi/g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's|CHECKPOINT_SYNC_URL=.*|CHECKPOINT_SYNC_URL="https://checkpoint-sync.hoodi.ethpandaops.io"|g' /home/geth_hoodi/eth-docker/.env
    sudo -u geth_hoodi sed -i 's/FEE_RECIPIENT=.*/FEE_RECIPIENT=0xd9264738573E25CB9149de0708b36527d56B59bd/g' /home/geth_hoodi/eth-docker/.env

    export COMPOSE_PROJECT_NAME=hoodi
    sudo -u geth_hoodi /home/geth_hoodi/eth-docker/ethd up

        echo -e "\n${GREEN}🎉 RPC installation complete!${NC}"
        SERVER_IP=$(curl -4 ifconfig.me)
        echo -e "${CYAN}To check if your RPC is working and synced, follow these steps:${NC}\n"
        echo "1. Open Grafana in your browser:"
        echo -e "   ${YELLOW}http://${SERVER_IP}:54000${NC}"
        echo "2. Use the following credentials to log in:"
        echo -e "   ${YELLOW}Username: admin${NC}"
        echo -e "   ${YELLOW}Password: admin${NC}"
        echo "3. Grafana will ask you to change the password – do it."
        echo "4. Go to:"
        echo -e "   ${YELLOW}Dashboards > Eth Docker > Home Staking Dashboard${NC}"
        echo "5. Wait until you see:"
        echo -e "   ${GREEN}Consensus = Synced${NC} and ${GREEN}Execution = Synced${NC}"
        echo -e "\n${GREEN}✅ Your Hoodi RPC is now ready for action.${NC}"
        echo -e "${CYAN}Your RPC endpoints:${NC}"
        echo -e "◦ HTTP: ${YELLOW}http://${SERVER_IP}:59545${NC}"
        echo -e "◦ WS:   ${YELLOW}ws://${SERVER_IP}:59546${NC}"
        echo -e "${GREEN}⭐️ If you found this helpful, don't forget to star the repo: https://github.com/noderguru/Ethereum-Testnet_RPCs 😎${NC}"
    ;;
  2)
    sudo -u geth_hoodi /home/geth_hoodi/eth-docker/ethd down -v
    rm -rf /home/geth_hoodi
    sudo deluser --remove-home geth_hoodi
    echo -e "${RED}RPC Hoodi has been removed${NC}"
    ;;
  *)
    echo -e "${RED}The wrong choice. Please enter a number from 1 to 2!${NC}"
    ;;
esac
