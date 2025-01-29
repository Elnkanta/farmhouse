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
        ;; Validate the new owner is not the zero address
        (asserts! (not (is-eq contract-owner 'SP000000000000000000002Q6VF78)) (err u6))
        (ok (var-set owner contract-owner))
    )
)

;; Register a new farm
(define-public (register-farm (farm-data (buff 256)))
    (begin
        (asserts! (default-to false (map-get? authorized-users tx-sender)) (err u2))
        ;; Validate farm data is not empty
        (asserts! (> (len farm-data) u0) (err u7))
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
        ;; Validate user is not the zero address and not already authorized
        (asserts! (and 
            (not (is-eq user 'SP000000000000000000002Q6VF78))
            (not (default-to false (map-get? authorized-users user)))
        ) (err u8))
        (ok (map-set authorized-users user true))
    )
)

;; Deauthorize a user
(define-public (deauthorize-user (user principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) (err u5))
        ;; Validate user exists and is not the owner
        (asserts! (and
            (default-to false (map-get? authorized-users user))
            (not (is-eq user (var-get owner)))
        ) (err u9))
        (ok (map-delete authorized-users user))
    )
)

;; Fetch total farms registered
(define-read-only (get-total-farms)
    (ok (var-get total-farms))
)