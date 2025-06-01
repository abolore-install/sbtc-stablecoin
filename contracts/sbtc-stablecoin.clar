;; Title: SBTCoin - A Bitcoin-Backed Stablecoin Protocol
;; Author: StackBlitz Development Team
;;
;; Summary:
;; SBTCoin is a decentralized stablecoin protocol built on Stacks that uses Bitcoin as collateral.
;; Users can create vaults, deposit BTC collateral, and mint stablecoins against their collateral
;; at a controlled ratio to maintain price stability.
;;
;; The protocol implements risk management through collateralization requirements, liquidation
;; mechanisms, and a decentralized price oracle system to ensure protocol solvency.

;; TRAIT DEFINITIONS

(define-trait sip-010-token (
    (transfer
        (uint principal principal (optional (buff 34)))
        (response bool uint)
    )
    (get-name
        ()
        (response (string-ascii 32) uint)
    )
    (get-symbol
        ()
        (response (string-ascii 5) uint)
    )
    (get-decimals
        ()
        (response uint uint)
    )
    (get-balance
        (principal)
        (response uint uint)
    )
    (get-total-supply
        ()
        (response uint uint)
    )
))

;; ERROR CODES

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1001))
(define-constant ERR-INVALID-COLLATERAL (err u1002))
(define-constant ERR-UNDERCOLLATERALIZED (err u1003))
(define-constant ERR-ORACLE-PRICE-UNAVAILABLE (err u1004))
(define-constant ERR-LIQUIDATION-FAILED (err u1005))
(define-constant ERR-MINT-LIMIT-EXCEEDED (err u1006))
(define-constant ERR-INVALID-PARAMETERS (err u1007))
(define-constant ERR-UNAUTHORIZED-VAULT-ACTION (err u1008))

;; SECURITY CONSTANTS

(define-constant MAX-BTC-PRICE u1000000000000) ;; Maximum reasonable BTC price ($10M)
(define-constant MAX-TIMESTAMP u18446744073709551615) ;; Maximum uint timestamp
(define-constant CONTRACT-OWNER tx-sender)

;; PROTOCOL CONFIGURATION

(define-data-var stablecoin-name (string-ascii 32) "SBTCoin USD")
(define-data-var stablecoin-symbol (string-ascii 5) "SBTC")
(define-data-var total-supply uint u0)
(define-data-var collateralization-ratio uint u150) ;; 150% minimum collateral ratio
(define-data-var liquidation-threshold uint u125) ;; 125% liquidation threshold

;; PROTOCOL PARAMETERS

(define-data-var mint-fee-bps uint u50) ;; 0.5% minting fee
(define-data-var redemption-fee-bps uint u50) ;; 0.5% redemption fee
(define-data-var max-mint-limit uint u1000000) ;; Maximum tokens mintable per vault

;; ORACLE SYSTEM

(define-map btc-price-oracles
    principal
    bool
)
(define-map last-btc-price
    {
        timestamp: uint,
        price: uint,
    }
    uint
)

;; VAULT SYSTEM

(define-map vaults
    {
        owner: principal,
        id: uint,
    }
    {
        collateral-amount: uint,
        stablecoin-minted: uint,
        created-at: uint,
    }
)