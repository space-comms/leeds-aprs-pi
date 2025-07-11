#!/usr/bin/env python3
"""
Leeds APRS Pi - API Server (Simplified for Development)
"""

import os
import sys
import json
import time
import logging
from datetime import datetime
from pathlib import Path

try:
    from flask import Flask, jsonify, request, send_file
    from flask_cors import CORS
except ImportError:
    print("Installing Flask dependencies...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "flask", "flask-cors"])
    from flask import Flask, jsonify, request, send_file
    from flask_cors import CORS

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Mock data for development
MOCK_STATUS = {
    'aprs': True,
    'gps': False,
    'callsign': os.environ.get('CALLSIGN', 'G0TEST'),
    'uptime': 0,
    'packets_sent': 42,
    'packets_received': 128,
    'hardware': {
        'rtl_sdr': False,
        'gps_device': False,
        'audio_device': False
    },
    'metrics': {
        'cpu_usage': 25,
        'memory_usage': 60,
        'disk_usage': 45,
        'temperature': 42.5
    },
    'timestamp': datetime.now().isoformat()
}

MOCK_CONFIG = {
    'callsign': os.environ.get('CALLSIGN', 'G0TEST'),
    'latitude': float(os.environ.get('LAT', '53.8008')),
    'longitude': float(os.environ.get('LON', '-1.5491')),
    'beacon_message': os.environ.get('BEACON_MESSAGE', 'Leeds APRS Pi - Development'),
    'beacon_interval': int(os.environ.get('BEACON_INTERVAL', '600'))
}

MOCK_LOGS = [
    {
        'timestamp': time.time() * 1000 - 300000,
        'level': 'info',
        'message': '?? Leeds APRS Pi system started in development mode'
    },
    {
        'timestamp': time.time() * 1000 - 240000,
        'level': 'info',
        'message': '?? API server initialized successfully'
    },
    {
        'timestamp': time.time() * 1000 - 180000,
        'level': 'info',
        'message': '?? Mock data loaded for demonstration'
    },
    {
        'timestamp': time.time() * 1000 - 120000,
        'level': 'info',
        'message': '? Web interface ready for testing'
    },
    {
        'timestamp': time.time() * 1000 - 60000,
        'level': 'info',
        'message': f"?? Station {MOCK_CONFIG['callsign']} configured"
    },
    {
        'timestamp': time.time() * 1000 - 30000,
        'level': 'info',
        'message': '?? System monitoring active (demo mode)'
    }
]

start_time = time.time()

@app.route('/api/status')
def get_status():
    """Get system status"""
    try:
        # Update uptime
        MOCK_STATUS['uptime'] = int(time.time() - start_time)
        MOCK_STATUS['timestamp'] = datetime.now().isoformat()
        
        logger.info("Status request served")
        return jsonify(MOCK_STATUS)
    except Exception as e:
        logger.error(f"Error getting status: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/config', methods=['GET', 'POST'])
def handle_config():
    """Get or update configuration"""
    try:
        if request.method == 'GET':
            logger.info("Configuration request served")
            return jsonify(MOCK_CONFIG)
        else:
            config = request.get_json()
            # In development mode, just return success
            logger.info(f"Configuration update request: {config}")
            return jsonify({'success': True, 'message': 'Configuration updated (demo mode)'})
    except Exception as e:
        logger.error(f"Error handling config: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/logs')
def get_logs():
    """Get system logs"""
    try:
        lines = int(request.args.get('lines', '50'))
        logs = MOCK_LOGS[-lines:] if len(MOCK_LOGS) > lines else MOCK_LOGS
        
        logger.info(f"Logs request served ({len(logs)} entries)")
        return jsonify(logs)
    except Exception as e:
        logger.error(f"Error getting logs: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/restart', methods=['POST'])
def restart_system():
    """Restart system (demo mode)"""
    try:
        logger.info("System restart requested (demo mode)")
        return jsonify({'success': True, 'message': 'System restart initiated (demo mode)'})
    except Exception as e:
        logger.error(f"Error restarting system: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'api_version': '1.0.0',
        'mode': 'development',
        'uptime': int(time.time() - start_time)
    })

@app.route('/')
def index():
    """Root endpoint"""
    return jsonify({
        'service': 'Leeds APRS Pi API',
        'status': 'running',
        'mode': 'development',
        'endpoints': [
            '/api/status',
            '/api/config', 
            '/api/logs',
            '/api/health'
        ]
    })

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Leeds APRS Pi API Server')
    parser.add_argument('--host', default='0.0.0.0', help='Host to bind to')
    parser.add_argument('--port', type=int, default=8000, help='Port to bind to')
    parser.add_argument('--debug', action='store_true', help='Enable debug mode')
    
    args = parser.parse_args()
    
    logger.info(f"?? Starting Leeds APRS Pi API Server")
    logger.info(f"?? Mode: Development")
    logger.info(f"?? Listening on {args.host}:{args.port}")
    logger.info(f"?? Health check: http://{args.host}:{args.port}/api/health")
    
    app.run(host=args.host, port=args.port, debug=args.debug)