# 🏛️ DAO Gobernada con Solidity + Foundry

Este proyecto representa una **DAO (Organización Autónoma Descentralizada)** construida con contratos inteligentes en Solidity y gobernada mediante el sistema de gobernanza de OpenZeppelin. Los miembros pueden crear propuestas, votar, y ejecutar acciones con un contrato `Timelock` para mayor seguridad ⏳.

---

## 📦 Contratos incluidos

- **Box.sol**:  
  Contrato simple con una variable `uint256` que puede ser modificada a través de propuestas aprobadas.

- **GovToken.sol**:  
  Token ERC20 con capacidades de gobernanza (`ERC20Votes`). Es el token usado para delegar votos y votar en propuestas.

- **MyGovernor.sol**:  
  Contrato de gobernanza que maneja las propuestas, la votación y la ejecución. Utiliza los estándares de OpenZeppelin.

- **Timelock.sol**:  
  Contrato que introduce un retardo (`minDelay`) entre la aprobación de una propuesta y su ejecución efectiva.

---

## 🧠 Flujo de gobernanza

1. Los usuarios **delegan** su poder de voto (`delegate()`).
2. Un miembro crea una **propuesta** (`propose()`).
3. Se lleva a cabo la **votación** (`castVote()`).
4. Si es aprobada, se **agenda en el Timelock**.
5. Luego del retardo, se puede **ejecutar** (`execute()`).

---

## 🧪 Pruebas con Foundry

Este proyecto incluye un archivo de pruebas:  
📁 `test/MyGovernorTest.t.sol`

### 🔧 Requisitos

- Tener instalado [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`, `cast`, etc.)

### ▶️ Instrucciones para correr el proyecto

```bash
# 1. Clona el repositorio
git clone <REPO_URL>
cd <nombre-del-proyecto>

# 2. Instala las dependencias (si las hay)
forge install

# 3. Compila los contratos
forge build

# 4. Ejecuta las pruebas
forge test
