# Leeds APRS Pi - API Documentation

## ?? Overview

The Leeds APRS Pi provides a comprehensive REST API for monitoring, configuration, and control of the APRS system. This API enables integration with external applications, monitoring systems, and educational tools.

## ?? Base URL

- **Local Development**: `http://localhost:8000`
- **Production**: `http://your-pi-ip:8000`
- **Docker Internal**: `http://aprs-api:8000`

## ?? Authentication

### API Key Authentication (Optional)
```bash
# Include API key in headers
curl -H "X-API-Key: your-api-key" http://localhost:8000/api/status
```

### Basic Authentication (Optional)
```bash
# Include basic auth
curl -u username:password http://localhost:8000/api/status
```

## ?? API Endpoints

### Status Endpoints

#### GET /api/status
Get comprehensive system status.

**Response:**
```json
{
  "timestamp": "2023-12-15T14:30:00Z",
  "system": {
    "uptime": 3600,
    "version": "1.0.0",
    "mode": "production"
  },
  "aprs": {
    "enabled": true,
    "connected": true,
    "callsign": "W1ABC",
    "packets_sent": 42,
    "packets_received": 128,
    "last_beacon": "2023-12-15T14:25:00Z"
  },
  "hardware": {
    "rtl_sdr": {
      "detected": true,
      "device_id": 0,
      "frequency": 144390000,
      "gain": 40
    },
    "gps": {
      "detected": false,
      "device": null,
      "latitude": null,
      "longitude": null,
      "fix_quality": 0
    },
    "audio": {
      "detected": true,
      "device": "hw:1,0",
      "input_level": 75,
      "output_level": 80
    }
  },
  "network": {
    "aprs_is": {
      "connected": true,
      "server": "noam.aprs2.net",
      "port": 14580,
      "filter": "r/42.3601/-71.0589/50"
    },
    "web_interface": {
      "enabled": true,
      "port": 8080,
      "connections": 3
    }
  },
  "performance": {
    "cpu_usage": 25.5,
    "memory_usage": 60.2,
    "disk_usage": 45.8,
    "temperature": 42.5,
    "load_average": [0.5, 0.8, 0.9]
  }
}
```

#### GET /api/status/brief
Get brief system status.

**Response:**
```json
{
  "status": "healthy",
  "aprs": true,
  "hardware": true,
  "network": true,
  "uptime": 3600
}
```

#### GET /api/status/hardware
Get detailed hardware status.

**Response:**
```json
{
  "rtl_sdr": {
    "devices": [
      {
        "id": 0,
        "manufacturer": "Realtek",
        "product": "RTL2838UHIDIR",
        "serial": "00000001",
        "frequency": 144390000,
        "gain": 40,
        "ppm_error": 0,
        "status": "active"
      }
    ]
  },
  "gps": {
    "devices": [
      {
        "device": "/dev/ttyUSB0",
        "type": "u-blox",
        "baud": 9600,
        "status": "connected",
        "fix_quality": 3,
        "satellites": 8,
        "location": {
          "latitude": 42.3601,
          "longitude": -71.0589,
          "altitude": 15.5,
          "accuracy": 2.5
        }
      }
    ]
  },
  "audio": {
    "devices": [
      {
        "id": "hw:1,0",
        "name": "USB Audio Device",
        "type": "USB",
        "channels": 2,
        "sample_rate": 44100,
        "status": "active"
      }
    ]
  }
}
```

#### GET /api/status/performance
Get system performance metrics.

**Response:**
```json
{
  "timestamp": "2023-12-15T14:30:00Z",
  "cpu": {
    "usage": 25.5,
    "load_average": [0.5, 0.8, 0.9],
    "cores": 4,
    "frequency": 1500
  },
  "memory": {
    "total": 4096,
    "used": 2458,
    "free": 1638,
    "usage_percent": 60.2,
    "swap_used": 0
  },
  "disk": {
    "total": 32768,
    "used": 15000,
    "free": 17768,
    "usage_percent": 45.8
  },
  "network": {
    "bytes_sent": 1048576,
    "bytes_received": 2097152,
    "packets_sent": 1024,
    "packets_received": 2048
  },
  "temperature": {
    "cpu": 42.5,
    "gpu": 40.2
  }
}
```

