#!/usr/bin/env python3
"""
APRS Pi - Enhanced API Server v1.1
"""

import os
import sys
import json
import time
import logging
import threading
import queue
import sqlite3
import hashlib
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Any
import asyncio
from dataclasses import dataclass

try:
    from flask import Flask, jsonify, request, send_file
    from flask_cors import CORS
    from flask_socketio import SocketIO, emit
    import psutil
    import requests
except ImportError:
    print("Installing enhanced dependencies...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", 
                          "flask", "flask-cors", "flask-socketio", 
                          "psutil", "requests", "websockets"])
    from flask import Flask, jsonify, request, send_file
    from flask_cors import CORS
    from flask_socketio import SocketIO, emit
    import psutil
    import requests

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config