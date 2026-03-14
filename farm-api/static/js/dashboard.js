/**
 * AutoFarm Dashboard — Client-side logic
 *
 * Fetches sensor data and action history from the farm-api,
 * updates the sensor cards and chart every POLL_INTERVAL ms.
 */

// ── Configuration ─────────────────────────────────────────────────────
const API_BASE = '';          // Same origin as farm-api
const POLL_INTERVAL = 10_000; // 10 seconds

// ── Sensor display metadata ───────────────────────────────────────────
const SENSOR_META = {
    temperature: {
        label: 'Température',
        icon: '🌡️',
        unit: '°C',
        color: '#f59e0b',
        colorRgba: 'rgba(245, 158, 11, 0.15)',
        idealMin: 18,
        idealMax: 26,
    },
    humidity: {
        label: 'Humidité Air',
        icon: '💧',
        unit: '%',
        color: '#3b82f6',
        colorRgba: 'rgba(59, 130, 246, 0.15)',
        idealMin: 60,
        idealMax: 70,
    },
    soil_moisture: {
        label: 'Humidité Sol',
        icon: '🌍',
        unit: '%',
        color: '#06b6d4',
        colorRgba: 'rgba(6, 182, 212, 0.15)',
        idealMin: 55,
        idealMax: 70,
    },
};

// ── Actuator display metadata ─────────────────────────────────────────
const ACTUATOR_META = {
    pump: { label: 'Pompe', icon: '💦', cssClass: 'pump' },
    fan: { label: 'Ventilateur', icon: '🌀', cssClass: 'fan' },
    light: { label: 'Lumière', icon: '💡', cssClass: 'light' },
};

// ── State ─────────────────────────────────────────────────────────────
let historyChart = null;
let currentLimit = 50;

// ══════════════════════════════════════════════════════════════════════
// Helpers
// ══════════════════════════════════════════════════════════════════════

/**
 * Formats a UNIX timestamp to a HH:MM time string.
 * @param {number} ts - UNIX timestamp in seconds.
 * @returns {string} Formatted time.
 */
function formatTime(ts) {
    const d = new Date(ts * 1000);
    return d.toLocaleTimeString('fr-FR', {
        hour: '2-digit',
        minute: '2-digit',
    });
}

/**
 * Formats a UNIX timestamp to a relative time string (e.g. "il y a 5 min").
 * @param {number} ts - UNIX timestamp in seconds.
 * @returns {string} Relative time string.
 */
function timeAgo(ts) {
    const diff = Math.floor(Date.now() / 1000) - ts;
    if (diff < 60) return "à l'instant";
    if (diff < 3600) return `il y a ${Math.floor(diff / 60)} min`;
    if (diff < 86400) return `il y a ${Math.floor(diff / 3600)}h`;
    return `il y a ${Math.floor(diff / 86400)}j`;
}

/**
 * Evaluates a sensor value against its ideal range and returns
 * a status label + CSS class.
 * @param {string} sensor - Sensor key (e.g. "temperature").
 * @param {number} value  - Current sensor value.
 * @returns {{ label: string, cssClass: string }}
 */
function evaluateStatus(sensor, value) {
    const meta = SENSOR_META[sensor];
    if (!meta) return { label: '—', cssClass: 'ok' };

    const margin = (meta.idealMax - meta.idealMin) * 0.3;
    if (value >= meta.idealMin && value <= meta.idealMax) {
        return { label: 'Optimal', cssClass: 'ok' };
    }
    if (value >= meta.idealMin - margin && value <= meta.idealMax + margin) {
        return { label: 'Attention', cssClass: 'warning' };
    }
    return { label: 'Critique', cssClass: 'danger' };
}

// ══════════════════════════════════════════════════════════════════════
// Renderers
// ══════════════════════════════════════════════════════════════════════

/**
 * Renders sensor cards into the #sensorGrid element.
 * @param {Array} sensors - Array of sensor objects from /sensors/latest.
 */
function renderSensorCards(sensors) {
    const grid = document.getElementById('sensorGrid');

    // Build a lookup map: sensor name → latest reading
    const sensorMap = {};
    sensors.forEach(s => { sensorMap[s.sensor] = s; });

    let html = '';
    for (const [key, meta] of Object.entries(SENSOR_META)) {
        const data = sensorMap[key];
        const value = data ? data.value.toFixed(1) : '--';
        const status = data
            ? evaluateStatus(key, data.value)
            : { label: 'N/A', cssClass: 'warning' };

        html += `
            <div class="sensor-card" data-sensor="${key}">
                <div class="card-header">
                    <div class="card-label">
                        <span class="card-icon">${meta.icon}</span>
                        <span class="card-name">${meta.label}</span>
                    </div>
                    <span class="card-status ${status.cssClass}">${status.label}</span>
                </div>
                <div class="card-value">
                    ${value}<span class="unit">${meta.unit}</span>
                </div>
                <div class="card-range">
                    Idéal : ${meta.idealMin}–${meta.idealMax}${meta.unit}
                </div>
            </div>
        `;
    }
    grid.innerHTML = html;
}

/**
 * Renders the recent actions list into #actionsList.
 * @param {Array} actions - Array of action objects from /actuators/history.
 */
function renderActions(actions) {
    const list = document.getElementById('actionsList');

    if (!actions || actions.length === 0) {
        list.innerHTML = '<div class="empty-state">Aucune action récente</div>';
        return;
    }

    let html = '';
    actions.forEach(a => {
        const meta = ACTUATOR_META[a.actuator] || {
            label: a.actuator,
            icon: '⚙️',
            cssClass: '',
        };

        html += `
            <div class="action-item">
                <div class="action-icon ${meta.cssClass}">${meta.icon}</div>
                <div class="action-details">
                    <div class="action-name">${meta.label}</div>
                    <div class="action-command">${a.command}</div>
                </div>
                <div class="action-meta">
                    <div class="action-time">${timeAgo(a.ts)}</div>
                    <span class="action-source">${a.source}</span>
                </div>
            </div>
        `;
    });
    list.innerHTML = html;
}

