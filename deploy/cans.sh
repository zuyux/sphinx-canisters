#!/bin/bash
export SPHINX_SECMAN=$(dfx canister id secman)
export SPHINX_CEREBELLUM=$(dfx canister id cerebellum)

dfx deploy backend --argument="(principal \"${SPHINX_SECMAN}\", principal \"${SPHINX_CEREBELLUM}\")"