### Configuration Endpoints

#### GET /api/config
Get current configuration.

**Response:**
```json
{
  "station": {
    "callsign": "W1ABC",
    "location": {
      "latitude": 42.3601,
      "longitude": -71.0589,
      "altitude": 15.5
    },
    "beacon": {
      "enabled": true,
      "interval": 600,
      "message": "Boston APRS Node",
      "comment": "Educational Use",
      "symbol": {
        "table": "/",
        "code": "&"
      }
    }
  },
  "aprs": {
    "modem": {
      "speed": 1200,
      "mark": 1200,
      "space": 2200
    },
    "digipeater": {
      "enabled": false,
      "alias": "WIDE1-1"
    },
    "aprs_is": {
      "enabled": true,
      "server": "noam.aprs2.net",
      "port": 14580,
      "passcode": "12345",
      "filter": "r/42.3601/-71.0589/50"
    }
  },
  "hardware": {
    "rtl_sdr": {
      "enabled": true,
      "device": 0,
      "frequency": 144390000,
      "gain": 40,
      "ppm_error": 0
    },
    "gps": {
      "enabled": false,
      "device": "/dev/ttyUSB0",
      "baud": 9600
    },
    "audio": {
      "enabled": true,
      "device": "hw:1,0",
      "sample_rate": 44100,
      "channels": 2
    },
    "ptt": {
      "enabled": false,
      "method": "gpio",
      "pin": 23,
      "invert": false
    }
  },
  "logging": {
    "level": "INFO",
    "file": "/app/logs/aprs.log",
    "max_size": "10MB",
    "backup_count": 5
  }
}
```

#### POST /api/config
Update configuration.

**Request:**
```json
{
  "station": {
    "callsign": "W1DEF",
    "location": {
      "latitude": 42.3601,
      "longitude": -71.0589
    },
    "beacon": {
      "interval": 300,
      "message": "Updated Message"
    }
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Configuration updated successfully",
  "changes": [
    "station.callsign",
    "station.beacon.interval",
    "station.beacon.message"
  ],
  "restart_required": true
}
```

#### GET /api/config/template
Get configuration template.

**Response:**
```json
{
  "template": "basic",
  "description": "Basic APRS station configuration",
  "required_fields": [
    "station.callsign",
    "station.location.latitude",
    "station.location.longitude",
    "aprs.aprs_is.passcode"
  ],
  "optional_fields": [
    "station.beacon.message",
    "station.beacon.interval",
    "hardware.rtl_sdr.frequency"
  ],
  "defaults": {
    "station.beacon.interval": 600,
    "station.beacon.message": "APRS Station",
    "hardware.rtl_sdr.frequency": 144390000
  }
}
```

#### POST /api/config/validate
Validate configuration.

**Request:**
```json
{
  "station": {
    "callsign": "INVALID",
    "location": {
      "latitude": 200,
      "longitude": -71.0589
    }
  }
}
```

**Response:**
```json
{
  "valid": false,
  "errors": [
    {
      "field": "station.callsign",
      "message": "Invalid callsign format",
      "code": "INVALID_CALLSIGN"
    },
    {
      "field": "station.location.latitude",
      "message": "Latitude must be between -90 and 90",
      "code": "INVALID_LATITUDE"
    }
  ],
  "warnings": [
    {
      "field": "station.beacon.interval",
      "message": "Beacon interval not specified, using default",
      "code": "USING_DEFAULT"
    }
  ]
}
```

### Packet Endpoints

#### GET /api/packets
Get recent APRS packets.

**Parameters:**
- `limit`: Maximum number of packets (default: 50)
- `since`: ISO timestamp for filtering
- `type`: Packet type filter (position, message, telemetry, etc.)

