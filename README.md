# Ethereum-Testnet_RPCs

### ✅ Geth RPC Requirements

| Network   | CPU (cores) | RAM (GB)       | Disk Usage (Geth Full Node) | Recommended Disk Type |
|-----------|-------------|----------------|------------------------------|------------------------|
| Holesky   | ≥ 6         | 16–32          | **~250 GB**                  | NVMe SSD               |
| Sepolia   | ≥ 6         | 16–32          | **~650 GB**                  | NVMe SSD               |
| Hoodi     | ≥ 6         | 16–32          | TBD (~10–30 GB estimated)    | NVMe SSD                    |

> ℹ️ These values reflect real disk usage from full Geth nodes with RPC enabled and active synchronization.  
> Plan for 20–30% overhead for growth and logs. Use SSD or NVMe only; HDDs are not supported.

## Holesky
```bash
curl -s -o HoleskyRPC.sh https://raw.githubusercontent.com/noderguru/Ethereum-Testnet_RPCs/main/HoleskyRPC.sh && chmod +x HoleskyRPC.sh && ./HoleskyRPC.sh
```
## Sepolia
```bash
curl -s -o SepoliaRPC.sh https://raw.githubusercontent.com/noderguru/Ethereum-Testnet_RPCs/main/SepoliaRPC.sh && chmod +x SepoliaRPC.sh && ./SepoliaRPC.sh
```
