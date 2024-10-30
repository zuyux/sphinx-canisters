#!/bin/bash
export SPHINX_SECMAN=$(dfx canister id sec)
export SPHINX_CEREBELLUM=$(dfx canister id gen)

dfx deploy backend --argument="(principal \"${SPHINX_SEC}\", principal \"${SPHINX_GEN}\")"