**Response:**
```json
{
  "packets": [
    {
      "timestamp": "2023-12-15T14:30:00Z",
      "source": "W1ABC",
      "destination": "APRS",
      "path": ["WIDE1-1", "WIDE2-1"],
      "type": "position",
      "data": {
        "latitude": 42.3601,
        "longitude": -71.0589,
        "symbol": "/&",
        "comment": "Boston APRS Node"
      },
      "raw": "W1ABC>APRS,WIDE1-1,WIDE2-1:=4221.61N/07103.53W&Boston APRS Node"
    }
  ],
  "count": 1,
  "total": 128
}
```

#### GET /api/packets/statistics
Get packet statistics.

**Response:**
```json
{
  "total": {
    "received": 1280,
    "transmitted": 64,
    "digipeated": 0
  },
  "by_type": {
    "position": 800,
    "message": 200,
    "telemetry": 150,
    "weather": 80,
    "other": 50
  },
  "by_hour": [
    {"hour": "2023-12-15T14:00:00Z", "count": 45},
    {"hour": "2023-12-15T13:00:00Z", "count": 52},
    {"hour": "2023-12-15T12:00:00Z", "count": 38}
  ],
  "top_stations": [
    {"callsign": "W1DEF", "count": 25},
    {"callsign": "W1GHI", "count": 18},
    {"callsign": "W1JKL", "count": 15}
  ]
}
```

#### POST /api/packets/send
Send APRS packet.

**Request:**
```json
{
  "type": "position",
  "data": {
    "latitude": 42.3601,
    "longitude": -71.0589,
    "symbol": "/&",
    "comment": "Manual beacon"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Packet sent successfully",
  "packet_id": "12345",
  "raw": "W1ABC>APRS,WIDE1-1:=4221.61N/07103.53W&Manual beacon"
}
```

### Logging Endpoints

#### GET /api/logs
Get system logs.

**Parameters:**
- `service`: Filter by service (aprs, web, api)
- `level`: Filter by log level (debug, info, warning, error)
- `lines`: Number of lines to return (default: 100)
- `follow`: Stream logs (WebSocket)

**Response:**
```json
{
  "logs": [
    {
      "timestamp": "2023-12-15T14:30:00Z",
      "level": "INFO",
      "service": "aprs",
      "message": "APRS beacon transmitted",
      "details": {
        "callsign": "W1ABC",
        "frequency": 144390000
      }
    }
  ],
  "count": 1,
  "total": 5000
}
```

#### GET /api/logs/download
Download log files.

**Parameters:**
- `service`: Service name (optional)
- `format`: Format (json, csv, txt)
- `date_range`: Date range filter

**Response:**
File download with appropriate Content-Type header.

### Control Endpoints

#### POST /api/control/beacon
Send manual beacon.

**Request:**
```json
{
  "message": "Manual test beacon",
  "comment": "Testing",
  "symbol": "/&"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Beacon sent successfully",
  "timestamp": "2023-12-15T14:30:00Z"
}
```

#### POST /api/control/restart
Restart system or service.

**Request:**
```json
{
  "service": "aprs",
  "reason": "Configuration update"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Service restart initiated",
  "estimated_downtime": 30
}
```

#### POST /api/control/shutdown
Shutdown system gracefully.

**Request:**
```json
{
  "delay": 60,
  "reason": "Scheduled maintenance"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Shutdown scheduled",
  "shutdown_time": "2023-12-15T14:31:00Z"
}
```

### Health Endpoints

#### GET /api/health
Get API health status.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2023-12-15T14:30:00Z",
  "version": "1.0.0",
  "uptime": 3600,
  "checks": {
    "database": "healthy",
    "aprs_service": "healthy",
    "disk_space": "healthy",
    "memory": "healthy"
  }
}
```

#### GET /api/health/detailed
Get detailed health information.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2023-12-15T14:30:00Z",
  "version": "1.0.0",
  "uptime": 3600,
  "checks": {
    "database": {
      "status": "healthy",
      "response_time": 5,
      "connections": 10
    },
    "aprs_service": {
      "status": "healthy",
      "process_id": 1234,
      "memory_usage": 45.2,
      "cpu_usage": 12.5
    },
    "disk_space": {
      "status": "healthy",
      "usage_percent": 45.8,
      "free_space": 17768
    },
    "memory": {
      "status": "healthy",
      "usage_percent": 60.2,
      "free_memory": 1638
    }
  }
}
```

