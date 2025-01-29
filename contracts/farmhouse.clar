;; FarmTrace Smart Contract v2.0
;; Enhancements for functionality, performance, and security.

(define-map farm-records principal (buff 256)) ;; Stores farm data mapped to user
(define-map authorized-users principal bool)   ;; Tracks authorized users
(define-data-var total-farms uint u0)         ;; Total number of farms registered
(define-data-var owner principal tx-sender)   ;; Contract owner

;; Set the contract owner
(define-public (initialize (contract-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) (err u1))
        (ok (var-set owner contract-owner))
    )
)

;; Register a new farm
(define-public (register-farm (farm-data (buff 256)))
    (begin
        (asserts! (default-to false (map-get? authorized-users tx-sender)) (err u2))
        (map-set farm-records tx-sender farm-data)
        (var-set total-farms (+ (var-get total-farms) u1))
        (ok true)
    )
)

;; Fetch farm data
(define-read-only (get-farm (farmer principal))
    (ok (unwrap! (map-get? farm-records farmer) (err u3)))
)

;; Authorize a new user
(define-public (authorize-user (user principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) (err u4))
        (ok (map-set authorized-users user true))
    )
)

;; Deauthorize a user
(define-public (deauthorize-user (user principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) (err u5))
        (ok (map-delete authorized-users user))
    )
)

;; Fetch total farms registered
(define-read-only (get-total-farms)
    (ok (var-get total-farms))
)