# micro-finance-1
# Installation

This project is required NodeJS 8.x.x LTS.
Dependencies Packages

Microsoft build tools:

$ npm i -g -p windows-build-tools

Ganache

$ npm i -g ganache-cli truffle mkinterface

#Testing Open terminal at the root directory of project:

ganache cli

then in another terminal:

$ truffle migrate --reset && truffle test

# Migrate

cd contract

truffle.cmd migrate --network infura --reset

# Run Nodejs
cd node

node index.js