## ?? WebSocket Endpoints

### Real-time Status Updates

#### /ws/status
Real-time system status updates.

**Connection:**
```javascript
const ws = new WebSocket('ws://localhost:8000/ws/status');

ws.onmessage = function(event) {
  const status = JSON.parse(event.data);
  console.log('Status update:', status);
};
```

**Message Format:**
```json
{
  "type": "status_update",
  "timestamp": "2023-12-15T14:30:00Z",
  "data": {
    "aprs": {
      "packets_sent": 43,
      "packets_received": 129
    },
    "performance": {
      "cpu_usage": 26.1,
      "memory_usage": 60.5
    }
  }
}
```

### Real-time Packet Stream

#### /ws/packets
Real-time APRS packet stream.

**Connection:**
```javascript
const ws = new WebSocket('ws://localhost:8000/ws/packets');

ws.onmessage = function(event) {
  const packet = JSON.parse(event.data);
  console.log('New packet:', packet);
};
```

**Message Format:**
```json
{
  "type": "packet",
  "timestamp": "2023-12-15T14:30:00Z",
  "data": {
    "source": "W1ABC",
    "destination": "APRS",
    "type": "position",
    "latitude": 42.3601,
    "longitude": -71.0589,
    "raw": "W1ABC>APRS:=4221.61N/07103.53W&Boston APRS Node"
  }
}
```

### Real-time Log Stream

#### /ws/logs
Real-time log stream.

**Connection:**
```javascript
const ws = new WebSocket('ws://localhost:8000/ws/logs');

ws.onmessage = function(event) {
  const log = JSON.parse(event.data);
  console.log('New log:', log);
};
```

**Message Format:**
```json
{
  "type": "log",
  "timestamp": "2023-12-15T14:30:00Z",
  "data": {
    "level": "INFO",
    "service": "aprs",
    "message": "Beacon transmitted successfully"
  }
}
```

## ?? Error Handling

### Error Response Format

All API errors follow a consistent format:

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Invalid request format",
    "details": "Missing required field 'callsign'",
    "timestamp": "2023-12-15T14:30:00Z",
    "request_id": "req_12345"
  }
}
```

### HTTP Status Codes

| Status Code | Meaning | Description |
|-------------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request format or parameters |
| 401 | Unauthorized | Authentication required |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict |
| 422 | Unprocessable Entity | Validation error |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

### Common Error Codes

| Error Code | Description |
|------------|-------------|
| `INVALID_REQUEST` | Request format or parameters invalid |
| `INVALID_CALLSIGN` | Callsign format invalid |
| `INVALID_COORDINATES` | GPS coordinates invalid |
| `HARDWARE_NOT_FOUND` | Required hardware not detected |
| `SERVICE_UNAVAILABLE` | APRS service not available |
| `CONFIGURATION_ERROR` | Configuration validation failed |
| `PERMISSION_DENIED` | Insufficient permissions |
| `RATE_LIMIT_EXCEEDED` | Too many requests |

## ?? Rate Limiting

### Rate Limit Headers

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1671112800
```

### Rate Limits by Endpoint

| Endpoint | Rate Limit | Window |
|----------|------------|--------|
| `/api/status` | 60 requests | 1 minute |
| `/api/config` | 10 requests | 1 minute |
| `/api/packets` | 30 requests | 1 minute |
| `/api/logs` | 20 requests | 1 minute |
| `/api/control/*` | 5 requests | 1 minute |

## ?? API Versioning

### Version Headers

```http
API-Version: 1.0
Accept: application/vnd.leeds-aprs-pi.v1+json
```

### Version Compatibility

- **v1.0**: Current stable version
- **v1.1**: Planned next version (backward compatible)
- **v2.0**: Future version (breaking changes)

## ?? Security

### API Security Features

