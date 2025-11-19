#!/usr/bin/env python3
"""
Simple Python App for Jenkins + Podman Demo
"""
from flask import Flask, jsonify
import datetime
import socket
import os
import platform

app = Flask(__name__)

@app.route('/')
def home():
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>🚀 Python App</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 40px; }}
            .container {{ max-width: 800px; margin: 0 auto; }}
            .info {{ background: #f5f5f5; padding: 20px; border-radius: 10px; }}
            .success {{ color: green; font-weight: bold; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Simple Python App</h1>
            <div class="info">
                <p><strong>Hostname:</strong> {socket.gethostname()}</p>
                <p><strong>Time:</strong> {datetime.datetime.now()}</p>
                <p><strong>Python Version:</strong> {platform.python_version()}</p>
                <p><strong>Status:</strong> <span class="success">✅ RUNNING</span></p>
                <p><strong>Deployed via:</strong> Jenkins + Podman</p>
            </div>
            <hr>
            <h3>📊 Endpoints:</h3>
            <ul>
                <li><a href="/health">/health</a> - Health check</li>
                <li><a href="/api/info">/api/info</a> - System information</li>
                <li><a href="/api/environment">/api/environment</a> - Environment variables</li>
            </ul>
        </div>
    </body>
    </html>
    """

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": str(datetime.datetime.now()),
        "hostname": socket.gethostname(),
        "service": "python-app"
    })

@app.route('/api/info')
def api_info():
    return jsonify({
        "application": "Simple Python App",
        "version": "1.0.0",
        "environment": os.getenv('APP_ENV', 'development'),
        "deployed_at": str(datetime.datetime.now()),
        "python_version": platform.python_version(),
        "platform": platform.system(),
        "container_id": socket.gethostname()
    })

@app.route('/api/environment')
def api_environment():
    env_vars = {
        k: v for k, v in os.environ.items() 
        if k.startswith('APP_') or k in ['HOSTNAME', 'PATH']
    }
    return jsonify(env_vars)

if __name__ == '__main__':
    app.run(
        host='0.0.0.0', 
        port=5000, 
        debug=False
    )
