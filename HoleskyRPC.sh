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

echo -e "${YELLOW}Your choice:${NC}"
echo -e "${CYAN}1) Install RPC${NC}"
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

        if ! id "geth_holesky" &>/dev/null; then
            useradd -s /bin/bash -m geth_holesky
            sudo usermod -aG sudo geth_holesky
            sudo usermod -aG docker geth_holesky
            sudo passwd geth_holesky
        else
            echo -e "${GREEN}User 'geth_holesky' already exists.${NC}"
        fi

        if [ ! -d "/home/geth_holesky/eth-docker" ]; then
            sudo -u geth_holesky git clone https://github.com/eth-educators/eth-docker.git /home/geth_holesky/eth-docker
        else
            echo -e "${GREEN}Directory '/home/geth_holesky/eth-docker' already exists.${NC}"
        fi

        sudo -u geth_holesky cp /home/geth_holesky/eth-docker/default.env /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/COMPOSE_FILE=.*/COMPOSE_FILE=prysm-cl-only.yml:geth.yml:grafana.yml:grafana-shared.yml:el-shared.yml/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/EL_P2P_PORT=.*/EL_P2P_PORT=40303/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/CL_P2P_PORT=.*/CL_P2P_PORT=49000/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/CL_QUIC_PORT=.*/CL_QUIC_PORT=49001/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/GRAFANA_PORT=.*/GRAFANA_PORT=43000/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/EL_RPC_PORT=.*/EL_RPC_PORT=48545/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/EL_WS_PORT=.*/EL_WS_PORT=48546/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/NETWORK=.*/NETWORK=holesky/g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's|CHECKPOINT_SYNC_URL=.*|CHECKPOINT_SYNC_URL=\"https://holesky.beaconstate.info\"|g' /home/geth_holesky/eth-docker/.env
        sudo -u geth_holesky sed -i 's/FEE_RECIPIENT=.*/FEE_RECIPIENT=0xd9264738573E25CB9149de0708b36527d56B59bd/g' /home/geth_holesky/eth-docker/.env

        export COMPOSE_PROJECT_NAME=holesky
        sudo -u geth_holesky /home/geth_holesky/eth-docker/ethd up

        echo -e "\n${GREEN}🎉 RPC installation complete!${NC}"
        SERVER_IP=$(curl -4 ifconfig.me)
        echo -e "${CYAN}To check if your RPC is working and synced, follow these steps:${NC}\n"
        echo "1. Open Grafana in your browser:"
        echo -e "   ${YELLOW}http://${SERVER_IP}:43000${NC}"
        echo "2. Use the following credentials to log in:"
        echo -e "   ${YELLOW}Username: admin${NC}"
        echo -e "   ${YELLOW}Password: admin${NC}"
        echo "3. Grafana will ask you to change the password – do it."
        echo "4. Go to:"
        echo -e "   ${YELLOW}Dashboards > Home Staking Dashboard${NC}"
        echo "5. Wait until you see:"
        echo -e "   ${GREEN}Consensus = Synced${NC} and ${GREEN}Execution = Synced${NC}"
        echo -e "\n${GREEN}✅ Your Holesky RPC is now ready for action.${NC}"
        ;;

    2)
        sudo -u geth_holesky /home/geth_holesky/eth-docker/ethd down -v
        rm -rf /home/geth_holesky
        sudo deluser --remove-home geth_holesky
        echo -e "${RED}RPC deleted.${NC}"
        ;;

    *)
        echo -e "${RED}The wrong choice. Please enter a number from 1 to 2!${NC}"
        ;;
esac