- **Rate Limiting**: Prevents abuse
- **Input Validation**: Prevents injection attacks
- **CORS Support**: Controlled cross-origin access
- **HTTPS Support**: Encrypted communication
- **API Keys**: Optional authentication

### Security Best Practices

1. **Use HTTPS**: Enable SSL/TLS encryption
2. **Validate Input**: Always validate all input data
3. **Rate Limiting**: Implement appropriate rate limits
4. **Authentication**: Use API keys for sensitive operations
5. **Logging**: Log all API access for security monitoring

## ?? Monitoring and Analytics

### API Metrics

Available metrics for monitoring:

- **Request Rate**: Requests per second
- **Response Time**: Average response time
- **Error Rate**: Percentage of failed requests
- **Throughput**: Data transfer rates
- **Concurrent Connections**: Active connections

### Monitoring Endpoints

#### GET /api/metrics
Get API metrics in Prometheus format.

**Response:**
```
# HELP api_requests_total Total number of API requests
# TYPE api_requests_total counter
api_requests_total{method="GET",endpoint="/api/status"} 1234

# HELP api_request_duration_seconds API request duration
# TYPE api_request_duration_seconds histogram
api_request_duration_seconds_bucket{le="0.1"} 100
api_request_duration_seconds_bucket{le="0.5"} 200
```

## ?? Testing

### API Testing Tools

#### Using cURL
```bash
# Test status endpoint
curl -X GET http://localhost:8000/api/status

# Test configuration update
curl -X POST http://localhost:8000/api/config \
  -H "Content-Type: application/json" \
  -d '{"station": {"callsign": "W1TEST"}}'
```

#### Using Python
```python
import requests

# Test API status
response = requests.get('http://localhost:8000/api/status')
print(response.json())

# Test configuration
config = {'station': {'callsign': 'W1TEST'}}
response = requests.post('http://localhost:8000/api/config', json=config)
print(response.json())
```

#### Using JavaScript
```javascript
// Test API status
fetch('http://localhost:8000/api/status')
  .then(response => response.json())
  .then(data => console.log(data));

// Test configuration
fetch('http://localhost:8000/api/config', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({station: {callsign: 'W1TEST'}})
})
.then(response => response.json())
.then(data => console.log(data));
```

### Test Suite

Run the complete API test suite:

```bash
# Run all tests
./scripts/test-api.sh

# Run specific test category
./scripts/test-api.sh --category status
./scripts/test-api.sh --category config
./scripts/test-api.sh --category packets

# Run performance tests
./scripts/test-api-performance.sh
```

## ?? SDK and Libraries

### Python SDK

```python
from leeds_aprs_pi import APRSClient

# Initialize client
client = APRSClient('http://localhost:8000')

# Get status
status = client.get_status()
print(f"APRS Status: {status.aprs.enabled}")

# Update configuration
client.update_config({
    'station': {
        'callsign': 'W1ABC',
        'beacon': {'interval': 300}
    }
})

# Send beacon
client.send_beacon('Manual test beacon')
```

### JavaScript SDK

```javascript
import { APRSClient } from 'leeds-aprs-pi';

// Initialize client
const client = new APRSClient('http://localhost:8000');

// Get status
const status = await client.getStatus();
console.log(`APRS Status: ${status.aprs.enabled}`);

// Update configuration
await client.updateConfig({
  station: {
    callsign: 'W1ABC',
    beacon: { interval: 300 }
  }
});

// Send beacon
await client.sendBeacon('Manual test beacon');
```

## ?? Changelog

### Version 1.0.0
- Initial API release
- Basic status and configuration endpoints
- Packet monitoring and control
- WebSocket support for real-time updates
- Comprehensive error handling and validation

### Version 1.1.0 (Planned)
- Enhanced packet filtering and search
- Bulk configuration operations
- Advanced metrics and analytics
- Improved WebSocket performance
- Additional hardware support

---

**This API documentation is maintained by the Leeds Space Communications Society. For questions, bug reports, or feature requests, please visit our GitHub repository.**

**73 de Leeds Space Comms! ??**