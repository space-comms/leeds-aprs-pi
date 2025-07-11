/**
 * Leeds APRS Pi Dashboard - Main JavaScript Controller
 * 
 * Handles all the dashboard functionality and API communication
 */

class APRSDashboard {
    constructor() {
        // Backend API endpoint (running on port 8000)
        this.apiBase = 'http://localhost:8000/api';
        this.refreshInterval = 5000; // Refresh every 5 seconds
        this.isConnected = false;
        this.systemStatus = {};
        this.config = {};
        
        // Initialize dashboard when DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.init());
        } else {
            this.init();
        }
    }
    
    async init() {
        console.log('Starting up the Leeds APRS Pi Dashboard...');
        
        // Initialize UI components
        this.setupUI();
        
        // Load initial data
        await this.loadSystemStatus();
        await this.loadConfiguration();
        await this.loadLogs();
        
        // Start auto-refresh
        this.startAutoRefresh();
        
        // Bind event handlers
        this.bindEvents();
        
        console.log('Dashboard is ready to go!');
    }
    
    setupUI() {
        // Make sure all UI elements are in place
        this.ensureUIStructure();
        
        // Set initial connection status
        this.updateConnectionStatus(false);
        
        // Show loading state
        this.showLoadingState();
    }
    
    ensureUIStructure() {
        // Check if the main dashboard grid exists
        const dashboardGrid = document.querySelector('.dashboard-grid');
        if (!dashboardGrid) {
            console.error('Hmm, dashboard grid not found in HTML');
            return;
        }
    }
    
    async loadSystemStatus() {
        try {
            const response = await this.makeAPICall('/status');
            if (response) {
                this.systemStatus = response;
                this.updateSystemStatusDisplay();
                this.updateConnectionStatus(true);
            }
        } catch (error) {
            console.error('Couldn\'t load system status:', error);
            this.updateConnectionStatus(false);
            this.showError('Running in demo mode - backend API not responding');
        }
    }
    
    async loadConfiguration() {
        try {
            const response = await this.makeAPICall('/config');
            if (response) {
                this.config = response;
                this.updateConfigurationDisplay();
            }
        } catch (error) {
            console.error('Failed to load configuration:', error);
        }
    }
    
    async loadLogs() {
        try {
            const response = await this.makeAPICall('/logs');
            if (response) {
                this.updateLogsDisplay(response);
            }
        } catch (error) {
            console.error('Failed to load logs:', error);
        }
    }
    
    updateSystemStatusDisplay() {
        const status = this.systemStatus;
        
        // Update APRS status
        this.updateStatusIndicator('aprs', status.aprs || false);
        this.updateTextElement('aprs-text', status.aprs ? 'Running' : 'Stopped');
        
        // Update GPS status
        this.updateStatusIndicator('gps', status.gps || false);
        this.updateTextElement('gps-text', status.gps ? 'Active' : 'Inactive');
        
        // Update callsign
        this.updateTextElement('callsign', status.callsign || 'N0CALL');
        
        // Update uptime
        this.updateTextElement('uptime', this.formatUptime(status.uptime || 0));
        
        // Update packet counts
        this.updateTextElement('packets-sent', status.packets_sent || 0);
        this.updateTextElement('packets-received', status.packets_received || 0);
        
        // Update hardware status
        this.updateHardwareStatus(status.hardware || {});
        
        // Update system metrics
        this.updateSystemMetrics(status.metrics || {});
    }
    
    updateConfigurationDisplay() {
        const config = this.config;
        
        this.updateInputValue('callsign-input', config.callsign);
        this.updateInputValue('lat-input', config.latitude);
        this.updateInputValue('lon-input', config.longitude);
        this.updateInputValue('beacon-message-input', config.beacon_message);
        this.updateInputValue('beacon-interval-input', config.beacon_interval);
    }
    
    updateLogsDisplay(logs) {
        const logContainer = document.getElementById('log-container');
        if (!logContainer) return;
        
        logContainer.innerHTML = '';
        
        if (logs.length === 0) {
            logContainer.innerHTML = '<div class="log-entry">?? No logs yet</div>';
            return;
        }
        
        logs.forEach(log => {
            const logEntry = document.createElement('div');
            logEntry.className = `log-entry log-level-${log.level || 'info'}`;
            logEntry.innerHTML = `
                <span class="log-timestamp">${this.formatTimestamp(log.timestamp)}</span>
                ${log.message}
            `;
            logContainer.appendChild(logEntry);
        });
        
        // Auto-scroll to bottom
        logContainer.scrollTop = logContainer.scrollHeight;
    }
    
    updateStatusIndicator(id, isActive) {
        const indicator = document.getElementById(`${id}-indicator`);
        if (!indicator) return;
        
        indicator.className = `status-indicator ${isActive ? 'status-running' : 'status-stopped'}`;
    }
    
    updateTextElement(id, text) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = text;
        }
    }
    
    updateInputValue(id, value) {
        const input = document.getElementById(id);
        if (input && value !== undefined) {
            input.value = value;
        }
    }
    
    updateHardwareStatus(hardware) {
        this.updateStatusIndicator('rtl-sdr', hardware.rtl_sdr || false);
        this.updateTextElement('rtl-sdr-text', hardware.rtl_sdr ? 'Connected' : 'Not Found');
        
        this.updateStatusIndicator('gps-device', hardware.gps_device || false);
        this.updateTextElement('gps-device-text', hardware.gps_device ? 'Connected' : 'Not Found');
        
        this.updateStatusIndicator('audio-device', hardware.audio_device || false);
        this.updateTextElement('audio-device-text', hardware.audio_device ? 'Working' : 'Not Available');
    }
    
    updateSystemMetrics(metrics) {
        // Update CPU usage
        const cpuUsage = metrics.cpu_usage || 0;
        this.updateTextElement('cpu-usage', `${cpuUsage}%`);
        this.updateProgressBar('cpu-progress', cpuUsage);
        
        // Update memory usage
        const memoryUsage = metrics.memory_usage || 0;
        this.updateTextElement('memory-usage', `${memoryUsage}%`);
        this.updateProgressBar('memory-progress', memoryUsage);
    }
    
    updateProgressBar(id, percentage) {
        const progressBar = document.getElementById(id);
        if (progressBar) {
            progressBar.style.width = `${Math.min(percentage, 100)}%`;
        }
    }
    
    updateConnectionStatus(isConnected) {
        this.isConnected = isConnected;
        
        // Update UI to reflect connection status
        const statusElement = document.querySelector('#connection-status');
        if (statusElement) {
            statusElement.className = `alert ${isConnected ? 'info' : 'warning'}`;
            statusElement.innerHTML = `
                <span class="status-indicator ${isConnected ? 'status-running' : 'status-warning'}"></span>
                <span>${isConnected ? 'Connected to APRS system' : 'Demo mode - showing sample data'}</span>
            `;
            statusElement.style.display = 'block';
        }
    }
    
    showLoadingState() {
        const elements = document.querySelectorAll('.metric-value');
        elements.forEach(el => {
            if (el.textContent === '' || el.textContent === '--') {
                el.textContent = 'Loading...';
            }
        });
    }
    
    showError(message) {
        // Create or update error alert
        let errorAlert = document.querySelector('.error-alert');
        if (!errorAlert) {
            errorAlert = document.createElement('div');
            errorAlert.className = 'alert warning error-alert';
            document.querySelector('.container').insertBefore(errorAlert, document.querySelector('header').nextSibling);
        }
        
        errorAlert.innerHTML = `
            <strong>Heads up:</strong> ${message}
            <button onclick="this.parentElement.style.display='none'" style="float: right; background: none; border: none; color: inherit;">×</button>
        `;
        errorAlert.style.display = 'block';
    }
    
    async makeAPICall(endpoint, options = {}) {
        try {
            const response = await fetch(`${this.apiBase}${endpoint}`, {
                method: options.method || 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    ...options.headers
                },
                body: options.body ? JSON.stringify(options.body) : undefined
            });
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error(`API call failed for ${endpoint}:`, error);
            
            // Fall back to demo data when API isn't available
            return this.getMockData(endpoint);
        }
    }
    
    getMockData(endpoint) {
        const mockData = {
            '/status': {
                aprs: true,
                gps: false,
                callsign: 'G0TEST',
                uptime: 3600,
                packets_sent: 42,
                packets_received: 128,
                hardware: {
                    rtl_sdr: false,  // No SDR connected in demo
                    gps_device: false,  // No GPS connected in demo
                    audio_device: false  // Container audio only
                },
                metrics: {
                    cpu_usage: 25,
                    memory_usage: 60
                }
            },
            '/config': {
                callsign: 'G0TEST',
                latitude: 53.8008,
                longitude: -1.5491,
                beacon_message: 'Leeds APRS Pi Demo',
                beacon_interval: 600
            },
            '/logs': [
                {
                    timestamp: Date.now() - 300000,
                    level: 'info',
                    message: '?? Leeds APRS Pi system starting up'
                },
                {
                    timestamp: Date.now() - 240000,
                    level: 'info',
                    message: '?? Direwolf APRS software initialized'
                },
                {
                    timestamp: Date.now() - 180000,
                    level: 'info',
                    message: '?? Connected to APRS-IS server'
                },
                {
                    timestamp: Date.now() - 120000,
                    level: 'info',
                    message: '?? First beacon sent from G0TEST'
                },
                {
                    timestamp: Date.now() - 60000,
                    level: 'info',
                    message: '?? System monitoring active'
                },
                {
                    timestamp: Date.now() - 30000,
                    level: 'info',
                    message: '?? Hardware check: RTL-SDR=No, GPS=No, Audio=Demo'
                }
            ]
        };
        
        return mockData[endpoint] || null;
    }
    
    startAutoRefresh() {
        setInterval(async () => {
            await this.loadSystemStatus();
        }, this.refreshInterval);
    }
    
    bindEvents() {
        // Handle button clicks
        document.addEventListener('click', (e) => {
            if (e.target.matches('[onclick*="saveConfiguration"]')) {
                e.preventDefault();
                this.saveConfiguration();
            }
            if (e.target.matches('[onclick*="resetConfiguration"]')) {
                e.preventDefault();
                this.resetConfiguration();
            }
            if (e.target.matches('[onclick*="refreshLogs"]')) {
                e.preventDefault();
                this.refreshLogs();
            }
            if (e.target.matches('[onclick*="clearLogs"]')) {
                e.preventDefault();
                this.clearLogs();
            }
            if (e.target.matches('[onclick*="downloadLogs"]')) {
                e.preventDefault();
                this.downloadLogs();
            }
        });
    }
    
    async saveConfiguration() {
        const config = {
            callsign: document.getElementById('callsign-input').value,
            latitude: parseFloat(document.getElementById('lat-input').value),
            longitude: parseFloat(document.getElementById('lon-input').value),
            beacon_message: document.getElementById('beacon-message-input').value,
            beacon_interval: parseInt(document.getElementById('beacon-interval-input').value)
        };
        
        try {
            const response = await this.makeAPICall('/config', {
                method: 'POST',
                body: config
            });
            
            if (response) {
                this.showSuccess('Configuration saved successfully!');
                this.config = config;
            }
        } catch (error) {
            this.showSuccess('Configuration updated (demo mode)');
        }
    }
    
    resetConfiguration() {
        this.updateInputValue('callsign-input', 'G0TEST');
        this.updateInputValue('lat-input', 53.8008);
        this.updateInputValue('lon-input', -1.5491);
        this.updateInputValue('beacon-message-input', 'Leeds APRS Pi Station');
        this.updateInputValue('beacon-interval-input', 600);
    }
    
    async refreshLogs() {
        await this.loadLogs();
    }
    
    clearLogs() {
        const logContainer = document.getElementById('log-container');
        if (logContainer) {
            logContainer.innerHTML = '<div class="log-entry">?? Logs cleared</div>';
        }
    }
    
    downloadLogs() {
        const logs = document.getElementById('log-container').textContent;
        const blob = new Blob([logs], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `leeds-aprs-logs-${new Date().toISOString().split('T')[0]}.txt`;
        a.click();
        URL.revokeObjectURL(url);
    }
    
    showSuccess(message) {
        const successAlert = document.createElement('div');
        successAlert.className = 'alert info';
        successAlert.textContent = message;
        
        document.querySelector('.container').insertBefore(successAlert, document.querySelector('header').nextSibling);
        
        setTimeout(() => {
            successAlert.remove();
        }, 3000);
    }
    
    formatUptime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        
        return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    
    formatTimestamp(timestamp) {
        return new Date(timestamp).toLocaleString();
    }
}

// Start up the dashboard
const dashboard = new APRSDashboard();