#!/bin/bash

set -e

echo "📂 Erstelle Verzeichnisse falls nicht vorhanden..."
mkdir -p frontend/src/pages
mkdir -p seed
mkdir -p backend/routes

echo "📥 Dateien kopieren..."

# Makefile
cat <<EOF > Makefile
.PHONY: setup seed up

setup:
	@echo "🔧 Installiere Node Modules..."
	cd frontend && npm install
	cd backend && npm install

seed:
	@echo "🗄️ Seed-Datenbank mit Demo-Daten..."
	psql -U postgres -d agrarhandel -f seed/seed_demo.sql
	psql -U postgres -d agrarhandel -f seed/seed_orders.sql

up:
	@echo "🐳 Starte Docker Container..."
	docker-compose up --build -d

all: setup seed up
EOF

# seed_orders.sql
cat <<EOF > seed/seed_orders.sql
-- Beispiel Bestellungen
INSERT INTO orders (product_id, buyer_id, quantity, unit, price, delivery_method, incoterm, tracking_url)
VALUES
(1, 3, 1000, 'kg', 0.35, 'Seefracht', 'FOB', 'http://tracking.com/abc123'),
(2, 3, 500, 'kg', 0.55, 'Luftfracht', 'CIF', 'http://tracking.com/xyz456'),
(3, 3, 200, 'l', 1.50, 'Straßentransport', 'DAP', '');

-- Dummy Nachrichten für Nutzer 3 (Käufer)
INSERT INTO messages (sender_id, receiver_id, message)
VALUES
(3, 2, 'Wann erfolgt die Lieferung von Weizen?'),
(2, 3, 'Wir verschicken nächste Woche.');
EOF

# AdminDashboard.jsx
cat <<EOF > frontend/src/pages/AdminDashboard.jsx
import React, { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts';
import api from '../api'; // Axios-Instance oder fetch-wrapper

export default function AdminDashboard() {
  const [stats, setStats] = useState({
    userCount: 0,
    orderCount: 0,
    productCount: 0,
    totalSales: 0,
    salesByProduct: [],
  });

  useEffect(() => {
    api.get('/stats/overview').then(res => setStats(res.data));
    api.get('/stats/sales-by-product').then(res => setStats(prev => ({ ...prev, salesByProduct: res.data })));
  }, []);

  return (
    <div>
      <h2>Admin Dashboard</h2>
      <div>
        <p>Benutzer: {stats.userCount}</p>
        <p>Bestellungen: {stats.orderCount}</p>
        <p>Produkte: {stats.productCount}</p>
        <p>Umsatz: {stats.totalSales} EUR</p>
      </div>

      <h3>Umsatz nach Produkt</h3>
      <BarChart width={600} height={300} data={stats.salesByProduct}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="title" />
        <YAxis />
        <Tooltip />
        <Legend />
        <Bar dataKey="totalSales" fill="#8884d8" />
      </BarChart>
    </div>
  );
}
EOF

# Backend stats.js route
cat <<EOF > backend/routes/stats.js
const express = require('express');
const router = express.Router();
const pool = require('../db');
const { auth, requireRole } = require('../middleware/auth');

router.get('/sales-by-product', auth, requireRole('admin'), async (req, res) => {
  const result = await pool.query(\`
    SELECT p.title, SUM(o.quantity * o.price) AS "totalSales"
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY p.title
    ORDER BY "totalSales" DESC
  \`);
  res.json(result.rows);
});

module.exports = router;
EOF

echo "✅ Dateien erfolgreich eingefügt."

echo "🚀 Jetzt kannst du mit 'make all' das Projekt setup, seed und starten."

echo "💡 Tipp: Falls du recharts noch nicht hast, installiere im frontend mit:"
echo "    cd frontend && npm install recharts"

