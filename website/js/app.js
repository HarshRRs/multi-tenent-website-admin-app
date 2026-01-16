// Configuration
const API_BASE = 'http://localhost:5000/public';
// For demo purposes, we'll use a hardcoded restaurant ID or pull from URL
const urlParams = new URLSearchParams(window.location.search);
const restaurantId = urlParams.get('id') || '677692cf88c7f7663de646f9'; // Example ID

let currentConfig = null;
let currentMenu = [];
let cart = [];

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    fetchBranding();
    fetchMenu();
    setupEventListeners();
});

// 1. Fetch Branding & Apply
async function fetchBranding() {
    try {
        const response = await fetch(`${API_BASE}/config/${restaurantId}`);
        const config = await response.json();
        currentConfig = config;

        // Apply branding
        if (config.primaryColor) {
            document.documentElement.style.setProperty('--primary', config.primaryColor);
        }
        if (config.headline) {
            document.getElementById('hero-headline').textContent = config.headline;
        }
        if (config.subheadline) {
            document.getElementById('hero-subheadline').textContent = config.subheadline;
        }
        if (config.startButtonText) {
            document.getElementById('hero-btn-text').textContent = config.startButtonText;
        }
        if (config.heroImageUrl) {
            document.querySelector('.hero').style.backgroundImage = `url('${config.heroImageUrl}')`;
        }
    } catch (err) {
        console.error('Error fetching branding:', err);
    }
}

// 2. Fetch Menu & Render
async function fetchMenu() {
    try {
        const response = await fetch(`${API_BASE}/menu/${restaurantId}`);
        const categories = await response.json();
        currentMenu = categories;

        renderCategories(categories);
        renderMenuGrid(categories[0]?.products || []);
    } catch (err) {
        console.error('Error fetching menu:', err);
    }
}

function renderCategories(categories) {
    const container = document.getElementById('menu-categories');
    container.innerHTML = categories.map((cat, index) => `
        <button class="cat-btn ${index === 0 ? 'active' : ''}" onclick="selectCategory('${cat.id}', this)">
            ${cat.name}
        </button>
    `).join('');
}

function selectCategory(catId, btn) {
    // UI Update
    document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    // Filter Menu
    const category = currentMenu.find(c => c.id === catId);
    renderMenuGrid(category.products);
}

function renderMenuGrid(products) {
    const grid = document.getElementById('menu-grid');
    if (!products || products.length === 0) {
        grid.innerHTML = '<div class="empty-state">No items available in this category.</div>';
        return;
    }

    grid.innerHTML = products.map(product => `
        <div class="menu-card">
            <div class="menu-img" style="background-image: url('${product.imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=300&auto=format&fit=crop'}')"></div>
            <div class="menu-info">
                <h3>${product.name}</h3>
                <p>${product.description || ''}</p>
                <div class="menu-footer">
                    <span class="price">$${product.price.toFixed(2)}</span>
                    <button class="btn btn-primary" onclick="addToCart('${product.id}', '${product.name}', ${product.price})">Add to Order</button>
                </div>
            </div>
        </div>
    `).join('');
}

// 3. Cart Management
function addToCart(id, name, price) {
    const existing = cart.find(item => item.id === id);
    if (existing) {
        existing.quantity += 1;
    } else {
        cart.push({ id, name, price, quantity: 1 });
    }
    updateCartUI();
    // Optional: Auto-open cart or show toast
}

function updateCartUI() {
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    document.getElementById('cart-total-val').textContent = `$${total.toFixed(2)}`;

    // Update count on order button
    const count = cart.reduce((sum, item) => sum + item.quantity, 0);
    document.querySelector('.order-btn').textContent = `Checkout (${count})`;
}

async function placeOrder() {
    if (cart.length === 0) return alert('Your cart is empty');

    const customerName = prompt('Please enter your name for the order:');
    if (!customerName) return;

    try {
        const response = await fetch('http://localhost:5000/public/order', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                restaurantId,
                customerName: customerName,
                items: cart.map(i => ({ name: i.name, quantity: i.quantity, price: i.price })),
                totalAmount: cart.reduce((sum, item) => sum + (item.price * item.quantity), 0)
            })
        });

        if (response.ok) {
            alert('Order placed successfully! The kitchen is preparing your food.');
            cart = [];
            updateCartUI();
        } else {
            alert('Error placing order. Please try again.');
        }
    } catch (err) {
        alert('Could not connect to the restaurant server.');
    }
}

// 4. Reservation Handling
function setupEventListeners() {
    const resForm = document.getElementById('res-form');
    resForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const data = {
            restaurantId,
            customerName: document.getElementById('res-name').value,
            time: document.getElementById('res-time').value,
            partySize: document.getElementById('res-party').value,
            phone: document.getElementById('res-phone').value
        };

        try {
            const response = await fetch('http://localhost:5000/public/reservation', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                alert('Reservation confirmed! We look forward to seeing you.');
                resForm.reset();
            } else {
                alert('Error booking reservation. Please check availability.');
            }
        } catch (err) {
            alert('Could not connect to the reservation system.');
        }
    });
}
