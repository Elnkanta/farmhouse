;; FarmTrace - Clarity Smart Contract for Managing and Sharing Recipes

;; Define constants
(define-constant ERR-ALREADY-EXISTS (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-INPUT (err u102))
(define-constant ERR-NO-PERMISSION (err u103))
(define-constant MAX-RECIPE-LENGTH u50)

;; Define data maps
(define-map recipes 
  { user: principal } 
  { name: (string-utf8 50), shared-with: (list 10 principal) }
)

(define-map recipe-history 
  { user: principal } 
  { actions: (list 50 (string-utf8 50)) }
)

(define-map recipe-token 
  { user: principal } 
  { balance: uint }
)

;; Function to add multiple recipes
(define-public (add-multiple-recipes (recipes-list (list 10 (string-utf8 50))))
  (fold add-recipe-fold recipes-list (ok true))
)

;; Helper function for add-multiple-recipes
(define-private (add-recipe-fold (recipe (string-utf8 50)) (previous-result (response bool uint)))
  (match previous-result
    success (add-recipe recipe)
    error (err error)
  )
)

;; Function to add a single recipe
(define-public (add-recipe (recipe-name (string-utf8 50)))
  (let 
    (
      (current-recipe (map-get? recipes { user: tx-sender }))
      (current-balance (get balance (default-to { balance: u0 } (map-get? recipe-token { user: tx-sender }))))
    )
    (if (> (len recipe-name) MAX-RECIPE-LENGTH)
      ERR-INVALID-INPUT
      (match current-recipe
        existing-recipe (if (is-eq (get name existing-recipe) recipe-name)
          ERR-ALREADY-EXISTS
          (begin
            (map-set recipes { user: tx-sender } { name: recipe-name, shared-with: (list) })
            (map-set recipe-token { user: tx-sender } { balance: (+ current-balance u1) })
            (ok true)
          ))
        (begin
          (map-set recipes { user: tx-sender } { name: recipe-name, shared-with: (list) })
          (map-set recipe-token { user: tx-sender } { balance: (+ current-balance u1) })
          (ok true)
        )
      )
    )
  )
)

;; Function to share a recipe
(define-public (share-recipe (recipe-name (string-utf8 50)) (recipient principal))
  (let ((recipe-data (map-get? recipes { user: tx-sender })))
    (match recipe-data
      existing-recipe (if (is-eq (get name existing-recipe) recipe-name)
        (if (is-some (index-of (get shared-with existing-recipe) recipient))
          ERR-ALREADY-EXISTS
          (begin
            (map-set recipes 
              { user: tx-sender } 
              { 
                name: recipe-name, 
                shared-with: (unwrap-panic (as-max-len? (append (get shared-with existing-recipe) recipient) u10))
              }
            )
            (ok true)
          )
        )
        ERR-NOT-FOUND
      )
      ERR-NOT-FOUND
    )
  )
)

;; Function to delete a recipe
(define-public (delete-recipe (recipe-name (string-utf8 50)))
  (let ((recipe-data (map-get? recipes { user: tx-sender })))
    (match recipe-data
      existing-recipe (if (is-eq (get name existing-recipe) recipe-name)
        (begin
          (map-delete recipes { user: tx-sender })
          (ok true)
        )
        ERR-NOT-FOUND
      )
      ERR-NOT-FOUND
    )
  )
)

;; Function to update a recipe
(define-public (update-recipe (old-recipe-name (string-utf8 50)) (new-recipe-name (string-utf8 50)))
  (if (> (len new-recipe-name) MAX-RECIPE-LENGTH)
    ERR-INVALID-INPUT
    (let ((recipe-data (map-get? recipes { user: tx-sender })))
      (match recipe-data
        existing-recipe (if (is-eq (get name existing-recipe) old-recipe-name)
          (begin
            (map-set recipes 
              { user: tx-sender } 
              { name: new-recipe-name, shared-with: (get shared-with existing-recipe) }
            )
            (ok true)
          )
          ERR-NOT-FOUND
        )
        ERR-NOT-FOUND
      )
    )
  )
)

;; Function to get a recipe
(define-read-only (get-recipe)
  (map-get? recipes { user: tx-sender })
)

;; Function to get token balance
(define-read-only (get-token-balance)
  (default-to { balance: u0 } (map-get? recipe-token { user: tx-sender }))
)