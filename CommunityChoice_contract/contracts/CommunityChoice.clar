
;; title: CommunityChoice
;; version: 1.0.0
;; summary: A voting system for neighborhood association decisions
;; description: Smart contract enabling secure, transparent voting on community proposals

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u101))
(define-constant ERR-PROPOSAL-EXPIRED (err u102))
(define-constant ERR-ALREADY-VOTED (err u103))
(define-constant ERR-PROPOSAL-NOT-ACTIVE (err u104))
(define-constant ERR-INVALID-VOTING-PERIOD (err u105))
(define-constant ERR-NOT-MEMBER (err u106))

;; Contract owner and admin
(define-constant CONTRACT-OWNER tx-sender)

;; Data variables
(define-data-var proposal-counter uint u0)

;; Data maps
;; Members registry
(define-map members principal bool)

;; Proposal details
(define-map proposals 
    uint 
    {
        title: (string-ascii 100),
        description: (string-ascii 500),
        creator: principal,
        start-height: uint,
        end-height: uint,
        yes-votes: uint,
        no-votes: uint,
        active: bool
    }
)

;; Track who voted on which proposal
(define-map votes {proposal-id: uint, voter: principal} bool)

;; Member management functions
(define-public (add-member (member principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (ok (map-set members member true))
    )
)

(define-public (remove-member (member principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (ok (map-delete members member))
    )
)

;; Proposal creation
(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (voting-period uint))
    (let
        (
            (proposal-id (+ (var-get proposal-counter) u1))
            (start-height block-height)
            (end-height (+ block-height voting-period))
        )
        (asserts! (default-to false (map-get? members tx-sender)) ERR-NOT-MEMBER)
        (asserts! (> voting-period u0) ERR-INVALID-VOTING-PERIOD)
        
        (map-set proposals proposal-id
            {
                title: title,
                description: description,
                creator: tx-sender,
                start-height: start-height,
                end-height: end-height,
                yes-votes: u0,
                no-votes: u0,
                active: true
            }
        )
        
        (var-set proposal-counter proposal-id)
        (ok proposal-id)
    )
)

;; Voting function
(define-public (vote (proposal-id uint) (vote-yes bool))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
            (vote-key {proposal-id: proposal-id, voter: tx-sender})
        )
        (asserts! (default-to false (map-get? members tx-sender)) ERR-NOT-MEMBER)
        (asserts! (get active proposal) ERR-PROPOSAL-NOT-ACTIVE)
        (asserts! (<= block-height (get end-height proposal)) ERR-PROPOSAL-EXPIRED)
        (asserts! (is-none (map-get? votes vote-key)) ERR-ALREADY-VOTED)
        
        ;; Record the vote
        (map-set votes vote-key true)
        
        ;; Update vote counts
        (if vote-yes
            (map-set proposals proposal-id
                (merge proposal {yes-votes: (+ (get yes-votes proposal) u1)})
            )
            (map-set proposals proposal-id
                (merge proposal {no-votes: (+ (get no-votes proposal) u1)})
            )
        )
        
        (ok true)
    )
)

;; Close proposal (can be called by creator or admin)
(define-public (close-proposal (proposal-id uint))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
        )
        (asserts! 
            (or 
                (is-eq tx-sender (get creator proposal))
                (is-eq tx-sender CONTRACT-OWNER)
            ) 
            ERR-NOT-AUTHORIZED
        )
        (asserts! (get active proposal) ERR-PROPOSAL-NOT-ACTIVE)
        
        (ok (map-set proposals proposal-id
            (merge proposal {active: false})
        ))
    )
)

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (is-member (address principal))
    (default-to false (map-get? members address))
)

(define-read-only (has-voted (proposal-id uint) (voter principal))
    (is-some (map-get? votes {proposal-id: proposal-id, voter: voter}))
)

(define-read-only (get-proposal-counter)
    (var-get proposal-counter)
)

(define-read-only (get-proposal-result (proposal-id uint))
    (match (map-get? proposals proposal-id)
        proposal 
        (let
            (
                (yes-votes (get yes-votes proposal))
                (no-votes (get no-votes proposal))
                (total-votes (+ yes-votes no-votes))
            )
            (some {
                proposal-id: proposal-id,
                yes-votes: yes-votes,
                no-votes: no-votes,
                total-votes: total-votes,
                passed: (> yes-votes no-votes),
                active: (get active proposal)
            })
        )
        none
    )
)

;; Initialize contract owner as first member
(map-set members CONTRACT-OWNER true)
