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
(define-public (add-multiple-recipes (user principal) (recipes-list (list 10 (string-utf8 50))))
  (begin
    (map (lambda (recipe) (add-recipe user recipe)) recipes-list)
    (ok "Recipes added successfully")
  )
)

;; Function to add a single recipe
(define-public (add-recipe (user principal) (recipe-name (string-utf8 50)))
  (let ((recipe-data (default-to { name: "", shared-with: (list) } (map-get? recipes { user: user }))))
    (if (> (len recipe-name) MAX-RECIPE-LENGTH)
      (err ERR-INVALID-INPUT)
      (if (is-eq (get name recipe-data) recipe-name)
        (err ERR-ALREADY-EXISTS)
        (begin
          (map-set recipes { user: user } { name: recipe-name, shared-with: (list) })
          (map-set recipe-token 
            { user: user } 
            { balance: (+ (default-to u0 (get balance (map-get? recipe-token { user: user }))) u1) }
          )
          (ok "Recipe added successfully")
        )
      )
    )
  )
)

;; Function to share a recipe
(define-public (share-recipe (user principal) (recipe-name (string-utf8 50)) (recipient principal))
  (let ((recipe-data (default-to { name: "", shared-with: (list) } (map-get? recipes { user: user }))))
    (if (is-eq (get name recipe-data) "")
      (err ERR-NOT-FOUND)
      (if (is-some (index-of (get shared-with recipe-data) recipient))
        (err ERR-ALREADY-EXISTS)
        (begin
          (map-set recipes 
            { user: user } 
            { name: recipe-name, shared-with: (unwrap-panic (as-max-len? (append (get shared-with recipe-data) recipient) u10)) }
          )
          (ok "Recipe shared successfully")
        )
      )
    )
  )
)

;; Function to delete a recipe
(define-public (delete-recipe (user principal) (recipe-name (string-utf8 50)))
  (let ((recipe-data (default-to { name: "", shared-with: (list) } (map-get? recipes { user: user }))))
    (if (is-eq (get name recipe-data) recipe-name)
      (begin
        (map-delete recipes { user: user })
        (ok "Recipe deleted successfully")
      )
      (err ERR-NOT-FOUND)
    )
  )
)

;; Function to update a recipe
(define-public (update-recipe (user principal) (old-recipe-name (string-utf8 50)) (new-recipe-name (string-utf8 50)))
  (let ((recipe-data (default-to { name: "", shared-with: (list) } (map-get? recipes { user: user }))))
    (if (is-eq (get name recipe-data) old-recipe-name)
      (begin
        (map-set recipes 
          { user: user } 
          { name: new-recipe-name, shared-with: (get shared-with recipe-data) }
        )
        (ok "Recipe updated successfully")
      )
      (err ERR-NOT-FOUND)
    )
  )
)

;; Function to get a recipe
(define-read-only (get-recipe (user principal))
  (default-to { name: "", shared-with: (list) } (map-get? recipes { user: user }))
)

;; Function to get token balance
(define-read-only (get-token-balance (user principal))
  (default-to { balance: u0 } (map-get? recipe-token { user: user }))
)

