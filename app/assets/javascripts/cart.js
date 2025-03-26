// app/assets/javascripts/cart.js

/** 
 * Retrieves a specific cookie by name.
 * @param {string} cname - The name of the cookie to retrieve.
 * @returns {string} - The value of the cookie or an empty string if not found.
 */
function getCookie(cname) {
  // Define the cookie name with an equals sign
  let name = cname + "=";
  // Decode the cookie string
  let decodedCookie = decodeURIComponent(document.cookie);
  // Split the cookies into an array
  let ca = decodedCookie.split(';');
  // Iterate through the array of cookies
  for (let i = 0; i < ca.length; i++) {
      // Get the current cookie
      let c = ca[i];
      // Remove leading spaces
      while (c.charAt(0) == ' ') {
          c = c.substring(1);
      }
      // Check if the cookie starts with the specified name
      if (c.indexOf(name) == 0) {
          // Return the value of the cookie
          return c.substring(name.length, c.length);
      }
  }
  // Return an empty string if the cookie is not found
  return "";
}

/** 
* Creates a new cart cookie with default values.
*/
function createCartCookie() {
  // Initialize the cart object with default values
  let cart = {
      ids: [], // Array to store item IDs
      qty: {}, // Object to store item quantities
      costs: {}, // Object to store item costs
      savings: {}, // Object to store item savings
      total: 0 // Total cost of the cart
  };
  // Convert the cart object to a JSON string
  let cartString = JSON.stringify(cart);
  // Create a new date object
  let date = new Date();
  // Set the cookie to expire in 7 days
  date.setTime(date.getTime() + (7 * 24 * 60 * 60 * 1000));
  // Format the expiration date for the cookie
  let expires = "; expires=" + date.toUTCString();
  // Create the cookie with the cart data
  document.cookie = "cart=" + cartString + expires + "; path=/";
}

/** 
* Adds an item to the cart.
* @param {number} ID - The ID of the item to add.
* @param {number} cost - The cost of the item.
* @param {number} [savings=0] - The savings on the item (default is 0).
*/
function addToCart(ID, cost, savings = 0) {
  // Check if the cart cookie exists; if not, create it
  if (getCookie('cart') == "") {
      createCartCookie();
  }

  // Parse the cart cookie into a JavaScript object
  let cart = JSON.parse(getCookie('cart'));

  // Check if the item is not already in the cart
  if (!cart.ids.includes(ID)) {
      // Add the item ID to the cart
      cart.ids.push(ID);
      // Initialize the quantity for the item
      cart.qty[ID] = 1;
      // Store the cost of the item
      cart.costs[ID] = cost;
      // Store the savings for the item
      cart.savings[ID] = savings;
  } else {
      // Increment the quantity of the item if it already exists in the cart
      cart.qty[ID]++;
  }

  // Update the total cost of the cart
  cart.total += (cost - savings);
  // Round the total to 2 decimal places
  cart.total = Math.round(cart.total * 100) / 100;

  // Convert the updated cart object to a JSON string
  let cartString = JSON.stringify(cart);
  // Create a new date object
  let date = new Date();
  // Set the cookie to expire in 7 days
  date.setTime(date.getTime() + (7 * 24 * 60 * 60 * 1000));
  // Format the expiration date for the cookie
  let expires = "; expires=" + date.toUTCString();
  // Update the cart cookie with the new data
  document.cookie = "cart=" + cartString + expires + "; path=/";

  // Reload the page to reflect the updated cart
  window.location.reload();
}

/** 
* Updates the total cost displayed in the cart.
*/
function updateCartTotal() {
  // Retrieve the cart from localStorage or initialize an empty array
  let cart = JSON.parse(localStorage.getItem('cart')) || [];
  // Initialize the total cost to 0
  let total = 0;

  // Iterate through each item in the cart
  cart.forEach(item => {
      // Add the cost of the item (after applying the discount) to the total
      total += (item.cost - (item.cost * (item.discount / 100)));
  });

  // Round the total to 2 decimal places
  total = total.toFixed(2);
  // Update the cart total element in the DOM
  document.getElementById('cart-total').innerText = `$${total}`;
}

/** 
* Executes when the page is fully loaded.
* Updates the cart total on page load.
*/
window.onload = function() {
  // Call the function to update the cart total
  updateCartTotal();
};