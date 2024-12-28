;; FarmTrace - A Clarity smart contract for managing and sharing recipes with advanced features

(define-constant ERR-ALREADY-EXISTS u1)
(define-constant ERR-NOT-FOUND u2)
(define-constant ERR-INVALID-INPUT u3)
(define-constant ERR-NO-PERMISSION u4)

(define-constant MAX-RECIPE-LENGTH u50)

(define-map recipes principal (tuple (name (string-utf8 50)) (shared-with (list 10 principal))))
(define-map recipe-history principal (list 50 (string-utf8 80)))
(define-map recipe-token principal u1) ;; Token balance for users

;; Add multiple recipes in a batch
(define-public (add-multiple-recipes (user principal) (recipes-list (list 10 (string-utf8 50)))))
  (begin
    (map-set recipes user (map (lambda (recipe) (add-recipe user recipe)) recipes-list))
    (ok "Recipes added successfully")
  ))

;; Add a recipe with token reward system
(define-public (add-recipe (user principal) (recipe-name (string-utf8 50)))
  (let ((name-length (len recipe-name)))
    (if (and (> name-length u0) (<= name-length MAX-RECIPE-LENGTH))
        (if (is-none (map-get? recipes user))
            (begin
              (map-set recipes user { name: recipe-name, shared-with: [] })
              (map-insert recipe-history user [(concat "Added recipe: " recipe-name)])
              (map-set recipe-token user (+ (get recipe-token user 0) u1)) ;; Reward user with a token
              (ok "Recipe added successfully"))
            (err ERR-ALREADY-EXISTS))
        (err ERR-INVALID-INPUT))))

;; Share a recipe with another user
(define-public (share-recipe (user principal) (recipe-name (string-utf8 50)) (recipient principal))
  (let ((recipe (map-get? recipes user)))
    (if (is-some recipe)
        (let ((recipe-data (unwrap! recipe (err ERR-NOT-FOUND))))
          (if (not (contains? recipe-data.shared-with recipient))
              (begin
                (map-set recipes user (tuple (name recipe-name) (shared-with (cons recipient recipe-data.shared-with))))
                (map-insert recipe-history user [(concat "Shared recipe " recipe-name " with " (to-string recipient))])
                (ok "Recipe shared successfully"))
              (err ERR-ALREADY-EXISTS)))
        (err ERR-NOT-FOUND))))

;; Delete a recipe
(define-public (delete-recipe (user principal) (recipe-name (string-utf8 50)))
  (let ((recipe (map-get? recipes user)))
    (if (is-some recipe)
        (let ((recipe-data (unwrap! recipe (err ERR-NOT-FOUND))))
          (if (= recipe-data.name recipe-name)
              (begin
                (map-delete recipes user)
                (map-insert recipe-history user [(concat "Deleted recipe: " recipe-name)])
                (ok "Recipe deleted successfully"))
              (err ERR-NOT-FOUND)))
        (err ERR-NOT-FOUND))))

;; Update a recipe's name
(define-public (update-recipe (user principal) (old-recipe-name (string-utf8 50)) (new-recipe-name (string-utf8 50)))
  (let ((recipe (map-get? recipes user)))
    (if (is-some recipe)
        (let ((recipe-data (unwrap! recipe (err ERR-NOT-FOUND))))
          (if (= recipe-data.name old-recipe-name)
              (begin
                (map-set recipes user (tuple (name new-recipe-name) recipe-data.shared-with))
                (map-insert recipe-history user [(concat "Updated recipe name from " old-recipe-name " to " new-recipe-name)])
                (ok "Recipe updated successfully"))
              (err ERR-NOT-FOUND)))
        (err ERR-NOT-FOUND))))

;; Other utility functions (optional)
(define-public (get-recipe (user principal)) 
  (let ((recipe (map-get? recipes user)))
    (if (is-some recipe)
        (ok (unwrap! recipe (err ERR-NOT-FOUND)))
        (err ERR-NOT-FOUND))))

(define-public (get-token-balance (user principal)) 
  (ok (get recipe-token user 0)))
