# CommunityChoice

CommunityChoice is a decentralized voting system smart contract built on the Stacks blockchain for neighborhood associations and community organizations to make transparent, secure decisions.

## Overview

CommunityChoice enables community members to create proposals, vote on important decisions, and track voting results in a transparent and tamper-proof manner. The contract ensures only registered community members can participate in the voting process while maintaining complete transparency of all proposals and voting outcomes.

## Features

- **Member Management**: Add and remove community members with admin controls
- **Proposal Creation**: Members can create proposals with titles, descriptions, and custom voting periods
- **Secure Voting**: One vote per member per proposal with vote tracking
- **Time-bound Voting**: Proposals have configurable voting periods with automatic expiration
- **Transparent Results**: Public access to proposal details and voting results
- **Admin Controls**: Contract owner can manage members and close proposals
- **Vote Verification**: Check if members have already voted on specific proposals

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity
- **Version**: 1.0.0
- **Clarity Version**: 2
- **Epoch**: 2.5

### Contract Architecture

The contract uses the following data structures:

- **Members Map**: Tracks registered community members
- **Proposals Map**: Stores proposal details including voting counts
- **Votes Map**: Records individual votes to prevent double voting
- **Proposal Counter**: Maintains sequential proposal IDs

## Installation

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) CLI installed
- [Node.js](https://nodejs.org/) (v18 or higher)
- Stacks wallet for deployment

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd CommunityChoice
```

2. Navigate to the contract directory:
```bash
cd CommunityChoice_contract
```

3. Install dependencies:
```bash
npm install
```

4. Check contract syntax:
```bash
clarinet check
```

## Usage Examples

### Deploy Contract

```bash
clarinet deploy --network testnet
```

### Testing

Run the test suite:
```bash
npm test
```

Run tests with coverage:
```bash
npm run test:report
```

Watch for changes:
```bash
npm run test:watch
```

### Contract Interactions

#### Add a Member (Admin Only)
```clarity
(contract-call? .CommunityChoice add-member 'SP1MEMBER123...)
```

#### Create a Proposal (Members Only)
```clarity
(contract-call? .CommunityChoice create-proposal 
    "Street Light Installation" 
    "Proposal to install LED street lights on Main Street for improved safety" 
    u1000) ;; 1000 blocks voting period
```

#### Vote on a Proposal
```clarity
;; Vote Yes
(contract-call? .CommunityChoice vote u1 true)

;; Vote No
(contract-call? .CommunityChoice vote u1 false)
```

#### Get Proposal Details
```clarity
(contract-call? .CommunityChoice get-proposal u1)
```

#### Check Voting Results
```clarity
(contract-call? .CommunityChoice get-proposal-result u1)
```

## Contract Functions

### Public Functions

#### Member Management

- **`add-member(member: principal)`**
  - Adds a new member to the community
  - Restricted to contract owner
  - Returns: `(ok bool)`

- **`remove-member(member: principal)`**
  - Removes a member from the community
  - Restricted to contract owner
  - Returns: `(ok bool)`

#### Proposal Management

- **`create-proposal(title: string-ascii 100, description: string-ascii 500, voting-period: uint)`**
  - Creates a new proposal for voting
  - Restricted to community members
  - Returns: `(ok uint)` with proposal ID

- **`vote(proposal-id: uint, vote-yes: bool)`**
  - Casts a vote on a proposal
  - Restricted to community members who haven't voted on this proposal
  - Returns: `(ok bool)`

- **`close-proposal(proposal-id: uint)`**
  - Manually closes an active proposal
  - Can be called by proposal creator or contract owner
  - Returns: `(ok bool)`

### Read-Only Functions

- **`get-proposal(proposal-id: uint)`**
  - Returns complete proposal details
  - Returns: `(optional proposal-data)`

- **`is-member(address: principal)`**
  - Checks if an address is a registered member
  - Returns: `bool`

- **`has-voted(proposal-id: uint, voter: principal)`**
  - Checks if a member has voted on a specific proposal
  - Returns: `bool`

- **`get-proposal-counter()`**
  - Returns the current proposal counter
  - Returns: `uint`

- **`get-proposal-result(proposal-id: uint)`**
  - Returns detailed voting results for a proposal
  - Returns: `(optional {proposal-id, yes-votes, no-votes, total-votes, passed, active})`

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | ERR-NOT-AUTHORIZED | Caller not authorized for this action |
| u101 | ERR-PROPOSAL-NOT-FOUND | Proposal ID does not exist |
| u102 | ERR-PROPOSAL-EXPIRED | Voting period has ended |
| u103 | ERR-ALREADY-VOTED | Member has already voted on this proposal |
| u104 | ERR-PROPOSAL-NOT-ACTIVE | Proposal is not active |
| u105 | ERR-INVALID-VOTING-PERIOD | Voting period must be greater than 0 |
| u106 | ERR-NOT-MEMBER | Caller is not a registered member |

## Deployment Guide

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deploy --network testnet
```

### Mainnet Deployment

1. Configure your mainnet settings in `settings/Mainnet.toml`
2. Ensure you have sufficient STX for deployment costs
3. Deploy using Clarinet:
```bash
clarinet deploy --network mainnet
```

### Post-Deployment Setup

1. Add initial community members using the `add-member` function
2. Create your first proposal to test the system
3. Communicate the contract address to your community

## Security Notes

### Access Control
- Only the contract owner can add/remove members
- Only registered members can create proposals and vote
- Proposal creators and contract owner can close proposals

### Voting Integrity
- Each member can vote only once per proposal
- Votes are recorded immutably on the blockchain
- Voting periods are enforced automatically

### Best Practices
- Regularly audit member list for inactive members
- Set appropriate voting periods based on proposal complexity
- Encourage community participation in proposal creation
- Monitor proposal activity and results

### Known Limitations
- No vote delegation mechanism
- No quorum requirements
- Fixed voting options (yes/no only)
- No vote weighting based on stake or tenure

## Development

### Project Structure
```
CommunityChoice/
├── README.md
└── CommunityChoice_contract/
    ├── contracts/
    │   └── CommunityChoice.clar
    ├── tests/
    │   └── CommunityChoice.test.ts
    ├── settings/
    │   ├── Devnet.toml
    │   ├── Testnet.toml
    │   └── Mainnet.toml
    ├── Clarinet.toml
    ├── package.json
    └── vitest.config.js
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

### Testing Strategy

The contract includes comprehensive unit tests covering:
- Member management operations
- Proposal creation and validation
- Voting mechanics and restrictions
- Access control enforcement
- Error condition handling

## License

This project is licensed under the ISC License.

## Support

For technical support or questions about the CommunityChoice contract, please open an issue in the project repository.