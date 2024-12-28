# FarmTrace - Clarity Smart Contract for Managing and Sharing Recipes

## Overview

FarmTrace is a Clarity smart contract designed to manage, share, and update recipes. It includes features such as token rewards for adding recipes, sharing recipes with other users, deleting recipes, and updating recipe names. The contract allows users to interact with their recipes through functions to add, update, delete, and share them, while rewarding them with tokens for their contributions.

## Features

- **Add Multiple Recipes**: Allows a user to add a list of recipes in a batch.
- **Add Recipe**: Allows a user to add a single recipe and receive a token reward.
- **Share Recipe**: Enables a user to share their recipe with another user.
- **Delete Recipe**: Allows a user to delete their recipe.
- **Update Recipe**: Allows a user to update the name of an existing recipe.
- **View Recipe**: Retrieve a specific recipe by user.
- **View Token Balance**: View the user's current token balance.

## Contract Functions

### 1. `add-multiple-recipes(user principal, recipes-list (list 10 (string-utf8 50))))`
   - Adds multiple recipes for the user in one transaction.
   - Accepts a list of recipe names.
   - Returns `"Recipes added successfully"` on success.

### 2. `add-recipe(user principal, recipe-name (string-utf8 50))`
   - Adds a single recipe for the user.
   - Validates the recipe name length.
   - Rewards the user with a token.
   - Returns `"Recipe added successfully"` on success or error if the recipe already exists or if the input is invalid.

### 3. `share-recipe(user principal, recipe-name (string-utf8 50), recipient principal)`
   - Shares a recipe with another user.
   - Checks if the recipe exists and if it's already shared with the recipient.
   - Returns `"Recipe shared successfully"` on success or error if the recipe doesn't exist or is already shared.

### 4. `delete-recipe(user principal, recipe-name (string-utf8 50))`
   - Deletes the specified recipe for the user.
   - Returns `"Recipe deleted successfully"` on success or error if the recipe doesn't exist.

### 5. `update-recipe(user principal, old-recipe-name (string-utf8 50), new-recipe-name (string-utf8 50))`
   - Updates the name of an existing recipe.
   - Returns `"Recipe updated successfully"` on success or error if the recipe doesn't exist.

### 6. `get-recipe(user principal)`
   - Retrieves the recipe for the user.
   - Returns the recipe name and shared-with list if it exists.

### 7. `get-token-balance(user principal)`
   - Retrieves the user's current token balance.
   - Returns the balance (in tokens).

## Constants

- **ERR-ALREADY-EXISTS**: Error code for already existing recipes.
- **ERR-NOT-FOUND**: Error code when a recipe is not found.
- **ERR-INVALID-INPUT**: Error code for invalid input (e.g., incorrect recipe name length).
- **ERR-NO-PERMISSION**: Error code for insufficient permissions (not used in the current code).
- **MAX-RECIPE-LENGTH**: The maximum length for a recipe name (50 characters).

## Data Structures

- **recipes**: A map that stores recipes for each user. It contains the recipe name and a list of users it is shared with.
- **recipe-history**: A map that records the history of actions for each user (e.g., added, shared, deleted recipes).
- **recipe-token**: A map that tracks the token balance for each user.

## Usage

1. **Add a Recipe**: A user can add a recipe using the `add-recipe` function.
2. **Add Multiple Recipes**: A user can batch add multiple recipes using `add-multiple-recipes`.
3. **Share a Recipe**: A user can share a recipe with another user using `share-recipe`.
4. **Delete a Recipe**: A user can delete a recipe with `delete-recipe`.
5. **Update a Recipe**: A user can update the recipe name with `update-recipe`.
6. **View Recipes and Tokens**: Users can view their recipes and token balances.

## Example Transactions

1. **Add Recipe**: `add-recipe(user, "Apple Pie")`
   - Adds the recipe "Apple Pie" for the user and rewards them with a token.

2. **Share Recipe**: `share-recipe(user, "Apple Pie", recipient)`
   - Shares the "Apple Pie" recipe with another user.

3. **Delete Recipe**: `delete-recipe(user, "Apple Pie")`
   - Deletes the "Apple Pie" recipe from the user's account.

4. **Update Recipe**: `update-recipe(user, "Apple Pie", "Classic Apple Pie")`
   - Updates the recipe name from "Apple Pie" to "Classic Apple Pie."

5. **View Token Balance**: `get-token-balance(user)`
   - Retrieves the current token balance of the user.

## Security

- Recipe names are validated to ensure they do not exceed the maximum length of 50 characters.
- Recipes can only be deleted or updated by the user who created them.
- Tokens are awarded for adding recipes, and the balance is tracked for each user.

## License

MIT License.