// ══════════════════════════════════════════════════════════════════════
// Chart
// ══════════════════════════════════════════════════════════════════════

/**
 * Fetches history for all sensors and renders/updates the chart.
 * @param {number} limit - Number of data points per sensor.
 */
async function loadHistory(limit) {
    const datasets = [];

    for (const [key, meta] of Object.entries(SENSOR_META)) {
        try {
            const res = await fetch(
                `${API_BASE}/sensors/history/${key}?limit=${limit}`
            );
            const data = await res.json();

            // API returns newest first — reverse for chronological order
            data.reverse();

            datasets.push({
                label: meta.label,
                data: data.map(d => ({
                    x: new Date(d.ts * 1000),
                    y: d.value,
                })),
                borderColor: meta.color,
                backgroundColor: meta.colorRgba,
                borderWidth: 2,
                pointRadius: 0,
                pointHoverRadius: 4,
                tension: 0.35,
                fill: true,
            });
        } catch (err) {
            console.warn(`[Dashboard] History fetch failed for ${key}:`, err);
        }
    }

    renderChart(datasets);
}

/**
 * Creates or updates the Chart.js line chart instance.
 * @param {Array} datasets - Chart.js dataset objects.
 */
function renderChart(datasets) {
    const ctx = document.getElementById('historyChart');

    // If chart already exists, update data in-place (no flicker)
    if (historyChart) {
        historyChart.data.datasets = datasets;
        historyChart.update('none');
        return;
    }

    historyChart = new Chart(ctx, {
        type: 'line',
        data: { datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false,
            },
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        color: '#94a3b8',
                        font: { family: 'Inter', size: 12 },
                        boxWidth: 12,
                        padding: 16,
                    },
                },
                tooltip: {
                    backgroundColor: '#1e293b',
                    titleColor: '#e2e8f0',
                    bodyColor: '#94a3b8',
                    borderColor: '#334155',
                    borderWidth: 1,
                    cornerRadius: 8,
                    padding: 10,
                    titleFont: { family: 'Inter', weight: '600' },
                    bodyFont: { family: 'Inter' },
                    callbacks: {
                        title: (items) => {
                            if (items.length > 0) {
                                return items[0].raw.x.toLocaleTimeString(
                                    'fr-FR',
                                    {
                                        hour: '2-digit',
                                        minute: '2-digit',
                                        second: '2-digit',
                                    }
                                );
                            }
                            return '';
                        },
                    },
                },
            },
            scales: {
                x: {
                    type: 'timeseries',
                    time: {
                        displayFormats: {
                            minute: 'HH:mm',
                            hour: 'HH:mm',
                        },
                    },
                    grid: { color: 'rgba(255, 255, 255, 0.04)' },
                    ticks: {
                        color: '#64748b',
                        font: { family: 'Inter', size: 11 },
                        maxTicksLimit: 10,
                    },
                },
                y: {
                    grid: { color: 'rgba(255, 255, 255, 0.04)' },
                    ticks: {
                        color: '#64748b',
                        font: { family: 'Inter', size: 11 },
                    },
                },
            },
        },
    });
}

// ══════════════════════════════════════════════════════════════════════
// Data Fetching
// ══════════════════════════════════════════════════════════════════════

/**
 * Sets the online/offline status indicator in the header.
 * @param {boolean} online - Whether the API is reachable.
 */
function setOnline(online) {
    const dot = document.getElementById('statusDot');
    const text = document.getElementById('statusText');

    if (online) {
        dot.className = 'status-dot';
        text.textContent = 'En ligne';
    } else {
        dot.className = 'status-dot offline';
        text.textContent = 'Hors ligne';
    }
}

/**
 * Fetches the global /status endpoint and updates all UI components.
 */
async function fetchStatus() {
    try {
        const res = await fetch(`${API_BASE}/status`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();

        // Update connection indicator
        setOnline(true);
        document.getElementById('lastUpdate').textContent =
            `· mis à jour ${formatTime(data.ts)}`;

        // Render sensor cards and actions list
        renderSensorCards(data.sensors);
        renderActions(data.last_actions);
    } catch (err) {
        console.error('[Dashboard] Fetch error:', err);
        setOnline(false);
    }
}

// ══════════════════════════════════════════════════════════════════════
// Event Listeners
// ══════════════════════════════════════════════════════════════════════

// Period toggle buttons (1h / 6h / 24h)
document.querySelectorAll('.chart-period button').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.chart-period button')
            .forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        currentLimit = parseInt(btn.dataset.limit, 10);
        loadHistory(currentLimit);
    });
});

// Manual refresh button
document.getElementById('refreshBtn').addEventListener('click', async () => {
    const btn = document.getElementById('refreshBtn');
    btn.style.opacity = '0.5';
    btn.style.pointerEvents = 'none';
    
    await fetchStatus();
    await loadHistory(currentLimit);
    
    setTimeout(() => {
        btn.style.opacity = '1';
        btn.style.pointerEvents = 'auto';
    }, 500);
});

// ══════════════════════════════════════════════════════════════════════
// Init & Polling
// ══════════════════════════════════════════════════════════════════════

/**
 * Bootstraps the dashboard and starts periodic polling.
 */
async function init() {
    await fetchStatus();
    await loadHistory(currentLimit);

    setInterval(async () => {
        await fetchStatus();
        await loadHistory(currentLimit);
    }, POLL_INTERVAL);
}

init();
